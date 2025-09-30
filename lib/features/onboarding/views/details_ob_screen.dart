// details_screen.dart
import 'package:flutter/material.dart';
import 'package:ravera/constants/constants.dart';

class DetailsObScreen extends StatelessWidget {
  const DetailsObScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F0F), Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
          ),
        ),
        child: Stack(
          children: [
            // Background elements
            Positioned(
              top: 100,
              left: -30,
              child: BlurContainer(
                height: 120,
                width: 120,
                blur: 20,
                bgColor: const Color(0xFFFFD700).withAlpha(15),
                radius: 60,
                child: const SizedBox(),
              ),
            ),
            Positioned(
              top: 200,
              right: -40,
              child: BlurContainer(
                height: 100,
                width: 100,
                blur: 15,
                bgColor: const Color(0xFFFFD700).withAlpha(25),
                radius: 50,
                child: const SizedBox(),
              ),
            ),
            Positioned(
              bottom: 150,
              left: -20,
              child: BlurContainer(
                height: 80,
                width: 80,
                blur: 12,
                bgColor: const Color(0xFFFFFFFF).withAlpha(15),
                radius: 40,
                child: const SizedBox(),
              ),
            ),
            Positioned(
              bottom: 300,
              right: -10,
              child: BlurContainer(
                height: 60,
                width: 60,
                blur: 10,
                bgColor: const Color(0xFFFFD700).withAlpha(20),
                radius: 30,
                child: const SizedBox(),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(height: height * 0.06),

                  // App Title Section
                  BlurContainer(
                    height: height * 0.25,
                    width: double.infinity,
                    blur: 15,
                    bgColor: Colors.white.withAlpha(12),
                    radius: 20,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          ImageConstants.selfhelp,
                          height: 100,
                          width: 100,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ravera - Smart Savings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Micro-investments made effortless',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Core Features Section
                  BlurContainer(
                    height: height * 0.46,
                    width: double.infinity,
                    blur: 15,
                    bgColor: Colors.white.withAlpha(10),
                    radius: 20,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What We Do For You',
                          style: TextStyle(
                            color: Colors.white,
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
                          accentColor: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(height: 12),

                        _buildFeatureItem(
                          icon: Icons.trending_up,
                          title: 'Micro-Investments',
                          subtitle:
                              'Turn your small savings into diversified investments starting from just ₹10',
                          accentColor: const Color(0xFF2196F3),
                        ),
                        const SizedBox(height: 12),

                        _buildFeatureItem(
                          icon: Icons.psychology,
                          title: 'Smart Goal Setting',
                          subtitle:
                              'AI-powered recommendations help you set and achieve realistic financial goals',
                          accentColor: const Color(0xFF9C27B0),
                        ),
                        const SizedBox(height: 12),

                        _buildFeatureItem(
                          icon: Icons.security,
                          title: 'Bank-Grade Security',
                          subtitle:
                              'Your money is protected with encryption and regulatory compliance',
                          accentColor: const Color(0xFFFF5722),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Benefits Section
                  BlurContainer(
                    height: height * 0.3,
                    width: double.infinity,
                    blur: 10,
                    bgColor: const Color(0xFFFFD700).withAlpha(15),
                    radius: 16,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_outline,
                              color: const Color(0xFFFFD700),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Why Choose Ravera?',
                              style: TextStyle(
                                color: Colors.white,
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
                            color: Colors.white70,
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
                        child: BlurContainer(
                          height: 80,
                          width: double.infinity,
                          blur: 8,
                          bgColor: Colors.white.withAlpha(8),
                          radius: 12,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '₹2,500',
                                style: TextStyle(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Avg Monthly\nSavings',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BlurContainer(
                          height: 80,
                          width: double.infinity,
                          blur: 8,
                          bgColor: Colors.white.withAlpha(8),
                          radius: 12,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '12%',
                                style: TextStyle(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Average\nReturns',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BlurContainer(
                          height: 80,
                          width: double.infinity,
                          blur: 8,
                          bgColor: Colors.white.withAlpha(8),
                          radius: 12,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '50K+',
                                style: TextStyle(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Happy\nUsers',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
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
                      onPressed: () {
                        // Handle getting started
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
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
          ],
        ),
      ),
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
        BlurContainer(
          height: 45,
          width: 45,
          blur: 8,
          bgColor: accentColor.withAlpha(20),
          radius: 12,
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
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white70,
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
