// lib/features/event/event_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/calendar_event.dart';
import '../../models/enums.dart';
import '../../providers/repository_providers.dart';
import '../../providers/auth_providers.dart';

class EventEditorScreen extends ConsumerStatefulWidget {
  const EventEditorScreen({super.key, this.initialDate, this.existing});
  final DateTime? initialDate;
  final CalendarEvent? existing;
  @override
  ConsumerState<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends ConsumerState<EventEditorScreen> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _location =
      TextEditingController(text: widget.existing?.location ?? '');
  late final TextEditingController _notes =
      TextEditingController(text: widget.existing?.notes ?? '');
  late DateTime _date = widget.existing?.date ?? widget.initialDate ?? DateTime.now();
  late bool _allDay = widget.existing?.allDay ?? true;
  TimeOfDay? _time;
  late EventOwner _owner = widget.existing?.owner ?? EventOwner.together;
  late ReminderOption _reminder = widget.existing?.reminder ?? ReminderOption.none;
  late Recurrence _recurrence = widget.existing?.recurrence ?? Recurrence.none;
  late bool _isBigDate = widget.existing?.isBigDate ?? false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final startTime = widget.existing?.startTime;
    if (startTime != null) {
      final parts = startTime.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          _time = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final uid = ref.read(authStateProvider).value?.uid ?? 'unknown';
    final startTime = (!_allDay && _time != null)
        ? '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}'
        : null;
    final event = CalendarEvent(
      id: widget.existing?.id ?? '',
      title: _title.text.trim(),
      date: _date,
      startTime: startTime,
      allDay: _allDay,
      location: _location.text.trim().isEmpty ? null : _location.text.trim(),
      owner: _owner,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      reminder: _reminder,
      recurrence: _recurrence,
      isBigDate: _isBigDate,
      createdBy: widget.existing?.createdBy ?? uid,
    );
    final repo = ref.read(eventRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      if (widget.existing == null) {
        await repo.add(event);
      } else {
        await repo.update(event);
      }
      if (mounted) navigator.pop();
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not save event. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    await ref.read(eventRepositoryProvider).delete(widget.existing!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New event' : 'Edit event'),
        actions: [
          if (widget.existing != null)
            IconButton(
                key: const Key('delete'),
                icon: const Icon(Icons.delete),
                onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              key: const Key('title'),
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          SegmentedButton<EventOwner>(
            segments: EventOwner.values
                .map((o) => ButtonSegment(
                    value: o,
                    label: Text(
                        o == EventOwner.together ? '❤️ Together' : o.label)))
                .toList(),
            selected: {_owner},
            onSelectionChanged: (s) => setState(() => _owner = s.first),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            trailing: Text('${_date.day}/${_date.month}/${_date.year}'),
            onTap: () async {
              final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100));
              if (picked != null) setState(() => _date = picked);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('All day'),
            value: _allDay,
            onChanged: (v) => setState(() => _allDay = v),
          ),
          if (!_allDay)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Time'),
              trailing: Text(_time?.format(context) ?? 'Set time'),
              onTap: () async {
                final t = await showTimePicker(
                    context: context,
                    initialTime: _time ?? TimeOfDay.now());
                if (t != null) setState(() => _time = t);
              },
            ),
          TextField(
              controller: _location,
              decoration:
                  const InputDecoration(labelText: 'Location (optional)')),
          const SizedBox(height: 12),
          DropdownButtonFormField<ReminderOption>(
            initialValue: _reminder,
            decoration: const InputDecoration(labelText: 'Reminder'),
            items: ReminderOption.values
                .map((r) =>
                    DropdownMenuItem(value: r, child: Text(r.label)))
                .toList(),
            onChanged: (r) => setState(() => _reminder = r!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Recurrence>(
            initialValue: _recurrence,
            decoration: const InputDecoration(labelText: 'Repeat'),
            items: Recurrence.values
                .map((r) =>
                    DropdownMenuItem(value: r, child: Text(r.label)))
                .toList(),
            onChanged: (r) => setState(() => _recurrence = r!),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Big date (show in countdown)'),
            value: _isBigDate,
            onChanged: (v) => setState(() => _isBigDate = v),
          ),
          TextField(
              controller: _notes,
              maxLines: 3,
              decoration:
                  const InputDecoration(labelText: 'Notes (optional)')),
          const SizedBox(height: 20),
          FilledButton(
            key: const Key('save'),
            onPressed: _busy ? null : _save,
            child:
                Text(widget.existing == null ? 'Add event' : 'Save changes'),
          ),
        ],
      ),
    );
  }
}
