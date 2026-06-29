// test/providers/event_providers_test.dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dianiels_calendar/models/calendar_event.dart';
import 'package:dianiels_calendar/models/enums.dart';
import 'package:dianiels_calendar/repositories/event_repository.dart';
import 'package:dianiels_calendar/providers/repository_providers.dart';
import 'package:dianiels_calendar/providers/event_providers.dart';

class _FakeRepo implements EventRepository {
  final List<CalendarEvent> seed;
  _FakeRepo(this.seed);
  @override Stream<List<CalendarEvent>> watchAll() {
    // Emit via microtask so the subscriber is attached before data arrives,
    // and keep the controller open so Riverpod's StreamProvider.future
    // resolves without the "disposed during loading" error.
    final ctrl = StreamController<List<CalendarEvent>>();
    scheduleMicrotask(() => ctrl.add(seed));
    return ctrl.stream;
  }
  @override Future<String> add(CalendarEvent e) async => 'x';
  @override Future<void> update(CalendarEvent e) async {}
  @override Future<void> delete(String id) async {}
}

void main() {
  test('eventsForMonth groups expanded events by day', () async {
    final seed = [
      CalendarEvent(id: 'b', title: 'Bday', date: DateTime(2000, 7, 15),
          owner: EventOwner.diana, recurrence: Recurrence.yearly, createdBy: 'u'),
    ];
    final container = ProviderContainer(overrides: [
      eventRepositoryProvider.overrideWithValue(_FakeRepo(seed)),
    ]);
    addTearDown(container.dispose);
    // Riverpod 3 pauses the stream subscription when no listeners are present,
    // preventing StreamProvider.future from ever resolving. Keep it active:
    final sub = container.listen(allEventsProvider, (_, _) {});
    addTearDown(sub.close);
    await container.read(allEventsProvider.future);
    final grouped = container.read(eventsForMonthProvider(DateTime(2026, 7, 1)));
    expect(grouped.value!['2026-07-15']!.length, 1);
  });
}
