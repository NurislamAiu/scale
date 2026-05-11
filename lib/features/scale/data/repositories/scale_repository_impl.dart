import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_scale/core/error/failures.dart';
import 'package:smart_scale/features/scale/data/datasources/scale_ble_datasource.dart';
import 'package:smart_scale/features/scale/domain/entities/scale_measurement.dart';
import 'package:smart_scale/features/scale/domain/repositories/scale_repository.dart';

class ScaleRepositoryImpl implements ScaleRepository {
  final ScaleBleDataSource _dataSource;

  ScaleRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, ScaleMeasurement>> watchMeasurements() {
    return _dataSource.watchMeasurements().map<Either<Failure, ScaleMeasurement>>((measurement) {
      return Right(measurement);
    }).handleError((error) {
      // Return a BleScanFailure on the stream instead of throwing
      return Left(BleScanFailure(error.toString()));
    });
  }

  @override
  Future<Either<Failure, Unit>> ensurePermissions() async {
    try {
      if (!await FlutterBluePlus.isSupported) {
        return const Left(BleNotSupportedFailure());
      }

      if (Platform.isAndroid) {
        // Request multiple permissions at once.
        Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location, // General location is often sufficient
        ].request();

        // Check if essential permissions are granted.
        final hasBlePermissions = 
            statuses[Permission.bluetoothScan] == PermissionStatus.granted &&
            statuses[Permission.bluetoothConnect] == PermissionStatus.granted;

        if (!hasBlePermissions) {
          // You could be more specific here based on which permission was denied.
          return const Left(PermissionDeniedFailure());
        }
      }

      // Check adapter state after ensuring permissions.
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        if (Platform.isAndroid) {
          try {
            await FlutterBluePlus.turnOn();
          } catch (e) {
            return const Left(BluetoothOffFailure());
          }
        } else {
          return const Left(BluetoothOffFailure());
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(BleScanFailure(e.toString()));
    }
  }

  // --- New Methods ---
  @override
  Stream<List<ScanResult>> get scanResults => _dataSource.scanResults;

  @override
  Future<void> startScan() => _dataSource.startScan();

  @override
  Future<void> stopScan() => _dataSource.stopScan();

  @override
  Future<void> connectToDevice(BluetoothDevice device) => _dataSource.connectToDevice(device);
}
