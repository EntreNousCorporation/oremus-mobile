import 'dart:math';

import 'package:flutter/material.dart';

class RosaryPainter extends CustomPainter {
  final int activeBeadIndex;
  final Color activeColor;
  final Color inactiveColor;
  final Color crossColor;

  RosaryPainter({
    required this.activeBeadIndex,
    required this.activeColor,
    required this.inactiveColor,
    this.crossColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Structure traditionnelle du chapelet
    const totalElements = 60;

    // Important: le facteur startAngle est la clé pour positionner correctement
    const startAngle = -pi / 2; // -90 degrés, commence en haut
    const angleStep = 2 * pi / totalElements;

    // Liste des positions de gros grains (Notre Père)
    final largeBeadPositions = [1, 5, 16, 27, 38, 49];

    for (int i = 0; i < totalElements; i++) {
      // Calculer l'angle pour chaque élément
      final angle = startAngle + (angleStep * i);

      // Calculer la position x,y
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      // Déterminer le type d'élément et sa couleur
      final isActive = i <= activeBeadIndex;

      if (i == 0) {
        // La croix en haut - toujours utiliser crossColor, quelle que soit son état
        drawCross(canvas, Offset(x, y), crossColor);
      } else if (largeBeadPositions.contains(i)) {
        // Les gros grains (Notre Père)
        drawLargeBead(canvas, Offset(x, y), isActive ? activeColor : inactiveColor);
      } else {
        // Les petits grains (Je vous salue Marie)
        drawSmallBead(canvas, Offset(x, y), isActive ? activeColor : inactiveColor);
      }
    }
  }

  void drawCross(Canvas canvas, Offset position, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Dessiner une croix simple
    canvas.drawLine(
      Offset(position.dx, position.dy - 8),
      Offset(position.dx, position.dy + 20),
      paint,
    );
    canvas.drawLine(
      Offset(position.dx - 8, position.dy),
      Offset(position.dx + 8, position.dy),
      paint,
    );
  }

  void drawLargeBead(Canvas canvas, Offset position, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 8, paint);
  }

  void drawSmallBead(Canvas canvas, Offset position, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 4, paint);
  }

  @override
  bool shouldRepaint(covariant RosaryPainter oldDelegate) {
    return oldDelegate.activeBeadIndex != activeBeadIndex ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.crossColor != crossColor;
  }
}