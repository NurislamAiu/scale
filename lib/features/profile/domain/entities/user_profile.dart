import 'package:equatable/equatable.dart';

enum Sex { male, female }

enum FitnessGoal {
  weightLoss,
  maintenance,
  massGain,
  aggressiveWeightLoss, // "Сушка"
}

enum ActivityLevel {
  sedentary, // Сидячий образ жизни
  light, // 1-3 тренировки в неделю
  moderate, // 3-5 тренировок
  active, // 6-7 тренировок
  veryActive, // Тяжелые тренировки 2 раза в день
}

class UserProfile extends Equatable {
  final int heightCm;
  final int ageYears;
  final Sex sex;
  final double? targetWeightKg;
  final ActivityLevel activityLevel;
  final FitnessGoal fitnessGoal;

  const UserProfile({
    required this.heightCm,
    required this.ageYears,
    required this.sex,
    this.targetWeightKg,
    required this.activityLevel,
    this.fitnessGoal = FitnessGoal.maintenance,
  });

  double get heightMeters => heightCm / 100.0;

  UserProfile copyWith({
    int? heightCm,
    int? ageYears,
    Sex? sex,
    double? targetWeightKg,
    ActivityLevel? activityLevel,
    FitnessGoal? fitnessGoal,
  }) {
    return UserProfile(
      heightCm: heightCm ?? this.heightCm,
      ageYears: ageYears ?? this.ageYears,
      sex: sex ?? this.sex,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
    );
  }

  // NOTE: Adding toJson/fromJson directly to entity for simplicity with shared_prefs
  Map<String, dynamic> toJson() {
    return {
      'heightCm': heightCm,
      'ageYears': ageYears,
      'sex': sex.name,
      'targetWeightKg': targetWeightKg,
      'activityLevel': activityLevel.name,
      'fitnessGoal': fitnessGoal.name,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      heightCm: json['heightCm'] as int,
      ageYears: json['ageYears'] as int,
      sex: Sex.values.firstWhere((e) => e.name == json['sex']),
      targetWeightKg: json['targetWeightKg'] as double?,
      activityLevel: ActivityLevel.values.firstWhere((e) => e.name == json['activityLevel']),
      fitnessGoal: FitnessGoal.values.firstWhere(
        (e) => e.name == (json['fitnessGoal'] ?? FitnessGoal.maintenance.name),
        orElse: () => FitnessGoal.maintenance,
      ),
    );
  }

  @override
  List<Object?> get props => [heightCm, ageYears, sex, targetWeightKg, activityLevel, fitnessGoal];
}
