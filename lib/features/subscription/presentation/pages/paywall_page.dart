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
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
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
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _ProRingPainter(color: _limeAccent),
              ),
            ),
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: _cardColor,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.workspace_premium_rounded, color: _limeAccent, size: 38),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          "Yoda PRO",
          style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        const Text(
          "Разблокируйте полную мощь ИИ",
          textAlign: TextAlign.center,
          style: TextStyle(color: _textGrey, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: [
        _buildFeatureItem(Icons.chat_bubble_outline_rounded, "Безлимитный ИИ-чат", "Задавайте любые вопросы без ограничений"),
        const SizedBox(height: 20),
        _buildFeatureItem(Icons.analytics_outlined, "Глубокий анализ", "Персональные инсайты на основе ваших данных"),
        const SizedBox(height: 20),
        _buildFeatureItem(Icons.restaurant_menu_rounded, "Планы питания", "Индивидуальное КБЖУ под ваши цели"),
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
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(desc, style: const TextStyle(color: _textGrey, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlans() {
    return Row(
      children: [
        Expanded(
          child: _buildPlanCard(
            index: 0,
            title: "1 Month",
            price: "\$4.99",
            subPrice: "\$0.16 / day",
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPlanCard(
            index: 1,
            title: "1 Year",
            price: "\$29.99",
            subPrice: "\$2.50 / mo",
            isBest: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({required int index, required String title, required String price, required String subPrice, bool isBest = false}) {
    final isSelected = _selectedPlan == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? _limeAccent : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: _limeAccent.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Column(
              children: [
                Text(title, style: TextStyle(color: isSelected ? Colors.white : _textGrey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(price, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subPrice, style: const TextStyle(color: _textGrey, fontSize: 11)),
              ],
            ),
          ),
          if (isBest)
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _limeAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "ВЫГОДНО",
                    style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                shadowColor: _limeAccent.withValues(alpha: 0.3),
              ),
              child: const Text("ПОПРОБОВАТЬ БЕСПЛАТНО", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ),
          ),
          const SizedBox(height: 16),
          const Text("7 дней бесплатно, далее по тарифу", style: TextStyle(color: _textGrey, fontSize: 12)),
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
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Внешние деления (как на Home Page)
    for (int i = 0; i < 40; i++) {
      final angle = (i / 40) * 2 * 3.14159;
      final isLong = i % 10 == 0;
      final tickLength = isLong ? 10.0 : 5.0;

      final innerPoint = Offset(
        center.dx + (radius - tickLength) * 0.9 * math.cos(angle),
        center.dy + (radius - tickLength) * 0.9 * math.sin(angle),
      );
      final outerPoint = Offset(
        center.dx + radius * 0.9 * math.cos(angle),
        center.dy + radius * 0.9 * math.sin(angle),
      );

      canvas.drawLine(innerPoint, outerPoint, paint);
    }

    // Светящаяся дуга
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.75),
      -3.14159 / 2,
      4.5, // Почти полный круг
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
