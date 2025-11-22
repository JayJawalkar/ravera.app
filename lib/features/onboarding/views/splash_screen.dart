// lib/features/splash/views/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:ravera/features/auth/service/auth_service.dart';
import 'package:ravera/features/auth/service/local_storage_service.dart';
import 'package:ravera/features/auth/views/login_screen.dart';
import 'package:ravera/features/home/views/home_screen_navigation.dart';
import 'package:ravera/features/onboarding/views/welcome_ob_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final localStorage = LocalStorageService();
    final isOnboardingCompleted = await localStorage.isOnboardingCompleted();

    // Use AuthService to check authentication
    final authService = AuthService();
    final isAuthenticated = await authService.isAuthenticated();

   

    Widget nextScreen;

    if (!isOnboardingCompleted) {
      // First time user - show onboarding
      nextScreen = const WelcomeObScreen();
    } else if (isAuthenticated) {
      // User is authenticated - go to home
      nextScreen = const HomeScreenNavigation();
    } else {
      // User needs to login
      nextScreen = const LoginScreen();
    }


    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo/ravera_logo.png', height: 100, width: 100),
            const SizedBox(height: 20),
            const Text(
              'Ravera',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.black),
          ],
        ),
      ),
    );
  }
}
