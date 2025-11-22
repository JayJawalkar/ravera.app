

import 'package:equatable/equatable.dart';

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
  final String message;
  const RegistrationSuccess({
    required this.email,
    required this.userId,
    required this.message,
  });

  @override
  List<Object> get props => [email, userId];
}
