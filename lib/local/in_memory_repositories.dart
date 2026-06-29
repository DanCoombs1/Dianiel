// In-memory implementations of the app's repositories, used to run the whole UI
// on-device WITHOUT Firebase (local mode). The real Firebase-backed repositories
// are swapped in via provider overrides once a Firebase project is configured.
//
// This is the payoff of the layered design: the UI depends only on the repository
// interfaces, so we can drive it from memory here and from Firestore later with no
// changes to any screen.
import 'dart:async';
import 'dart:io';

import '../models/calendar_event.dart';
import '../models/enums.dart';
import '../models/todo_item.dart';
import '../models/vault_photo.dart';
import '../repositories/auth_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/todo_repository.dart';
import '../repositories/vault_repository.dart';

/// Always-signed-in fake auth for local mode (no real Apple sign-in).
class LocalAuthRepository implements AuthRepository {
  @override
  Stream<AppAuthUser?> authStateChanges() =>
      Stream.value(const AppAuthUser(uid: 'local-dan', displayName: 'Dan'));

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signOut() async {}
}

/// In-memory event store backed by a broadcast stream so Riverpod's
/// StreamProvider gets live updates exactly as it would from Firestore.
class InMemoryEventRepository implements EventRepository {
  InMemoryEventRepository({List<CalendarEvent>? seed}) {
    _events.addAll(seed ?? _defaultSeed());
    _emit();
  }

  final _events = <CalendarEvent>[];
  final _controller = StreamController<List<CalendarEvent>>.broadcast();
  var _nextId = 1000;

  void _emit() => _controller.add(List.unmodifiable(_events));

  @override
  Stream<List<CalendarEvent>> watchAll() async* {
    yield List.unmodifiable(_events);
    yield* _controller.stream;
  }

  @override
  Future<String> add(CalendarEvent e) async {
    final id = 'mem-${_nextId++}';
    _events.add(_withId(e, id));
    _emit();
    return id;
  }

  @override
  Future<void> update(CalendarEvent e) async {
    final i = _events.indexWhere((x) => x.id == e.id);
    if (i != -1) {
      _events[i] = e;
      _emit();
    }
  }

  @override
  Future<void> delete(String id) async {
    _events.removeWhere((x) => x.id == id);
    _emit();
  }

  CalendarEvent _withId(CalendarEvent e, String id) => CalendarEvent(
        id: id,
        title: e.title,
        date: e.date,
        startTime: e.startTime,
        allDay: e.allDay,
        location: e.location,
        owner: e.owner,
        notes: e.notes,
        reminder: e.reminder,
        recurrence: e.recurrence,
        isBigDate: e.isBigDate,
        createdBy: e.createdBy,
      );

  static List<CalendarEvent> _defaultSeed() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      CalendarEvent(
        id: 'seed-1',
        title: 'Date night',
        date: today.add(const Duration(days: 2)),
        startTime: '19:30',
        allDay: false,
        location: 'The Ivy',
        owner: EventOwner.together,
        reminder: ReminderOption.oneHour,
        isBigDate: false,
        createdBy: 'local-dan',
      ),
      CalendarEvent(
        id: 'seed-2',
        title: "Diana's mum's birthday",
        date: DateTime(now.year, now.month, now.day).add(const Duration(days: 9)),
        owner: EventOwner.diana,
        recurrence: Recurrence.yearly,
        isBigDate: true,
        createdBy: 'local-dan',
      ),
      CalendarEvent(
        id: 'seed-3',
        title: 'Five-a-side',
        date: today.add(const Duration(days: 1)),
        startTime: '18:00',
        allDay: false,
        owner: EventOwner.dan,
        recurrence: Recurrence.weekly,
        createdBy: 'local-dan',
      ),
      CalendarEvent(
        id: 'seed-4',
        title: 'Our anniversary',
        date: DateTime(now.year, now.month, now.day).add(const Duration(days: 20)),
        owner: EventOwner.together,
        recurrence: Recurrence.yearly,
        isBigDate: true,
        createdBy: 'local-dan',
      ),
    ];
  }
}

/// In-memory shared to-do list for local mode.
class InMemoryTodoRepository implements TodoRepository {
  InMemoryTodoRepository() {
    _items.addAll([
      const TodoItem(
          id: 'todo-1', title: 'Book the restaurant', done: false,
          scheduledDate: null, createdBy: 'local-dan'),
      const TodoItem(
          id: 'todo-2', title: 'Plan weekend away', done: false,
          scheduledDate: null, createdBy: 'local-dan'),
    ]);
    _emit();
  }

  final _items = <TodoItem>[];
  final _controller = StreamController<List<TodoItem>>.broadcast();
  var _nextId = 1000;

  void _emit() => _controller.add(List.unmodifiable(_items));

  @override
  Stream<List<TodoItem>> watchAll() async* {
    yield List.unmodifiable(_items);
    yield* _controller.stream;
  }

  @override
  Future<String> add(TodoItem t) async {
    final id = 'memtodo-${_nextId++}';
    _items.add(TodoItem(
        id: id, title: t.title, done: t.done,
        scheduledDate: t.scheduledDate, createdBy: t.createdBy));
    _emit();
    return id;
  }

  @override
  Future<void> update(TodoItem t) async {
    final i = _items.indexWhere((x) => x.id == t.id);
    if (i != -1) {
      _items[i] = t;
      _emit();
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((x) => x.id == id);
    _emit();
  }
}

/// In-memory vault for local mode. Stores the picked file's local path as the
/// "downloadUrl"; the gallery's `vaultImage` helper renders non-http paths via
/// Image.file, so local photos display without any cloud storage.
class InMemoryVaultRepository implements VaultRepository {
  InMemoryVaultRepository() {
    _emit();
  }

  final _photos = <VaultPhoto>[];
  final _controller = StreamController<List<VaultPhoto>>.broadcast();
  var _nextId = 1000;

  void _emit() => _controller.add(List.unmodifiable(_photos));

  @override
  Stream<List<VaultPhoto>> watchPhotos() async* {
    yield List.unmodifiable(_photos);
    yield* _controller.stream;
  }

  @override
  Future<void> addPhoto(File file, String uid) async {
    final id = 'memvault-${_nextId++}';
    _photos.insert(
      0,
      VaultPhoto(
        id: id,
        storagePath: file.path,
        downloadUrl: file.path, // local path → rendered via Image.file
        uploadedBy: uid,
      ),
    );
    _emit();
  }

  @override
  Future<void> removePhoto(String id) async {
    _photos.removeWhere((p) => p.id == id);
    _emit();
  }
}
