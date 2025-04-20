import 'dart:math';
import 'package:flutter/material.dart';

// Énumération des différents styles disponibles
enum RosaryStyle {
  classic,
  elegant,
  minimalist,
  luxurious,
}

// Énumération des différents thèmes de couleurs
enum RosaryColorTheme {
  original,
  monochrome,
  aurora,
  serenity,
  amber,
  vegetal,
}

class RosaryTheme {
  final Color crossColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;

  const RosaryTheme({
    required this.crossColor,
    required this.activeColor,
    required this.inactiveColor,
    this.backgroundColor = Colors.white,
  });

  // Thèmes prédéfinis
  static const RosaryTheme original = RosaryTheme(
    crossColor: Color(0xFF000000),
    activeColor: Color(0xFF558B2F),
    inactiveColor: Color(0xFFE0E0E0),
    backgroundColor: Colors.white,
  );

  static const RosaryTheme monochrome = RosaryTheme(
    crossColor: Color(0xFF505050),
    activeColor: Color(0xFF303030),
    inactiveColor: Color(0xFFE0E0E0),
    backgroundColor: Colors.white,
  );

  static const RosaryTheme aurora = RosaryTheme(
    crossColor: Color(0xFF383D54),
    activeColor: Color(0xFF5DA9E9),
    inactiveColor: Color(0xFFB6D8F5),
    backgroundColor: Color(0xFFF8FCFF),
  );

  static const RosaryTheme serenity = RosaryTheme(
    crossColor: Color(0xFF6B5876),
    activeColor: Color(0xFFB393B3),
    inactiveColor: Color(0xFFE1DCDD),
    backgroundColor: Color(0xFFFBF9FA),
  );

  static const RosaryTheme amber = RosaryTheme(
    crossColor: Color(0xFF9B7E6B),
    activeColor: Color(0xFFE6B89C),
    inactiveColor: Color(0xFFF9F5F0),
    backgroundColor: Color(0xFFFFFAF5),
  );

  static const RosaryTheme vegetal = RosaryTheme(
    crossColor: Color(0xFF8D6E63),
    activeColor: Color(0xFF7A9E7E),
    inactiveColor: Color(0xFFE8F1E8),
    backgroundColor: Color(0xFFF7FAF7),
  );

  static RosaryTheme getTheme(RosaryColorTheme theme) {
    switch (theme) {
      case RosaryColorTheme.original:
        return original;
      case RosaryColorTheme.monochrome:
        return monochrome;
      case RosaryColorTheme.aurora:
        return aurora;
      case RosaryColorTheme.serenity:
        return serenity;
      case RosaryColorTheme.amber:
        return amber;
      case RosaryColorTheme.vegetal:
        return vegetal;
    }
  }
}

class RosaryPainter extends CustomPainter {
  final int activeBeadIndex;
  final RosaryStyle style;
  final RosaryColorTheme colorTheme;
  final RosaryTheme theme;

  // Positions des gros grains (Notre Père)
  static const List<int> largeBeadPositions = [1, 5, 16, 27, 38, 49];
  static const int totalElements = 60;

  RosaryPainter({
    required this.activeBeadIndex,
    this.style = RosaryStyle.classic,
    this.colorTheme = RosaryColorTheme.original,
  }) : theme = RosaryTheme.getTheme(colorTheme);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Dessiner l'arrière-plan si nécessaire (styles élégant et luxueux)
    if (style == RosaryStyle.elegant || style == RosaryStyle.luxurious) {
      _drawBackground(canvas, center, radius, theme);
    }

    // Structure traditionnelle du chapelet
    const startAngle = -pi / 2; // Commence en haut
    const angleStep = 2 * pi / totalElements;

