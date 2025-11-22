// details_screen.dart
import 'package:flutter/material.dart';
import 'package:ravera/constants/constants.dart';
import 'package:ravera/features/auth/service/local_storage_service.dart';
import 'package:ravera/features/auth/views/login_screen.dart';
import 'package:ravera/features/onboarding/views/welcome_ob_screen.dart';

class DetailsObScreen extends StatefulWidget {
  const DetailsObScreen({super.key});

  @override
  State<DetailsObScreen> createState() => _DetailsObScreenState();
}

class _DetailsObScreenState extends State<DetailsObScreen>
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
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Wave Background
          _buildWaveBackground(),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(height: height * 0.06),

                  // App Title Section
                  Container(
                    height: height * 0.25,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(178),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withAlpha(22)),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          ImageConstants.selfhelp,
                          height: 90,
                          width: 90,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ravera - Smart Savings',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Micro-investments made effortless',
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Core Features Section
                  Container(
                    height: height * 0.46,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(187),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withAlpha(22)),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What We Do For You',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildFeatureItem(
                          icon: Icons.autorenew,
                          title: 'Automated Round-Ups',
                          subtitle:
                              'Every purchase automatically rounds up and saves the spare change for your future',
                          accentColor: Colors.green,
                        ),
                        const SizedBox(height: 12),

                        _buildFeatureItem(
                          icon: Icons.trending_up,
                          title: 'Micro-Investments',
                          subtitle:
                              'Turn your small savings into diversified investments starting from just ₹10',
                          accentColor: Colors.blue,
                        ),
                        const SizedBox(height: 12),

                        _buildFeatureItem(
                          icon: Icons.psychology,
                          title: 'Smart Goal Setting',
                          subtitle:
                              'AI-powered recommendations help you set and achieve realistic financial goals',
                          accentColor: Colors.purple,
                        ),
                        const SizedBox(height: 12),

                        _buildFeatureItem(
                          icon: Icons.security,
                          title: 'Bank-Grade Security',
                          subtitle:
                              'Your money is protected with encryption and regulatory compliance',
                          accentColor: Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Benefits Section
                  Container(
                    height: height * 0.3,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withAlpha(22)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_outline,
                              color: Colors.black,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Why Choose Ravera?',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Build wealth effortlessly without changing your spending habits\n'
                          '• Start with any amount - no minimum balance required\n'
                          '• Gamified experience with rewards and achievement badges\n'
                          '• Emergency fund access when you need it most',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Success Stats Section
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(185),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black.withAlpha(22),
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '₹2,500',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Avg Monthly\nSavings',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(187),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black.withAlpha(22),
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '12%',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Average\nReturns',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(185),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black.withAlpha(22),
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '50K+',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Happy\nUsers',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Async call
                        await LocalStorageService().setOnboardingCompleted();

                        // Check if the widget is still mounted after async gap
                        if (!context.mounted) return;

                        // Now it's safe to use context
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start Saving Today',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
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

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: accentColor.withAlpha(22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withAlpha(22)),
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
