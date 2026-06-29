// Smoke test: the local-mode app boots straight into the calendar (the local
// auth repository reports an always-signed-in user).
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dianiels_calendar/app.dart';
import 'package:dianiels_calendar/local/in_memory_repositories.dart';
import 'package:dianiels_calendar/providers/repository_providers.dart';

void main() {
  testWidgets('local-mode app boots into the calendar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(LocalAuthRepository()),
          eventRepositoryProvider.overrideWithValue(InMemoryEventRepository()),
        ],
        child: const DianielApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text("Dianiel's Calendar"), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
  });
}
