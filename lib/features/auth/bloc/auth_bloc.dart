// auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ravera/features/auth/service/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthInitialize extends AuthEvent {}

class AuthSendOtp extends AuthEvent {
  final String phoneNumber;

  const AuthSendOtp(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class AuthVerifyOtp extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const AuthVerifyOtp(this.phoneNumber, this.otp);

  @override
  List<Object> get props => [phoneNumber, otp];
}

class RegisterWithEmail extends AuthEvent {
  final String email;
  final String password;
  final String phoneNumber;
  final String fullName;

  const RegisterWithEmail({
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.fullName,
  });

  @override
  List<Object> get props => [email, password, phoneNumber, fullName];
}

class SignInWithEmail extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmail({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthSignOut extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpSent extends AuthState {
  final String phoneNumber;

  const AuthOtpSent(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class AuthSuccess extends AuthState {
  final Map<String, dynamic> userData;

  const AuthSuccess(this.userData);

  @override
  List<Object> get props => [userData];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object> get props => [error];
}

class AuthUnauthenticated extends AuthState {}

class EmailNotVerified extends AuthState {
  final String userId;
  final String message;

  const EmailNotVerified({required this.userId, required this.message});

  @override
  List<Object> get props => [userId, message];
}

class RegistrationSuccess extends AuthState {
  final String email;
  final String userId;

  const RegistrationSuccess({required this.email, required this.userId});

  @override
  List<Object> get props => [email, userId];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<AuthInitialize>(_onInitialize);
    on<AuthSendOtp>(_onSendOtp);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<RegisterWithEmail>(_onRegisterWithEmail);
    on<SignInWithEmail>(_onSignInWithEmail);
    on<AuthSignOut>(_onSignOut);
    on<AuthCheckStatus>(_onCheckStatus);
  }

  Future<void> _onInitialize(
    AuthInitialize event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      if (isAuthenticated) {
        final user = _authService.getCurrentUser();
        emit(AuthSuccess({'user': user}));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure('Initialization failed: $e'));
    }
  }

  Future<void> _onSendOtp(AuthSendOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _authService.sendOtp(event.phoneNumber);
      if (result['success'] == true) {
        emit(AuthOtpSent(event.phoneNumber));
      } else {
        emit(AuthFailure(result['message']));
      }
    } catch (e) {
      emit(AuthFailure('Failed to send OTP: $e'));
    }
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authService.verifyOtp(event.phoneNumber, event.otp);
      if (result['success'] == true) {
        emit(AuthSuccess(result));
      } else {
        emit(AuthFailure(result['message']));
      }
    } catch (e) {
      emit(AuthFailure('OTP verification failed: $e'));
    }
  }

  Future<void> _onRegisterWithEmail(
    RegisterWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authService.registerWithEmail(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
      );

      if (result['success'] == true) {
        final user = result['user'] as User?;
        if (user?.emailConfirmedAt == null) {
          emit(RegistrationSuccess(email: event.email, userId: user?.id ?? ''));
        } else {
          emit(AuthSuccess(result));
        }
      } else {
        emit(AuthFailure(result['message']));
      }
    } catch (e) {
      emit(AuthFailure('Registration failed: $e'));
    }
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authService.signInWithEmail(
        email: event.email,
        password: event.password,
      );

      if (result['success'] == true) {
        emit(AuthSuccess(result));
      } else {
        emit(AuthFailure(result['message']));
      }
    } catch (e) {
      emit(AuthFailure('Sign in failed: $e'));
    }
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure('Sign out failed: $e'));
    }
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure('Status check failed: $e'));
    }
  }
}
