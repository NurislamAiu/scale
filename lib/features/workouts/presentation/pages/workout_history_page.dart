import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/workouts/domain/entities/workout_progress.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

class WorkoutHistoryPage extends StatelessWidget {
  const WorkoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mockSessions = _generateMockSessions();

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final profile = profileState.profile;

        return Scaffold(
          backgroundColor: _bgColor,
          appBar: AppBar(
            backgroundColor: _bgColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              "История тренировок",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSummaryRow(mockSessions),
                const SizedBox(height: 24),
                const Text(
                  "Последние тренировки",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...mockSessions.map((session) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSessionCard(session),
                )),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(List<WorkoutSession> sessions) {
    final totalWorkouts = sessions.length;
    final totalDuration = sessions.fold<int>(0, (sum, s) => sum + s.totalDurationSeconds);
    final streak = _calculateStreak(sessions);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _limeAccent.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  "$totalWorkouts",
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text("Тренировок", style: TextStyle(color: _textGrey, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "${totalDuration ~/ 60} мин",
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text("Время", style: TextStyle(color: _textGrey, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "$streak",
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Text("Дней подряд", style: TextStyle(color: _textGrey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStreak(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return 0;
    int streak = 0;
    DateTime? lastDate;
    for (final session in sessions) {
      final sessionDate = session.startTime;
      if (lastDate == null) {
        streak = 1;
      } else if (lastDate.difference(sessionDate).inDays == 1) {
        streak++;
      } else {
        break;
      }
      lastDate = sessionDate;
    }
    return streak;
  }

  Widget _buildSessionCard(WorkoutSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _limeAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.fitness_center_rounded, color: _limeAccent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.programTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  session.dayTitle,
                  style: const TextStyle(color: _textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    session.isCompleted ? Icons.check_circle_rounded : Icons.timer_rounded,
                    color: session.isCompleted ? _limeAccent : Colors.blueAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${session.totalDurationSeconds ~/ 60}м ${session.totalDurationSeconds % 60}с",
                    style: const TextStyle(color: _textGrey, fontSize: 12),
                  ),
                ],
              ),
              if (session.isCompleted)
                Text(
                  "Завершена",
                  style: TextStyle(
                    color: _limeAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<WorkoutSession> _generateMockSessions() {
    final now = DateTime.now();
    return [
      WorkoutSession(
        programTitle: "Full Body (Жиросжигание)",
        dayTitle: "День 1",
        exercises: [
          ExerciseProgress(exerciseName: "Приседания", sets: 3, reps: "15-20", completedSets: 3, isCompleted: true),
          ExerciseProgress(exerciseName: "Отжимания", sets: 3, reps: "max", completedSets: 3, isCompleted: true),
          ExerciseProgress(exerciseName: "Выпады", sets: 3, reps: "12 на ногу", completedSets: 3, isCompleted: true),
          ExerciseProgress(exerciseName: "Планка", sets: 3, reps: "45-60 сек", completedSets: 3, isCompleted: true),
        ],
        startTime: now.subtract(const Duration(hours: 2, minutes: 30)),
        endTime: now.subtract(const Duration(hours: 2)),
        isCompleted: true,
      ),
      WorkoutSession(
        programTitle: "Full Body (Жиросжигание)",
        dayTitle: "День 2",
        exercises: [
          ExerciseProgress(exerciseName: "Бёрпи", sets: 3, reps: "10-12", completedSets: 3, isCompleted: true),
          ExerciseProgress(exerciseName: "Подтягивания", sets: 3, reps: "10-12", completedSets: 2, isCompleted: false),
          ExerciseProgress(exerciseName: "Прыжки на скакалке", sets: 3, reps: "1 мин", completedSets: 3, isCompleted: false),
          ExerciseProgress(exerciseName: "Скручивания", sets: 3, reps: "20", completedSets: 1, isCompleted: false),
        ],
        startTime: now.subtract(const Duration(hours: 5)),
        isCompleted: false,
      ),
      WorkoutSession(
        programTitle: "HIIT Кардио",
        dayTitle: "Круг 1",
        exercises: [
          ExerciseProgress(exerciseName: "Бег на месте", sets: 1, reps: "30 сек", completedSets: 1, isCompleted: true),
          ExerciseProgress(exerciseName: "Альпинист", sets: 1, reps: "30 сек", completedSets: 1, isCompleted: true),
          ExerciseProgress(exerciseName: "Джампинг Джек", sets: 1, reps: "30 сек", completedSets: 1, isCompleted: true),
          ExerciseProgress(exerciseName: "Отдых", sets: 1, reps: "30 сек", completedSets: 1, isCompleted: true),
        ],
        startTime: now.subtract(const Duration(days: 1, hours: 3)),
        endTime: now.subtract(const Duration(days: 1, hours: 2, minutes: 50)),
        isCompleted: true,
      ),
    ];
  }
}