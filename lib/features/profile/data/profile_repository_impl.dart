import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_scale/core/error/failures.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SharedPreferences _prefs;
  final StreamController<UserProfile?> _streamController = StreamController<UserProfile?>.broadcast();

  static const String _profileKey = 'user_profile_v1';

  ProfileRepositoryImpl(this._prefs) {
    // Emit initial value so listeners get it immediately
    _getProfileSync().fold(
      (_) => _streamController.add(null),
      (profile) => _streamController.add(profile),
    );
  }

  Either<Failure, UserProfile?> _getProfileSync() {
    try {
      final jsonString = _prefs.getString(_profileKey);
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return Right(UserProfile.fromJson(jsonMap));
      }
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to load profile: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> getProfile() async {
    return _getProfileSync();
  }

  @override
  Future<Either<Failure, Unit>> saveProfile(UserProfile profile) async {
    try {
      final jsonString = jsonEncode(profile.toJson());
      final success = await _prefs.setString(_profileKey, jsonString);
      
      if (success) {
        _streamController.add(profile);
        return const Right(unit);
      } else {
        return const Left(StorageFailure('Failed to write profile to storage'));
      }
    } catch (e) {
      return Left(StorageFailure('Failed to save profile: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearProfile() async {
    try {
      final success = await _prefs.remove(_profileKey);
      if (success) {
        _streamController.add(null);
        return const Right(unit);
      } else {
        return const Left(StorageFailure('Failed to remove profile from storage'));
      }
    } catch (e) {
      return Left(StorageFailure('Failed to clear profile: $e'));
    }
  }

  @override
  Stream<UserProfile?> watchProfile() {
    return _streamController.stream;
  }
}
