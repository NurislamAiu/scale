import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_scale/features/scale/presentation/bloc/scale_bloc.dart';

part 'nutrition_event.dart';
part 'nutrition_state.dart';

class NutritionBloc extends Bloc<NutritionEvent, NutritionState> {
  final ProfileBloc profileBloc;
  final ScaleBloc scaleBloc;
  final SharedPreferences prefs;
  late StreamSubscription _profileSubscription;
  late StreamSubscription _scaleSubscription;

  NutritionBloc({
    required this.profileBloc,
    required this.scaleBloc,
    required this.prefs,
  }) : super(NutritionState(selectedDate: DateTime.now())) {
    on<NutritionDataUpdated>(_onDataUpdated);
    on<NutritionMealAdded>(_onMealAdded);
    on<NutritionMealDeleted>(_onMealDeleted);
    on<NutritionDateChanged>(_onDateChanged);
    on<_NutritionInternalDataLoaded>(_onInternalDataLoaded);

    _profileSubscription = profileBloc.stream.listen((profileState) {
      add(NutritionDataUpdated(
        profile: profileState.profile,
        currentWeight: scaleBloc.state.lastMeasurement?.weightKg,
      ));
    });

    _scaleSubscription = scaleBloc.stream.listen((scaleState) {
      add(NutritionDataUpdated(
        profile: profileBloc.state.profile,
        currentWeight: scaleState.lastMeasurement?.weightKg,
      ));
    });

    // Initial load and update
    _loadMeals(state.selectedDate);
    add(NutritionDataUpdated(
      profile: profileBloc.state.profile,
      currentWeight: scaleBloc.state.lastMeasurement?.weightKg,
    ));
  }

  void _onDataUpdated(NutritionDataUpdated event, Emitter<NutritionState> emit) {
    if (event.profile == null || event.currentWeight == null) {
      emit(state.copyWith(targetCalories: 0));
      return;
    }

    final profile = event.profile!;
    final weight = event.currentWeight!;

    // Mifflin-St Jeor Equation
    double bmr;
    if (profile.sex == Sex.male) {
      bmr = (10 * weight) + (6.25 * profile.heightCm) - (5 * profile.ageYears) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * profile.heightCm) - (5 * profile.ageYears) - 161;
    }

    // Activity Multiplier
    double multiplier;
    switch (profile.activityLevel) {
      case ActivityLevel.sedentary:
        multiplier = 1.2;
      case ActivityLevel.light:
        multiplier = 1.375;
      case ActivityLevel.moderate:
        multiplier = 1.55;
      case ActivityLevel.active:
        multiplier = 1.725;
      case ActivityLevel.veryActive:
        multiplier = 1.9;
    }

    double tdee = bmr * multiplier;

    // Goal Adjustment
    int targetCalories;
    switch (profile.fitnessGoal) {
      case FitnessGoal.weightLoss:
        targetCalories = (tdee - 500).round();
      case FitnessGoal.aggressiveWeightLoss:
        targetCalories = (tdee - 750).round();
      case FitnessGoal.maintenance:
        targetCalories = tdee.round();
      case FitnessGoal.massGain:
        targetCalories = (tdee + 400).round();
    }

    // Macros Calculation (Standard ratio)
    int proteinTarget = (weight * 2.0).round();
    int fatTarget = (weight * 0.9).round();
    int carbsTarget = ((targetCalories - (proteinTarget * 4) - (fatTarget * 9)) / 4).round();

