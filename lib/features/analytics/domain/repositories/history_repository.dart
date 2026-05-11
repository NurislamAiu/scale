import 'package:dartz/dartz.dart';
import 'package:smart_scale/core/error/failures.dart';
import 'package:smart_scale/features/scale/domain/entities/scale_measurement.dart';

abstract class HistoryRepository {
  Future<Either<Failure, Unit>> addMeasurement(ScaleMeasurement measurement);
  Future<Either<Failure, List<ScaleMeasurement>>> getMeasurements();
  Future<Either<Failure, Unit>> clearHistory();
}
