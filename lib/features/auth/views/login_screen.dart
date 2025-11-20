// login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ravera/features/auth/bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  late TabController _tabController;
  bool _otpSent = false;
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Welcome to Fintech App'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Phone Login'),
            Tab(text: 'Email Login'),
          ],
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is AuthOtpSent) {
            setState(() => _otpSent = true);
            _showSnackBar('OTP sent successfully');
          }

          if (state is AuthFailure) {
            _showSnackBar(state.error);
          }

          if (state is RegistrationSuccess) {
            _showSnackBar(
              'Registration successful! Please check your email for verification.',
            );
            setState(() => _isSignUp = false);
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            // Phone Login Tab
            _buildPhoneLogin(),
            // Email Login Tab
            _buildEmailLogin(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneLogin() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_iphone, size: 60, color: Colors.blue[800]),
          const SizedBox(height: 20),
          const Text(
            'Login with Phone',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your phone number to receive OTP',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Phone Input
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '+91XXXXXXXXXX',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.black,
            ),
            keyboardType: TextInputType.phone,
            enabled: !_otpSent,
          ),
          const SizedBox(height: 20),

          // OTP Input (only show after OTP is sent)
          if (_otpSent) ...[
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                hintText: '6-digit code',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.black,
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 20),
          ],

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePhoneAuth,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _otpSent ? 'Verify OTP' : 'Send OTP',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),

          // Resend OTP option
          if (_otpSent) ...[
            const SizedBox(height: 20),
            TextButton(
              onPressed: _isLoading ? null : _resendOtp,
              child: const Text(
                'Resend OTP',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmailLogin() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email, size: 60, color: Colors.blue[800]),
            const SizedBox(height: 20),
            Text(
              _isSignUp ? 'Create Account' : 'Login with Email',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isSignUp
                  ? 'Create your account to get started'
                  : 'Enter your email and password to continue',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Name Field (only for signup)
            if (_isSignUp) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Email Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.black,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Password Field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.black,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Phone Field (only for signup)
            if (_isSignUp) ...[
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.black,
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
            ],

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleEmailAuth,
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _isSignUp ? 'Create Account' : 'Sign In',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),

            // Toggle between Sign In and Sign Up
            const SizedBox(height: 20),
            TextButton(
              onPressed: _isLoading ? null : _toggleSignUp,
              child: Text(
                _isSignUp
                    ? 'Already have an account? Sign In'
                    : 'Don\'t have an account? Sign Up',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePhoneAuth() {
    if (!_otpSent) {
      if (_phoneController.text.isEmpty) {
        _showSnackBar('Please enter your phone number');
        return;
      }
      context.read<AuthBloc>().add(AuthSendOtp(_phoneController.text));
    } else {
      if (_otpController.text.length != 6) {
        _showSnackBar('Please enter a valid 6-digit OTP');
        return;
      }
      context.read<AuthBloc>().add(
        AuthVerifyOtp(_phoneController.text, _otpController.text),
      );
    }
  }

  void _handleEmailAuth() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please fill all required fields');
      return;
    }

    if (_isSignUp) {
      if (_nameController.text.isEmpty) {
        _showSnackBar('Please enter your full name');
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
    } else {
      context.read<AuthBloc>().add(
        SignInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  void _resendOtp() {
    context.read<AuthBloc>().add(AuthSendOtp(_phoneController.text));
  }

  void _toggleSignUp() {
    setState(() {
      _isSignUp = !_isSignUp;
      // Clear fields when toggling
      if (!_isSignUp) {
        _nameController.clear();
      }
    });
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
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
