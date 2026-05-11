import '../entities/user_profile.dart';

class NutritionPlan {
  final double calories;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final String message;
  final int? weeksToGoal;

  NutritionPlan({
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.message,
    this.weeksToGoal,
  });
}

class FitnessAdvisor {
  static NutritionPlan getNutritionPlan(UserProfile profile, double currentWeightKg, double tdee) {
    double calories = tdee;
    String message = "";
    int? weeksToGoal;

    // 1. Calculate calorie target based on goal
    switch (profile.fitnessGoal) {
      case FitnessGoal.weightLoss:
        calories = tdee - 500;
        message = "Дефицит 500 ккал для плавного похудения (~0.5 кг в неделю).";
        break;
      case FitnessGoal.aggressiveWeightLoss:
        calories = tdee - 750;
        message = "Агрессивный дефицит 750 ккал для быстрой сушки.";
        break;
      case FitnessGoal.massGain:
        calories = tdee + 400;
        message = "Профицит 400 ккал для набора мышечной массы.";
        break;
      case FitnessGoal.maintenance:
        calories = tdee;
        message = "Поддержание текущего веса.";
        break;
    }

    // 2. Estimate weeks to goal
    if (profile.targetWeightKg != null && currentWeightKg > 0) {
      final double diff = currentWeightKg - profile.targetWeightKg!;
      if (profile.fitnessGoal == FitnessGoal.weightLoss && diff > 0) {
        // 500 kcal deficit ~ 0.5kg per week
        weeksToGoal = (diff / 0.5).ceil();
      } else if (profile.fitnessGoal == FitnessGoal.aggressiveWeightLoss && diff > 0) {
        // 750 kcal deficit ~ 0.75kg per week
        weeksToGoal = (diff / 0.75).ceil();
      } else if (profile.fitnessGoal == FitnessGoal.massGain && diff < 0) {
        // 400 kcal surplus ~ 0.4kg per week
        weeksToGoal = (diff.abs() / 0.4).ceil();
      }
    }

    // 3. Macronutrient distribution
    double proteinG, fatG, carbsG;
    
    if (profile.fitnessGoal == FitnessGoal.weightLoss || profile.fitnessGoal == FitnessGoal.aggressiveWeightLoss) {
      proteinG = currentWeightKg * 2.0;
      fatG = currentWeightKg * 1.0;
    } else if (profile.fitnessGoal == FitnessGoal.massGain) {
      proteinG = currentWeightKg * 1.8;
      fatG = currentWeightKg * 0.8;
    } else {
      proteinG = currentWeightKg * 1.6;
      fatG = currentWeightKg * 1.0;
    }

    // 1g protein = 4 kcal, 1g fat = 9 kcal, 1g carbs = 4 kcal
    final double remainingCalories = calories - (proteinG * 4) - (fatG * 9);
    carbsG = remainingCalories / 4;
    if (carbsG < 0) carbsG = 0;

    return NutritionPlan(
      calories: calories,
      proteinG: proteinG,
      fatG: fatG,
      carbsG: carbsG,
      message: message,
      weeksToGoal: weeksToGoal,
    );
  }
}
