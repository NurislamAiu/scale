import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/profile/domain/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileSaveRequested>(_onProfileSaveRequested);
    on<ProfileClearRequested>(_onProfileClearRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    
    final result = await _repository.getProfile();
    
    result.fold(
      (failure) => emit(state.copyWith(status: ProfileStatus.error, errorMessage: failure.message)),
      (profile) {
        if (profile != null) {
          emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
        } else {
          emit(state.copyWith(status: ProfileStatus.missing));
        }
      },
    );
  }

  Future<void> _onProfileSaveRequested(
    ProfileSaveRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    
    final result = await _repository.saveProfile(event.profile);
    
    result.fold(
      (failure) => emit(state.copyWith(status: ProfileStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: ProfileStatus.saved, profile: event.profile)),
    );
  }

  Future<void> _onProfileClearRequested(
    ProfileClearRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    
    final result = await _repository.clearProfile();
    
    result.fold(
      (failure) => emit(state.copyWith(status: ProfileStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: ProfileStatus.missing, profile: null)),
    );
  }
}
