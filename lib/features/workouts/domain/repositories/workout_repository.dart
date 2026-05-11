import '../entities/workout_program.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';

class WorkoutRepository {
  List<WorkoutProgram> getProgramsForGoal(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.weightLoss:
        return [
          const WorkoutProgram(
            title: "Full Body (Жиросжигание)",
            description: "Круговая тренировка на все тело для максимального расхода калорий.",
            days: [
              WorkoutDay(
                title: "День 1",
                exercises: [
                  Exercise(name: "Приседания", sets: "3", reps: "15-20"),
                  Exercise(name: "Отжимания", sets: "3", reps: "max"),
                  Exercise(name: "Выпады", sets: "3", reps: "12 на каждую ногу"),
                  Exercise(name: "Планка", sets: "3", reps: "45-60 сек"),
                ],
              ),
              WorkoutDay(
                title: "День 2",
                exercises: [
                  Exercise(name: "Бёрпи", sets: "3", reps: "10-12"),
                  Exercise(name: "Подтягивания (или тяга)", sets: "3", reps: "10-12"),
                  Exercise(name: "Прыжки на скакалке", sets: "3", reps: "1 мин"),
                  Exercise(name: "Скручивания", sets: "3", reps: "20"),
                ],
              ),
            ],
          ),
          const WorkoutProgram(
            title: "HIIT Кардио",
            description: "Высокоинтенсивный интервальный тренинг.",
            days: [
              WorkoutDay(
                title: "Круг 1 (4 повтора)",
                exercises: [
                  Exercise(name: "Бег на месте", sets: "1", reps: "30 сек"),
                  Exercise(name: "Альпинист", sets: "1", reps: "30 сек"),
                  Exercise(name: "Джампинг Джек", sets: "1", reps: "30 сек"),
                  Exercise(name: "Отдых", sets: "1", reps: "30 сек"),
                ],
              ),
            ],
          ),
        ];
      case FitnessGoal.massGain:
        return [
          const WorkoutProgram(
            title: "Push / Pull / Legs",
            description: "Классическая сплит-система для гипертрофии мышц.",
            days: [
              WorkoutDay(
                title: "Push (Толкай)",
                exercises: [
                  Exercise(name: "Жим лежа", sets: "3", reps: "8-10"),
                  Exercise(name: "Армейский жим", sets: "3", reps: "10-12"),
                  Exercise(name: "Отжимания на брусьях", sets: "3", reps: "max"),
                ],
              ),
              WorkoutDay(
                title: "Pull (Тяни)",
                exercises: [
                  Exercise(name: "Подтягивания", sets: "3", reps: "8-10"),
                  Exercise(name: "Тяга штанги в наклоне", sets: "3", reps: "10-12"),
                  Exercise(name: "Подъем на бицепс", sets: "3", reps: "12-15"),
                ],
              ),
              WorkoutDay(
                title: "Legs (Ноги)",
                exercises: [
                  Exercise(name: "Приседания со штангой", sets: "3", reps: "8-10"),
                  Exercise(name: "Мертвая тяга", sets: "3", reps: "10-12"),
                  Exercise(name: "Выпады", sets: "3", reps: "12 на ногу"),
                ],
              ),
            ],
          ),
        ];
      default:
        return [
          const WorkoutProgram(
            title: "Оздоровительная",
            description: "Базовый комплекс для поддержания здоровья и тонуса.",
            days: [
              WorkoutDay(
                title: "Весь комплекс",
                exercises: [
                  Exercise(name: "Суставная разминка", sets: "1", reps: "5 мин"),
                  Exercise(name: "Приседания", sets: "3", reps: "15"),
                  Exercise(name: "Отжимания от пола", sets: "3", reps: "12"),
                  Exercise(name: "Лодочка", sets: "3", reps: "15"),
                  Exercise(name: "Растяжка", sets: "1", reps: "5 мин"),
                ],
              ),
            ],
          ),
        ];
    }
  }
}
