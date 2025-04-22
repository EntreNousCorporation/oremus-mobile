// Painter pour la barre de progression artistique
import 'dart:math' as math;

import 'package:flutter/material.dart';

class ArtisticProgressPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  ArtisticProgressPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final Paint activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Dessiner la ligne ondulée inactive
    final Path inactivePath = Path();
    final amplitude = size.height * 0.2;
    final period = size.width / 20;

    inactivePath.moveTo(0, size.height / 2);

    for (double x = 0; x < size.width; x += 1) {
      final y = size.height / 2 + amplitude * math.sin((x / period) * 3.14159);
      inactivePath.lineTo(x, y);
    }

    canvas.drawPath(inactivePath, inactivePaint);

    // Dessiner la partie active de la ligne
    if (progress > 0) {
      final Path activePath = Path();
      activePath.moveTo(0, size.height / 2);

      for (double x = 0; x < size.width * progress; x += 1) {
        final y = size.height / 2 + amplitude * math.sin((x / period) * 3.14159);
        activePath.lineTo(x, y);
      }

      canvas.drawPath(activePath, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}