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
