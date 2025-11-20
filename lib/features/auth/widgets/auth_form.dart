import 'package:flutter/material.dart';

/// A reusable authentication form widget for both Login and Sign Up.
///
/// Parameters:
/// - [controllers]: A list of TextEditingControllers in order:
///   - For Login: [emailController, passwordController]
///   - For Sign Up: [nameController, phoneController, emailController, passwordController]
/// - [isLogin]: Whether this form is for Login or Sign Up.
/// - [onSubmit]: Callback triggered when the user taps the submit button.
/// - [onForgotPassword]: Optional callback for forgot password.
class AuthForm extends StatefulWidget {
  final List<TextEditingController> controllers;
  final bool isLogin;
  final VoidCallback onSubmit;
  final VoidCallback? onForgotPassword;

  const AuthForm({
    super.key,
    required this.controllers,
    required this.isLogin,
    required this.onSubmit,
    this.onForgotPassword,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final controllers = widget.controllers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- NAME FIELD (Sign Up only) ----------
        if (!widget.isLogin) ...[
          _buildLabel('Full Name'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controllers[0],
            hintText: 'Enter your full name',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
        ],

        ///For signUp strucutre is name phone email password
        ///
        ///
        // ---------- PHONE FIELD (Sign Up only) ----------
        if (!widget.isLogin) ...[
          _buildLabel('Phone Number'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controllers[1],
            hintText: 'Enter your phone number',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
        ],

        // ---------- EMAIL FIELD ----------
        _buildLabel('Email'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: widget.isLogin ? controllers[0] : controllers[2],
          hintText: 'Enter your email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        // ---------- PASSWORD FIELD ----------
        _buildLabel('Password'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: widget.isLogin ? controllers[1] : controllers[3],
          hintText: 'Enter your password',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
        ),

        // ---------- REMEMBER ME + FORGOT PASSWORD ----------
        if (widget.isLogin) ...[
          const SizedBox(height: 16),
          _buildRememberAndForgot(),
        ],

        const SizedBox(height: 24),

        // ---------- SUBMIT BUTTON ----------
        _buildSubmitButton(),
      ],
    );
  }

  /// Label text for input fields
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Reusable styled text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(21),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(55)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon, color: Colors.white70),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  /// Row with Remember Me + Forgot Password
  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() => _rememberMe = value ?? false);
              },
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFFFD700);
                }
                return Colors.transparent;
              }),
              checkColor: Colors.black,
              side: const BorderSide(color: Colors.white70),
            ),
            const Text(
              'Remember me',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        TextButton(
          onPressed: widget.onForgotPassword,
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  /// Styled Submit button with gradient
  Widget _buildSubmitButton() {
    final buttonText = widget.isLogin ? 'LOG IN' : 'SIGN UP';
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFC400)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withAlpha(56),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextButton(
        onPressed: widget.onSubmit,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
