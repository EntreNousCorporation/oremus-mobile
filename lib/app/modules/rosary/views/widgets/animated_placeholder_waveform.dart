import 'package:flutter/material.dart';
import 'package:oremusapp/app/modules/rosary/views/painters/placeholder_waveform_painter.dart';

class AnimatedPlaceholderWaveform extends StatefulWidget {
  final Color activeColor;
  final Color inactiveColor;

  const AnimatedPlaceholderWaveform({
    Key? key,
    required this.activeColor,
    required this.inactiveColor,
  }) : super(key: key);

  @override
  State<AnimatedPlaceholderWaveform> createState() => _AnimatedPlaceholderWaveformState();
}

class _AnimatedPlaceholderWaveformState extends State<AnimatedPlaceholderWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 40),
          painter: PlaceholderWaveformPainter(
            progress: _animationController.value,
            activeColor: widget.activeColor,
            inactiveColor: widget.inactiveColor,
          ),
        );
      },
    );
  }
}