    emit(state.copyWith(
      targetCalories: targetCalories,
      proteinTarget: proteinTarget,
      fatTarget: fatTarget,
      carbsTarget: carbsTarget,
      historyProgress: _generateMockHistory(),
    ));
  }

  Map<DateTime, double> _generateMockHistory() {
    final now = DateTime.now();
    return {
      DateTime(now.year, now.month, now.day - 1): 0.95, // Зеленый
      DateTime(now.year, now.month, now.day - 2): 1.15, // Красный
      DateTime(now.year, now.month, now.day - 3): 0.88, // Зеленый
      DateTime(now.year, now.month, now.day - 4): 0.70, // Зеленый
      DateTime(now.year, now.month, now.day - 5): 1.25, // Красный
    };
  }

  void _onMealAdded(NutritionMealAdded event, Emitter<NutritionState> emit) {
    int consumedCalories = state.consumedCalories;
    int proteinConsumed = state.proteinConsumed;
    int fatConsumed = state.fatConsumed;
    int carbsConsumed = state.carbsConsumed;
    List<Meal> updatedMeals = List<Meal>.from(state.meals);

    // If we are replacing an existing meal, remove it first
    if (event.replaceMealId != null) {
      final oldMeal = updatedMeals.where((m) => m.id == event.replaceMealId).firstOrNull;
      if (oldMeal != null) {
        consumedCalories -= oldMeal.calories;
        proteinConsumed -= oldMeal.protein;
        fatConsumed -= oldMeal.fat;
        carbsConsumed -= oldMeal.carbs;
        updatedMeals.removeWhere((m) => m.id == event.replaceMealId);
      }
    }

    String imageUrl;
    switch (event.type) {
      case MealType.breakfast:
        imageUrl = 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?q=80&w=500&auto=format&fit=crop';
        break;
      case MealType.lunch:
        imageUrl = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=500&auto=format&fit=crop';
        break;
      case MealType.dinner:
        imageUrl = 'https://images.unsplash.com/photo-1559339352-11d035aa65de?q=80&w=500&auto=format&fit=crop';
        break;
    }

    final newMeal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title,
      calories: event.calories,
      protein: event.protein,
      fat: event.fat,
      carbs: event.carbs,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      type: event.type,
    );

    updatedMeals.add(newMeal);

    final newState = state.copyWith(
      consumedCalories: consumedCalories + event.calories,
      proteinConsumed: proteinConsumed + event.protein,
      fatConsumed: fatConsumed + event.fat,
      carbsConsumed: carbsConsumed + event.carbs,
      meals: updatedMeals,
    );
    
    emit(newState);
    _saveMeals(state.selectedDate, updatedMeals);
  }

  void _onMealDeleted(NutritionMealDeleted event, Emitter<NutritionState> emit) {
    final mealToDelete = state.meals.where((m) => m.id == event.mealId).firstOrNull;
    if (mealToDelete == null) return;

    final updatedMeals = state.meals.where((m) => m.id != event.mealId).toList();

    final newState = state.copyWith(
      consumedCalories: state.consumedCalories - mealToDelete.calories,
      proteinConsumed: state.proteinConsumed - mealToDelete.protein,
      fatConsumed: state.fatConsumed - mealToDelete.fat,
      carbsConsumed: state.carbsConsumed - mealToDelete.carbs,
      meals: updatedMeals,
    );

    emit(newState);
    _saveMeals(state.selectedDate, updatedMeals);
  }

  void _onDateChanged(NutritionDateChanged event, Emitter<NutritionState> emit) {
    emit(state.copyWith(selectedDate: event.date));
    _loadMeals(event.date);
  }

  void _onInternalDataLoaded(_NutritionInternalDataLoaded event, Emitter<NutritionState> emit) {
    emit(state.copyWith(
      meals: event.meals,
      consumedCalories: event.calories,
      proteinConsumed: event.protein,
      fatConsumed: event.fat,
      carbsConsumed: event.carbs,
    ));
  }

  void _saveMeals(DateTime date, List<Meal> meals) {
    final dateKey = _getDateKey(date);
    final jsonList = meals.map((m) => m.toJson()).toList();
    prefs.setString('nutrition_meals_$dateKey', jsonEncode(jsonList));
  }

  void _loadMeals(DateTime date) {
    final dateKey = _getDateKey(date);
    final jsonString = prefs.getString('nutrition_meals_$dateKey');
    
    List<Meal> meals = [];
    int calories = 0;
    int protein = 0;
    int fat = 0;
    int carbs = 0;

    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        meals = jsonList.map((j) => Meal.fromJson(j)).toList();
        for (var m in meals) {
          calories += m.calories;
          protein += m.protein;
          fat += m.fat;
          carbs += m.carbs;
        }
      } catch (e) {
        prefs.remove('nutrition_meals_$dateKey');
      }
    }

    add(_NutritionInternalDataLoaded(
      meals: meals,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
    ));
  }

  String _getDateKey(DateTime date) {
    return "${date.year}_${date.month}_${date.day}";
  }

  @override
  Future<void> close() {
    _profileSubscription.cancel();
    _scaleSubscription.cancel();
    return super.close();
  }
}

// Internal event to update state after loading from storage
class _NutritionInternalDataLoaded extends NutritionEvent {
  final List<Meal> meals;
  final int calories;
  final int protein;
  final int fat;
  final int carbs;

  const _NutritionInternalDataLoaded({
    required this.meals,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  @override
  List<Object?> get props => [meals, calories, protein, fat, carbs];
}