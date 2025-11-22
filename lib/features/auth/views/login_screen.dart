import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ravera/features/auth/bloc/auth_bloc.dart';
import 'package:ravera/features/auth/widgets/background_auth.dart';
import 'package:ravera/features/auth/widgets/google_signin_button.dart';
import 'package:ravera/features/auth/widgets/login_divider.dart';
import 'package:ravera/features/auth/widgets/login_form.dart';
import 'package:ravera/features/auth/widgets/login_header.dart';
import 'package:ravera/features/auth/widgets/sign_up_link.dart';
import 'package:ravera/features/home/views/home_screen_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  late AnimationController _waveController;
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _showRegistrationSuccess = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  void _handleRegistrationSuccess() {
    setState(() {
      _isLoading = false;
      _showRegistrationSuccess = true;
    });

    // Clear fields and switch to login after a brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _isSignUp = false;
          _showRegistrationSuccess = false;
        });
      }
    });

    _showSnackBar('🎉 Account created! Please sign in to continue.');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    // Use AuthBloc for sign in
    context.read<AuthBloc>().add(
      SignInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  void _handleSignUp() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    // Use AuthBloc for registration
    context.read<AuthBloc>().add(
      RegisterWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: '', // You can add phone field if needed
        fullName: _nameController.text,
      ),
    );
  }

  void _handleGoogleSignIn() {
    _showSnackBar('Google Sign In clicked');
    // Implement Google Sign In logic here
  }

  void _toggleSignUp() {
    setState(() {
      _isSignUp = !_isSignUp;
      // Clear fields when switching
      if (!_isSignUp) {
        _nameController.clear();
      }
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {

        if (state is AuthSuccess) {
          setState(() => _isLoading = false);

          // Navigate directly to home screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreenNavigation(),
              ),
            );
          });
        } else if (state is AuthFailure) {
          setState(() => _isLoading = false);
          _showSnackBar(state.error);
        } else if (state is RegistrationSuccess) {
          _handleRegistrationSuccess();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Subtle Wave Background
            LoginWaveBackground(waveController: _waveController),

            // Success overlay
            if (_showRegistrationSuccess)
              Container(
                color: Colors.black.withAlpha(187),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Account Created!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Redirecting to login...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),

            // Rest of your existing content
            if (!_showRegistrationSuccess)
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 40),
                                Image.asset(
                                  'assets/logo/ravera_logo.png',
                                  height: 120,
                                ),
                                const SizedBox(height: 20),

                                // Header with conditional message
                                Column(
                                  children: [
                                    LoginHeader(isSignUp: _isSignUp),
                                    if (_isSignUp)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          'Create your account to get started',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Login Form
                                LoginForm(
                                  isSignUp: _isSignUp,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  nameController: _nameController,
                                  obscurePassword: _obscurePassword,
                                  isLoading: _isLoading,
                                  onSignIn: _handleSignIn,
                                  onSignUp: _handleSignUp,
                                  onTogglePasswordVisibility:
                                      _togglePasswordVisibility,
                                ),

                                const SizedBox(height: 24),

                                // Divider
                                const LoginDivider(),

                                const SizedBox(height: 24),

                                // Google Sign In
                                GoogleSignInButton(
                                  onPressed: _handleGoogleSignIn,
                                ),

                                const SizedBox(height: 32),

                                // Sign Up Link
                                SignUpLink(
                                  isSignUp: _isSignUp,
                                  onToggle: _toggleSignUp,
                                ),

                                // Add flexible space to push content up
                                const Expanded(child: SizedBox()),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
