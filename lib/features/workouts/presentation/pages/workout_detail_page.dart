import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_scale/features/workouts/domain/entities/workout_program.dart';
import 'package:smart_scale/features/workouts/domain/repositories/workout_repository.dart';

import '../../../profile/domain/entities/user_profile.dart';

import '../../../profile/domain/entities/user_profile.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

class WorkoutDetailPage extends StatelessWidget {
  final String programIndex;

  const WorkoutDetailPage({super.key, required this.programIndex});

  static final _repository = WorkoutRepository();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final profile = profileState.profile;
        final goal = profile?.fitnessGoal ?? FitnessGoal.maintenance;
        final programs = _repository.getProgramsForGoal(goal);
        final index = int.tryParse(programIndex) ?? 0;
        final program = index < programs.length ? programs[index] : programs.first;

        return Scaffold(
          backgroundColor: _bgColor,
          appBar: AppBar(
            backgroundColor: _bgColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: Text(
              program.title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildProgramHeader(program),
                const SizedBox(height: 24),
                _buildStatsRow(program),
                const SizedBox(height: 24),
                const Text(
                  "Дни тренировок",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...program.days.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildDayCard(context, program, entry.key, entry.value),
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgramHeader(WorkoutProgram program) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _limeAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _limeAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.fitness_center_rounded, color: _limeAccent, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  program.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            program.description,
            style: const TextStyle(color: _textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(WorkoutProgram program) {
    final totalDays = program.days.length;
    final totalExercises = program.days.fold<int>(0, (sum, d) => sum + d.exercises.length);
    final totalSets = program.days.fold<int>(
      0,
      (sum, d) => sum + d.exercises.fold<int>(0, (s, e) => s + (int.tryParse(e.sets) ?? 0)),
    );

    return Row(
      children: [
        Expanded(child: _buildStatCard("Дней", totalDays.toString(), Icons.calendar_today_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("Упражнений", totalExercises.toString(), Icons.format_list_numbered_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("Подходов", totalSets.toString(), Icons.repeat_rounded)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: _textGrey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, WorkoutProgram program, int dayIndex, WorkoutDay day) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _limeAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${dayIndex + 1}",
                style: const TextStyle(color: _limeAccent, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          title: Text(
            day.title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${day.exercises.length} упражнений",
            style: const TextStyle(color: _textGrey, fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.expand_more_rounded, color: _textGrey),
            ],
          ),
          children: [
            ...day.exercises.map((exercise) => _buildExerciseItem(exercise)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/workouts/execute/$programIndex/$dayIndex');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _limeAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  "Начать день",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                if (exercise.description != null)
                  Text(exercise.description!, style: const TextStyle(color: _textGrey, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${exercise.sets} × ${exercise.reps}",
              style: const TextStyle(color: _textGrey, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}