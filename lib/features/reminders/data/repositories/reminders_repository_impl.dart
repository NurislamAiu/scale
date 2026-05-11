import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_scale/core/error/failures.dart';
import 'package:smart_scale/features/reminders/domain/entities/reminder.dart';
import 'package:smart_scale/features/reminders/domain/repositories/reminders_repository.dart';

class RemindersRepositoryImpl implements RemindersRepository {
  final SharedPreferences _prefs;
  static const String _reminderKey = 'daily_weigh_in_reminder';

  RemindersRepositoryImpl(this._prefs);

  @override
  Future<Either<Failure, Reminder>> getReminder() async {
    try {
      final String? jsonString = _prefs.getString(_reminderKey);
      if (jsonString != null) {
        final parts = jsonString.split('|');
        return Right(Reminder(
          id: 0, // static ID for now
          time: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
          isEnabled: parts[2] == 'true',
        ));
      } else {
        // Return default reminder
        return const Right(Reminder(
          id: 0,
          time: TimeOfDay(hour: 8, minute: 0),
          isEnabled: false,
        ));
      }
    } catch (e) {
      return Left(StorageFailure('Failed to load reminder'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveReminder(Reminder reminder) async {
    try {
      final value = '${reminder.time.hour}|${reminder.time.minute}|${reminder.isEnabled}';
      await _prefs.setString(_reminderKey, value);
      return const Right(unit);
    } catch (e) {
      return Left(StorageFailure('Failed to save reminder'));
    }
  }
}
