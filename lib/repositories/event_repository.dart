// lib/repositories/event_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calendar_event.dart';

abstract class EventRepository {
  Stream<List<CalendarEvent>> watchAll();
  Future<String> add(CalendarEvent e);
  Future<void> update(CalendarEvent e);
  Future<void> delete(String id);
}

class FirestoreEventRepository implements EventRepository {
  FirestoreEventRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('events');

  @override
  Stream<List<CalendarEvent>> watchAll() => _col.snapshots().map(
        (snap) => snap.docs
            .map((d) => CalendarEvent.fromFirestore(d.id, d.data()))
            .toList(),
      );

  @override
  Future<String> add(CalendarEvent e) async {
    final ref = await _col.add(e.toFirestore()..['createdAt'] = FieldValue.serverTimestamp());
    return ref.id;
  }

  @override
  Future<void> update(CalendarEvent e) => _col.doc(e.id).update(e.toFirestore());

  @override
  Future<void> delete(String id) => _col.doc(id).delete();
}
