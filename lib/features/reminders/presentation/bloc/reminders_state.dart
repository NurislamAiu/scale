part of 'reminders_bloc.dart';

enum RemindersStatus { initial, loading, loaded, saved, error }

class RemindersState extends Equatable {
  final RemindersStatus status;
  final Reminder reminder;
  final String? errorMessage;

  const RemindersState({
    this.status = RemindersStatus.initial,
    this.reminder = const Reminder(id: 0, time: TimeOfDay(hour: 8, minute: 0), isEnabled: false),
    this.errorMessage,
  });

  RemindersState copyWith({
    RemindersStatus? status,
    Reminder? reminder,
    String? errorMessage,
  }) {
    return RemindersState(
      status: status ?? this.status,
      reminder: reminder ?? this.reminder,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reminder, errorMessage];
}
