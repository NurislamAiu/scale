import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:smart_scale/features/nutrition/presentation/bloc/nutrition_bloc.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionBloc, NutritionState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, state),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              _buildHeader(state),
                              const SizedBox(height: 40),
                              Row(
                                children: [
                                  Expanded(child: _buildCalculatorButton(context)),
                                  const SizedBox(width: 12),
                                  _buildAiRecipeButton(context),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildMacrosGrid(context, state),
                              const SizedBox(height: 32),
                              _buildAIAnalysis(state),
                              const SizedBox(height: 32),
                              _buildMealList(context, state),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, NutritionState state) {
    String dateTitle = "Питание";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(state.selectedDate.year, state.selectedDate.month, state.selectedDate.day);

    if (selected == today) {
      dateTitle = "Сегодня";
    } else if (selected == today.subtract(const Duration(days: 1))) {
      dateTitle = "Вчера";
    } else {
      dateTitle = DateFormat('d MMMM', 'ru_RU').format(state.selectedDate);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateTitle,
                style: const TextStyle(
                  color: _limeAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (selected != today)
                const Text(
                  "Просмотр истории",
                  style: TextStyle(color: _textGrey, fontSize: 12),
                ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: _limeAccent, size: 22),
            onPressed: () => _showProgressCalendar(context, state),
          ),
        ],
      ),
    );
  }

  void _showProgressCalendar(BuildContext context, NutritionState state) {
    final nutritionBloc = context.read<NutritionBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: nutritionBloc,
        child: _ProgressCalendarSheet(
          initialDate: state.selectedDate,
          historyProgress: state.historyProgress,
          onDateSelected: (date) {
            nutritionBloc.add(NutritionDateChanged(date));
          },
        ),
      ),
    );
  }

  Widget _buildHeader(NutritionState state) {
    if (state.targetCalories == 0) {
      return Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monitor_weight_outlined, color: _limeAccent, size: 48),
            SizedBox(height: 16),
            Text(
              'Взвесьтесь, чтобы\nрассчитать норму',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textGrey, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final progress = (state.consumedCalories / state.targetCalories).clamp(0.0, 1.0);
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 260,
            height: 260,
            child: CustomPaint(
              painter: CalorieRingPainter(
                progress: progress,
                activeColor: _limeAccent,
                inactiveColor: const Color(0xFF2C2C2E),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Осталось',
                style: TextStyle(
                  color: _textGrey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.remainingCalories.abs()}',
                style: TextStyle(
                  color: state.remainingCalories >= 0 ? Colors.white : const Color(0xFFFF453A),
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  shadows: [
                    Shadow(
                      color: (state.remainingCalories >= 0 ? _limeAccent : const Color(0xFFFF453A)).withOpacity(0.3),
                      blurRadius: 15,
                    )
                  ],
                ),
              ),
              const Text(
                "ккал",
                style: TextStyle(color: _textGrey, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${state.consumedCalories}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${state.targetCalories} ккал',
                        style: const TextStyle(
                          color: _textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosGrid(BuildContext context, NutritionState state) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        _buildCompactStatCard(
          context: context,
          label: 'Белки',
          value: '${state.proteinConsumed}г',
          target: '${state.proteinTarget}г',
          progress: state.proteinTarget > 0 ? state.proteinConsumed / state.proteinTarget : 0,
          color: const Color(0xFFFF7B5C),
          icon: Icons.egg_outlined,
          description: 'Белки — основной строительный материал для мышц и тканей. Необходимы для восстановления и роста клеток организма.',
        ),
        _buildCompactStatCard(
          context: context,
          label: 'Жиры',
          value: '${state.fatConsumed}г',
          target: '${state.fatTarget}г',
          progress: state.fatTarget > 0 ? state.fatConsumed / state.fatTarget : 0,
          color: const Color(0xFFFFD600),
          icon: Icons.opacity_rounded,
          description: 'Жиры — важный источник энергии и регулятор гормонального фона. Участвуют в усвоении витаминов A, D, E, K.',
        ),
        _buildCompactStatCard(
          context: context,
          label: 'Углеводы',
          value: '${state.carbsConsumed}г',
          target: '${state.carbsTarget}г',
          progress: state.carbsTarget > 0 ? state.carbsConsumed / state.carbsTarget : 0,
          color: const Color(0xFF00E5FF),
          icon: Icons.bakery_dining_outlined,
          description: 'Углеводы — главное топливо для мозга и мышц. Обеспечивают энергию для физической активности и работы нервной системы.',
        ),
      ],
    );
  }

  Widget _buildCompactStatCard({
    required BuildContext context,
    required String label,
    required String value,
    required String target,
    required double progress,
    required Color color,
    required IconData icon,
    required String description,
  }) {
    return GestureDetector(
      onTap: () => _showMacroInfo(context, label, description, icon, color),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                Icon(Icons.info_outline_rounded, color: Colors.white.withOpacity(0.1), size: 14),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: _textGrey, fontSize: 10, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMacroInfo(BuildContext context, String title, String description, IconData icon, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            Text(description, style: const TextStyle(color: _textGrey, fontSize: 16, height: 1.5)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withOpacity(0.1),
                  foregroundColor: color,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Понятно', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCalorieCalculator(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _limeAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded, color: _limeAccent, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Поиск еды",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiRecipeButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAiIngredientsCalculator(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_limeAccent, _limeAccent.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _limeAccent.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: const Icon(Icons.auto_awesome, color: Colors.black, size: 24),
      ),
    );
  }

  void _showAiIngredientsCalculator(BuildContext context) {
    final nutritionBloc = context.read<NutritionBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: nutritionBloc,
        child: const _AiIngredientsSheet(),
      ),
    );
  }

  void _showCalorieCalculator(BuildContext context, {MealType? initialType, String? replaceMealId}) {
    final nutritionBloc = context.read<NutritionBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: nutritionBloc,
        child: _CalorieCalculatorSheet(initialType: initialType, replaceMealId: replaceMealId),
      ),
    );
  }

  Widget _buildAIAnalysis(NutritionState state) {
    String analysis = 'Начните записывать приемы пищи, чтобы получить персональный анализ.';
    if (state.consumedCalories > 0) {
      if (state.proteinConsumed < (state.proteinTarget * 0.5)) {
        analysis = 'Сегодня у вас дефицит белка. Попробуйте добавить в рацион творог или яйца.';
      } else if (state.remainingCalories < 0) {
        analysis = 'Вы превысили норму калорий. Постарайтесь сегодня быть более активным.';
      } else {
        analysis = 'Ваш рацион сбалансирован. Вы отлично придерживаетесь плана!';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _limeAccent.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: _limeAccent, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Совет',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  analysis,
                  style: const TextStyle(
                    color: _textGrey,
                    fontSize: 13,
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

  Widget _buildMealList(BuildContext context, NutritionState state) {
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
        _buildMealSection(context, state, MealType.breakfast, 'Завтрак'),
        const SizedBox(height: 16),
        _buildMealSection(context, state, MealType.lunch, 'Обед'),
        const SizedBox(height: 16),
        _buildMealSection(context, state, MealType.dinner, 'Ужин'),
      ],
    );
  }

  Widget _buildMealSection(BuildContext context, NutritionState state, MealType type, String title) {
    final meals = state.meals.where((m) => m.type == type).toList();
    
    if (meals.isEmpty) {
      return _buildEmptyMealCard(context, title, type);
    }

    return Column(
      children: meals.map((meal) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Dismissible(
          key: Key(meal.id),
          direction: DismissDirection.horizontal,
          background: _buildDismissBackground(Alignment.centerLeft, Colors.redAccent, Icons.delete_rounded, "Удалить"),
          secondaryBackground: _buildDismissBackground(Alignment.centerRight, Colors.blueAccent, Icons.edit_rounded, "Изменить"),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              context.read<NutritionBloc>().add(NutritionMealDeleted(meal.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${meal.title} удален"), backgroundColor: Colors.redAccent)
              );
            }
          },
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Edit action
              _showCalorieCalculator(context, initialType: meal.type, replaceMealId: meal.id);
              return false; // Don't dismiss the item
            }
            return true; // Dismiss for deletion
          },
          child: _buildMealCard(
            title: meal.title,
            calories: '${meal.calories} ккал',
            imageUrl: meal.imageUrl,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDismissBackground(Alignment alignment, Color color, IconData icon, String label) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft 
          ? [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ]
          : [
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 12),
              Icon(icon, color: color, size: 24),
            ],
      ),
    );
  }

  Widget _buildMealCard({
    required String title,
    required String calories,
    required String imageUrl,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: _cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF2C2C2E),
                  child: const Icon(Icons.restaurant_rounded, color: Colors.white10, size: 40),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _limeAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _limeAccent.withOpacity(0.2)),
                    ),
                    child: Text(
                      calories,
                      style: const TextStyle(
                        color: _limeAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMealCard(BuildContext context, String title, MealType type) {
    return CustomPaint(
      painter: DottedBorderPainter(
        color: Colors.white.withValues(alpha: 0.1),
        radius: 24,
      ),
      child: Container(
        height: 100,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _showCalorieCalculator(context, initialType: type),
              style: ElevatedButton.styleFrom(
                backgroundColor: _limeAccent,
                foregroundColor: Colors.black,
                elevation: 8,
                shadowColor: _limeAccent.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Добавить',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
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
  final Color activeColor;
  final Color inactiveColor;

  CalorieRingPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 14.0;

    // Background track
    final trackPaint = Paint()
      ..color = inactiveColor
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
      trackPaint,
    );

    if (progress > 0) {
      // Glow effect
      final glowPaint = Paint()
        ..color = activeColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        totalSweepAngle * progress,
        false,
        glowPaint,
      );

      // Main progress arc
      final progressPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        totalSweepAngle * progress,
        false,
        progressPaint,
      );
    }
    
    // Draw tick marks like the home page
    final tickPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const totalTicks = 40;
    const tickLength = 6.0;
    
    for (int i = 0; i <= totalTicks; i++) {
      final angle = startAngle + (i / totalTicks) * totalSweepAngle;
      final isTickActive = (i / totalTicks) <= progress && progress > 0;

      tickPaint.color = isTickActive ? activeColor : inactiveColor.withOpacity(0.5);
      tickPaint.strokeWidth = 1.5;

      final innerPoint = Offset(
        center.dx + (radius - strokeWidth - tickLength - 4) * math.cos(angle),
        center.dy + (radius - strokeWidth - tickLength - 4) * math.sin(angle),
      );

      final outerPoint = Offset(
        center.dx + (radius - strokeWidth - 4) * math.cos(angle),
        center.dy + (radius - strokeWidth - 4) * math.sin(angle),
      );

      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CalorieRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
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

class _ProgressCalendarSheet extends StatelessWidget {
  final DateTime initialDate;
  final Map<DateTime, double> historyProgress;
  final Function(DateTime) onDateSelected;

  const _ProgressCalendarSheet({
    required this.initialDate,
    required this.historyProgress,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "Календарь прогресса",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: _limeAccent,
                  onPrimary: Colors.black,
                  surface: _bgColor,
                  onSurface: Colors.white,
                ),
                dialogBackgroundColor: _bgColor,
              ),
              child: CalendarDatePicker(
                initialDate: initialDate,
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
                onDateChanged: (date) {
                  onDateSelected(date);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          _buildLegend(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(Colors.greenAccent, "Норма соблюдена"),
          const SizedBox(width: 24),
          _buildLegendItem(Colors.redAccent, "Перебор ккал"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: _textGrey, fontSize: 12)),
      ],
    );
  }
}

class _AiIngredientsSheet extends StatefulWidget {
  const _AiIngredientsSheet({super.key});

  @override
  State<_AiIngredientsSheet> createState() => _AiIngredientsSheetState();
}

class _AiIngredientsSheetState extends State<_AiIngredientsSheet> {
  final TextEditingController _ingredientsController = TextEditingController();
  bool _isAnalyzing = false;
  List<Map<String, dynamic>>? _suggestions;
  Map<String, dynamic>? _selectedResult;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = ''; // Store previously recognized text

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() {
          _isListening = true;
          // Remember current text to append to it
          _lastWords = _ingredientsController.text;
        });
        
        _speech.listen(
          onResult: (val) => setState(() {
            // Append recognized words to the original text
            String newText = _lastWords;
            if (newText.isNotEmpty && val.recognizedWords.isNotEmpty) {
              newText += " ";
            }
            _ingredientsController.text = newText + val.recognizedWords;
          }),
          localeId: 'ru_RU',
          listenFor: const Duration(minutes: 2), // Full 2 minutes of total recording
          pauseFor: const Duration(seconds: 20),  // Wait 20 seconds of silence!
          cancelOnError: false,
          partialResults: true,
          listenMode: stt.ListenMode.dictation, // Use dictation mode for better long-form support
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _analyzeIngredients() async {
    if (_ingredientsController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _suggestions = null;
      _selectedResult = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _suggestions = [
          {
            'name': 'Омлет с овощами',
            'cal': 320,
            'p': 18,
            'f': 22,
            'c': 12,
            'desc': 'Легкий и питательный завтрак. Взбейте яйца, добавьте нарезанные овощи и обжарьте на небольшом количестве масла.',
          },
          {
            'name': 'Салат с курицей',
            'cal': 410,
            'p': 32,
            'f': 15,
            'c': 28,
            'desc': 'Сбалансированное блюдо для обеда. Нарежьте курицу и овощи, заправьте оливковым маслом или лимонным соком.',
          },
          {
            'name': 'Стир-фрай из остатков',
            'cal': 380,
            'p': 25,
            'f': 18,
            'c': 35,
            'desc': 'Быстрый способ приготовить все сразу. Обжарьте все ингредиенты на сильном огне с соевым соусом.',
          },
        ];
      });
    }
  }

  void _addMeal(MealType type) {
    if (_selectedResult == null) return;

    context.read<NutritionBloc>().add(NutritionMealAdded(
          title: _selectedResult!['name'],
          calories: _selectedResult!['cal'],
          protein: _selectedResult!['p'],
          fat: _selectedResult!['f'],
          carbs: _selectedResult!['c'],
          type: type,
        ));

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${_selectedResult!['name']} добавлен"),
        backgroundColor: _limeAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (_selectedResult != null)
                IconButton(
                  onPressed: () => setState(() => _selectedResult = null),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _limeAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: _limeAccent, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "ИИ Рецепт",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isAnalyzing) {
      return const Center(child: CircularProgressIndicator(color: _limeAccent));
    }

    if (_selectedResult != null) {
      return _buildResultView();
    }

    if (_suggestions != null) {
      return _buildSuggestionsList();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Перечислите ингредиенты, которые у вас есть, и ИИ предложит, что приготовить",
            style: TextStyle(color: _textGrey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ingredientsController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Например: 2 яйца, 100г курицы, шпинат...",
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              filled: true,
              fillColor: _cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  onPressed: _listen,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.redAccent : _limeAccent,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _analyzeIngredients,
              style: ElevatedButton.styleFrom(
                backgroundColor: _limeAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text("РАССЧИТАТЬ ЧЕРЕЗ ИИ", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ИИ предлагает варианты:",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _suggestions!.length,
            itemBuilder: (context, index) {
              final item = _suggestions![index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () => setState(() => _selectedResult = item),
                  title: Text(
                    item['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${item['cal']} ккал",
                    style: const TextStyle(color: _limeAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: _textGrey, size: 16),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => setState(() => _suggestions = null),
            child: const Text("Изменить ингредиенты", style: TextStyle(color: _textGrey)),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            "${_selectedResult!['cal']}",
            style: const TextStyle(color: _limeAccent, fontSize: 64, fontWeight: FontWeight.bold),
          ),
          const Text("ккал в блюде", style: TextStyle(color: _textGrey, fontSize: 16)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientSmall("Белки", "${_selectedResult!['p']}г", const Color(0xFFFF7B5C)),
              _buildNutrientSmall("Жиры", "${_selectedResult!['f']}г", const Color(0xFFFFD600)),
              _buildNutrientSmall("Углеводы", "${_selectedResult!['c']}г", const Color(0xFF00E5FF)),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Text(
              _selectedResult!['desc'],
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 32),
          const Text("Добавить как:", style: TextStyle(color: _textGrey, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTypeAddButton(MealType.breakfast, "Завтрак")),
              const SizedBox(width: 8),
              Expanded(child: _buildTypeAddButton(MealType.lunch, "Обед")),
              const SizedBox(width: 8),
              Expanded(child: _buildTypeAddButton(MealType.dinner, "Ужин")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeAddButton(MealType type, String label) {
    return ElevatedButton(
      onPressed: () => _addMeal(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: _cardColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildNutrientSmall(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _CalorieCalculatorSheet extends StatefulWidget {
  final MealType? initialType;
  final String? replaceMealId;

  const _CalorieCalculatorSheet({this.initialType, this.replaceMealId});

  @override
  State<_CalorieCalculatorSheet> createState() => _CalorieCalculatorSheetState();
}

class _CalorieCalculatorSheetState extends State<_CalorieCalculatorSheet> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _mockFoods = [
    {'name': 'Куриная грудка', 'cal': 165, 'p': 31, 'f': 3, 'c': 0, 'unit': 'г'},
    {'name': 'Яйцо вареное', 'cal': 70, 'p': 6, 'f': 5, 'c': 0, 'unit': 'шт'},
    {'name': 'Творог 5%', 'cal': 121, 'p': 17, 'f': 5, 'c': 3, 'unit': 'г'},
    {'name': 'Овсянка на воде', 'cal': 68, 'p': 2, 'f': 1, 'c': 12, 'unit': 'г'},
    {'name': 'Банан', 'cal': 105, 'p': 1, 'f': 0, 'c': 27, 'unit': 'шт'},
    {'name': 'Кофе с молоком', 'cal': 45, 'p': 2, 'f': 2, 'c': 5, 'unit': 'мл'},
    {'name': 'Гречка отварная', 'cal': 110, 'p': 4, 'f': 1, 'c': 21, 'unit': 'г'},
    {'name': 'Авокадо', 'cal': 160, 'p': 2, 'f': 15, 'c': 9, 'unit': 'г'},
    {'name': 'Протеиновый батончик', 'cal': 210, 'p': 20, 'f': 7, 'c': 15, 'unit': 'шт'},
    {'name': 'Яблоко', 'cal': 52, 'p': 0, 'f': 0, 'c': 14, 'unit': 'шт'},
    {'name': 'Лосось запеченный', 'cal': 208, 'p': 20, 'f': 13, 'c': 0, 'unit': 'г'},
    {'name': 'Рис белый отварной', 'cal': 130, 'p': 3, 'f': 0, 'c': 28, 'unit': 'г'},
    {'name': 'Орехи микс', 'cal': 607, 'p': 15, 'f': 54, 'c': 18, 'unit': 'г'},
    {'name': 'Йогурт натуральный', 'cal': 59, 'p': 3, 'f': 3, 'c': 4, 'unit': 'г'},
  ];

  List<Map<String, dynamic>> _filteredFoods = [];
  Map<String, dynamic>? _selectedFood;
  double _amount = 100;
  late MealType _selectedType;

  @override
  void initState() {
    super.initState();
    _filteredFoods = _mockFoods;
    _selectedType = widget.initialType ?? MealType.breakfast;
  }

  void _filterFoods(String query) {
    setState(() {
      _filteredFoods = _mockFoods
          .where((food) => food['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectFood(Map<String, dynamic> food) {
    setState(() {
      _selectedFood = food;
      _amount = food['unit'] == 'шт' ? 1 : 100;
    });
  }

  void _addFood() {
    if (_selectedFood == null) return;

    final double factor = _selectedFood!['unit'] == 'шт' ? _amount : _amount / 100;
    
    context.read<NutritionBloc>().add(NutritionMealAdded(
      title: "${_selectedFood!['name']} (${_amount.toInt()}${_selectedFood!['unit']})",
      calories: (_selectedFood!['cal'] * factor).round(),
      protein: (_selectedFood!['p'] * factor).round(),
      fat: (_selectedFood!['f'] * factor).round(),
      carbs: (_selectedFood!['c'] * factor).round(),
      type: _selectedType,
      replaceMealId: widget.replaceMealId,
    ));

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${_selectedFood!['name']} добавлен"),
        backgroundColor: _limeAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectedFood == null ? _buildSearchList() : _buildFoodDetail(),
      ),
    );
  }

  Widget _buildSearchList() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Калькулятор",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
        _buildTypeSelector(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: _searchController,
            onChanged: _filterFoods,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Поиск продуктов...",
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.3)),
              filled: true,
              fillColor: _cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _filteredFoods.length,
            itemBuilder: (context, index) {
              final food = _filteredFoods[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () => _selectFood(food),
                  title: Text(
                    food['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Б: ${food['p']}г  Ж: ${food['f']}г  У: ${food['c']}г",
                      style: const TextStyle(color: _textGrey, fontSize: 12),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${food['cal']}",
                        style: const TextStyle(color: _limeAccent, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Text(
                        "ккал / 100г",
                        style: TextStyle(color: _textGrey, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildTypeOption(MealType.breakfast, "Завтрак"),
          const SizedBox(width: 8),
          _buildTypeOption(MealType.lunch, "Обед"),
          const SizedBox(width: 8),
          _buildTypeOption(MealType.dinner, "Ужин"),
        ],
      ),
    );
  }

  Widget _buildTypeOption(MealType type, String label) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _limeAccent : _cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _limeAccent : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodDetail() {
    final food = _selectedFood!;
    final double factor = food['unit'] == 'шт' ? _amount : _amount / 100;
    final int calories = (food['cal'] * factor).round();

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedFood = null),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  food['name'],
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "$calories",
                  style: const TextStyle(color: _limeAccent, fontSize: 72, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "килокалорий",
                  style: TextStyle(color: _textGrey, fontSize: 16),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientInfo("Белки", (food['p'] * factor).toStringAsFixed(1), const Color(0xFFFF7B5C)),
                    _buildNutrientInfo("Жиры", (food['f'] * factor).toStringAsFixed(1), const Color(0xFFFFD600)),
                    _buildNutrientInfo("Углеводы", (food['c'] * factor).toStringAsFixed(1), const Color(0xFF00E5FF)),
                  ],
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Количество",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${_amount.toInt()} ${food['unit']}",
                      style: const TextStyle(color: _limeAccent, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _limeAccent,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                    thumbColor: Colors.white,
                    overlayColor: _limeAccent.withValues(alpha: 0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _amount,
                    min: food['unit'] == 'шт' ? 0.5 : 10,
                    max: food['unit'] == 'шт' ? 10 : 1000,
                    divisions: food['unit'] == 'шт' ? 19 : 99,
                    onChanged: (value) => setState(() => _amount = value),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _addFood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _limeAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: _limeAccent.withValues(alpha: 0.4),
                    ),
                    child: const Text(
                      "ДОБАВИТЬ В ДНЕВНИК",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
