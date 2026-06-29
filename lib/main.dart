import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'local/in_memory_repositories.dart';
import 'providers/repository_providers.dart';

/// Entry point — LOCAL MODE.
///
/// The app currently runs entirely on-device with in-memory data and no
/// Firebase, so it can be launched and used before any Firebase/Apple setup.
/// When the Firebase project is configured, replace this with a `main()` that
/// calls `Firebase.initializeApp(...)` and drops these overrides (the real
/// Firebase-backed providers are already the defaults).
void main() {
  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(LocalAuthRepository()),
        eventRepositoryProvider.overrideWithValue(InMemoryEventRepository()),
        todoRepositoryProvider.overrideWithValue(InMemoryTodoRepository()),
        vaultRepositoryProvider.overrideWithValue(InMemoryVaultRepository()),
      ],
      child: const DianielApp(),
    ),
  );
}
