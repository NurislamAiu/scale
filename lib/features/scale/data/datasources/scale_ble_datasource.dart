import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:smart_scale/features/scale/domain/entities/scale_measurement.dart';
import 'package:smart_scale/features/scale/data/datasources/yoda_scale_protocol.dart';

class ScaleBleDataSource {
  StreamController<ScaleMeasurement>? _measurementController;
  StreamSubscription? _scanSubscription;
  BluetoothDevice? _connectedDevice;

  Stream<ScaleMeasurement> watchMeasurements() {
    _measurementController ??= StreamController<ScaleMeasurement>.broadcast(
      onListen: _startScanForYoda,
      onCancel: stopScan,
    );
    return _measurementController!.stream;
  }

  // Legacy method for automatic weight streaming
  Future<void> _startScanForYoda() async {
    // This method is now just for the measurement stream
    await _startScan(
      withNames: [YodaScaleProtocol.deviceName],
      timeout: null, // Бесконечное сканирование для главного экрана
      callback: (result) {
        if (result.advertisementData.advName == YodaScaleProtocol.deviceName) {
          final rawData = YodaScaleProtocol.reconstructPayload(result.advertisementData.manufacturerData);
          final measurement = YodaScaleProtocol.parse(rawData);

          if (measurement != null && _measurementController != null && !_measurementController!.isClosed) {
            _measurementController!.add(measurement);
          }
        }
      },
    );
  }

  // --- New methods for manual scanning ---
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Future<void> startScan() => _startScan(withNames: [YodaScaleProtocol.deviceName], timeout: const Duration(seconds: 15));

  Future<void> _startScan({List<String> withNames = const [], Function(ScanResult)? callback, Duration? timeout}) async {
    try {
      if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();

      if (!await FlutterBluePlus.isSupported) {
        throw Exception('BLE is not supported on this device');
      }

      await FlutterBluePlus.adapterState
          .where((state) => state == BluetoothAdapterState.on)
          .first
          .timeout(const Duration(seconds: 30));

      if (callback != null) {
        _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
          for (ScanResult result in results) {
            callback(result);
          }
        });
      }

      await FlutterBluePlus.startScan(
        withNames: withNames,
        continuousUpdates: true,
        continuousDivisor: 1,
        androidScanMode: AndroidScanMode.lowLatency,
        timeout: timeout,
      );
    } catch (e) {
      if (kDebugMode) print('[ScaleBleDataSource] Scan Error: $e');
      // Propagate error to measurement stream if it's active
      if (_measurementController != null && !_measurementController!.isClosed) {
        _measurementController!.addError(e);
      }
      rethrow;
    }
  }

  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    // Disconnect from any previous device
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    
    // The Yoda scale doesn't require a connection, it just broadcasts.
    // In a real scenario with a connectable device, this is where you'd connect:
    // await device.connect();
    // _connectedDevice = device;
    
    // For Yoda, "connecting" means we save this device's ID and filter scans for it.
    // This is a conceptual connection. The existing measurement stream will just work.
    if (kDebugMode) print('[ScaleBleDataSource] "Connected" to ${device.remoteId}');
  }

  void dispose() {
    stopScan();
    _measurementController?.close();
    _measurementController = null;
  }
}
