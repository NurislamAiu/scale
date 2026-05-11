import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  final String name;
  final String sets;
  final String reps;
  final String? description;

  const Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.description,
  });

  @override
  List<Object?> get props => [name, sets, reps, description];
}

class WorkoutDay extends Equatable {
  final String title;
  final List<Exercise> exercises;

  const WorkoutDay({
    required this.title,
    required this.exercises,
  });

  @override
  List<Object?> get props => [title, exercises];
}

class WorkoutProgram extends Equatable {
  final String title;
  final String description;
  final List<WorkoutDay> days;

  const WorkoutProgram({
    required this.title,
    required this.description,
    required this.days,
  });

  @override
  List<Object?> get props => [title, description, days];
}
