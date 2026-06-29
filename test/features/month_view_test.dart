// test/features/month_view_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dianiels_calendar/models/calendar_event.dart';
import 'package:dianiels_calendar/models/enums.dart';
import 'package:dianiels_calendar/repositories/event_repository.dart';
import 'package:dianiels_calendar/providers/repository_providers.dart';
import 'package:dianiels_calendar/features/month/month_view_screen.dart';

class _FakeRepo implements EventRepository {
  @override
  Stream<List<CalendarEvent>> watchAll() => Stream.value([
        CalendarEvent(
            id: 'a',
            title: 'Trip',
            date: DateTime.now(),
            owner: EventOwner.together,
            createdBy: 'u'),
      ]);
  @override
  Future<String> add(CalendarEvent e) async => 'x';
  @override
  Future<void> update(CalendarEvent e) async {}
  @override
  Future<void> delete(String id) async {}
}

void main() {
  testWidgets('month view renders a grid and the month title', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [eventRepositoryProvider.overrideWithValue(_FakeRepo())],
      child: const MaterialApp(home: MonthViewScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // 7 weekday headers present
    expect(find.text('Mon'), findsOneWidget);
    expect(find.byType(GridView), findsWidgets);
    // month title in header (MonthPhotoHeader uses DateFormat('MMMM yyyy'))
    final now = DateTime.now();
    final expectedTitle = DateFormat('MMMM yyyy').format(DateTime(now.year, now.month));
    expect(find.text(expectedTitle), findsOneWidget);
  });
}
