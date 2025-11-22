import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  final bool isSignUp;

  const LoginHeader({
    super.key,
    required this.isSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isSignUp ? 'Create Account' : 'Welcome Back',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isSignUp
              ? 'Start your financial journey'
              : 'Sign in to continue your journey',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}