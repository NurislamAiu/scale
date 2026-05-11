import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/workouts/domain/entities/workout_program.dart';
import 'package:smart_scale/features/workouts/domain/repositories/workout_repository.dart';
import 'package:smart_scale/features/workouts/presentation/widgets/workout_card.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  static final _repository = WorkoutRepository();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final profile = profileState.profile;
        final goal = profile?.fitnessGoal ?? FitnessGoal.maintenance;
        final programs = _repository.getProgramsForGoal(goal);

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
              "Тренировки",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded, color: Colors.white),
                onPressed: () => context.push('/workouts/history'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildGoalHeader(context, profile, goal),
                const SizedBox(height: 24),
                _buildQuickStats(programs),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Text(
                      "Программы",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Все",
                        style: TextStyle(color: _limeAccent, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...programs.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: WorkoutCard(
                      program: entry.value,
                      index: entry.key,
                      progress: entry.key == 0 ? 0.5 : 0.0,
                    ),
                  );
                }),
                const SizedBox(height: 12),
                _buildTipsCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalHeader(BuildContext context, UserProfile? profile, FitnessGoal goal) {
    final label = _getGoalLabel(goal);
    final icon = _getGoalIcon(goal);
    final color = _getGoalColor(goal);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _limeAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _limeAccent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Текущая цель",
                  style: TextStyle(color: _textGrey, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/profile/edit'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Изменить",
                style: TextStyle(color: _textGrey, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<WorkoutProgram> programs) {
    final totalDays = programs.fold<int>(0, (sum, p) => sum + p.days.length);
    final totalSets = programs.fold<int>(
      0,
      (sum, p) => sum +
          p.days.fold<int>(0, (s, d) =>
              s + d.exercises.fold<int>(0, (ss, e) => ss + (int.tryParse(e.sets) ?? 0))),
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatBox(Icons.fitness_center_rounded, programs.length.toString(), "программ", Colors.blueAccent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatBox(Icons.calendar_today_rounded, totalDays.toString(), "дней", Colors.orangeAccent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatBox(Icons.repeat_rounded, totalSets.toString(), "подходов", _limeAccent),
        ),
      ],
    );
  }

  Widget _buildStatBox(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: _textGrey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_rounded, color: Colors.orangeAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Совет дня",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Не забывайте разминаться перед каждой тренировкой — это снижает риск травм на 40%!",
                  style: TextStyle(color: _textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGoalLabel(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.weightLoss:
        return "Похудение";
      case FitnessGoal.maintenance:
        return "Поддержание";
      case FitnessGoal.massGain:
        return "Набор массы";
      case FitnessGoal.aggressiveWeightLoss:
        return "Сушка";
    }
  }

  IconData _getGoalIcon(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.weightLoss:
        return Icons.local_fire_department_rounded;
      case FitnessGoal.maintenance:
        return Icons.balance_rounded;
      case FitnessGoal.massGain:
        return Icons.fitness_center_rounded;
      case FitnessGoal.aggressiveWeightLoss:
        return Icons.flash_on_rounded;
    }
  }

  Color _getGoalColor(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.weightLoss:
        return Colors.orangeAccent;
      case FitnessGoal.maintenance:
        return _limeAccent;
      case FitnessGoal.massGain:
        return Colors.blueAccent;
      case FitnessGoal.aggressiveWeightLoss:
        return Colors.redAccent;
    }
  }
}