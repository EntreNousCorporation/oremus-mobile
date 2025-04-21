import 'dart:math';

import 'package:flutter/material.dart';

// Énumération des différents styles disponibles
enum RosaryStyle {
  classic,
  elegant,
  minimalist,
  modern,
  artistique,
  prestigieux,
}

// Énumération des différents thèmes de couleurs
enum RosaryColorTheme {
  original,
  monochrome,
  //aurora,
  serenity,
  amber,
  vegetal,
  contemporain,
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

  static const RosaryTheme contemporain = RosaryTheme(
    crossColor: Color(0xFF2D3047),
    activeColor: Color(0xFF5E60CE),
    inactiveColor: Color(0xFFE9ECEF),
    backgroundColor: Color(0xFFF8F9FA),
  );

  static RosaryTheme getTheme(RosaryColorTheme theme) {
    switch (theme) {
      case RosaryColorTheme.original:
        return original;
      case RosaryColorTheme.monochrome:
        return monochrome;
      /*case RosaryColorTheme.aurora:
        return aurora;*/
      case RosaryColorTheme.serenity:
        return serenity;
      case RosaryColorTheme.amber:
        return amber;
      case RosaryColorTheme.vegetal:
        return vegetal;
      case RosaryColorTheme.contemporain:
        return contemporain;
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
    if (style == RosaryStyle.elegant ||
        //style == RosaryStyle.luxurious ||
        style == RosaryStyle.modern ||
        style == RosaryStyle.artistique ||
        style == RosaryStyle.prestigieux) {
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

  void _drawBackground(
      Canvas canvas, Offset center, double radius, RosaryTheme theme) {
    if (style == RosaryStyle.elegant) {
      // Fond subtil pour le style élégant
      final bgPaint = Paint()
        ..color = theme.backgroundColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius + 2, bgPaint);
    } else if (style == RosaryStyle.modern) {
      // Fond moderne avec motif géométrique
      final bgPaint = Paint()
        ..color = theme.backgroundColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius + 2, bgPaint);

      // Ajouter une grille de points discrète
      final dotPaint = Paint()
        ..color = theme.crossColor.withValues(alpha: 0.05)
        ..style = PaintingStyle.fill;

      const dotSpacing = 20.0;
      final rect = Rect.fromCircle(center: center, radius: radius);

      for (double x = rect.left; x <= rect.right; x += dotSpacing) {
        for (double y = rect.top; y <= rect.bottom; y += dotSpacing) {
          final dotPos = Offset(x, y);
          // Ne dessiner que les points à l'intérieur du cercle
          if ((dotPos - center).distance <= radius) {
            canvas.drawCircle(dotPos, 1, dotPaint);
          }
        }
      }
    } else if (style == RosaryStyle.artistique) {
      // Fond artistique avec texture légère
      final bgPaint = Paint()
        ..color = theme.backgroundColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius + 2, bgPaint);

      // Ajouter un effet de "papier texturé" avec des points aléatoires très subtils
      final Random random = Random(42); // Seed fixe pour consistance
      final dotPaint = Paint()
        ..color = theme.crossColor.withValues(alpha: 0.03)
        ..style = PaintingStyle.fill;

      // Dessiner de petits points aléatoires pour simuler la texture du papier
      for (int i = 0; i < 200; i++) {
        final angle = random.nextDouble() * 2 * pi;
        final distance = random.nextDouble() * radius;
        final x = center.dx + cos(angle) * distance;
        final y = center.dy + sin(angle) * distance;

        final dotSize =
            random.nextDouble() * 0.8 + 0.2; // Points entre 0.2 et 1.0
        canvas.drawCircle(Offset(x, y), dotSize, dotPaint);
      }

      // Ajouter quelques traits fins et subtils
      final linePaint = Paint()
        ..color = theme.crossColor.withValues(alpha: 0.04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;

      for (int i = 0; i < 8; i++) {
        final angle = random.nextDouble() * 2 * pi;
        final startDistance = random.nextDouble() * radius * 0.4 + radius * 0.4;
        final endDistance = startDistance + random.nextDouble() * radius * 0.2;

        final startX = center.dx + cos(angle) * startDistance;
        final startY = center.dy + sin(angle) * startDistance;
        final endX = center.dx + cos(angle) * endDistance;
        final endY = center.dy + sin(angle) * endDistance;

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
      }
    } else if (style == RosaryStyle.prestigieux) {
      // Fond prestigieux avec motif subtil de damassé
      final bgPaint = Paint()
        ..color = Color.lerp(theme.backgroundColor, Colors.white, 0.7)!
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius + 5, bgPaint);

      // Ajouter un contour élégant
      final outlinePaint = Paint()
        ..color = Color.lerp(Colors.amber[800]!, Colors.white, 0.6)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      canvas.drawCircle(center, radius + 5, outlinePaint);

      // Ajouter un motif de damassé subtil
      final patternPaint = Paint()
        ..color = theme.crossColor.withValues(alpha: 0.04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.3;

      // Dessiner des motifs répétitifs et élégants
      for (int i = 0; i < 12; i++) {
        final angle = (i * pi / 6);
        final startX = center.dx + (radius * 0.6) * cos(angle);
        final startY = center.dy + (radius * 0.6) * sin(angle);

        // Dessiner des ornements floraux stylisés
        final ovalRect = Rect.fromCenter(
            center: Offset(startX, startY),
            width: radius * 0.4,
            height: radius * 0.2);

        canvas.drawOval(ovalRect, patternPaint);

        // Rotation de 90 degrés
        final ovalRect2 = Rect.fromCenter(
            center: Offset(startX, startY),
            width: radius * 0.2,
            height: radius * 0.4);

        canvas.drawOval(ovalRect2, patternPaint);
      }

      // Ajouter un léger halo lumineux
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(center, radius * 0.7, glowPaint);
    }
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
      case RosaryStyle.modern:
        _drawModernCross(canvas, position, color);
        break;
      case RosaryStyle.artistique:
        _drawArtistiqueCross(canvas, position, color);
        break;
      case RosaryStyle.prestigieux:
        _drawPrestigieuxCross(canvas, position, color);
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

  void _drawModernCross(Canvas canvas, Offset position, Color color) {
    // Dessiner une croix avec des lignes épurées et un style géométrique
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    // Ligne verticale avec un petit espace au milieu
    canvas.drawLine(
      Offset(position.dx, position.dy - 6),
      Offset(position.dx, position.dy - 2),
      paint,
    );

    canvas.drawLine(
      Offset(position.dx, position.dy + 2),
      Offset(position.dx, position.dy + 15),
      paint,
    );

    // Ligne horizontale
    canvas.drawLine(
      Offset(position.dx - 6, position.dy),
      Offset(position.dx + 6, position.dy),
      paint,
    );

    // Contour carré autour de la croix
    canvas.drawRect(
      Rect.fromCenter(center: position, width: 20, height: 30),
      paint,
    );
  }

  void _drawArtistiqueCross(Canvas canvas, Offset position, Color color) {
    // Utiliser un style de trait qui ressemble à un dessin à main levée
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Créer un chemin pour dessiner une croix légèrement irrégulière
    final path = Path();

    // Ligne verticale légèrement irrégulière
    path.moveTo(position.dx - 0.5, position.dy - 10);
    path.cubicTo(
        position.dx + 0.5,
        position.dy - 6, // point de contrôle 1
        position.dx - 0.5,
        position.dy - 2, // point de contrôle 2
        position.dx,
        position.dy + 2 // point final
        );
    path.cubicTo(
        position.dx + 0.5,
        position.dy + 6, // point de contrôle 1
        position.dx - 0.5,
        position.dy + 10, // point de contrôle 2
        position.dx,
        position.dy + 16 // point final
        );

    // Ligne horizontale légèrement irrégulière
    path.moveTo(position.dx - 8, position.dy + 0.5);
    path.cubicTo(
        position.dx - 4,
        position.dy - 0.5, // point de contrôle 1
        position.dx,
        position.dy + 0.5, // point de contrôle 2
        position.dx + 4,
        position.dy - 0.3 // point final
        );
    path.cubicTo(
        position.dx + 6,
        position.dy + 0.5, // point de contrôle 1
        position.dx + 7,
        position.dy - 0.5, // point de contrôle 2
        position.dx + 8,
        position.dy // point final
        );

    // Dessiner le chemin
    canvas.drawPath(path, paint);

    // Ajouter quelques petits traits décoratifs
    final detailPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    // Quelques petits traits autour de la croix pour un effet artistique
    canvas.drawLine(Offset(position.dx + 3, position.dy - 8),
        Offset(position.dx + 5, position.dy - 6), detailPaint);

    canvas.drawLine(Offset(position.dx - 5, position.dy + 6),
        Offset(position.dx - 3, position.dy + 8), detailPaint);
  }

  void _drawPrestigieuxCross(Canvas canvas, Offset position, Color color) {
    // Créer un dégradé subtil pour la croix
    final baseColor = color;
    final accentColor = Color.lerp(baseColor, Colors.white, 0.4)!;
    final darkAccent = Color.lerp(baseColor, Colors.black, 0.3)!;

    // Effet d'ombre douce
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

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

    // Dessiner la partie verticale de la croix avec un dégradé élaboré
    final verticalRect = Rect.fromPoints(
      Offset(position.dx - 2, position.dy - 10),
      Offset(position.dx + 2, position.dy + 20),
    );

    final verticalGradient = LinearGradient(
      colors: [accentColor, baseColor, accentColor, baseColor, accentColor],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final verticalPaint = Paint()
      ..shader = verticalGradient.createShader(verticalRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Partie verticale avec extrémités légèrement évasées
    final verticalPath = Path();
    verticalPath.moveTo(position.dx, position.dy - 10);
    verticalPath.lineTo(position.dx, position.dy - 1);
    verticalPath.moveTo(position.dx, position.dy + 1);
    verticalPath.lineTo(position.dx, position.dy + 20);

    canvas.drawPath(verticalPath, verticalPaint);

    // Dessiner la partie horizontale avec un dégradé différent
    final horizontalRect = Rect.fromPoints(
      Offset(position.dx - 10, position.dy - 2),
      Offset(position.dx + 10, position.dy + 2),
    );

    final horizontalGradient = LinearGradient(
      colors: [accentColor, baseColor, accentColor, baseColor, accentColor],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final horizontalPaint = Paint()
      ..shader = horizontalGradient.createShader(horizontalRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Partie horizontale avec extrémités ornées
    canvas.drawLine(
      Offset(position.dx - 10, position.dy),
      Offset(position.dx + 10, position.dy),
      horizontalPaint,
    );

    // Ajouter des détails ornementaux aux extrémités de la croix
    final detailPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // Petits ornements aux extrémités
    canvas.drawCircle(Offset(position.dx, position.dy - 10), 1.5, detailPaint);
    canvas.drawCircle(Offset(position.dx, position.dy + 20), 1.5, detailPaint);
    canvas.drawCircle(Offset(position.dx - 10, position.dy), 1.5, detailPaint);
    canvas.drawCircle(Offset(position.dx + 10, position.dy), 1.5, detailPaint);

    // Ajouter un point central orné où les lignes se croisent
    final centerPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 2.5, centerPaint);

    final centerOutlinePaint = Paint()
      ..color = darkAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawCircle(position, 2.5, centerOutlinePaint);

    // Point de lumière pour effet de brillance
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(position.dx - 0.8, position.dy - 0.8), 1.0, highlightPaint);
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
      case RosaryStyle.modern:
        _drawModernLargeBead(canvas, position, color);
        break;
      case RosaryStyle.artistique:
        _drawArtistiqueLargeBead(canvas, position, color);
        break;
      case RosaryStyle.prestigieux:
        _drawPrestigieuxLargeBead(canvas, position, color);
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

    canvas.drawCircle(
        Offset(position.dx - 2, position.dy - 2), 2, highlightPaint);
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

  void _drawModernLargeBead(Canvas canvas, Offset position, Color color) {
    // Utiliser une forme carrée avec des coins arrondis pour un look moderne
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Dessiner un carré avec coins arrondis
    final rect = Rect.fromCenter(center: position, width: 14, height: 14);
    const radius = Radius.circular(4);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, borderPaint);

    // Détail géométrique interne
    final innerPaint = Paint()
      ..color = Color.lerp(color, Colors.white, 0.3)!
      ..style = PaintingStyle.fill;

    final innerRect = Rect.fromCenter(center: position, width: 6, height: 6);
    canvas.drawRect(innerRect, innerPaint);
  }

  void _drawArtistiqueLargeBead(Canvas canvas, Offset position, Color color) {
    // Utiliser un style de trait irrégulier pour l'aspect dessiné à main
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Créer un chemin pour dessiner un cercle imparfait
    final path = Path();
    const radius = 8.0;

    // Un cercle légèrement irrégulier avec 8 points de contrôle
    path.moveTo(position.dx + radius, position.dy);

    // Premier arc (haut-droite)
    path.cubicTo(
        position.dx + radius,
        position.dy - radius * 0.4,
        position.dx + radius * 0.8,
        position.dy - radius,
        position.dx,
        position.dy - radius * 1.1);

    // Deuxième arc (haut-gauche)
    path.cubicTo(
        position.dx - radius * 0.8,
        position.dy - radius,
        position.dx - radius,
        position.dy - radius * 0.4,
        position.dx - radius * 0.9,
        position.dy);

    // Troisième arc (bas-gauche)
    path.cubicTo(
        position.dx - radius,
        position.dy + radius * 0.4,
        position.dx - radius * 0.8,
        position.dy + radius,
        position.dx,
        position.dy + radius * 1.05);

    // Quatrième arc (bas-droite)
    path.cubicTo(
        position.dx + radius * 0.8,
        position.dy + radius,
        position.dx + radius,
        position.dy + radius * 0.4,
        position.dx + radius,
        position.dy);

    // Dessiner le remplissage et le contour
    canvas.drawPath(path, paint);
    canvas.drawPath(path, outlinePaint);

    // Ajouter quelques effets de texture
    final detailPaint = Paint()
      ..color = Color.lerp(color, Colors.white, 0.3)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    // Quelques lignes courbes aléatoires à l'intérieur pour donner de la texture
    final detailPath = Path();
    detailPath.moveTo(position.dx - 3, position.dy - 1);
    detailPath.quadraticBezierTo(
        position.dx, position.dy - 3, position.dx + 3, position.dy);
    detailPath.quadraticBezierTo(
        position.dx + 1, position.dy + 2, position.dx - 2, position.dy + 1);

    canvas.drawPath(detailPath, detailPaint);
  }

  void _drawPrestigieuxLargeBead(Canvas canvas, Offset position, Color color) {
    // Effet d'ombre pour la profondeur
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(
        Offset(position.dx + 1.5, position.dy + 1.5), 9, shadowPaint);

    // Créer un aspect légèrement ovale pour plus d'élégance
    final rect = Rect.fromCenter(
      center: position,
      width: 18,
      height: 17, // Légèrement plus petit verticalement pour effet ovale subtil
    );

    // Créer un dégradé radial complexe pour imiter une perle ou pierre précieuse
    final pearlGradient = RadialGradient(
      colors: [
        Color.lerp(color, Colors.white, 0.6)!,
        Color.lerp(color, Colors.white, 0.3)!,
        color,
        Color.lerp(color, Colors.black, 0.2)!,
        Color.lerp(color, Colors.black, 0.1)!,
      ],
      stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
      center: const Alignment(-0.2, -0.2),
      focal: const Alignment(-0.5, -0.5),
      focalRadius: 0.2,
      radius: 1.0,
    );

    final pearlPaint = Paint()..shader = pearlGradient.createShader(rect);

    canvas.drawOval(rect, pearlPaint);

    // Ajouter un contour subtil en or ou argent
    final borderColor = Color.lerp(Colors.amber[800]!, Colors.white, 0.3)!;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    canvas.drawOval(rect, borderPaint);

    // Ajouter des reflets pour simuler des facettes
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    // Reflet principal
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(position.dx - 3, position.dy - 3),
        width: 6,
        height: 5,
      ),
      highlightPaint, //.withValues(alpha: 0.7),
    );

    // Reflets secondaires (facettes)
    canvas.drawCircle(
      Offset(position.dx + 3, position.dy - 1),
      1.2,
      highlightPaint, //.withValues(alpha: 0.5),
    );
    canvas.drawCircle(
      Offset(position.dx - 2, position.dy + 4),
      1.0,
      highlightPaint, //.withValues(alpha: 0.4),
    );

    // Détails supplémentaires - petites lignes pour suggérer des facettes
    final facetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawArc(
      Rect.fromCenter(center: position, width: 12, height: 11),
      pi / 6,
      pi / 3,
      false,
      facetPaint,
    );

    canvas.drawArc(
      Rect.fromCenter(center: position, width: 14, height: 13),
      pi + pi / 6,
      pi / 3,
      false,
      facetPaint,
    );
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
      case RosaryStyle.modern:
        _drawModernSmallBead(canvas, position, color);
        break;
      case RosaryStyle.artistique:
        _drawArtistiqueSmallBead(canvas, position, color);
        break;
      case RosaryStyle.prestigieux:
        _drawPrestigieuxSmallBead(canvas, position, color);
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

    canvas.drawCircle(
        Offset(position.dx + 0.5, position.dy + 0.5), 4, shadowPaint);

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

    canvas.drawCircle(
        Offset(position.dx - 1, position.dy - 1), 1, highlightPaint);
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

  void _drawModernSmallBead(Canvas canvas, Offset position, Color color) {
    // Utiliser une forme de losange pour un look moderne et géométrique
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Créer un losange
    final path = Path();
    path.moveTo(position.dx, position.dy - 5); // Haut
    path.lineTo(position.dx + 5, position.dy); // Droite
    path.lineTo(position.dx, position.dy + 5); // Bas
    path.lineTo(position.dx - 5, position.dy); // Gauche
    path.close();

    canvas.drawPath(path, paint);

    // Contour fin
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawPath(path, borderPaint);
  }

  void _drawArtistiqueSmallBead(Canvas canvas, Offset position, Color color) {
    // Pour les petits grains, utilisez un style de trait fin et irrégulier
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Créer un chemin pour dessiner un petit grain de forme organique
    final path = Path();
    const radius = 3.5;

    // Dessiner une forme un peu comme une goutte d'eau
    path.moveTo(position.dx, position.dy - radius);
    path.cubicTo(
        position.dx + radius * 1.2,
        position.dy - radius * 0.5,
        position.dx + radius * 1.2,
        position.dy + radius * 0.5,
        position.dx,
        position.dy + radius);
    path.cubicTo(
        position.dx - radius * 1.2,
        position.dy + radius * 0.5,
        position.dx - radius * 1.2,
        position.dy - radius * 0.5,
        position.dx,
        position.dy - radius);

    // Dessiner le grain
    canvas.drawPath(path, paint);

    // Ajouter un détail
    final detailPaint = Paint()
      ..color = Color.lerp(color, Colors.white, 0.4)!
      ..style = PaintingStyle.fill;

    // Un petit point lumineux pour donner de la dimension
    canvas.drawCircle(Offset(position.dx - 0.8, position.dy - 0.8), 1.0, detailPaint);
  }

  void _drawPrestigieuxSmallBead(Canvas canvas, Offset position, Color color) {
    // Ombre légère pour la profondeur
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(Offset(position.dx + 1, position.dy + 1), 5, shadowPaint);

    // Dessiner une forme hexagonale pour simuler une pierre taillée
    final path = Path();
    const radius = 4.5;

    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3) +
          (pi /
              6); // Rotation de 30 degrés pour un hexagone orienté verticalement
      final x = position.dx + radius * cos(angle);
      final y = position.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Créer un dégradé pour la pierre taillée
    final rect = Rect.fromCenter(
        center: position, width: radius * 2.5, height: radius * 2.5);
    final gemGradient = RadialGradient(
      colors: [
        Color.lerp(color, Colors.white, 0.5)!,
        color,
        Color.lerp(color, Colors.black, 0.2)!,
      ],
      stops: const [0.0, 0.6, 1.0],
      center: const Alignment(-0.3, -0.3),
      radius: 1.0,
    );

    final gemPaint = Paint()..shader = gemGradient.createShader(rect);

    canvas.drawPath(path, gemPaint);

    // Ajouter un contour d'or fin
    final borderColor = Color.lerp(Colors.amber[800]!, Colors.white, 0.3)!;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawPath(path, borderPaint);

    // Ajouter un reflet pour effet brillant
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Petit triangle de lumière en haut à gauche
    final highlightPath = Path();
    highlightPath.moveTo(position.dx - 1, position.dy - 1);
    highlightPath.lineTo(position.dx - 2, position.dy - 2);
    highlightPath.lineTo(position.dx, position.dy - 2);
    highlightPath.close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant RosaryPainter oldDelegate) {
    return oldDelegate.activeBeadIndex != activeBeadIndex ||
        oldDelegate.style != style ||
        oldDelegate.colorTheme != colorTheme;
  }
}
