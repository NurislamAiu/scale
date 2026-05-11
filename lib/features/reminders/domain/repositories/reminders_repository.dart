import 'package:dartz/dartz.dart';
import 'package:smart_scale/core/error/failures.dart';
import 'package:smart_scale/features/reminders/domain/entities/reminder.dart';

abstract class RemindersRepository {
  Future<Either<Failure, Reminder>> getReminder();
  Future<Either<Failure, Unit>> saveReminder(Reminder reminder);
}
