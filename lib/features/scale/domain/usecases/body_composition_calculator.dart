import 'dart:math';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/scale/domain/entities/body_composition.dart';

/// Calculates body composition based on scientifically established empirical formulas.
/// 
/// Sources:
/// - BMI: WHO Standard
/// - Body Fat %: Deurenberg et al. (1991)
/// - Body Water %: Hume-Weyers (1971)
/// - LBM: Derived from weight and body fat
/// - Visceral Fat: Empirical estimation
/// - BMR: Mifflin-St Jeor (1990)
/// - Ideal Weight: Devine (1974)
class BodyCompositionCalculator {
  static BodyComposition calculate({
    required double weightKg,
    required UserProfile profile,
  }) {
    final double heightM = profile.heightMeters;
    final double heightCm = profile.heightCm.toDouble();
    final int age = profile.ageYears;
    final isMale = profile.sex == Sex.male;

    // 1. BMI (WHO)
    final double bmi = weightKg / (heightM * heightM);
    final BmiCategory bmiCategory = _getBmiCategory(bmi);

    // 2. Body Fat % (Deurenberg 1991)
    // Formula: 1.20 × BMI + 0.23 × age - 10.8 × sex - 5.4 (sex: 1 male, 0 female)
    double bodyFatPercent = 1.20 * bmi + 0.23 * age - 10.8 * (isMale ? 1 : 0) - 5.4;
    bodyFatPercent = bodyFatPercent.clamp(3.0, 60.0);

    // 3. Body Water % (Hume 1971)
    double bodyWaterPercent;
    if (isMale) {
      final tbw = 0.194786 * heightCm + 0.296785 * weightKg - 14.012934;
      bodyWaterPercent = (tbw / weightKg) * 100;
    } else {
      final tbw = 0.34454 * heightCm + 0.183809 * weightKg - 35.270121;
      bodyWaterPercent = (tbw / weightKg) * 100;
    }
    bodyWaterPercent = bodyWaterPercent.clamp(30.0, 75.0);

    // 4. Lean Body Mass
    final double leanBodyMassKg = weightKg * (1 - bodyFatPercent / 100.0);

    // 5. Muscle Mass (Estimation)
    final double muscleMassKg = isMale ? leanBodyMassKg * 0.49 : leanBodyMassKg * 0.45;

    // 6. Visceral Fat Rating (Empirical)
    // Formula: clamp(round((BMI - 20) * 0.8 + (age - 30) * 0.05 + (1.5 if male else 0)), 1, 30)
    double vf = (bmi - 20) * 0.8 + (age - 30) * 0.05 + (isMale ? 1.5 : 0);
    int visceralFatRating = vf.round().clamp(1, 30);

    // 7. Basal Metabolic Rate (Mifflin-St Jeor 1990)
    // M: 10 * weight + 6.25 * heightCm - 5 * age + 5
    // F: 10 * weight + 6.25 * heightCm - 5 * age - 161
    double bmr = 10 * weightKg + 6.25 * heightCm - 5 * age;
    bmr += isMale ? 5 : -161;

    // 8. Total Daily Energy Expenditure
    final double activityMultiplier = _getActivityMultiplier(profile.activityLevel);
    final double tdee = bmr * activityMultiplier;

    // 9. Ideal Weight (Devine 1974)
    // M: 50 + 2.3 * max(0, height_inches - 60)
    // F: 45.5 + 2.3 * max(0, height_inches - 60)
    final double heightInches = heightCm / 2.54;
    final double over60Inches = max(0, heightInches - 60);
    final double idealWeightKg = (isMale ? 50.0 : 45.5) + 2.3 * over60Inches;

    return BodyComposition(
      weightKg: weightKg,
      bmi: bmi,
      bmiCategory: bmiCategory,
      bodyFatPercent: bodyFatPercent,
      muscleMassKg: muscleMassKg,
      bodyWaterPercent: bodyWaterPercent,
      leanBodyMassKg: leanBodyMassKg,
      visceralFatRating: visceralFatRating,
      bmr: bmr,
      tdee: tdee,
      idealWeightKg: idealWeightKg,
    );
  }

  static BmiCategory _getBmiCategory(double bmi) {
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < 25.0) return BmiCategory.normal;
    if (bmi < 30.0) return BmiCategory.overweight;
    if (bmi < 35.0) return BmiCategory.obeseClass1;
    if (bmi < 40.0) return BmiCategory.obeseClass2;
    return BmiCategory.obeseClass3;
  }

  static double _getActivityMultiplier(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
    }
  }
}
