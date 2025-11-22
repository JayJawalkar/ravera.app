import 'package:flutter/material.dart';

class SignUpLink extends StatelessWidget {
  final bool isSignUp;
  final VoidCallback onToggle;

  const SignUpLink({
    super.key,
    required this.isSignUp,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black54, fontSize: 14),
          children: [
            TextSpan(
              text: isSignUp
                  ? 'Already have an account? '
                  : 'Don\'t have an account? ',
            ),
            TextSpan(
              text: isSignUp ? 'Sign In' : 'Sign Up',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}