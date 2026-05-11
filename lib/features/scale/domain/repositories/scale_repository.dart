import 'package:dartz/dartz.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:smart_scale/core/error/failures.dart';
import 'package:smart_scale/features/scale/domain/entities/scale_measurement.dart';

abstract class ScaleRepository {
  Stream<Either<Failure, ScaleMeasurement>> watchMeasurements();
  Future<Either<Failure, Unit>> ensurePermissions();
  Stream<List<ScanResult>> get scanResults;
  Future<void> startScan();
  Future<void> stopScan();
  Future<void> connectToDevice(BluetoothDevice device);
}
