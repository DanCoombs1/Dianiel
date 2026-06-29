// lib/features/month/month_view_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/event_providers.dart';
import '../day/day_agenda_screen.dart';
import '../event/event_editor_screen.dart';
import 'widgets/month_grid.dart';
import 'widgets/month_photo_header.dart';
import '../countdown/countdown_strip.dart';
import '../settings/settings_screen.dart';
import '../todo/todo_list_screen.dart';
import '../vault/vault_screen.dart';

/// Destinations reachable from the app-bar dropdown menu.
enum _MenuDestination { todos, vault, settings }

class MonthViewScreen extends ConsumerStatefulWidget {
  const MonthViewScreen({super.key});
  @override
  ConsumerState<MonthViewScreen> createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends ConsumerState<MonthViewScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _shift(int by) =>
      setState(() => _month = DateTime(_month.year, _month.month + by));

  @override
  Widget build(BuildContext context) {
    final grouped = ref.watch(eventsForMonthProvider(_month));
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dianiel's Calendar"),
        actions: [
          IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _shift(-1)),
          IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _shift(1)),
          PopupMenuButton<_MenuDestination>(
            icon: const Icon(Icons.settings),
            onSelected: (dest) {
              final Widget page = switch (dest) {
                _MenuDestination.todos => const TodoListScreen(),
                _MenuDestination.vault => const VaultScreen(),
                _MenuDestination.settings => const SettingsScreen(),
              };
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => page));
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _MenuDestination.todos,
                child: ListTile(
                    leading: Icon(Icons.checklist), title: Text('To-dos')),
              ),
              PopupMenuItem(
                value: _MenuDestination.vault,
                child: ListTile(
                    leading: Icon(Icons.lock), title: Text('Vault')),
              ),
              PopupMenuItem(
                value: _MenuDestination.settings,
                child: ListTile(
                    leading: Icon(Icons.settings), title: Text('Settings')),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EventEditorScreen(initialDate: _month))),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          MonthPhotoHeader(month: _month),
          const CountdownStrip(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: grouped.when(
              data: (byDay) => MonthGrid(
                month: _month,
                eventsByDay: byDay,
                onDayTap: (day) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DayAgendaScreen(day: day))),
              ),
              loading: () => const Center(
                  child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator())),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
