import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_scale/features/scale/presentation/bloc/scale_bloc.dart';

part 'nutrition_event.dart';
part 'nutrition_state.dart';

class NutritionBloc extends Bloc<NutritionEvent, NutritionState> {
  final ProfileBloc profileBloc;
  final ScaleBloc scaleBloc;
  late StreamSubscription _profileSubscription;
  late StreamSubscription _scaleSubscription;

  NutritionBloc({
    required this.profileBloc,
    required this.scaleBloc,
  }) : super(const NutritionState()) {
    on<NutritionDataUpdated>(_onDataUpdated);

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

    // Initial update
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
    // Protein: 2g per kg (or 30% for mass gain)
    // Fats: 0.8g - 1g per kg (or 25%)
    // Carbs: Remainder (or 45-50%)
    
    int proteinTarget = (weight * 2.0).round();
    int fatTarget = (weight * 0.9).round();
    int carbsTarget = ((targetCalories - (proteinTarget * 4) - (fatTarget * 9)) / 4).round();

    // Mock consumed data for demo
    const consumedCalories = 760;
    const proteinConsumed = 65;
    const fatConsumed = 42;
    const carbsConsumed = 180;

    final mockMeals = [
      Meal(
        title: 'Завтрак',
        calories: 450,
        imageUrl: 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?q=80&w=500&auto=format&fit=crop',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Meal(
        title: 'Обед',
        calories: 310,
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=500&auto=format&fit=crop',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    emit(state.copyWith(
      targetCalories: targetCalories,
      consumedCalories: consumedCalories,
      proteinTarget: proteinTarget,
      proteinConsumed: proteinConsumed,
      fatTarget: fatTarget,
      fatConsumed: fatConsumed,
      carbsTarget: carbsTarget,
      carbsConsumed: carbsConsumed,
      meals: mockMeals,
    ));
  }

  @override
  Future<void> close() {
    _profileSubscription.cancel();
    _scaleSubscription.cancel();
    return super.close();
  }
}
