import '../models/calendar_event.dart';
import '../models/enums.dart';
import 'date_utils.dart';

List<CalendarEvent> expandEvents(
    List<CalendarEvent> base, DateTime rangeStart, DateTime rangeEnd) {
  final start = dateOnly(rangeStart);
  final end = dateOnly(rangeEnd);
  final out = <CalendarEvent>[];
  for (final e in base) {
    switch (e.recurrence) {
      case Recurrence.none:
        if (!e.date.isBefore(start) && !e.date.isAfter(end)) out.add(e);
      case Recurrence.weekly:
        _step(e, start, end, out, (d) => DateTime(d.year, d.month, d.day + 7));
      case Recurrence.monthly:
        _stepMonths(e, start, end, out, 1);
      case Recurrence.yearly:
        _stepMonths(e, start, end, out, 12);
    }
  }
  out.sort((a, b) => a.startsAt.compareTo(b.startsAt));
  return out;
}

void _step(CalendarEvent e, DateTime start, DateTime end,
    List<CalendarEvent> out, DateTime Function(DateTime) next) {
  var d = dateOnly(e.date);
  while (d.isBefore(start)) { d = next(d); }
  while (!d.isAfter(end)) {
    out.add(e.copyWith(date: d));
    d = next(d);
  }
}

void _stepMonths(CalendarEvent e, DateTime start, DateTime end,
    List<CalendarEvent> out, int monthStep) {
  final base = dateOnly(e.date);
  var cursor = DateTime(start.year, start.month);
  while (!cursor.isAfter(end)) {
    final monthsFromBase = (cursor.year - base.year) * 12 + (cursor.month - base.month);
    if (monthsFromBase >= 0 && monthsFromBase % monthStep == 0) {
      final occ = DateTime(cursor.year, cursor.month, base.day);
      if (occ.month == cursor.month && // guards short months (e.g. day 31)
          !occ.isBefore(start) && !occ.isAfter(end)) {
        out.add(e.copyWith(date: occ));
      }
    }
    cursor = DateTime(cursor.year, cursor.month + 1);
  }
}
