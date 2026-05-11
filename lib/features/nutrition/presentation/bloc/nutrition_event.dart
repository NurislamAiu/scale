part of 'nutrition_bloc.dart';

abstract class NutritionEvent extends Equatable {
  const NutritionEvent();

  @override
  List<Object?> get props => [];
}

class NutritionDataUpdated extends NutritionEvent {
  final UserProfile? profile;
  final double? currentWeight;

  const NutritionDataUpdated({this.profile, this.currentWeight});

  @override
  List<Object?> get props => [profile, currentWeight];
}

class NutritionMealAdded extends NutritionEvent {
  final String title;
  final int calories;
  final int protein;
  final int fat;
  final int carbs;
  final MealType type;
  final String? replaceMealId;

  const NutritionMealAdded({
    required this.title,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.type,
    this.replaceMealId,
  });

  @override
  List<Object?> get props => [title, calories, protein, fat, carbs, type, replaceMealId];
}

class NutritionMealDeleted extends NutritionEvent {
  final String mealId;

  const NutritionMealDeleted(this.mealId);

  @override
  List<Object?> get props => [mealId];
}

class NutritionDateChanged extends NutritionEvent {
  final DateTime date;

  const NutritionDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}
