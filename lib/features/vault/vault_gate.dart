import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class VaultGate extends StatefulWidget {
  const VaultGate({
    super.key,
    required this.onUnlocked,
    this.prompt,
  });

  final VoidCallback onUnlocked;
  final String? prompt;

  @override
  State<VaultGate> createState() => _VaultGateState();
}

class _VaultGateState extends State<VaultGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _unlockFired = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_unlockFired) {
      _unlockFired = true;
      widget.onUnlocked();
    }
  }

  void _startHold() {
    // Only start forward if not already running/completed.
    if (_controller.status != AnimationStatus.forward &&
        _controller.status != AnimationStatus.completed) {
      _controller.forward();
    }
  }

  void _cancelHold() {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.prompt ?? 'Hold to unlock the vault 🤫';

    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              // onTapDown fires immediately when the pointer goes down,
              // before any gesture arena competition resolves.
              onTapDown: (_) => _startHold(),
              // onTapUp fires if the pointer lifts before becoming a long press.
              onTapUp: (_) => _cancelHold(),
              // onTapCancel fires when a long-press recognizer steals the gesture
              // from the tap recognizer. We deliberately do NOT reset here —
              // the animation is already running from onTapDown and should continue.
              // A true cancellation (pointer leaves, drag away) is handled by
              // onLongPressEnd once the long press is active.
              onTapCancel: () {}, // intentionally no-op
              // onLongPressStart fires for actual long-press recognition (belt+suspenders).
              onLongPressStart: (_) => _startHold(),
              // onLongPressEnd fires when a long-press hold is released.
              onLongPressEnd: (_) => _cancelHold(),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _controller.value,
                          strokeWidth: 5,
                          color: AppColors.babyPinkDark,
                          backgroundColor:
                              AppColors.babyPink.withValues(alpha: 0.3),
                        ),
                        child!,
                      ],
                    ),
                  );
                },
                child: const Icon(
                  Icons.fingerprint,
                  size: 96,
                  color: AppColors.babyPinkDark,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.babyPinkDark,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
