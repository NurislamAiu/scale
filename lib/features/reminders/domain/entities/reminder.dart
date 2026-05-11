import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Reminder extends Equatable {
  final int id;
  final TimeOfDay time;
  final bool isEnabled;

  const Reminder({
    required this.id,
    required this.time,
    required this.isEnabled,
  });

  Reminder copyWith({
    TimeOfDay? time,
    bool? isEnabled,
  }) {
    return Reminder(
      id: id,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object?> get props => [id, time, isEnabled];
}
