import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dianiels_calendar/features/vault/vault_gate.dart';

// pump(Duration) advances the clock by the given amount but processes only ONE
// frame per call. An AnimationController's Ticker needs a frame per tick to
// advance. We therefore pump multiple 100ms frames to let the animation run
// through its 3-second duration rather than a single large pump.
Future<void> _pumpFrames(WidgetTester tester, Duration total) async {
  const step = Duration(milliseconds: 100);
  var elapsed = Duration.zero;
  while (elapsed < total) {
    await tester.pump(step);
    elapsed += step;
  }
}

void main() {
  testWidgets('A: holding for 3 seconds unlocks', (tester) async {
    bool unlocked = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: VaultGate(onUnlocked: () => unlocked = true),
      ),
    ));

    // startGesture sends a pointer-down event. onTapDown fires immediately
    // (before any pump), starting the AnimationController.forward().
    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.fingerprint)),
    );

    // Advance 3.2 seconds in 100ms steps so the ticker gets enough frames to
    // reach AnimationStatus.completed (controller duration = 3s).
    await _pumpFrames(tester, const Duration(milliseconds: 3200));

    expect(unlocked, isTrue);

    // Releasing after completion is a no-op (guard flag prevents re-fire).
    await gesture.up();
    await tester.pump();
    expect(unlocked, isTrue);
  });

  testWidgets('B: releasing early does NOT unlock', (tester) async {
    bool unlocked = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: VaultGate(onUnlocked: () => unlocked = true),
      ),
    ));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.fingerprint)),
    );

    // Hold for only 1 second — well short of the 3-second threshold.
    await _pumpFrames(tester, const Duration(seconds: 1));

    // Release: onTapUp fires → _cancelHold() → controller.reset().
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 50));

    expect(unlocked, isFalse);
  });
}
