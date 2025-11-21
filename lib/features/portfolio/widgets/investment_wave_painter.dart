import 'dart:math';

import 'package:flutter/material.dart';

class InvestmentsWavePainter extends CustomPainter {
  final double animationValue;

  InvestmentsWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final paint2 = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paint3 = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // First wave - slow
    _drawWave(
      canvas,
      size,
      paint1,
      animationValue * 2 * pi,
      0.15,
      waveHeight: 40,
    );

    // Second wave - medium
    _drawWave(
      canvas,
      size,
      paint2,
      -animationValue * 2 * pi,
      0.3,
      waveHeight: 30,
    );

    // Third wave - fast
    _drawWave(
      canvas,
      size,
      paint3,
      animationValue * 4 * pi,
      0.45,
      waveHeight: 50,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    Paint paint,
    double phase,
    double verticalPosition, {
    double waveHeight = 40,
  }) {
    final path = Path();
    final baseY = size.height * verticalPosition;

    path.moveTo(0, baseY);

    for (double x = 0; x <= size.width; x += 5) {
      final y = baseY + sin((x / size.width * 4 * pi) + phase) * waveHeight;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant InvestmentsWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
