import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scale/features/analytics/domain/repositories/history_repository.dart';
import 'package:smart_scale/features/scale/domain/entities/scale_measurement.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final HistoryRepository _repository;

  AnalyticsBloc(this._repository) : super(const AnalyticsState()) {
    on<AnalyticsLoadRequested>(_onLoadRequested);
    on<AnalyticsTimeRangeChanged>(_onTimeRangeChanged);
    on<AnalyticsMetricChanged>(_onMetricChanged);
  }

  Future<void> _onLoadRequested(AnalyticsLoadRequested event, Emitter<AnalyticsState> emit) async {
    emit(state.copyWith(status: AnalyticsStatus.loading));

    final result = await _repository.getMeasurements();
    
    result.fold(
      (failure) => emit(state.copyWith(status: AnalyticsStatus.error, errorMessage: failure.message)),
      (measurements) {
        final filtered = _filterMeasurements(measurements, state.selectedTimeRangeIndex);
        emit(state.copyWith(
          status: AnalyticsStatus.loaded,
          allMeasurements: measurements,
          filteredMeasurements: filtered,
        ));
      },
    );
  }

  void _onTimeRangeChanged(AnalyticsTimeRangeChanged event, Emitter<AnalyticsState> emit) {
    if (state.status != AnalyticsStatus.loaded) return;
    
    final filtered = _filterMeasurements(state.allMeasurements, event.timeRangeIndex);
    emit(state.copyWith(
      selectedTimeRangeIndex: event.timeRangeIndex,
      filteredMeasurements: filtered,
    ));
  }

  void _onMetricChanged(AnalyticsMetricChanged event, Emitter<AnalyticsState> emit) {
    emit(state.copyWith(selectedMetricIndex: event.metricIndex));
  }

  List<ScaleMeasurement> _filterMeasurements(List<ScaleMeasurement> all, int rangeIndex) {
    if (all.isEmpty) return [];
    
    final now = DateTime.now();
    DateTime startDate;

    switch (rangeIndex) {
      case 0: // Неделя
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 1: // Месяц
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 2: // Год
        startDate = now.subtract(const Duration(days: 365));
        break;
      default:
        return [];
    }
    
    // В all данные уже отсортированы desc.
    return all.where((m) => m.timestamp.isAfter(startDate)).toList();
  }
}
