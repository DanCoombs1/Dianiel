// lib/repositories/vault_repository.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/vault_photo.dart';

abstract class VaultRepository {
  Stream<List<VaultPhoto>> watchPhotos();
  Future<void> addPhoto(File file, String uid);
  Future<void> removePhoto(String id);
}

class FirebaseVaultRepository implements VaultRepository {
  FirebaseVaultRepository(this._db, this._storage);

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('vaultPhotos');

  @override
  Stream<List<VaultPhoto>> watchPhotos() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => VaultPhoto.fromFirestore(d.id, d.data()))
          .toList());

  @override
  Future<void> addPhoto(File file, String uid) async {
    // Use a Firestore doc ref to generate the ID first.
    final docRef = _col.doc();
    final storagePath = 'vault/${docRef.id}.jpg';

    // Upload bytes to Storage.
    final ref = _storage.ref(storagePath);
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    // Write the metadata doc.
    await docRef.set({
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'uploadedBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removePhoto(String id) async {
    // Fetch the doc to get the storagePath before deleting.
    final snap = await _col.doc(id).get();
    if (snap.exists) {
      final storagePath = snap.data()?['storagePath'] as String?;
      if (storagePath != null) {
        await _storage.ref(storagePath).delete().catchError((_) {});
      }
    }
    await _col.doc(id).delete();
  }
}
