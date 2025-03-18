import 'dart:math';

import 'package:flutter/material.dart';

class RosaryPainter extends CustomPainter {
  final int beadCount;
  final int activeBeadIndex;
  final Color activeColor;
  final Color inactiveColor;

  RosaryPainter({
    required this.beadCount,
    required this.activeBeadIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    for (int i = 0; i < beadCount; i++) {
      final angle = 2 * pi * i / beadCount;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      final paint = Paint()
        ..color = i <= activeBeadIndex ? activeColor : inactiveColor
        ..style = PaintingStyle.fill;

      // Draw larger beads for decades
      if (i % 10 == 0) {
        canvas.drawCircle(Offset(x, y), 8, paint);
      } else {
        canvas.drawCircle(Offset(x, y), 5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}