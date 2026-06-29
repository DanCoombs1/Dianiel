import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';
import '../utils/date_utils.dart';

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;       // day the event lands on (date only)
  final String? startTime;   // "HH:mm" or null when allDay
  final bool allDay;
  final String? location;
  final EventOwner owner;
  final String? notes;
  final ReminderOption reminder;
  final Recurrence recurrence;
  final bool isBigDate;
  final String createdBy;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    this.startTime,
    this.allDay = true,
    this.location,
    required this.owner,
    this.notes,
    this.reminder = ReminderOption.none,
    this.recurrence = Recurrence.none,
    this.isBigDate = false,
    required this.createdBy,
  });

  /// The concrete DateTime of this occurrence (date + startTime), for reminders.
  DateTime get startsAt {
    if (allDay || startTime == null) return dateOnly(date);
    final parts = startTime!.split(':');
    return DateTime(date.year, date.month, date.day,
        int.parse(parts[0]), int.parse(parts[1]));
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'date': Timestamp.fromDate(dateOnly(date)),
        'startTime': startTime,
        'allDay': allDay,
        'location': location,
        'owner': owner.name,
        'notes': notes,
        'reminder': reminder.name,
        'recurrence': recurrence.name,
        'isBigDate': isBigDate,
        'createdBy': createdBy,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory CalendarEvent.fromFirestore(String id, Map<String, dynamic> m) {
    return CalendarEvent(
      id: id,
      title: m['title'] as String,
      date: (m['date'] as Timestamp).toDate(),
      startTime: m['startTime'] as String?,
      allDay: m['allDay'] as bool? ?? true,
      location: m['location'] as String?,
      owner: EventOwner.values.byName(m['owner'] as String),
      notes: m['notes'] as String?,
      reminder: ReminderOption.values.byName(m['reminder'] as String? ?? 'none'),
      recurrence: Recurrence.values.byName(m['recurrence'] as String? ?? 'none'),
      isBigDate: m['isBigDate'] as bool? ?? false,
      createdBy: m['createdBy'] as String,
    );
  }

  CalendarEvent copyWith({
    String? title, DateTime? date, String? startTime, bool? allDay,
    String? location, EventOwner? owner, String? notes,
    ReminderOption? reminder, Recurrence? recurrence, bool? isBigDate,
  }) =>
      CalendarEvent(
        id: id,
        title: title ?? this.title,
        date: date ?? this.date,
        startTime: startTime ?? this.startTime,
        allDay: allDay ?? this.allDay,
        location: location ?? this.location,
        owner: owner ?? this.owner,
        notes: notes ?? this.notes,
        reminder: reminder ?? this.reminder,
        recurrence: recurrence ?? this.recurrence,
        isBigDate: isBigDate ?? this.isBigDate,
        createdBy: createdBy,
      );
}
