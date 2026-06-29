// test/repositories/todo_repository_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dianiels_calendar/models/todo_item.dart';
import 'package:dianiels_calendar/repositories/todo_repository.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirestoreTodoRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirestoreTodoRepository(db);
  });

  TodoItem sample() => const TodoItem(
      id: '', title: 'Buy flowers', done: false, createdBy: 'uid1');

  test('add then watchAll returns the todo with correct title and done=false',
      () async {
    await repo.add(sample());
    final todos = await repo.watchAll().first;
    expect(todos.length, 1);
    expect(todos.first.title, 'Buy flowers');
    expect(todos.first.done, isFalse);
  });

  test('update toggles done to true (watchAll reflects it, id preserved)',
      () async {
    final id = await repo.add(sample());
    final stored = (await repo.watchAll().first).first;
    await repo.update(stored.copyWith(done: true));
    final todos = await repo.watchAll().first;
    expect(todos.first.done, isTrue);
    expect(todos.first.id, id);
  });

  test('setting scheduledDate via update round-trips a non-null DateTime',
      () async {
    await repo.add(sample());
    final stored = (await repo.watchAll().first).first;
    final date = DateTime(2026, 8, 15);
    await repo.update(stored.copyWith(scheduledDate: date));
    final todos = await repo.watchAll().first;
    expect(todos.first.scheduledDate, isNotNull);
    expect(todos.first.scheduledDate!.year, 2026);
    expect(todos.first.scheduledDate!.month, 8);
    expect(todos.first.scheduledDate!.day, 15);
  });

  test('delete removes the todo', () async {
    final id = await repo.add(sample());
    await repo.delete(id);
    final todos = await repo.watchAll().first;
    expect(todos, isEmpty);
  });
}
