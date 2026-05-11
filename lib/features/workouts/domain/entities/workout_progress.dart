import 'package:equatable/equatable.dart';

class ExerciseProgress extends Equatable {
  final String exerciseName;
  final int sets;
  final String reps;
  final int completedSets;
  final bool isCompleted;

  const ExerciseProgress({
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.completedSets = 0,
    this.isCompleted = false,
  });

  ExerciseProgress copyWith({
    int? completedSets,
    bool? isCompleted,
  }) {
    return ExerciseProgress(
      exerciseName: exerciseName,
      sets: sets,
      reps: reps,
      completedSets: completedSets ?? this.completedSets,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [exerciseName, sets, reps, completedSets, isCompleted];
}

class WorkoutSession extends Equatable {
  final String programTitle;
  final String dayTitle;
  final List<ExerciseProgress> exercises;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;

  const WorkoutSession({
    required this.programTitle,
    required this.dayTitle,
    required this.exercises,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
  });

  WorkoutSession copyWith({
    List<ExerciseProgress>? exercises,
    DateTime? endTime,
    bool? isCompleted,
  }) {
    return WorkoutSession(
      programTitle: programTitle,
      dayTitle: dayTitle,
      exercises: exercises ?? this.exercises,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double get progress {
    if (exercises.isEmpty) return 0.0;
    final completed = exercises.where((e) => e.isCompleted).length;
    return completed / exercises.length;
  }

  int get totalDurationSeconds {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inSeconds;
  }

  @override
  List<Object?> get props => [programTitle, dayTitle, exercises, startTime, endTime, isCompleted];
}
