import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_scale/features/workouts/domain/entities/workout_progress.dart';
import 'package:smart_scale/features/workouts/domain/repositories/workout_repository.dart';

import '../../../profile/domain/entities/user_profile.dart';

// ─── Color Palette ───
const Color _bgColor = Color(0xFF0A0A0A);
const Color _surfaceColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFF6B6B70);
const Color _white = Color(0xFFE8E8ED);

class WorkoutExecutePage extends StatefulWidget {
  final String programIndex;
  final String dayIndex;

  const WorkoutExecutePage({
    super.key,
    required this.programIndex,
    required this.dayIndex,
  });

  @override
  State<WorkoutExecutePage> createState() => _WorkoutExecutePageState();
}

class _WorkoutExecutePageState extends State<WorkoutExecutePage>
    with TickerProviderStateMixin {
  static final _repository = WorkoutRepository();

  late WorkoutSession _session;
  int _currentExerciseIndex = 0;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isResting = false;
  int _restSeconds = 60;

  late AnimationController _pulseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _initSession();
    _startTimer();
  }

  void _initSession() {
    final profile = context.read<ProfileBloc>().state.profile;
    final goal = profile?.fitnessGoal ?? FitnessGoal.maintenance;
    final programs = _repository.getProgramsForGoal(goal);
    final pIndex = int.tryParse(widget.programIndex) ?? 0;
    final dIndex = int.tryParse(widget.dayIndex) ?? 0;

    final program =
        pIndex < programs.length ? programs[pIndex] : programs.first;
    final day =
        dIndex < program.days.length ? program.days[dIndex] : program.days.first;

    _session = WorkoutSession(
      programTitle: program.title,
      dayTitle: day.title,
      exercises: day.exercises
          .map((e) => ExerciseProgress(
                exerciseName: e.name,
                sets: int.tryParse(e.sets) ?? 3,
                reps: e.reps,
              ))
          .toList(),
      startTime: DateTime.now(),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (!_isResting) {
        setState(() => _elapsedSeconds++);
      } else {
        setState(() => _restSeconds--);
        if (_restSeconds <= 0) {
          setState(() => _isResting = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  void _completeSet() {
    final current = _session.exercises[_currentExerciseIndex];
    final newCompletedSets = current.completedSets + 1;

    if (newCompletedSets >= current.sets) {
      _completeExercise();
    } else {
      setState(() {
        _session.exercises[_currentExerciseIndex] = current.copyWith(
          completedSets: newCompletedSets,
        );
      });
      _startRest();
    }
  }

  void _completeExercise() {
    setState(() {
      _session.exercises[_currentExerciseIndex] =
          _session.exercises[_currentExerciseIndex].copyWith(
        isCompleted: true,
      );
    });

    if (_currentExerciseIndex < _session.exercises.length - 1) {
      setState(() => _currentExerciseIndex++);
      _startRest();
    } else {
      _finishWorkout();
    }
  }

  void _startRest() {
    setState(() {
      _isResting = true;
      _restSeconds = 60;
    });
  }

  void _skipRest() {
    setState(() => _isResting = false);
  }

  void _finishWorkout() {
    _timer?.cancel();
    final completedSession = _session.copyWith(
      endTime: DateTime.now(),
      isCompleted: true,
    );
    _showCompletionDialog(completedSession);
  }

  void _showCompletionDialog(WorkoutSession session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CompletionDialog(session: session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = _session.exercises[_currentExerciseIndex];
    final progress = (_currentExerciseIndex + 1) / _session.exercises.length;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(progress),
            Expanded(
              child: _isResting
                  ? _buildRestScreen()
                  : _buildExerciseScreen(currentExercise),
            ),
            _buildBottomControls(currentExercise),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              _buildIconButton(Icons.close_rounded, _showExitDialog),
              const Spacer(),
              Text(
                _session.dayTitle,
                style: const TextStyle(
                  color: _white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              _buildIconButton(Icons.more_horiz_rounded, () {}),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "${_currentExerciseIndex + 1}/${_session.exercises.length}",
                style: const TextStyle(
                  color: _textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor: const AlwaysStoppedAnimation<Color>(_limeAccent),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatTime(_elapsedSeconds),
                style: const TextStyle(
                  color: _limeAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _white, size: 20),
      ),
    );
  }

  Widget _buildExerciseScreen(ExerciseProgress exercise) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildExerciseIcon(),
            const SizedBox(height: 32),
            Text(
              exercise.exerciseName,
              style: const TextStyle(
                color: _white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "${exercise.reps} повторений",
              style: const TextStyle(
                color: _textGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            _buildSetsCircles(exercise),
            const SizedBox(height: 40),
            _buildExerciseList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 100 + (_pulseController.value * 8),
          height: 100 + (_pulseController.value * 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _limeAccent.withValues(alpha: 0.2),
                _limeAccent.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _limeAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: _limeAccent,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSetsCircles(ExerciseProgress exercise) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: [
          const Text(
            "Подходы",
            style: TextStyle(
              color: _textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(exercise.sets, (index) {
              final isCompleted = index < exercise.completedSets;
              final isCurrent = index == exercise.completedSets;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? _limeAccent
                        : isCurrent
                            ? _limeAccent.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: _limeAccent, width: 2)
                        : null,
                    boxShadow: isCompleted
                        ? [
                            BoxShadow(
                              color: _limeAccent.withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_rounded,
                            color: Colors.black, size: 24)
                        : Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: isCurrent ? _limeAccent : _textGrey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  "Все упражнения",
                  style: TextStyle(
                    color: _white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  "${_session.exercises.where((e) => e.isCompleted).length}/${_session.exercises.length}",
                  style: const TextStyle(color: _textGrey, fontSize: 13),
                ),
              ],
            ),
          ),
          ..._session.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            final isCurrent = index == _currentExerciseIndex;

            return _buildExerciseListItem(exercise, index, isCurrent);
          }),
        ],
      ),
    );
  }

  Widget _buildExerciseListItem(
      ExerciseProgress exercise, int index, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent
            ? _limeAccent.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isCurrent
            ? Border.all(color: _limeAccent.withValues(alpha: 0.2))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: exercise.isCompleted
                  ? _limeAccent
                  : isCurrent
                      ? _limeAccent.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: exercise.isCompleted
                ? const Icon(Icons.check_rounded,
                    color: Colors.black, size: 16)
                : Center(
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: isCurrent ? _limeAccent : _textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              exercise.exerciseName,
              style: TextStyle(
                color: exercise.isCompleted
                    ? _textGrey
                    : isCurrent
                        ? _white
                        : _textGrey,
                fontSize: 14,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                decoration:
                    exercise.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            "${exercise.sets} × ${exercise.reps}",
            style: const TextStyle(color: _textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── Rest Screen with Analog Timer ───
  Widget _buildRestScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "ОТДЫХ",
            style: TextStyle(
              color: _textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 40),
          _buildAnalogTimer(),
          const SizedBox(height: 40),
          Text(
            _formatTime(_restSeconds),
            style: const TextStyle(
              color: _white,
              fontSize: 48,
              fontWeight: FontWeight.w200,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "секунд",
            style: TextStyle(color: _textGrey, fontSize: 14),
          ),
          const SizedBox(height: 48),
          _buildSkipButton(),
        ],
      ),
    );
  }

  Widget _buildAnalogTimer() {
    return SizedBox(
      width: 220,
      height: 220,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return CustomPaint(
            painter: _ClockPainter(
              progress: 1 - (_restSeconds / 60),
              pulseValue: _pulseController.value,
            ),
            child: Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: _limeAccent.withValues(alpha: 0.1),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        color: _limeAccent.withValues(alpha: 0.6),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$_restSeconds",
                        style: const TextStyle(
                          color: _limeAccent,
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: _skipRest,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: const Text(
          "Пропустить",
          style: TextStyle(
            color: _white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(ExerciseProgress exercise) {
    final isLastSet = exercise.completedSets >= exercise.sets - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentExerciseIndex > 0)
            _buildSecondaryButton("Назад", () {
              setState(() {
                _currentExerciseIndex--;
                _isResting = false;
              });
            }),
          if (_currentExerciseIndex > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _buildPrimaryButton(
              isLastSet ? "Завершить" : "Подход выполнен",
              _completeSet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4FF45), Color(0xFFB8E03A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _limeAccent.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: _white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Выйти?",
            style: TextStyle(
                color: _white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        content: const Text(
          "Прогресс тренировки будет потерян",
          style: TextStyle(color: _textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Отмена", style: TextStyle(color: _textGrey)),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: const Text(
              "Выйти",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Analog Clock Painter ───
class _ClockPainter extends CustomPainter {
  final double progress;
  final double pulseValue;

  _ClockPainter({required this.progress, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius - 3, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          _limeAccent,
          _limeAccent.withValues(alpha: 0.5),
        ],
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + (2 * math.pi * progress),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 3),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Tick marks
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * math.pi / 180;
      final isMajor = i % 5 == 0;
      final innerRadius = radius - (isMajor ? 16 : 12);
      final outerRadius = radius - 8;

      final tickPaint = Paint()
        ..color = isMajor
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.1)
        ..strokeWidth = isMajor ? 2 : 1;

      final x1 = center.dx + innerRadius * math.cos(angle - math.pi / 2);
      final y1 = center.dy + innerRadius * math.sin(angle - math.pi / 2);
      final x2 = center.dx + outerRadius * math.cos(angle - math.pi / 2);
      final y2 = center.dy + outerRadius * math.sin(angle - math.pi / 2);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }

    // Glow effect
    final glowPaint = Paint()
      ..color = _limeAccent.withValues(alpha: 0.1 + pulseValue * 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 3),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulseValue != pulseValue;
  }
}

// ─── Completion Dialog ───
class _CompletionDialog extends StatelessWidget {
  final WorkoutSession session;

  const _CompletionDialog({required this.session});

  @override
  Widget build(BuildContext context) {
    final duration = session.totalDurationSeconds;
    final mins = duration ~/ 60;
    final secs = duration % 60;

    return Dialog(
      backgroundColor: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _limeAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: _limeAccent,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Отличная работа!",
              style: TextStyle(
                color: _white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              session.programTitle,
              style: const TextStyle(color: _textGrey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat("Время", "${mins}м ${secs}с"),
                _buildStat("Упражнений", "${session.exercises.length}"),
                _buildStat("Подходов",
                    "${session.exercises.fold<int>(0, (s, e) => s + e.sets)}"),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                  context.pop();
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _limeAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  "Завершить",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: _limeAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: _textGrey, fontSize: 11)),
      ],
    );
  }
}
