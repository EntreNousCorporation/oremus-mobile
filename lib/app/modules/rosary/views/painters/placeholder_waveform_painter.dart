import 'dart:math' as math;

import 'package:flutter/material.dart';

class PlaceholderWaveformPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  PlaceholderWaveformPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 30;
    const barWidth = 3.0;
    final spacing = (size.width - barCount * barWidth) / (barCount - 1);

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    for (int i = 0; i < barCount; i++) {
      // Créer un motif de hauteur variable pour simuler un waveform
      final fraction = i / barCount;
      final phase = (fraction * 2 * math.pi) + (progress * 2 * math.pi);
      final amplitude = (math.sin(phase).abs() * 0.8) + 0.2;

      final barHeight = size.height * amplitude * 0.7;
      final x = i * (barWidth + spacing) + barWidth / 2;
      final top = (size.height - barHeight) / 2;

      // Animation de couleur plus visible
      // Mélange entre inactiveColor et activeColor basé sur l'amplitude
      final color = Color.lerp(inactiveColor, activeColor, amplitude) ?? inactiveColor;
      paint.color = color;

      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PlaceholderWaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}