    // Dessiner le cercle de fond pour le style minimaliste
    if (style == RosaryStyle.minimalist) {
      final circlePaint = Paint()
        ..color = theme.inactiveColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, circlePaint);
    }

    for (int i = 0; i < totalElements; i++) {
      // Calculer l'angle pour chaque élément
      final angle = startAngle + (angleStep * i);

      // Calculer la position x,y
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      // Déterminer le type d'élément et sa couleur
      final isActive = i <= activeBeadIndex;

      // Dessiner les lignes connectrices pour le style luxueux
      if (style == RosaryStyle.luxurious && i > 0) {
        _drawConnectingLine(canvas, center, radius, i, angleStep, startAngle, theme);
      }

      // Dessiner l'élément approprié
      if (i == 0) {
        // La croix
        _drawCross(canvas, Offset(x, y), isActive, theme, style);
      } else if (largeBeadPositions.contains(i)) {
        // Les gros grains (Notre Père)
        _drawLargeBead(canvas, Offset(x, y), isActive, theme, style);
      } else {
        // Les petits grains (Je vous salue Marie)
        _drawSmallBead(canvas, Offset(x, y), isActive, theme, style);
      }
    }
  }

  void _drawBackground(Canvas canvas, Offset center, double radius, RosaryTheme theme) {
    if (style == RosaryStyle.luxurious) {
      // Fond décoratif pour le style luxueux
      final bgPaint = Paint()
        ..color = theme.backgroundColor.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius + 5, bgPaint);

      // Contour décoratif
      final borderPaint = Paint()
        ..color = theme.crossColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius + 5, borderPaint);
    } else if (style == RosaryStyle.elegant) {
      // Fond subtil pour le style élégant
      final bgPaint = Paint()
        ..color = theme.backgroundColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius + 2, bgPaint);
    }
  }

  void _drawConnectingLine(Canvas canvas, Offset center, double radius,
      int index, double angleStep, double startAngle,
      RosaryTheme theme) {
    final angle = startAngle + (angleStep * index);
    final x = center.dx + radius * cos(angle);
    final y = center.dy + radius * sin(angle);

    final prevAngle = startAngle + (angleStep * (index - 1));
    final prevX = center.dx + radius * cos(prevAngle);
    final prevY = center.dy + radius * sin(prevAngle);

    final linePaint = Paint()
      ..color = theme.crossColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawLine(Offset(prevX, prevY), Offset(x, y), linePaint);
  }

  void _drawCross(Canvas canvas, Offset position, bool isActive,
      RosaryTheme theme, RosaryStyle style) {
    final color = theme.crossColor;

    switch (style) {
      case RosaryStyle.classic:
        _drawClassicCross(canvas, position, color);
        break;
      case RosaryStyle.elegant:
        _drawElegantCross(canvas, position, color);
        break;
      case RosaryStyle.minimalist:
        _drawMinimalistCross(canvas, position, color);
        break;
      case RosaryStyle.luxurious:
        _drawLuxuriousCross(canvas, position, color);
        break;
    }
  }

  void _drawClassicCross(Canvas canvas, Offset position, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

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

  void _drawElegantCross(Canvas canvas, Offset position, Color color) {
    // Dessiner une ombre pour effet 3D
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    canvas.drawLine(
      Offset(position.dx + 1, position.dy - 7),
      Offset(position.dx + 1, position.dy + 19),
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
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(position.dx, position.dy - 8),
      Offset(position.dx, position.dy + 18),
      paint,
    );
    canvas.drawLine(
      Offset(position.dx - 8, position.dy),
      Offset(position.dx + 8, position.dy),
      paint,
    );
  }

  void _drawMinimalistCross(Canvas canvas, Offset position, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Dessiner une croix plus simple et élégante
    canvas.drawLine(
      Offset(position.dx, position.dy - 8),
      Offset(position.dx, position.dy + 15),
      paint,
    );
    canvas.drawLine(
      Offset(position.dx - 6, position.dy),
      Offset(position.dx + 6, position.dy),
      paint,
    );
  }

  void _drawLuxuriousCross(Canvas canvas, Offset position, Color color) {
    // Ajouter une ombre pour la profondeur
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawLine(
      Offset(position.dx + 1.5, position.dy - 8),
      Offset(position.dx + 1.5, position.dy + 20),
      shadowPaint,
    );
    canvas.drawLine(
      Offset(position.dx - 8, position.dy + 1.5),
      Offset(position.dx + 15, position.dy + 1.5),
      shadowPaint,
    );

    // Créer un dégradé pour la croix
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color,
          Color.lerp(color, Colors.white, 0.3)!,
          color,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: position, radius: 15))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Dessiner la croix principale
    canvas.drawLine(
      Offset(position.dx, position.dy - 9),
      Offset(position.dx, position.dy + 18),
      gradientPaint,
    );
    canvas.drawLine(
      Offset(position.dx - 9, position.dy),
      Offset(position.dx + 9, position.dy),
      gradientPaint,
    );

    // Ajouter un halo autour de la croix
    final haloPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(position, 14, haloPaint);
  }

  void _drawLargeBead(Canvas canvas, Offset position, bool isActive,
      RosaryTheme theme, RosaryStyle style) {
    final color = isActive ? theme.activeColor : theme.inactiveColor;

    switch (style) {
      case RosaryStyle.classic:
        _drawClassicLargeBead(canvas, position, color);
        break;
      case RosaryStyle.elegant:
        _drawElegantLargeBead(canvas, position, color);
        break;
      case RosaryStyle.minimalist:
        _drawMinimalistLargeBead(canvas, position, color);
        break;
      case RosaryStyle.luxurious:
        _drawLuxuriousLargeBead(canvas, position, color);
        break;
    }
  }

  void _drawClassicLargeBead(Canvas canvas, Offset position, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 8, paint);
  }

  void _drawElegantLargeBead(Canvas canvas, Offset position, Color color) {
    // Dessiner l'ombre
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(Offset(position.dx + 1, position.dy + 1), 8, shadowPaint);

    // Dessiner le grain avec dégradé
    final rect = Rect.fromCircle(center: position, radius: 8);
    final gradient = RadialGradient(
      colors: [
        color.withValues(alpha: 0.9),
        color,
      ],
      center: Alignment.topLeft,
      radius: 1.2,
    );

    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 8, gradientPaint);

    // Ajouter une bordure légère
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawCircle(position, 8, borderPaint);

    // Ajouter un point de lumière (reflet)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(position.dx - 2, position.dy - 2), 2, highlightPaint);
  }

  void _drawMinimalistLargeBead(Canvas canvas, Offset position, Color color) {
    // Cercle extérieur (contour)
    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(position, 7, outlinePaint);

    // Cercle intérieur (remplissage léger)
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 6, fillPaint);
  }

  void _drawLuxuriousLargeBead(Canvas canvas, Offset position, Color color) {
    // Effet d'ombre
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(Offset(position.dx + 1.5, position.dy + 1.5), 9, shadowPaint);

    // Effet de perle avec dégradé radial
    final pearlPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(color, Colors.white, 0.4)!,
          color,
          Color.lerp(color, Colors.black, 0.2)!,
        ],
        stops: const [0.0, 0.5, 1.0],
        center: const Alignment(-0.3, -0.3),
        radius: 1.2,
      ).createShader(Rect.fromCircle(center: position, radius: 9));

    canvas.drawCircle(position, 9, pearlPaint);

    // Contour doré
    final borderPaint = Paint()
      ..color = Color.lerp(color, theme.crossColor, 0.3)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    canvas.drawCircle(position, 9, borderPaint);

    // Effet de reflet (highlight)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(position.dx - 3, position.dy - 3), 2.5, highlightPaint);
  }

  void _drawSmallBead(Canvas canvas, Offset position, bool isActive,
      RosaryTheme theme, RosaryStyle style) {
    final color = isActive ? theme.activeColor : theme.inactiveColor;

    switch (style) {
      case RosaryStyle.classic:
        _drawClassicSmallBead(canvas, position, color);
        break;
      case RosaryStyle.elegant:
        _drawElegantSmallBead(canvas, position, color);
        break;
      case RosaryStyle.minimalist:
        _drawMinimalistSmallBead(canvas, position, color);
        break;
      case RosaryStyle.luxurious:
        _drawLuxuriousSmallBead(canvas, position, color);
        break;
    }
  }

  void _drawClassicSmallBead(Canvas canvas, Offset position, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 4, paint);
  }

  void _drawElegantSmallBead(Canvas canvas, Offset position, Color color) {
    // Dessiner l'ombre
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(Offset(position.dx + 0.5, position.dy + 0.5), 4, shadowPaint);

    // Dessiner le grain avec dégradé
    final rect = Rect.fromCircle(center: position, radius: 4);
    final gradient = RadialGradient(
      colors: [
        color.withValues(alpha: 0.9),
        color,
      ],
      center: Alignment.topLeft,
      radius: 1.2,
    );

    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 4, gradientPaint);

    // Ajouter une bordure légère
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    canvas.drawCircle(position, 4, borderPaint);

    // Ajouter un point de lumière (reflet)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(position.dx - 1, position.dy - 1), 1, highlightPaint);
  }

  void _drawMinimalistSmallBead(Canvas canvas, Offset position, Color color) {
    // Pour les petits grains, juste un contour fin
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(position, 3.5, paint);

    // Petit point central
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 1.5, dotPaint);
  }

  void _drawLuxuriousSmallBead(Canvas canvas, Offset position, Color color) {
    // Effet d'ombre
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(Offset(position.dx + 1, position.dy + 1), 5, shadowPaint);

    // Effet de perle avec dégradé
    final pearlPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(color, Colors.white, 0.5)!,
          color,
          Color.lerp(color, Colors.black, 0.1)!,
        ],
        stops: const [0.0, 0.6, 1.0],
        center: const Alignment(-0.3, -0.3),
        radius: 1.2,
      ).createShader(Rect.fromCircle(center: position, radius: 5));

    canvas.drawCircle(position, 5, pearlPaint);

    // Léger contour
    final borderPaint = Paint()
      ..color = Color.lerp(color, theme.crossColor, 0.2)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawCircle(position, 5, borderPaint);

    // Petit reflet
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(position.dx - 1.5, position.dy - 1.5), 1.5, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant RosaryPainter oldDelegate) {
    return oldDelegate.activeBeadIndex != activeBeadIndex ||
        oldDelegate.style != style ||
        oldDelegate.colorTheme != colorTheme;
  }
}
