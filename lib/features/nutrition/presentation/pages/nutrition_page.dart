import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                _buildAppBar(),
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
                              _buildCalculatorButton(context),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Text(
            "Питание",
            style: TextStyle(
              color: _limeAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: _limeAccent, size: 20),
            onPressed: () {},
          ),
        ],
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _limeAccent,
              _limeAccent.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _limeAccent.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calculate_rounded, color: Colors.black, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Подсчет калорий",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    "Добавьте продукты или блюда",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 18),
          ],
        ),
      ),
    );
  }

  void _showCalorieCalculator(BuildContext context, {MealType? initialType}) {
    final nutritionBloc = context.read<NutritionBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: nutritionBloc,
        child: _CalorieCalculatorSheet(initialType: initialType),
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
              _showCalorieCalculator(context, initialType: meal.type);
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
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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

class _CalorieCalculatorSheet extends StatefulWidget {
  final MealType? initialType;

  const _CalorieCalculatorSheet({this.initialType});

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
