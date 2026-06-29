import 'package:flutter/material.dart';

import 'vault_gate.dart';
import 'vault_gallery.dart';

/// The Vault tab/page. Locked behind the 3-second hold gimmick ([VaultGate]).
/// Unlock state is in-memory, so leaving and re-entering (a fresh instance)
/// re-locks the vault.
class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return const VaultGallery();
    return Scaffold(
      appBar: AppBar(title: const Text('Vault')),
      body: VaultGate(
        onUnlocked: () => setState(() => _unlocked = true),
      ),
    );
  }
}
