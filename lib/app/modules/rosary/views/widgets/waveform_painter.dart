import 'dart:typed_data';

import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final Uint8List waveform;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  WaveformPainter({
    required this.waveform,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sampleCount = waveform.length;
    final sampleWidth = size.width / sampleCount;
    final height = size.height;
    final centerY = height / 2;

    // Calculer l'index de progression
    final progressSampleIndex = (sampleCount * progress).floor();

    for (var i = 0; i < sampleCount; i++) {
      // Normaliser l'amplitude entre 0 et 1
      final amplitude = waveform[i] / 255;

      // Déterminer la hauteur de la barre
      final barHeight = amplitude * height * 0.8; // 80% de la hauteur totale

      // Calculer la position X
      final x = i * sampleWidth;

      // Déterminer la couleur en fonction de la progression
      final color = i <= progressSampleIndex ? activeColor : inactiveColor;

      // Dessiner la barre
      final paint = Paint()
        ..color = color
        ..strokeWidth = sampleWidth * 0.8 // Légèrement plus étroit que l'espace disponible
        ..strokeCap = StrokeCap.round;

      // Dessiner une ligne verticale centrée
      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveform != waveform;
  }
}
