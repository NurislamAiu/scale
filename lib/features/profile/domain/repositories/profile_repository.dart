import 'package:dartz/dartz.dart';
import 'package:smart_scale/core/error/failures.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile?>> getProfile();
  Future<Either<Failure, Unit>> saveProfile(UserProfile profile);
  Future<Either<Failure, Unit>> clearProfile();
  Stream<UserProfile?> watchProfile();
}
