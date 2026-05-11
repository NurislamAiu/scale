part of 'scale_bloc.dart';

sealed class ScaleEvent extends Equatable {
  const ScaleEvent();

  @override
  List<Object> get props => [];
}

class ScaleStarted extends ScaleEvent {
  const ScaleStarted();
}

class ScaleMeasurementReceived extends ScaleEvent {
  final ScaleMeasurement measurement;

  const ScaleMeasurementReceived(this.measurement);

  @override
  List<Object> get props => [measurement];
}

class ScaleErrored extends ScaleEvent {
  final String message;

  const ScaleErrored(this.message);

  @override
  List<Object> get props => [message];
}

// --- New Events for Manual Scanning ---
class ScaleScanStarted extends ScaleEvent {
  const ScaleScanStarted();
}

class ScaleScanStopped extends ScaleEvent {
  const ScaleScanStopped();
}

class _ScaleScanResultsUpdated extends ScaleEvent {
  final List<ScanResult> results;

  const _ScaleScanResultsUpdated(this.results);
  
  @override
  List<Object> get props => [results];
}

class ScaleDeviceSelected extends ScaleEvent {
  final BluetoothDevice device;

  const ScaleDeviceSelected(this.device);

  @override
  List<Object> get props => [device];
}

class ScaleMeasurementSaved extends ScaleEvent {
  final ScaleMeasurement measurement;

  const ScaleMeasurementSaved(this.measurement);

  @override
  List<Object> get props => [measurement];
}
