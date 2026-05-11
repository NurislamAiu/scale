import 'package:equatable/equatable.dart';

class ScaleMeasurement extends Equatable {
  final double weightKg;
  final int? impedanceOhms;
  final bool isStabilized;
  final DateTime timestamp;

  const ScaleMeasurement({
    required this.weightKg,
    this.impedanceOhms,
    required this.isStabilized,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'weightKg': weightKg,
      'isStabilized': isStabilized,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScaleMeasurement.fromJson(Map<String, dynamic> json) {
    return ScaleMeasurement(
      weightKg: json['weightKg'] as double,
      isStabilized: json['isStabilized'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }


  @override
  List<Object?> get props => [weightKg, impedanceOhms, isStabilized, timestamp];
}
