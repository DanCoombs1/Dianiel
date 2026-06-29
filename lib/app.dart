import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/sign_in_screen.dart';
import 'features/month/month_view_screen.dart';
import 'providers/auth_providers.dart';
import 'theme/app_theme.dart';

/// Root widget. Watches auth state and shows either the sign-in screen or the
/// calendar. In local mode the auth stream is always a signed-in user, so the
/// calendar shows immediately.
class DianielApp extends ConsumerWidget {
  const DianielApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return MaterialApp(
      title: "Dianiel's Calendar",
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (user) =>
            user == null ? const SignInScreen() : const MonthViewScreen(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}
