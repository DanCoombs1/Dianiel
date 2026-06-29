import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/auth_providers.dart';
import '../../providers/repository_providers.dart';
import '../../models/vault_photo.dart';

/// Renders a vault image. Works for both Firebase download URLs (http...) and
/// local file paths (local mode), so the same gallery runs against either backend.
Widget vaultImage(String url, {BoxFit fit = BoxFit.cover}) =>
    url.startsWith('http')
        ? Image.network(url, fit: fit)
        : Image.file(File(url), fit: fit);

class VaultGallery extends ConsumerWidget {
  const VaultGallery({super.key});

  Future<void> _pickAndUpload(WidgetRef ref) async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 2000, imageQuality: 85);
    if (picked == null) return;
    final uid = ref.read(authStateProvider).value?.uid ?? 'unknown';
    await ref.read(vaultRepositoryProvider).addPhoto(File(picked.path), uid);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(vaultPhotosProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Vault 🤫')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAndUpload(ref),
        child: const Icon(Icons.add_a_photo),
      ),
      body: photosAsync.when(
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(child: Text('Vault is empty 🤫'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: photos.length,
            itemBuilder: (context, i) {
              final photo = photos[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _VaultPhotoView(photo: photo),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: vaultImage(photo.downloadUrl),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _VaultPhotoView extends ConsumerWidget {
  const _VaultPhotoView({required this.photo});
  final VaultPhoto photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await ref.read(vaultRepositoryProvider).removePhoto(photo.id);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(child: vaultImage(photo.downloadUrl, fit: BoxFit.contain)),
    );
  }
}
