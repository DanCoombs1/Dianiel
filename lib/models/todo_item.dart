// lib/models/todo_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoItem {
  final String id;
  final String title;
  final bool done;
  final DateTime? scheduledDate;
  final String createdBy;

  const TodoItem({
    required this.id,
    required this.title,
    required this.done,
    this.scheduledDate,
    required this.createdBy,
  });

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'done': done,
        'scheduledDate':
            scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory TodoItem.fromFirestore(String id, Map<String, dynamic> m) {
    final ts = m['scheduledDate'];
    return TodoItem(
      id: id,
      title: m['title'] as String,
      done: m['done'] as bool? ?? false,
      scheduledDate: ts != null ? (ts as Timestamp).toDate() : null,
      createdBy: m['createdBy'] as String,
    );
  }

  TodoItem copyWith({
    String? title,
    bool? done,
    DateTime? scheduledDate,
  }) =>
      TodoItem(
        id: id,
        title: title ?? this.title,
        done: done ?? this.done,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        createdBy: createdBy,
      );
}
