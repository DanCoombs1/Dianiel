import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dianiels_calendar/models/calendar_event.dart';
import 'package:dianiels_calendar/models/todo_item.dart';
import 'package:dianiels_calendar/repositories/event_repository.dart';
import 'package:dianiels_calendar/repositories/todo_repository.dart';
import 'package:dianiels_calendar/providers/repository_providers.dart';
import 'package:dianiels_calendar/providers/auth_providers.dart';
import 'package:dianiels_calendar/repositories/auth_repository.dart';
import 'package:dianiels_calendar/features/todo/todo_list_screen.dart';

// ── Fake TodoRepository ─────────────────────────────────────────────────────

class FakeTodoRepository implements TodoRepository {
  late final StreamController<List<TodoItem>> _controller;

  List<TodoItem> _items = [];

  // Calls recorded for assertion
  final List<TodoItem> addedItems = [];
  final List<TodoItem> updatedItems = [];
  final List<String> deletedIds = [];

  FakeTodoRepository({List<TodoItem> initialItems = const []}) {
    _items = List.of(initialItems);
    _controller = StreamController<List<TodoItem>>(
      onListen: () => _controller.add(List.of(_items)),
    );
  }

  void seed(List<TodoItem> items) {
    _items = List.of(items);
    _controller.add(List.of(_items));
  }

  @override
  Stream<List<TodoItem>> watchAll() => _controller.stream;

  @override
  Future<String> add(TodoItem t) async {
    addedItems.add(t);
    final item = TodoItem(
      id: 'fake-id-${addedItems.length}',
      title: t.title,
      done: t.done,
      scheduledDate: t.scheduledDate,
      createdBy: t.createdBy,
    );
    _items = [..._items, item];
    _controller.add(_items);
    return item.id;
  }

  @override
  Future<void> update(TodoItem t) async {
    updatedItems.add(t);
    _items = _items.map((i) => i.id == t.id ? t : i).toList();
    _controller.add(_items);
  }

  @override
  Future<void> delete(String id) async {
    deletedIds.add(id);
    _items = _items.where((i) => i.id != id).toList();
    _controller.add(_items);
  }
}

// ── Fake EventRepository ─────────────────────────────────────────────────────

class FakeEventRepository implements EventRepository {
  final List<CalendarEvent> addedEvents = [];

  @override
  Stream<List<CalendarEvent>> watchAll() => const Stream.empty();

  @override
  Future<String> add(CalendarEvent e) async {
    addedEvents.add(e);
    return 'event-id-1';
  }

  @override
  Future<void> update(CalendarEvent e) async {}

  @override
  Future<void> delete(String id) async {}
}

// ── Helper to build the widget under test ────────────────────────────────────

Widget buildUnderTest({
  required FakeTodoRepository todoRepo,
  required FakeEventRepository eventRepo,
}) {
  return ProviderScope(
    overrides: [
      todoRepositoryProvider.overrideWithValue(todoRepo),
      eventRepositoryProvider.overrideWithValue(eventRepo),
      // Override authStateProvider to immediately resolve to u1.
      // We use overrideWith and yield a value from a broadcast stream
      // so the StreamProvider resolves in the first pump.
      authStateProvider.overrideWith(
        (ref) => Stream<AppAuthUser?>.value(const AppAuthUser(uid: 'u1')),
      ),
    ],
    child: const MaterialApp(home: TodoListScreen()),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('entering text and tapping Add calls todoRepo.add with that title',
      (tester) async {
    final todoRepo = FakeTodoRepository();
    final eventRepo = FakeEventRepository();

    await tester.pumpWidget(buildUnderTest(
      todoRepo: todoRepo,
      eventRepo: eventRepo,
    ));
    // Pump until auth StreamProvider resolves (Stream.value emits synchronously,
    // but Riverpod needs a microtask cycle to process it).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byKey(const Key('todo-input')), 'Buy flowers');
    await tester.tap(find.byKey(const Key('todo-add')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(todoRepo.addedItems, hasLength(1));
    expect(todoRepo.addedItems.first.title, 'Buy flowers');
  });

  testWidgets('tapping checkbox on a seeded todo calls update with done=true',
      (tester) async {
    const seedItem = TodoItem(
      id: 'todo-1',
      title: 'Walk the dog',
      done: false,
      scheduledDate: null,
      createdBy: 'u1',
    );
    final todoRepo = FakeTodoRepository(initialItems: [seedItem]);
    final eventRepo = FakeEventRepository();

    await tester.pumpWidget(buildUnderTest(
      todoRepo: todoRepo,
      eventRepo: eventRepo,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // The CheckboxListTile for 'Walk the dog' should be visible
    expect(find.text('Walk the dog'), findsOneWidget);

    // Tap the checkbox (the Checkbox widget inside CheckboxListTile)
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(todoRepo.updatedItems, hasLength(1));
    expect(todoRepo.updatedItems.first.done, isTrue);
    expect(todoRepo.updatedItems.first.id, 'todo-1');
  });
}
