part of 'scale_bloc.dart';

enum ScaleStatus {
  initial,
  requestingPermissions,
  ready,
  scanning, // Added for manual scan
  weighing,
  stabilized,
  permissionDenied,
  error,
}

class ScaleState extends Equatable {
  final ScaleStatus status;
  final ScaleMeasurement? lastMeasurement;
  final BodyComposition? bodyComposition;
  final List<ScanResult> scanResults; // Added to hold scan results
  final String? errorMessage;

  const ScaleState({
    this.status = ScaleStatus.initial,
    this.lastMeasurement,
    this.bodyComposition,
    this.scanResults = const [],
    this.errorMessage,
  });

  ScaleState copyWith({
    ScaleStatus? status,
    ScaleMeasurement? lastMeasurement,
    BodyComposition? bodyComposition,
    List<ScanResult>? scanResults,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ScaleState(
      status: status ?? this.status,
      lastMeasurement: lastMeasurement ?? this.lastMeasurement,
      bodyComposition: bodyComposition ?? this.bodyComposition,
      scanResults: scanResults ?? this.scanResults,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, lastMeasurement, bodyComposition, scanResults, errorMessage];
}
