import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scale/features/nutrition/presentation/bloc/nutrition_bloc.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionBloc, NutritionState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(state),
                      const SizedBox(height: 32),
                      _buildMacros(state),
                      const SizedBox(height: 32),
                      _buildAIAnalysis(state),
                      const SizedBox(height: 32),
                      _buildMealList(state),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return const SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: 0,
      floating: true,
      pinned: true,
      title: Text(
        'Питание',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildHeader(NutritionState state) {
    if (state.targetCalories == 0) {
      return Container(
        height: 240,
        alignment: Alignment.center,
        child: const Text(
          'Взвесьтесь, чтобы рассчитать норму',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }
    final progress = state.targetCalories > 0 ? state.consumedCalories / state.targetCalories : 0.0;
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 240,
            height: 240,
            child: CustomPaint(
              painter: CalorieRingPainter(
                progress: progress.clamp(0.0, 1.0),
                color: const Color(0xFFCCFF00),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Осталось',
                style: TextStyle(
                  color: Color(0xFFA0A0A5),
                  fontSize: 16,
                ),
              ),
              Text(
                '${state.remainingCalories.abs()}',
                style: TextStyle(
                  color: state.remainingCalories >= 0 ? Colors.white : Colors.redAccent,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${state.consumedCalories}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${state.targetCalories} ккал',
                      style: const TextStyle(
                        color: Color(0xFFA0A0A5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacros(NutritionState state) {
    return Row(
      children: [
        Expanded(
          child: _buildMacroItem(
            'Белки',
            '${state.proteinConsumed}г',
            state.proteinTarget > 0 ? state.proteinConsumed / state.proteinTarget : 0,
            const Color(0xFFFF7B5C),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMacroItem(
            'Жиры',
            '${state.fatConsumed}г',
            state.fatTarget > 0 ? state.fatConsumed / state.fatTarget : 0,
            const Color(0xFFFFD600),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMacroItem(
            'Углеводы',
            '${state.carbsConsumed}г',
            state.carbsTarget > 0 ? state.carbsConsumed / state.carbsTarget : 0,
            const Color(0xFF00E5FF),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItem(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFA0A0A5), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildAIAnalysis(NutritionState state) {
    // Basic AI feedback based on data
    String analysis = 'Начните записывать приемы пищи, чтобы получить персональный анализ.';
    if (state.consumedCalories > 0) {
      if (state.proteinConsumed < (state.proteinTarget * 0.5)) {
        analysis = 'Сегодня у вас дефицит белка. Попробуйте добавить в рацион творог, яйца или куриную грудку для лучшего восстановления.';
      } else if (state.remainingCalories < 0) {
        analysis = 'Вы превысили дневную норму калорий. Постарайтесь сегодня быть более активным, чтобы сбалансировать энергию.';
      } else {
        analysis = 'Ваш рацион сбалансирован. Продолжайте в том же духе, вы отлично придерживаетесь своего плана!';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFFCCFF00), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Анализ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  analysis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealList(NutritionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Приемы пищи',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ...state.meals.map((meal) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildMealCard(
                title: meal.title,
                calories: '${meal.calories} ккал',
                imageUrl: meal.imageUrl,
              ),
            )),
        if (state.meals.length < 3) _buildEmptyMealCard('Ужин'),
      ],
    );
  }

  Widget _buildMealCard({
    required String title,
    required String calories,
    required String imageUrl,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              calories,
              style: const TextStyle(
                color: Color(0xFFCCFF00),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMealCard(String title) {
    return CustomPaint(
      painter: DottedBorderPainter(
        color: Colors.white.withOpacity(0.1),
        radius: 24,
      ),
      child: Container(
        height: 120,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCCFF00),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text(
                'Добавить сейчас',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalorieRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  CalorieRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 20.0;

    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start angle: 0.75 * pi (bottom-left)
    // Sweep angle: 1.5 * pi (creating a gap at the bottom)
    const startAngle = 0.75 * math.pi;
    const totalSweepAngle = 1.5 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      totalSweepAngle,
      false,
      backgroundPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      totalSweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate is! CalorieRingPainter ||
      oldDelegate.progress != progress ||
      oldDelegate.color != color;
}

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  DottedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    const dashWidth = 8.0;
    const dashSpace = 6.0;

    final pathMetrics = path.computeMetrics();
    for (var metric in pathMetrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
