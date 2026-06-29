# Task 23 Report: VaultGate (3-second hold gimmick)

## Files

- **Created:** `lib/features/vault/vault_gate.dart`
- **Created:** `test/features/vault_gate_test.dart`

## Exact Test Outputs

### Vault-gate tests only

```
flutter test test/features/vault_gate_test.dart --reporter expanded

00:00 +0: A: holding for 3 seconds unlocks
00:00 +1: B: releasing early does NOT unlock
00:00 +2: All tests passed!
```

### Full suite

```
flutter test

00:08 +41: All tests passed!
```

(Previously 39 tests; +2 new vault-gate tests = 41 total.)

### Analyze

```
flutter analyze

No issues found! (ran in 2.0s)
```

## How the Hold/Timer Was Made Testable

### The core problem

`WidgetTester.pump(Duration)` advances the fake clock by the given amount but schedules **only one frame**. An `AnimationController` is driven by a `Ticker` — it needs a rendered frame per tick to advance its value. A single `pump(const Duration(seconds: 3))` therefore processes one frame and does not progress the animation through its 3-second duration.

### Investigation findings

1. `pump()` (zero-duration) does **not** resolve the gesture arena; `onTapDown` fires during `startGesture` itself (immediately on pointer-down for a `GestureDetector` with only tap handlers).
2. When **both** `onTapDown` AND `onLongPressStart` are registered, the gesture arena delays resolution: `onTapDown` fires during `startGesture`, but `onTapCancel` fires ~0ms later when the long-press recognizer wins the arena. If `onTapCancel` calls `reset()`, the animation is killed before `onLongPressStart` fires at ~500ms — leaving only 2.5s of a 3s window.
3. `pump(100ms)` × N works correctly: 31+ frames of 100ms each gives the ticker enough ticks to run through the 3-second duration.

### Solutions applied

**Implementation:**
- `onTapDown` → `_startHold()` (fires immediately during `startGesture`).
- `onTapCancel` → **intentional no-op**: when the long-press recognizer steals the gesture from the tap recognizer, `onTapCancel` fires. We must NOT reset here — the animation is already running from `onTapDown` and should continue uninterrupted.
- `onLongPressStart` → `_startHold()` (belt-and-suspenders; `_startHold()` guards against calling `forward()` when already running).
- `onTapUp` + `onLongPressEnd` → `_cancelHold()` (only these genuine release events reset the animation).
- A `_unlockFired` bool guard ensures `onUnlocked` fires exactly once.

**Tests:**
- Used a `_pumpFrames(tester, duration)` helper that pumps 100ms steps for the requested total, giving the ticker enough frames to advance:
  - Test A: `_pumpFrames(tester, Duration(milliseconds: 3200))` → unlocked = true.
  - Test B: `_pumpFrames(tester, Duration(seconds: 1))` + `gesture.up()` → unlocked = false.

## Concerns

1. **`onTapCancel` no-op vs real cancellation:** Making `onTapCancel` a no-op means that if the user's finger is stolen by a parent scroll view (not just a long-press recognizer), the animation will keep running invisibly. This is acceptable for a modal vault gate (no scrollable ancestors), but would need revisiting if `VaultGate` were embedded in a `ScrollView`.

2. **`pump(Duration)` vs multiple `pump` calls:** The Flutter test framework's single-pump-per-call behavior for animations is a known footgun. The `_pumpFrames` helper is explicit and readable, but future maintainers should be aware that `pump(const Duration(seconds: 3))` will NOT advance a 3-second animation to completion in tests.

3. **Long-press timeout overlap:** `kLongPressTimeout` (500ms) fires `onLongPressStart` partway through the 3-second hold. This double-calls `_startHold()`, which is harmless due to the `status != forward` guard, but does mean the animation was already driven from `onTapDown` — `onLongPressStart` is effectively redundant for the start path. It still provides value for release (`onLongPressEnd` is the correct cancel for holds > 500ms that don't complete).
