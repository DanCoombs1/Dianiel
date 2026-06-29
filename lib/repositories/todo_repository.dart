// lib/repositories/todo_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_item.dart';

abstract class TodoRepository {
  Stream<List<TodoItem>> watchAll();
  Future<String> add(TodoItem t);
  Future<void> update(TodoItem t);
  Future<void> delete(String id);
}

class FirestoreTodoRepository implements TodoRepository {
  FirestoreTodoRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('todos');

  @override
  Stream<List<TodoItem>> watchAll() => _col.snapshots().map(
        (snap) =>
            snap.docs.map((d) => TodoItem.fromFirestore(d.id, d.data())).toList(),
      );

  @override
  Future<String> add(TodoItem t) async {
    final ref = await _col.add(t.toFirestore());
    return ref.id;
  }

  @override
  Future<void> update(TodoItem t) => _col.doc(t.id).update(t.toFirestore());

  @override
  Future<void> delete(String id) => _col.doc(id).delete();
}
