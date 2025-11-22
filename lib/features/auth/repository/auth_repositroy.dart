import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositroy {
  final _supabase = Supabase.instance.client;
  static const Duration _operationTimeout = Duration(seconds: 24);

  Future<dynamic> registerUser({
    required String email,
    required String password,
    required String phoneNumber,
    required String fullName,
  }) async {
    AuthResponse? response;
    try {
      response = await _supabase.auth.signUp(
        password: password,
        email: email,
        data: {'phone': phoneNumber, 'fullName': fullName},
      );

      if (response.user == null) {
        throw Exception('Registration failed');
      }

      await Future.delayed(const Duration(seconds: 2));

      bool profileCreated = false;
      int retryCount = 0;
      const maxRetries = 3;

      while (!profileCreated && retryCount < maxRetries) {
        try {
          await createUserProfile(
            userId: response.user!.id,
            email: email,
            phoneNumber: phoneNumber,
            fullName: fullName,
          );
          profileCreated = true;
        } catch (e) {
          retryCount++;
          if (retryCount < maxRetries) {
            Future.delayed(const Duration(seconds: 2));
          } else {}
        }
      }
    } catch (e) {
      throw Exception('Failes to register $e');
    }
  }

  Future<dynamic> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final resposne = await _supabase.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (resposne.user == null) {
        throw Exception('Sign in failed');
      }
    } catch (e) {
      e.toString();
    }
  }

  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String phoneNumber,
    required String fullName,
  }) async {
    try {
      final result = await _supabase
          .rpc(
            'create_user_profile',
            params: {
              'p_user_id': userId,
              'p_email': email,
              'p_phone': phoneNumber,
              'p_full_name': fullName,
            },
          )
          .timeout(_operationTimeout);

      if (result == null || (result is Map && result['status'] == 'error')) {
        throw Exception(
          'Failed to create profile AUTH REPO LINE 57 ${result?['message']}',
        );
      }
    } catch (e) {
      e.toString();
    }
  }

  Future<dynamic> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      e.toString();
    }
  }
}
