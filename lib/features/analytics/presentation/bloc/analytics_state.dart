part of 'analytics_bloc.dart';

enum AnalyticsStatus { initial, loading, loaded, error }

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final List<ScaleMeasurement> allMeasurements;
  final List<ScaleMeasurement> filteredMeasurements;
  final int selectedTimeRangeIndex;
  final int selectedMetricIndex;
  final String? errorMessage;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.allMeasurements = const [],
    this.filteredMeasurements = const [],
    this.selectedTimeRangeIndex = 0, // По умолчанию "Неделя"
    this.selectedMetricIndex = 0, // По умолчанию "Вес"
    this.errorMessage,
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    List<ScaleMeasurement>? allMeasurements,
    List<ScaleMeasurement>? filteredMeasurements,
    int? selectedTimeRangeIndex,
    int? selectedMetricIndex,
    String? errorMessage,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      allMeasurements: allMeasurements ?? this.allMeasurements,
      filteredMeasurements: filteredMeasurements ?? this.filteredMeasurements,
      selectedTimeRangeIndex: selectedTimeRangeIndex ?? this.selectedTimeRangeIndex,
      selectedMetricIndex: selectedMetricIndex ?? this.selectedMetricIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, allMeasurements, filteredMeasurements, selectedTimeRangeIndex, selectedMetricIndex, errorMessage];
}
