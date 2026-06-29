// lib/models/vault_photo.dart

class VaultPhoto {
  final String id;
  final String storagePath;
  final String downloadUrl;
  final String uploadedBy;

  const VaultPhoto({
    required this.id,
    required this.storagePath,
    required this.downloadUrl,
    required this.uploadedBy,
  });

  factory VaultPhoto.fromFirestore(String id, Map<String, dynamic> m) {
    return VaultPhoto(
      id: id,
      storagePath: m['storagePath'] as String,
      downloadUrl: m['downloadUrl'] as String,
      uploadedBy: m['uploadedBy'] as String,
    );
  }
}
