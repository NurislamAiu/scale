import 'dart:ui';

import 'package:flutter/material.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);
const Color _softBlue = Color(0xFF64D2FF);

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  int _selectedPlan = 1;

  static const List<_Plan> _plans = [
    _Plan(
      title: 'Месяц',
      price: '\$4.99',
      period: 'в месяц',
      note: 'Без обязательств',
      badge: 'Гибкий старт',
      trialText: '7 дней бесплатно',
    ),
    _Plan(
      title: 'Год',
      price: '\$29.99',
      period: 'в год',
      note: 'Всего \$2.50 в месяц',
      badge: 'Экономия 50%',
      trialText: '7 дней бесплатно',
      isBest: true,
    ),
  ];

  _Plan get _selected => _plans[_selectedPlan];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          Positioned(
            top: -170,
            right: -120,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _limeAccent.withValues(alpha: 0.12),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            top: 160,
            left: -140,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _softBlue.withValues(alpha: 0.06),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHero(),
                        const SizedBox(height: 22),
                        _buildValueStrip(),
                        const SizedBox(height: 22),
                        _buildFeatureGrid(),
                        const SizedBox(height: 24),
                        _buildPlans(),
                        const SizedBox(height: 14),
                        _buildTrustNotes(),
                      ],
                    ),
                  ),
                ),
                _buildBottomCta(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon:
                const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded,
                    color: _limeAccent, size: 16),
                SizedBox(width: 6),
                Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _limeAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _limeAccent.withValues(alpha: 0.18)),
          ),
          child: const Text(
            'Yoda PRO',
            style: TextStyle(
              color: _limeAccent,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Персональный тренер по телу, питанию и прогрессу',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Yoda анализирует ваши измерения с весов, объясняет изменения в теле и помогает держать план без ручных таблиц.',
          style: TextStyle(
            color: _textGrey,
            fontSize: 15,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildValueStrip() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _MiniValue(
              value: '24/7',
              label: 'ИИ-консультант',
              color: _limeAccent,
            ),
          ),
          _DividerLine(),
          Expanded(
            child: _MiniValue(
              value: 'КБЖУ',
              label: 'под вашу цель',
              color: _softBlue,
            ),
          ),
          _DividerLine(),
          Expanded(
            child: _MiniValue(
              value: 'PRO',
              label: 'инсайты тела',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.psychology_alt_rounded,
                title: 'ИИ объяснит цифры',
                text:
                    'Что значит вес, жир, вода и мышцы именно для вашей цели.',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                icon: Icons.restaurant_menu_rounded,
                title: 'Питание без догадок',
                text: 'Калории, белки, жиры и углеводы под текущий прогресс.',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.insights_rounded,
                title: 'Прогноз результата',
                text: 'Показывает тренд и помогает понять, что менять дальше.',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                icon: Icons.chat_bubble_rounded,
                title: 'Безлимитный чат',
                text:
                    'Вопросы про питание, вес, тренировки и привычки без лимита.',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Выберите тариф',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _plans.length; i++) ...[
          _PlanCard(
            plan: _plans[i],
            selected: _selectedPlan == i,
            onTap: () => setState(() => _selectedPlan = i),
          ),
          if (i != _plans.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildTrustNotes() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_rounded, color: _limeAccent, size: 16),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'Можно отменить в любой момент. Оплата после пробного периода.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textGrey, fontSize: 12, height: 1.35),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCta() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: _bgColor.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _limeAccent,
                foregroundColor: Colors.black,
                elevation: 12,
                shadowColor: _limeAccent.withValues(alpha: 0.25),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ),
              child: const Text(
                'Попробовать 7 дней бесплатно',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Затем ${_selected.price} ${_selected.period}. ${_selected.note}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Plan {
  final String title;
  final String price;
  final String period;
  final String note;
  final String badge;
  final String trialText;
  final bool isBest;

  const _Plan({
    required this.title,
    required this.price,
    required this.period,
    required this.note,
    required this.badge,
    required this.trialText,
    this.isBest = false,
  });
}

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? _limeAccent.withValues(alpha: 0.08) : _cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color:
                selected ? _limeAccent : Colors.white.withValues(alpha: 0.07),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: _limeAccent.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          plan.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: plan.isBest
                              ? _limeAccent
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          plan.badge,
                          style: TextStyle(
                            color: plan.isBest ? Colors.black : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plan.trialText,
                    style: TextStyle(
                      color: selected ? _limeAccent : _textGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.note,
                    style: const TextStyle(
                      color: _textGrey,
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  plan.period,
                  style: const TextStyle(
                    color: _textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? _limeAccent : _textGrey,
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 156),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _limeAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: _limeAccent, size: 21),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: _textGrey,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniValue extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MiniValue({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _textGrey,
            fontSize: 11,
            height: 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}
