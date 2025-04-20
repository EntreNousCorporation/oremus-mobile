import 'dart:math';

import 'package:flutter/material.dart';

class RosaryPainter extends CustomPainter {
  final int activeBeadIndex;
  final Color activeColor;
  final Color inactiveColor;
  final Color crossColor;
  final bool useElegantStyle;

  RosaryPainter({
    required this.activeBeadIndex,
    required this.activeColor,
    required this.inactiveColor,
    this.crossColor = Colors.black,
    this.useElegantStyle = true,
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

    // Pour le style élégant, définir des couleurs avec des dégradés et ombres
    final activeGradient = useElegantStyle ? RadialGradient(
      colors: [
        activeColor.withValues(alpha: 0.9),
        activeColor,
      ],
      center: Alignment.topLeft,
      radius: 1.2,
    ) : null;

    final inactiveGradient = useElegantStyle ? RadialGradient(
      colors: [
        inactiveColor.withValues(alpha: 0.9),
        inactiveColor.withValues(alpha: 0.7),
      ],
      center: Alignment.topLeft,
      radius: 1.2,
    ) : null;

    for (int i = 0; i < totalElements; i++) {
      // Calculer l'angle pour chaque élément
      final angle = startAngle + (angleStep * i);

      // Calculer la position x,y
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      // Déterminer le type d'élément et sa couleur
      final isActive = i <= activeBeadIndex;

      if (i == 0) {
        // La croix en haut - toujours utiliser crossColor
        drawCross(canvas, Offset(x, y), crossColor);
      } else if (largeBeadPositions.contains(i)) {
        // Les gros grains (Notre Père)
        if (useElegantStyle) {
          drawElegantLargeBead(
              canvas,
              Offset(x, y),
              isActive ? activeGradient! : inactiveGradient!,
              isActive ? activeColor : inactiveColor
          );
        } else {
          drawLargeBead(canvas, Offset(x, y), isActive ? activeColor : inactiveColor);
        }
      } else {
        // Les petits grains (Je vous salue Marie)
        if (useElegantStyle) {
          drawElegantSmallBead(
              canvas,
              Offset(x, y),
              isActive ? activeGradient! : inactiveGradient!,
              isActive ? activeColor : inactiveColor
          );
        } else {
          drawSmallBead(canvas, Offset(x, y), isActive ? activeColor : inactiveColor);
        }
      }
    }
  }

  void drawCross(Canvas canvas, Offset position, Color color) {
    if (useElegantStyle) {
      // Dessiner une croix élégante avec ombre
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      // Dessiner l'ombre de la croix
      canvas.drawLine(
        Offset(position.dx + 1, position.dy - 7),
        Offset(position.dx + 1, position.dy + 21),
        shadowPaint,
      );
      canvas.drawLine(
        Offset(position.dx - 7, position.dy + 1),
        Offset(position.dx + 9, position.dy + 1),
        shadowPaint,
      );

      // Dessiner la croix principale
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

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
    } else {
      // Style standard
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;

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
  }

  void drawElegantLargeBead(Canvas canvas, Offset position, RadialGradient gradient, Color baseColor) {
    // Dessiner l'ombre
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(Offset(position.dx + 1, position.dy + 1), 8, shadowPaint);

    // Dessiner le grain avec dégradé
    final rect = Rect.fromCircle(center: position, radius: 8);
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 8, gradientPaint);

    // Ajouter une bordure légère
    final borderPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawCircle(position, 8, borderPaint);

    // Ajouter un point de lumière (reflet)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(position.dx - 2, position.dy - 2), 2, highlightPaint);
  }

  void drawElegantSmallBead(Canvas canvas, Offset position, RadialGradient gradient, Color baseColor) {
    // Dessiner l'ombre
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(Offset(position.dx + 0.5, position.dy + 0.5), 4, shadowPaint);

    // Dessiner le grain avec dégradé
    final rect = Rect.fromCircle(center: position, radius: 4);
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 4, gradientPaint);

    // Ajouter une bordure légère
    final borderPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    canvas.drawCircle(position, 4, borderPaint);

    // Ajouter un point de lumière (reflet)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(position.dx - 1, position.dy - 1), 1, highlightPaint);
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
        oldDelegate.crossColor != crossColor ||
        oldDelegate.useElegantStyle != useElegantStyle;
  }
}
