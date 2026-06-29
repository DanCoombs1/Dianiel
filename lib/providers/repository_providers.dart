import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/vault_photo.dart';
import '../repositories/auth_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/todo_repository.dart';
import '../repositories/vault_repository.dart';
import '../services/notification_service.dart';

final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final storageProvider = Provider((ref) => FirebaseStorage.instance);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(ref.watch(firebaseAuthProvider)),
);

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => FirestoreEventRepository(ref.watch(firestoreProvider)),
);

final notificationServiceProvider = Provider((ref) => NotificationService());

final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => FirestoreTodoRepository(ref.watch(firestoreProvider)),
);

final vaultRepositoryProvider = Provider<VaultRepository>(
  (ref) => FirebaseVaultRepository(
    ref.watch(firestoreProvider),
    ref.watch(storageProvider),
  ),
);

final vaultPhotosProvider = StreamProvider<List<VaultPhoto>>(
  (ref) => ref.watch(vaultRepositoryProvider).watchPhotos(),
);
