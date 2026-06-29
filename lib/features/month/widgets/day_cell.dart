// lib/features/month/widgets/day_cell.dart
import 'package:flutter/material.dart';
import '../../../models/calendar_event.dart';
import '../../../theme/owner_color.dart';

class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.day,
    required this.inMonth,
    required this.events,
    required this.onTap,
  });
  final DateTime day;
  final bool inMonth;
  final List<CalendarEvent> events;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasTogether = events.any((e) => e.owner.isTogether);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: inMonth ? Colors.white : Colors.white.withValues(alpha: 0.4),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                      color: inMonth ? Colors.black87 : Colors.black38),
                ),
                if (hasTogether)
                  const Text('❤️', style: TextStyle(fontSize: 10)),
              ],
            ),
            const SizedBox(height: 2),
            Wrap(
              spacing: 2,
              children: events
                  .take(3)
                  .map((e) => CircleAvatar(
                      radius: 3, backgroundColor: ownerColor(e.owner)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
