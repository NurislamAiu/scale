part of 'nutrition_bloc.dart';

class NutritionState extends Equatable {
  final int targetCalories;
  final int consumedCalories;
  final int proteinTarget;
  final int proteinConsumed;
  final int fatTarget;
  final int fatConsumed;
  final int carbsTarget;
  final int carbsConsumed;
  final List<Meal> meals;

  const NutritionState({
    this.targetCalories = 2000,
    this.consumedCalories = 0,
    this.proteinTarget = 150,
    this.proteinConsumed = 0,
    this.fatTarget = 70,
    this.fatConsumed = 0,
    this.carbsTarget = 250,
    this.carbsConsumed = 0,
    this.meals = const [],
  });

  int get remainingCalories => targetCalories - consumedCalories;

  NutritionState copyWith({
    int? targetCalories,
    int? consumedCalories,
    int? proteinTarget,
    int? proteinConsumed,
    int? fatTarget,
    int? fatConsumed,
    int? carbsTarget,
    int? carbsConsumed,
    List<Meal>? meals,
  }) {
    return NutritionState(
      targetCalories: targetCalories ?? this.targetCalories,
      consumedCalories: consumedCalories ?? this.consumedCalories,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      proteinConsumed: proteinConsumed ?? this.proteinConsumed,
      fatTarget: fatTarget ?? this.fatTarget,
      fatConsumed: fatConsumed ?? this.fatConsumed,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      carbsConsumed: carbsConsumed ?? this.carbsConsumed,
      meals: meals ?? this.meals,
    );
  }

  @override
  List<Object?> get props => [
        targetCalories,
        consumedCalories,
        proteinTarget,
        proteinConsumed,
        fatTarget,
        fatConsumed,
        carbsTarget,
        carbsConsumed,
        meals,
      ];
}

class Meal extends Equatable {
  final String title;
  final int calories;
  final String imageUrl;
  final DateTime timestamp;

  const Meal({
    required this.title,
    required this.calories,
    required this.imageUrl,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [title, calories, imageUrl, timestamp];
}
