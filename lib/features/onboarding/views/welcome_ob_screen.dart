// welcome_ob_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:ravera/constants/constants.dart';
import 'package:ravera/features/onboarding/views/terms_and_conditions_screen.dart';

class WelcomeObScreen extends StatefulWidget {
  const WelcomeObScreen({super.key});

  @override
  State<WelcomeObScreen> createState() => _WelcomeObScreenState();
}

class _WelcomeObScreenState extends State<WelcomeObScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Wave Background
          _buildWaveBackground(),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Main Content
                  Container(
                    height: size.height * 0.42,
                    width: size.width * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(184),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black.withAlpha(22)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          ImageConstants.confused,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Welcome to Ravera',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your all-in-one fintech companion for smart savings, micro-investments, and financial growth. Start your journey to financial freedom today!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Features Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _FeatureChip(icon: Icons.savings, text: 'Smart Savings'),
                      _FeatureChip(
                        icon: Icons.trending_up,
                        text: 'Micro-Invest',
                      ),
                      _FeatureChip(
                        icon: Icons.auto_awesome,
                        text: 'Auto Round-up',
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Navigation Buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TermsAndConditionsScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBackground() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
          painter: OnboardingWavePainter(_waveController.value),
        );
      },
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(185),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha(22)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black, size: 24),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class OnboardingWavePainter extends CustomPainter {
  final double animationValue;

  OnboardingWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.black.withAlpha(22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final paint2 = Paint()
      ..color = Colors.black.withAlpha(8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paint3 = Paint()
      ..color = Colors.black.withAlpha(5)
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
  bool shouldRepaint(covariant OnboardingWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
