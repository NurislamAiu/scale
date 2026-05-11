part of 'nutrition_bloc.dart';

enum MealType { breakfast, lunch, dinner }

class NutritionState extends Equatable {
  final DateTime selectedDate;
  final Map<DateTime, double> historyProgress; // Date -> consumed/target ratio
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
    required this.selectedDate,
    this.historyProgress = const {},
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
    DateTime? selectedDate,
    Map<DateTime, double>? historyProgress,
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
      selectedDate: selectedDate ?? this.selectedDate,
      historyProgress: historyProgress ?? this.historyProgress,
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
        selectedDate,
        historyProgress,
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
  final String id;
  final String title;
  final int calories;
  final int protein;
  final int fat;
  final int carbs;
  final String imageUrl;
  final DateTime timestamp;
  final MealType type;

  const Meal({
    required this.id,
    required this.title,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.imageUrl,
    required this.timestamp,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, calories, protein, fat, carbs, imageUrl, timestamp, type];
}
