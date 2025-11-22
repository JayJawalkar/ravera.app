import 'package:flutter/material.dart';
import 'login_text_field.dart';
import 'login_button.dart';

class LoginForm extends StatelessWidget {
  final bool isSignUp;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  final VoidCallback onTogglePasswordVisibility;

  const LoginForm({
    super.key,
    required this.isSignUp,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onSignIn,
    required this.onSignUp,
    required this.onTogglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isSignUp ? _buildSignUpForm() : _buildSignInForm(),
    );
  }

  Widget _buildSignInForm() {
    return Column(
      key: const ValueKey('signin'),
      children: [
        // Email Field
        LoginTextField(
          controller: emailController,
          hintText: 'Email address',
          prefixIcon: Icons.email_outlined,
        ),

        const SizedBox(height: 16),

        // Password Field
        LoginTextField(
          controller: passwordController,
          hintText: 'Password',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          obscureText: obscurePassword,
          onToggleVisibility: onTogglePasswordVisibility,
        ),

        const SizedBox(height: 24),

        // Sign In Button
        LoginButton(
          text: 'Continue with Email',
          isLoading: isLoading,
          isSignUp: false,
          onPressed: onSignIn,
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      key: const ValueKey('signup'),
      children: [
        // Name Field
        LoginTextField(
          controller: nameController,
          hintText: 'Full name',
          prefixIcon: Icons.person_outline,
        ),

        const SizedBox(height: 16),

        // Email Field
        LoginTextField(
          controller: emailController,
          hintText: 'Email address',
          prefixIcon: Icons.email_outlined,
        ),

        const SizedBox(height: 16),

        // Password Field
        LoginTextField(
          controller: passwordController,
          hintText: 'Password',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          obscureText: obscurePassword,
          onToggleVisibility: onTogglePasswordVisibility,
        ),

        const SizedBox(height: 24),

        // Create Account Button
        LoginButton(
          text: 'Create Account',
          isLoading: isLoading,
          isSignUp: true,
          onPressed: onSignUp,
        ),
      ],
    );
  }
}