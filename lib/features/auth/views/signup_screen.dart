import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ravera/constants/ui/blur_container.dart';
import 'package:ravera/features/auth/bloc/auth_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Please fill all required fields');
      return;
    }

    context.read<AuthBloc>().add(
      RegisterWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.toLowerCase().contains('success')
            ? Colors.green
            : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is RegistrationSuccess) {
          _showSnackBar(
            'Registration successful! Please check your email for verification.',
          );
          // Optionally navigate to verification screen or home
          // Navigator.pushReplacementNamed(context, '/email-verification');
        }

        if (state is AuthFailure) {
          _showSnackBar(state.error);
        }

        if (state is AuthSuccess) {
          _showSnackBar('Registration completed successfully!');
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Blur Containers
            Positioned(
              top: -size.height * 0.1,
              left: -size.width * 0.1,
              child: BlurContainer(
                height: 200,
                width: 200,
                blur: 25,
                bgColor: const Color(0xFFFFD700).withAlpha(40),
                radius: 100,
                child: const SizedBox(),
              ),
            ),
            Positioned(
              bottom: -size.height * 0.15,
              right: -size.width * 0.1,
              child: BlurContainer(
                height: 250,
                width: 250,
                blur: 25,
                bgColor: const Color(0xFF2196F3).withAlpha(40),
                radius: 125,
                child: const SizedBox(),
              ),
            ),
            Positioned(
              top: size.height * 0.2,
              right: size.width * 0.2,
              child: BlurContainer(
                height: 100,
                width: 100,
                blur: 20,
                bgColor: const Color(0xFFE91E63).withAlpha(40),
                radius: 50,
                child: const SizedBox(),
              ),
            ),

            // Content
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.05),

                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_add_alt_1,
                            size: 60,
                            color: Colors.blue[800],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Create Your Account',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Join us and start your financial journey',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Sign Up Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: BlurContainer(
                        height: size.height * 0.55,
                        width: double.infinity,
                        blur: 20,
                        bgColor: Colors.white.withAlpha(23),
                        shadowColor: Colors.black.withAlpha(45),
                        radius: 20,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Name Field
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name *',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Email Field
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email Address *',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password *',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 16),

                            // Phone Field (Optional)
                            TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number (Optional)',
                                prefixIcon: const Icon(Icons.phone),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 24),

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Login Redirect
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
