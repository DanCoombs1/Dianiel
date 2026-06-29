import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/calendar_event.dart';
import '../../models/enums.dart';
import '../../models/todo_item.dart';
import '../../providers/auth_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/todo_providers.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  String _getUid() =>
      ref.read(authStateProvider).value?.uid ?? 'unknown';

  Future<void> _add() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final uid = _getUid();
    await ref.read(todoRepositoryProvider).add(
          TodoItem(
            id: '',
            title: text,
            done: false,
            scheduledDate: null,
            createdBy: uid,
          ),
        );
    _inputController.clear();
  }

  Future<void> _scheduleOnCalendar(TodoItem todo) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final uid = _getUid();
    await ref.read(eventRepositoryProvider).add(
          CalendarEvent(
            id: '',
            title: todo.title,
            date: picked,
            allDay: true,
            owner: EventOwner.together,
            createdBy: uid,
          ),
        );
    await ref.read(todoRepositoryProvider).update(
          todo.copyWith(scheduledDate: picked),
        );
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todosProvider);
    final dateFormat = DateFormat('d MMM');

    return Scaffold(
      appBar: AppBar(title: const Text('To-dos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('todo-input'),
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'New to-do...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  key: const Key('todo-add'),
                  icon: const Icon(Icons.add),
                  onPressed: _add,
                ),
              ],
            ),
          ),
          Expanded(
            child: todosAsync.when(
              data: (todos) {
                if (todos.isEmpty) {
                  return const Center(child: Text('No to-dos yet 🌸'));
                }
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return CheckboxListTile(
                      value: todo.done,
                      onChanged: (v) {
                        if (v == null) return;
                        ref.read(todoRepositoryProvider).update(
                              todo.copyWith(done: v),
                            );
                      },
                      title: Text(todo.title),
                      subtitle: todo.scheduledDate != null
                          ? Text('Scheduled · ${dateFormat.format(todo.scheduledDate!)}')
                          : null,
                      secondary: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.event),
                            onPressed: () => _scheduleOnCalendar(todo),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                ref.read(todoRepositoryProvider).delete(todo.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
