// auth_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ravera/features/auth/service/local_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static const String _deviceIdKey = 'app_device_id';
  static const String _sessionKey = 'supabase_session';

  // Email & Password Authentication
  // Add these methods to your existing AuthService class

  Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phoneNumber},
      );

      if (response.user != null) {
        return {
          'success': true,
          'user': response.user,
          'message': 'Registration successful',
        };
      } else {
        return {'success': false, 'message': 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // In your AuthService class, update the signInWithEmail method
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final deviceId = await getDeviceId();

      final AuthResponse authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (authResponse.user != null && authResponse.session != null) {
        // Store the session properly
        await _storeSession(authResponse.session!);

        // Check if profile exists, if not create it
        await _supabase
            .from('user_profiles')
            .select()
            .eq('id', authResponse.user!.id)
            .single()
            .catchError((_) => null);

        // Profile exists, update it
        await _updateUserProfile(authResponse.user!, deviceId);

        await _createUserSession(authResponse.user!, deviceId);

        // Set user as logged in
        await LocalStorageService().setUserLoggedIn(true);

        await _logAuthEvent(
          authResponse.user!.id,
          'email_login_success',
          deviceId,
          extraData: {'email': email},
        );

        // Verify session was stored
      await getCurrentSession();

        return {
          'success': true,
          'user': authResponse.user,
          'session': authResponse.session,
          'message': 'Login successful',
        };
      } else {
        return {'success': false, 'message': 'Login failed. Please try again.'};
      }
    } catch (e) {
      final errorMessage = _getEmailErrorMessage(e);
      await _logAuthEvent(
        null,
        'email_login_failed',
        await getDeviceId(),
        extraData: {'error': e.toString(), 'email': email},
      );

      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signOut() async {
    try {
      final user = _supabase.auth.currentUser;
      final deviceId = await getDeviceId();

      if (user != null) {
        await _logAuthEvent(user.id, 'logout', deviceId);
        await _supabase
            .from('user_sessions')
            .update({
              'is_revoked': true,
              'revoked_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('user_id', user.id)
            .eq('device_id', deviceId);
      }

      await _supabase.auth.signOut();
      await _secureStorage.delete(key: _sessionKey);

      // Clear login state
      await LocalStorageService().setUserLoggedIn(false);

      return {'success': true, 'message': 'Signed out successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Sign out failed: $e',
        'error': e.toString(),
      };
    }
  }

  // Phone Authentication (Existing methods)
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      final deviceId = await getDeviceId();

      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
        data: {
          'device_id': deviceId,
          'app_metadata': {
            'platform': await _getPlatform(),
            'app_version': await _getAppVersion(),
          },
        },
      );

      await _logAuthEvent(
        null,
        'otp_sent',
        deviceId,
        extraData: {'phone': formattedPhone},
      );

      return {'success': true, 'message': 'OTP sent successfully'};
    } catch (e) {
      final errorMessage = _getErrorMessage(e);

      await _logAuthEvent(
        null,
        'otp_failed',
        await getDeviceId(),
        extraData: {'error': e.toString(), 'phone': phoneNumber},
      );

      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      final deviceId = await getDeviceId();

      final AuthResponse authResponse = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      if (authResponse.user == null) {
        throw Exception('User authentication failed');
      }

      await _storeSession(authResponse.session);
      await _createUserProfile(
        authResponse.user!,
        phone: formattedPhone,
        deviceId: deviceId,
      );
      await _createUserSession(authResponse.user!, deviceId);

      await _logAuthEvent(
        authResponse.user!.id,
        'phone_login_success',
        deviceId,
        extraData: {'phone': formattedPhone},
      );

      return {
        'success': true,
        'user': authResponse.user,
        'session': authResponse.session,
        'message': 'Login successful',
      };
    } catch (e) {
      final errorMessage = _getErrorMessage(e);

      await _logAuthEvent(
        null,
        'phone_login_failed',
        await getDeviceId(),
        extraData: {'error': e.toString(), 'phone': phoneNumber},
      );

      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    }
  }

  // Profile Management
  Future<void> _createUserProfile(
    User user, {
    String? email,
    String? phone,
    String? fullName,
    required String deviceId,
  }) async {
    try {
      // Use email from user object if not provided
      final userEmail = email ?? user.email;

      if (userEmail == null) {
      }

      await _supabase.from('user_profiles').upsert({
        'id': user.id,
        'email': userEmail, // This can't be null due to DB constraint
        'phone': phone,
        'full_name': fullName,
        'is_email_verified': user.emailConfirmedAt != null,
        'is_phone_verified': phone != null,
        'last_login': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      e.toString();
      rethrow;
    }
  }

  Future<void> _updateUserProfile(User user, String deviceId) async {
    try {
      await _supabase.from('user_profiles').upsert({
        'id': user.id,
        'email': user.email, // Add this line - email is required
        'is_email_verified': user.emailConfirmedAt != null,
        'last_login': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      e.toString();
    }
  }

  // Error Handling
  String _getEmailErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Email not confirmed':
          return 'Please verify your email before signing in';
        case 'Invalid login credentials':
          return 'Invalid email or password';
        case 'User already registered':
          return 'An account with this email already exists';
        case 'Password should be at least 6 characters':
          return 'Password must be at least 6 characters long';
        default:
          return error.message;
      }
    }

    final errorStr = error.toString();
    if (errorStr.contains('network') || errorStr.contains('Connection')) {
      return 'Network error. Please check your connection.';
    }

    return 'Authentication failed. Please try again.';
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Phone number is invalid':
          return 'Please enter a valid phone number';
        case 'SMS quota exceeded':
          return 'Too many attempts. Please try again later.';
        case 'For security purposes, you can only request this once every 60 seconds':
          return 'Please wait 60 seconds before requesting another code';
        default:
          return error.message;
      }
    }

    final errorStr = error.toString();
    if (errorStr.contains('network') || errorStr.contains('Connection')) {
      return 'Network error. Please check your connection.';
    }

    return 'Authentication failed. Please try again.';
  }

  // Rest of the existing methods remain the same...
  // (getDeviceId, _formatPhoneNumber, _createUserSession, _storeSession,
  // getCurrentSession, getCurrentUser, isAuthenticated, signOut, etc.)

  String _formatPhoneNumber(String phoneNumber) {
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (!digitsOnly.startsWith('+')) {
      digitsOnly = '+91$digitsOnly';
    }
    return digitsOnly;
  }

  Future<String> getDeviceId() async {
    try {
      String? deviceId = await _secureStorage.read(key: _deviceIdKey);
      if (deviceId == null) {
        final deviceInfo = await _deviceInfo.deviceInfo;
        final packageInfo = await PackageInfo.fromPlatform();

        String baseId = '';
        if (deviceInfo is AndroidDeviceInfo) {
          baseId = deviceInfo.id;
        } else if (deviceInfo is IosDeviceInfo) {
          baseId = deviceInfo.identifierForVendor ?? 'unknown_ios';
        } else {
          baseId = 'unknown_platform';
        }

        deviceId =
            '${packageInfo.packageName}_${baseId}_${DateTime.now().millisecondsSinceEpoch}';
        await _secureStorage.write(key: _deviceIdKey, value: deviceId);
      }
      return deviceId;
    } catch (e) {
      final fallbackId =
          'fallback_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
      await _secureStorage.write(key: _deviceIdKey, value: fallbackId);
      return fallbackId;
    }
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Future<String> _getPlatform() async {
    final deviceInfo = await _deviceInfo.deviceInfo;
    if (deviceInfo is AndroidDeviceInfo) {
      return 'Android ${deviceInfo.version.release}';
    } else if (deviceInfo is IosDeviceInfo) {
      return 'iOS ${deviceInfo.systemVersion}';
    }
    return 'Unknown';
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version} (${packageInfo.buildNumber})';
  }

  Future<void> _createUserSession(User user, String deviceId) async {
    try {
      final deviceInfo = await _deviceInfo.deviceInfo;

      String deviceName = 'Unknown Device';
      String platform = 'Unknown';

      if (deviceInfo is AndroidDeviceInfo) {
        deviceName = '${deviceInfo.manufacturer} ${deviceInfo.model}';
        platform = 'Android';
      } else if (deviceInfo is IosDeviceInfo) {
        deviceName = '${deviceInfo.name} ${deviceInfo.model}';
        platform = 'iOS';
      }

      await _supabase.from('user_sessions').upsert({
        'user_id': user.id,
        'device_id': deviceId,
        'device_name': deviceName,
        'platform': platform,
        'last_active': DateTime.now().toUtc().toIso8601String(),
        'is_revoked': false,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      e.toString();
    }
  }

  Future<void> _storeSession(Session? session) async {
    if (session != null) {
      await _secureStorage.write(
        key: _sessionKey,
        value: jsonEncode(session.toJson()),
      );
    }
  }

  Future<Session?> getCurrentSession() async {
    try {
      return _supabase.auth.currentSession;
    } catch (e) {
      return null;
    }
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Future<bool> isAuthenticated() async {
    final session = await getCurrentSession();
    if (session == null) return false;

    final expiresAtSeconds = session.expiresAt;
    if (expiresAtSeconds == null) return false;

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(
      expiresAtSeconds * 1000,
    );
    return expiryDate.isAfter(DateTime.now());
  }

  Future<void> _logAuthEvent(
    String? userId,
    String eventType,
    String deviceId, {
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final logData = {
        'user_id': userId,
        'event_type': eventType,
        'device_id': deviceId,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        ...?extraData,
      };

      await _supabase.from('auth_audit_logs').insert(logData);
    } catch (e) {
      e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getUserSessions() async {
    final user = getCurrentUser();
    if (user == null) return [];

    final response = await _supabase
        .from('user_sessions')
        .select('*')
        .eq('user_id', user.id)
        .order('last_active', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> revokeSession(String sessionId) async {
    final user = getCurrentUser();
    if (user == null) return;

    await _supabase
        .from('user_sessions')
        .update({
          'is_revoked': true,
          'revoked_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', sessionId)
        .eq('user_id', user.id);
  }
}
