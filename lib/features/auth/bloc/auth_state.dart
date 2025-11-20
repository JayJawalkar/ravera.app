import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String userId;
  final bool isNewUser;
  const Authenticated({required this.userId, required this.isNewUser});

  @override
  List<Object> get props => [userId, isNewUser];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class EmailNotVerified extends AuthState {
  final String userId;
  final String message;
  const EmailNotVerified({required this.userId, required this.message});

  @override
  List<Object> get props => [userId, message];
}

class RegistrationSucess extends AuthState {
  final String email;
  final String userId;
  const RegistrationSucess({required this.email, required this.userId});

  @override
  List<Object> get props => [];
}

class ActiveSession extends AuthState {
  final String userId;
  final String deviceInfo;
  final String lastLoginTime;
  const ActiveSession({
    required this.userId,
    required this.deviceInfo,
    required this.lastLoginTime,
  });

  @override
  List<Object> get props => [userId, deviceInfo, lastLoginTime];
}
