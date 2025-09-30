// terms_conditions_screen.dart
import 'package:flutter/material.dart';
import 'package:ravera/constants/image/image_constants.dart';
import 'package:ravera/constants/ui/blur_container.dart';
import 'package:ravera/features/onboarding/views/details_ob_screen.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
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
              left: -50,
              child: BlurContainer(
                height: 150,
                width: 150,
                blur: 20,
                bgColor: const Color(0xFFFFD700).withAlpha(20),
                radius: 75,
                child: const SizedBox(),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -30,
              child: BlurContainer(
                height: 120,
                width: 120,
                blur: 15,
                bgColor: const Color(0xFFFFFFFF).withAlpha(15),
                radius: 60,
                child: const SizedBox(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  BlurContainer(
                    height: height * 0.7,
                    width: double.infinity,
                    blur: 15,
                    bgColor: Colors.white.withAlpha(10),
                    radius: 20,
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            ImageConstants.notscam,
                            height: height * 0.25,
                            width: double.infinity,
                          ),
                          _buildSectionTitle('1. Account Terms'),
                          _buildSectionContent(
                            'By creating an account with Ravera, you agree to provide accurate and complete information. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
                          ),

                          const SizedBox(height: 20),
                          _buildSectionTitle('2. Financial Services'),
                          _buildSectionContent(
                            'Ravera provides micro-investment and savings services. All investments carry risk, and past performance is not indicative of future results. You should consider your financial situation and consult with a financial advisor before making investment decisions.',
                          ),

                          const SizedBox(height: 20),
                          _buildSectionTitle('3. Privacy & Data Security'),
                          _buildSectionContent(
                            'We are committed to protecting your personal and financial information. Your data is encrypted and stored securely. We comply with applicable data protection laws and regulations.',
                          ),

                          const SizedBox(height: 20),
                          _buildSectionTitle('4. Fees & Charges'),
                          _buildSectionContent(
                            'Ravera may charge fees for premium services as outlined in our pricing plan. All fees will be clearly disclosed before you incur any charges. We reserve the right to modify our fee structure with 30 days notice.',
                          ),

                          const SizedBox(height: 20),
                          _buildSectionTitle('5. Termination'),
                          _buildSectionContent(
                            'You may close your account at any time. We reserve the right to suspend or terminate accounts that violate our terms or engage in fraudulent activities.',
                          ),

                          const SizedBox(height: 20),
                          _buildSectionTitle('6. Regulatory Compliance'),
                          _buildSectionContent(
                            'Ravera operates in compliance with financial regulations in your jurisdiction. We partner with regulated financial institutions to provide banking and investment services.',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Decline',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DetailsObScreen(),
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
                            'Accept & Continue',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFFD700),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.6),
    );
  }
}
