import 'package:equatable/equatable.dart';

enum BmiCategory {
  underweight,
  normal,
  overweight,
  obeseClass1,
  obeseClass2,
  obeseClass3,
}

class BodyComposition extends Equatable {
  final double weightKg;
  final double bmi;
  final BmiCategory bmiCategory;
  final double bodyFatPercent;
  final double muscleMassKg;
  final double bodyWaterPercent;
  final double leanBodyMassKg;
  final int visceralFatRating;
  final double bmr;
  final double tdee;
  final double idealWeightKg;

  const BodyComposition({
    required this.weightKg,
    required this.bmi,
    required this.bmiCategory,
    required this.bodyFatPercent,
    required this.muscleMassKg,
    required this.bodyWaterPercent,
    required this.leanBodyMassKg,
    required this.visceralFatRating,
    required this.bmr,
    required this.tdee,
    required this.idealWeightKg,
  });

  double get fatMassKg => weightKg * (bodyFatPercent / 100.0);

  @override
  List<Object?> get props => [
        weightKg,
        bmi,
        bmiCategory,
        bodyFatPercent,
        muscleMassKg,
        bodyWaterPercent,
        leanBodyMassKg,
        visceralFatRating,
        bmr,
        tdee,
        idealWeightKg,
      ];
}
