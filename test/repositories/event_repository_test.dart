// test/repositories/event_repository_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dianiels_calendar/models/calendar_event.dart';
import 'package:dianiels_calendar/models/enums.dart';
import 'package:dianiels_calendar/repositories/event_repository.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirestoreEventRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirestoreEventRepository(db);
  });

  CalendarEvent sample() => CalendarEvent(
    id: '', title: 'Anniversary', date: DateTime(2026, 7, 20),
    owner: EventOwner.together, createdBy: 'uid1');

  test('add then watchAll returns the event', () async {
    await repo.add(sample());
    final events = await repo.watchAll().first;
    expect(events.length, 1);
    expect(events.first.title, 'Anniversary');
    expect(events.first.owner, EventOwner.together);
  });

  test('delete removes the event', () async {
    final id = await repo.add(sample());
    await repo.delete(id);
    final events = await repo.watchAll().first;
    expect(events, isEmpty);
  });

  test('update changes fields', () async {
    final id = await repo.add(sample());
    final stored = (await repo.watchAll().first).first;
    await repo.update(stored.copyWith(title: 'Big Anniversary'));
    final events = await repo.watchAll().first;
    expect(events.first.title, 'Big Anniversary');
    expect(events.first.id, id);
  });
}
