import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scale/core/notifications/notification_service.dart';
import 'package:smart_scale/features/reminders/domain/entities/reminder.dart';
import 'package:smart_scale/features/reminders/domain/repositories/reminders_repository.dart';

part 'reminders_event.dart';
part 'reminders_state.dart';

class RemindersBloc extends Bloc<RemindersEvent, RemindersState> {
  final RemindersRepository _repository;
  final NotificationService _notificationService;

  RemindersBloc(this._repository, this._notificationService) : super(const RemindersState()) {
    on<RemindersLoadRequested>(_onLoadRequested);
    on<ReminderIsEnabledChanged>(_onIsEnabledChanged);
    on<ReminderTimeChanged>(_onTimeChanged);
    on<ReminderSaveRequested>(_onSaveRequested);
  }

  Future<void> _onLoadRequested(RemindersLoadRequested event, Emitter<RemindersState> emit) async {
    emit(state.copyWith(status: RemindersStatus.loading));
    final result = await _repository.getReminder();
    result.fold(
      (failure) => emit(state.copyWith(status: RemindersStatus.error, errorMessage: failure.message)),
      (reminder) => emit(state.copyWith(status: RemindersStatus.loaded, reminder: reminder)),
    );
  }

  void _onIsEnabledChanged(ReminderIsEnabledChanged event, Emitter<RemindersState> emit) {
    emit(state.copyWith(
      reminder: state.reminder.copyWith(isEnabled: event.isEnabled),
    ));
  }

  void _onTimeChanged(ReminderTimeChanged event, Emitter<RemindersState> emit) {
    emit(state.copyWith(
      reminder: state.reminder.copyWith(time: event.time),
    ));
  }

  Future<void> _onSaveRequested(ReminderSaveRequested event, Emitter<RemindersState> emit) async {
    final reminder = state.reminder;
    await _repository.saveReminder(reminder);

    // Cancel previous reminder before setting a new one
    await _notificationService.cancelReminder(reminder.id);

    if (reminder.isEnabled) {
      await _notificationService.scheduleDailyReminder(
        id: reminder.id,
        title: 'Время взвеситься!',
        body: 'Не забудьте зафиксировать свой утренний вес.',
        time: reminder.time,
      );
    }
    
    emit(state.copyWith(status: RemindersStatus.saved));
  }
}
