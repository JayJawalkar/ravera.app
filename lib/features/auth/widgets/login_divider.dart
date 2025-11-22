import 'package:flutter/material.dart';

class LoginDivider extends StatelessWidget {
  const LoginDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.black.withAlpha(22), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: TextStyle(color: Colors.black.withAlpha(167), fontSize: 14),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.black.withAlpha(22), thickness: 1),
        ),
      ],
    );
  }
}