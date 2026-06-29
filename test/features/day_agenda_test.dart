import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dianiels_calendar/models/calendar_event.dart';
import 'package:dianiels_calendar/models/enums.dart';
import 'package:dianiels_calendar/repositories/event_repository.dart';
import 'package:dianiels_calendar/providers/repository_providers.dart';
import 'package:dianiels_calendar/features/day/day_agenda_screen.dart';

class _FakeRepo implements EventRepository {
  final DateTime day;
  final StreamController<List<CalendarEvent>> _controller =
      StreamController<List<CalendarEvent>>();

  _FakeRepo(this.day) {
    _controller.add([
      CalendarEvent(
          id: 'a', title: 'Cinema', date: day,
          owner: EventOwner.together, createdBy: 'u'),
      CalendarEvent(
          id: 'b', title: 'OtherDay',
          date: day.add(const Duration(days: 1)),
          owner: EventOwner.diana, createdBy: 'u'),
    ]);
  }

  @override
  Stream<List<CalendarEvent>> watchAll() => _controller.stream;

  @override Future<String> add(CalendarEvent e) async => 'x';
  @override Future<void> update(CalendarEvent e) async {}
  @override Future<void> delete(String id) async {}
}

void main() {
  testWidgets('agenda lists the day\'s events', (tester) async {
    final day = DateTime(2026, 7, 4);
    await tester.pumpWidget(ProviderScope(
      overrides: [eventRepositoryProvider.overrideWithValue(_FakeRepo(day))],
      child: MaterialApp(home: DayAgendaScreen(day: day)),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Together events render as '❤️ Cinema'; use textContaining for the title.
    expect(find.textContaining('Cinema'), findsOneWidget);
    // Event on a different day must be filtered out.
    expect(find.textContaining('OtherDay'), findsNothing);
    // Together convention shows a heart.
    expect(find.textContaining('❤️'), findsOneWidget);
  });
}
