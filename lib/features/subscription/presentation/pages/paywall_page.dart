import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  int _selectedPlan = 1; // 0: Monthly, 1: Yearly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // Декоративный свет сверху
          Positioned(
            top: -150,
            left: -50,
            right: -50,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _limeAccent.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildFeatures(),
                        const SizedBox(height: 48),
                        _buildPlans(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon:
                const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _ProRingPainter(color: _limeAccent),
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: _limeAccent.withValues(alpha: 0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _limeAccent.withValues(alpha: 0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const Center(
                child: Icon(Icons.workspace_premium_rounded,
                    color: _limeAccent, size: 36),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          "Yoda PRO",
          style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        const Text(
          "Разблокируйте полную мощь ИИ",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: _textGrey, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: [
        _buildFeatureItem(Icons.chat_bubble_outline_rounded,
            "Безлимитный ИИ-чат", "Задавайте любые вопросы без ограничений"),
        const SizedBox(height: 20),
        _buildFeatureItem(Icons.analytics_outlined, "Глубокий анализ",
            "Персональные инсайты на основе ваших данных"),
        const SizedBox(height: 20),
        _buildFeatureItem(Icons.restaurant_menu_rounded, "Планы питания",
            "Индивидуальное КБЖУ под ваши цели"),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String desc) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Icon(icon, color: _limeAccent, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text(desc,
                  style: const TextStyle(color: _textGrey, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlans() {
    return Column(
      children: [
        _buildPlanCard(
          index: 1,
          title: "ANNUAL SUBSCRIPTION",
          price: "\$29.99",
          subPrice: "\$2.50 / month",
          isBest: true,
          description: "Best choice for long-term health goals",
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          index: 0,
          title: "MONTHLY SUBSCRIPTION",
          price: "\$4.99",
          subPrice: "\$0.16 / day",
          description: "Flexible plan for a quick start",
        ),
      ],
    );
  }

  Widget _buildPlanCard(
      {required int index,
      required String title,
      required String price,
      required String subPrice,
      required String description,
      bool isBest = false}) {
    final isSelected = _selectedPlan == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? _limeAccent.withValues(alpha: 0.05) : _cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? _limeAccent
                : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: _limeAccent.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: isSelected ? _limeAccent : _textGrey,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1)),
                      ),
                      if (isBest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _limeAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text("ВЫГОДНО", style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(description, style: TextStyle(color: isSelected ? Colors.white70 : _textGrey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(subPrice, style: TextStyle(color: isSelected ? _limeAccent.withValues(alpha: 0.7) : _textGrey.withValues(alpha: 0.5), fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900)),
                Icon(isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, color: isSelected ? _limeAccent : _textGrey, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () {
                // Логика оплаты
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _limeAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                shadowColor: _limeAccent.withValues(alpha: 0.3),
              ),
              child: const Text("ПОПРОБОВАТЬ БЕСПЛАТНО",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5)),
            ),
          ),
          const SizedBox(height: 16),
          const Text("7 дней бесплатно, далее по тарифу",
              style: TextStyle(color: _textGrey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ProRingPainter extends CustomPainter {
  final Color color;

  _ProRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Внешние деления (как на Home Page)
    const int totalTicks = 60;
    for (int i = 0; i < totalTicks; i++) {
      final angle = (i / totalTicks) * 2 * math.pi;
      final isLong = i % 15 == 0;
      final tickLength = isLong ? 12.0 : 6.0;

      final innerPoint = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );
      final outerPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.drawLine(innerPoint, outerPoint, paint);
    }

    // Светящаяся дуга прогресса
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Свечение под дугой
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    const startAngle = -math.pi / 2;
    const sweepAngle = 1.6 * math.pi; // Неполный круг для красоты

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 20),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 20),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
