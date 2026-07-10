import 'package:flutter/material.dart';

class MultiTapDetector extends StatefulWidget {
  const MultiTapDetector({
    super.key,
    required this.child,
    required this.onMultiTap,
    this.numberOfTaps = 3,
    this.maxDelay = const Duration(milliseconds: 350),
    this.behavior = HitTestBehavior.deferToChild,
  }) : assert(numberOfTaps >= 2);

  final Widget child;
  final VoidCallback onMultiTap;

  /// Nombre de taps consécutifs à détecter.
  final int numberOfTaps;

  /// Délai maximal entre deux taps.
  final Duration maxDelay;

  final HitTestBehavior behavior;

  @override
  State<MultiTapDetector> createState() => _MultiTapDetectorState();
}

class _MultiTapDetectorState extends State<MultiTapDetector> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = DateTime.now();

    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > widget.maxDelay) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }

    _lastTapTime = now;

    if (_tapCount == widget.numberOfTaps) {
      _tapCount = 0;
      widget.onMultiTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTap: _handleTap,
      child: widget.child,
    );
  }
}