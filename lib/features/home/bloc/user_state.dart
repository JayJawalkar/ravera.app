

import 'package:ravera/features/home/model/user_profile_model.dart';

abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserProfile userProfile;

  UserProfileLoaded({required this.userProfile});
}

class UserProfileError extends UserProfileState {
  final String message;

  UserProfileError({required this.message});
}