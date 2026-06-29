// lib/providers/event_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_event.dart';
import '../utils/date_utils.dart';
import '../utils/recurrence_expander.dart';
import 'repository_providers.dart';

final allEventsProvider = StreamProvider<List<CalendarEvent>>(
  (ref) => ref.watch(eventRepositoryProvider).watchAll(),
);

final eventsForMonthProvider =
    Provider.family<AsyncValue<Map<String, List<CalendarEvent>>>, DateTime>(
        (ref, month) {
  final async = ref.watch(allEventsProvider);
  return async.whenData((events) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    final expanded = expandEvents(events, start, end);
    final map = <String, List<CalendarEvent>>{};
    for (final e in expanded) {
      map.putIfAbsent(dayKey(e.date), () => []).add(e);
    }
    return map;
  });
});
