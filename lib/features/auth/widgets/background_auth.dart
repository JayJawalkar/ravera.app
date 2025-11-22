import 'package:flutter/material.dart';
import 'dart:math';

class LoginWaveBackground extends StatelessWidget {
  final AnimationController waveController;

  const LoginWaveBackground({
    super.key,
    required this.waveController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: LoginWavePainter(waveController.value),
        );
      },
    );
  }
}

class LoginWavePainter extends CustomPainter {
  final double animationValue;

  LoginWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.black.withAlpha(55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paint2 = Paint()
      ..color = Colors.black.withAlpha(24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final paint3 = Paint()
      ..color = Colors.black.withAlpha(16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // First wave - subtle
    _drawWave(
      canvas,
      size,
      paint1,
      animationValue * 2 * pi,
      0.2,
      waveHeight: 25,
    );

    // Second wave - even more subtle
    _drawWave(
      canvas,
      size,
      paint2,
      -animationValue * 2 * pi,
      0.35,
      waveHeight: 20,
    );

    _drawWave(
      canvas,
      size,
      paint2,
      -animationValue * 2 * pi,
      0.5,
      waveHeight: 16,
    );

    _drawWave(
      canvas,
      size,
      paint3,
      -animationValue * 2 * pi,
      0.65,
      waveHeight: 40,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    Paint paint,
    double phase,
    double verticalPosition, {
    double waveHeight = 25,
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
  bool shouldRepaint(covariant LoginWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}