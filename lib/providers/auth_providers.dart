import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import 'repository_providers.dart';

final authStateProvider = StreamProvider<AppAuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);
