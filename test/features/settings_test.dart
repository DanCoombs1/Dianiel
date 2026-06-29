// test/features/settings_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dianiels_calendar/repositories/auth_repository.dart';
import 'package:dianiels_calendar/providers/repository_providers.dart';
import 'package:dianiels_calendar/features/settings/settings_screen.dart';

class _FakeAuth implements AuthRepository {
  bool signedOut = false;
  @override Stream<AppAuthUser?> authStateChanges() async* { yield null; }
  @override Future<void> signInWithApple() async {}
  @override Future<void> signOut() async { signedOut = true; }
}

void main() {
  testWidgets('tapping sign out calls signOut', (tester) async {
    final auth = _FakeAuth();
    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
      child: const MaterialApp(home: SettingsScreen()),
    ));
    await tester.tap(find.text('Sign out'));
    await tester.pump();
    expect(auth.signedOut, isTrue);
  });
}
