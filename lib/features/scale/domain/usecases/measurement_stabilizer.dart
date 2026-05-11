import 'dart:async';
import 'package:smart_scale/features/scale/domain/entities/scale_measurement.dart';

class MeasurementStabilizer {
  final int windowSize;
  final double toleranceKg;
  
  final List<ScaleMeasurement> _window = [];

  MeasurementStabilizer({
    this.windowSize = 6,
    this.toleranceKg = 0.15,
  });

  ScaleMeasurement process(ScaleMeasurement raw) {
    if (_window.length >= windowSize) {
      _window.removeAt(0);
    }
    _window.add(raw);

    bool isStable = false;
    if (_window.length == windowSize) {
      // Calculate mean
      final double sum = _window.fold(0.0, (acc, m) => acc + m.weightKg);
      final double mean = sum / windowSize;

      // Check if all elements are within tolerance from the mean
      isStable = _window.every((m) => (m.weightKg - mean).abs() <= toleranceKg);
    }

    return ScaleMeasurement(
      weightKg: raw.weightKg,
      impedanceOhms: raw.impedanceOhms,
      isStabilized: isStable,
      timestamp: raw.timestamp,
    );
  }

  void reset() {
    _window.clear();
  }
}

extension StabilizerExtension on Stream<ScaleMeasurement> {
  Stream<ScaleMeasurement> stabilized({int windowSize = 6, double toleranceKg = 0.15}) {
    final stabilizer = MeasurementStabilizer(windowSize: windowSize, toleranceKg: toleranceKg);
    
    return transform(
      StreamTransformer<ScaleMeasurement, ScaleMeasurement>.fromHandlers(
        handleData: (measurement, sink) {
          final processed = stabilizer.process(measurement);
          sink.add(processed);
        },
        handleDone: (sink) {
          stabilizer.reset();
          sink.close();
        },
      ),
    );
  }
}
