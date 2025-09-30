// welcome_ob_screen.dart
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:ravera/constants/constants.dart';
import 'package:ravera/features/onboarding/views/terms_and_conditions_screen.dart';

class WelcomeObScreen extends StatelessWidget {
  const WelcomeObScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
            // Background decorative elements
            Positioned(
              top: -50,
              right: -30,
              child: BlurContainer(
                height: 200,
                width: 200,
                blur: 25,
                bgColor: const Color(0xFFFFD700).withAlpha(30),
                radius: 100,
                child: const SizedBox(),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -40,
              child: BlurContainer(
                height: 250,
                width: 250,
                blur: 20,
                bgColor: const Color(0xFFFFFFFF).withAlpha(20),
                radius: 125,
                child: const SizedBox(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
 
                  // Main Content
                  BlurContainer(
                    height: size.height * 0.42,
                    width: size.width * 0.85,
                    blur: 15,
                    bgColor: Colors.white.withAlpha(15),
                    shadowColor: Colors.black.withAlpha(100),
                    radius: 24,
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
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your all-in-one fintech companion for smart savings, micro-investments, and financial growth. Start your journey to financial freedom today!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
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
                        ).blurry(blur: 3, color: Colors.transparent),
                      ),
                    ],
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return BlurContainer(
      height: 80,
      width: 80,
      blur: 10,
      bgColor: Colors.white.withAlpha(10),
      radius: 16,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 24),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white70,
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
