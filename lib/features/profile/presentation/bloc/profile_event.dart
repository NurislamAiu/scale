part of 'profile_bloc.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileSaveRequested extends ProfileEvent {
  final UserProfile profile;

  const ProfileSaveRequested(this.profile);
}

class ProfileClearRequested extends ProfileEvent {
  const ProfileClearRequested();
}
