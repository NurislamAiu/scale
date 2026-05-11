part of 'analytics_bloc.dart';

sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object> get props => [];
}

class AnalyticsLoadRequested extends AnalyticsEvent {
  const AnalyticsLoadRequested();
}

class AnalyticsTimeRangeChanged extends AnalyticsEvent {
  final int timeRangeIndex; // 0: Неделя, 1: Месяц, 2: Год

  const AnalyticsTimeRangeChanged(this.timeRangeIndex);

  @override
  List<Object> get props => [timeRangeIndex];
}

class AnalyticsMetricChanged extends AnalyticsEvent {
  final int metricIndex;

  const AnalyticsMetricChanged(this.metricIndex);

  @override
  List<Object> get props => [metricIndex];
}
