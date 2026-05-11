part of 'reminders_bloc.dart';

sealed class RemindersEvent extends Equatable {
  const RemindersEvent();

  @override
  List<Object> get props => [];
}

class RemindersLoadRequested extends RemindersEvent {
  const RemindersLoadRequested();
}

class ReminderIsEnabledChanged extends RemindersEvent {
  final bool isEnabled;

  const ReminderIsEnabledChanged(this.isEnabled);

  @override
  List<Object> get props => [isEnabled];
}

class ReminderTimeChanged extends RemindersEvent {
  final TimeOfDay time;

  const ReminderTimeChanged(this.time);

  @override
  List<Object> get props => [time];
}

class ReminderSaveRequested extends RemindersEvent {
  const ReminderSaveRequested();
}
