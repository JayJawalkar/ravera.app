
  import 'package:flutter/material.dart';
import 'package:ravera/constants/ui/blur_container.dart';

Widget buildSocialLogin() {
    return Column(
      children: [
        Text('Or continue with', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(icon: Icons.g_mobiledata, onTap: () {}),
            const SizedBox(width: 20),
            _buildSocialButton(icon: Icons.facebook, onTap: () {}),
            const SizedBox(width: 20),
            _buildSocialButton(icon: Icons.apple, onTap: () {}),
          ],
        ),
      ],
    );
  }

  
  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: BlurContainer(
        height: 50,
        width: 50,
        blur: 10,
        bgColor: Colors.white.withAlpha(22),
        radius: 25,
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
