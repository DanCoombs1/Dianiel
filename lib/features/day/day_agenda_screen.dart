import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/event_providers.dart';
import '../../utils/date_utils.dart';
import '../../utils/recurrence_expander.dart';
import '../event/event_editor_screen.dart';
import '../../theme/owner_color.dart';

class DayAgendaScreen extends ConsumerWidget {
  const DayAgendaScreen({super.key, required this.day});
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allEventsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(DateFormat('EEE d MMM yyyy').format(day))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => EventEditorScreen(initialDate: day))),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        data: (all) {
          final dayEvents = expandEvents(all, day, day)
              .where((e) => isSameDay(e.date, day)).toList()
            ..sort((a, b) {
              if (a.allDay != b.allDay) return a.allDay ? -1 : 1;
              return a.startsAt.compareTo(b.startsAt);
            });
          if (dayEvents.isEmpty) {
            return const Center(child: Text('No events 🌸'));
          }
          return ListView(
            children: dayEvents.map((e) => ListTile(
              leading: CircleAvatar(backgroundColor: ownerColor(e.owner), radius: 8),
              title: Text('${e.owner.isTogether ? '❤️ ' : ''}${e.title}'),
              subtitle: Text([
                if (e.allDay) 'All day' else (e.startTime ?? ''),
                if (e.location != null) '· ${e.location}',
              ].join(' ')),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => EventEditorScreen(existing: e))),
            )).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
