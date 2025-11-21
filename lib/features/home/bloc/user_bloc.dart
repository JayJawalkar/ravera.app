import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ravera/features/home/bloc/user_profile.dart';
import 'package:ravera/features/home/bloc/user_state.dart';
import 'package:ravera/features/home/repository/user_profile_repository.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserProfileRepository repository;

  UserProfileBloc({required this.repository}) : super(UserProfileInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    try {
      final userProfile = await repository.getUserProfile();
      emit(UserProfileLoaded(userProfile: userProfile));
    } catch (e) {
      emit(UserProfileError(message: e.toString()));
    }
  }
}
