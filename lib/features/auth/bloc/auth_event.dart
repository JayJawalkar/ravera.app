import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class RegisterWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String phoneNumber;
  final String fullName;
  const RegisterWithEmailEvent({
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.fullName,
  });

  @override
  List<Object> get props => [email, password, phoneNumber, fullName];
}

class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  const SignInWithEmailEvent({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class SignUpwithGoogleEvent extends AuthEvent {
  const SignUpwithGoogleEvent();

  @override
  List<Object> get props => [];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();

  @override
  List<Object> get props => [];
}

class CheckEmailVerificationEvent extends AuthEvent {
  final String userId;
  final bool isNewUser;
  const CheckEmailVerificationEvent({
    required this.userId,
    required this.isNewUser,
  });

  @override
  List<Object> get props => [userId, isNewUser];
}
