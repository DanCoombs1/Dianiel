// lib/features/month/widgets/month_grid.dart
import 'package:flutter/material.dart';
import '../../../models/calendar_event.dart';
import '../../../utils/date_utils.dart';
import 'day_cell.dart';

class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.eventsByDay,
    required this.onDayTap,
  });
  final DateTime month;
  final Map<String, List<CalendarEvent>> eventsByDay;
  final void Function(DateTime day) onDayTap;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final leading = (first.weekday - 1) % 7; // Monday-first (Mon=1 → 0 leading)
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final cells = <DateTime>[];
    for (var i = 0; i < leading; i++) {
      cells.add(first.subtract(Duration(days: leading - i)));
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(month.year, month.month, d));
    }
    while (cells.length % 7 != 0) {
      cells.add(cells.last.add(const Duration(days: 1)));
    }
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // Self-sizing Column (shrinkWrapped, non-scrolling grid). This is safe to
    // place inside an outer scrollable like MonthViewScreen's ListView; it must
    // NOT introduce its own vertical viewport or it will crash there.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: labels
              .map((l) => Expanded(
                    child: Center(
                      child: Text(l,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ))
              .toList(),
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.8,
          children: cells
              .map((d) => DayCell(
                    day: d,
                    inMonth: d.month == month.month,
                    events: eventsByDay[dayKey(d)] ?? const [],
                    onTap: () => onDayTap(d),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
