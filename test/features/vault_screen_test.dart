// test/features/vault_screen_test.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dianiels_calendar/models/vault_photo.dart';
import 'package:dianiels_calendar/providers/repository_providers.dart';
import 'package:dianiels_calendar/repositories/vault_repository.dart';
import 'package:dianiels_calendar/features/vault/vault_screen.dart';

class _FakeVaultRepository implements VaultRepository {
  final _controller = StreamController<List<VaultPhoto>>.broadcast();

  _FakeVaultRepository() {
    _controller.add([
      const VaultPhoto(
        id: 'p1',
        storagePath: 'vault/p1.jpg',
        downloadUrl: 'https://example.com/p1.jpg',
        uploadedBy: 'uid-dan',
      ),
    ]);
  }

  @override
  Stream<List<VaultPhoto>> watchPhotos() => _controller.stream;

  @override
  Future<void> addPhoto(File file, String uid) async {}

  @override
  Future<void> removePhoto(String id) async {}

  void dispose() => _controller.close();
}

void main() {
  testWidgets('VaultScreen shows VaultGate (fingerprint icon) before unlock',
      (tester) async {
    final fakeRepo = _FakeVaultRepository();
    addTearDown(fakeRepo.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vaultRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(home: VaultScreen()),
      ),
    );

    await tester.pump();

    // The VaultGate should be visible (fingerprint icon shown).
    expect(find.byIcon(Icons.fingerprint), findsOneWidget);

    // The gallery (GridView) should NOT be visible yet.
    expect(find.byType(GridView), findsNothing);
  });
}
