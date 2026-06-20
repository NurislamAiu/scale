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
          return const Left(PermissionDeniedFailure());
        }
      } else if (Platform.isIOS) {
        // On iOS, we request Bluetooth and Location.
        // FBP will trigger the system prompt if needed.
        // We don't return failure immediately here based on permission_handler status
        // because it can be unreliable on iOS if the Podfile macros are missing.
        // Instead, we rely on FlutterBluePlus.adapterState.
        await [
          Permission.bluetooth,
          Permission.location,
        ].request();
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
          // If unauthorized, it means permissions were denied
          if (adapterState == BluetoothAdapterState.unauthorized) {
            return const Left(PermissionDeniedFailure());
          }
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
