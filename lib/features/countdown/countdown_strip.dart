// lib/features/countdown/countdown_strip.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/calendar_event.dart';
import '../../providers/event_providers.dart';
import '../../utils/date_utils.dart';
import '../../utils/recurrence_expander.dart';

List<CalendarEvent> upcomingBigDates(List<CalendarEvent> all, DateTime from,
    {int limit = 3}) {
  final end = DateTime(from.year + 1, from.month, from.day);
  final expanded = expandEvents(all.where((e) => e.isBigDate).toList(), from, end);
  expanded.sort((a, b) => a.date.compareTo(b.date));
  return expanded.take(limit).toList();
}

class CountdownStrip extends ConsumerWidget {
  const CountdownStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allEventsProvider);
    final today = dateOnly(DateTime.now());
    return async.maybeWhen(
      data: (all) {
        final items = upcomingBigDates(all, today);
        if (items.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 64,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: items.map((e) {
              final days = dateOnly(e.date).difference(today).inDays;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                      child: Text(
                    '${e.title} · ${days == 0 ? 'today' : 'in $days days'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )),
                ),
              );
            }).toList(),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
