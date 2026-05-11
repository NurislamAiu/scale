import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scale/features/profile/domain/usecases/fitness_advisor.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/scale/domain/usecases/body_composition_calculator.dart';
import 'package:smart_scale/features/scale/presentation/bloc/scale_bloc.dart';

import '../../../subscription/presentation/pages/paywall_page.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;

        return Scaffold(
          backgroundColor: _bgColor,
          appBar: AppBar(
            backgroundColor: _bgColor,
            elevation: 0,
            title: const Text(
              "Профиль",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildProfileHeader(context, profile),
                const SizedBox(height: 20),
                _buildPremiumCard(context),
                const SizedBox(height: 20),
                _buildQuickStats(profile),
                const SizedBox(height: 20),
                if (profile != null) _buildRecommendationsSection(context, profile),
                const SizedBox(height: 20),
                _buildSettingsMenu(context, profile),
                const SizedBox(height: 40),
                _buildLogoutButton(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PaywallPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_limeAccent, _limeAccent.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Разблокировать PRO",
                    style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "Безлимитный ИИ и аналитика",
                    style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black, size: 28),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Эта функция находится в разработке",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _limeAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile? profile) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: _limeAccent.withValues(alpha: 0.5), width: 2),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 50,
                color: _textGrey,
              ),
            ),
            GestureDetector(
              onTap: () => _showComingSoon(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: _limeAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "Yoda Health",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "yoda@example.com",
          style: TextStyle(
            color: _textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(UserProfile? profile) {
    final height = profile?.heightCm.toString() ?? "175";
    final age = profile?.ageYears.toString() ?? "25";
    final target = profile?.targetWeightKg != null 
        ? profile!.targetWeightKg!.toStringAsFixed(1) 
        : "--";

    return Row(
      children: [
        Expanded(child: _buildStatBox("Рост", height, "см")),
        const SizedBox(width: 16),
        Expanded(child: _buildStatBox("Возраст", age, "лет")),
        const SizedBox(width: 16),
        Expanded(child: _buildStatBox("Цель", target, "кг")),
      ],
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, UserProfile profile) {
    return BlocBuilder<ScaleBloc, ScaleState>(
      builder: (context, scaleState) {
        final currentWeight = scaleState.lastMeasurement?.weightKg ?? 70.0;
        final comp = BodyCompositionCalculator.calculate(weightKg: currentWeight, profile: profile);
        final plan = FitnessAdvisor.getNutritionPlan(profile, currentWeight, comp.tdee);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Рекомендации",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  _getGoalLabel(profile.fitnessGoal),
                  style: const TextStyle(color: _limeAccent, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNutritionCard(plan),
            const SizedBox(height: 16),
            _buildWorkoutPlanCard(profile.fitnessGoal),
          ],
        );
      },
    );
  }

  String _getGoalLabel(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.weightLoss: return "Похудение";
      case FitnessGoal.maintenance: return "Поддержание";
      case FitnessGoal.massGain: return "Набор массы";
      case FitnessGoal.aggressiveWeightLoss: return "Сушка";
    }
  }

  Widget _buildNutritionCard(NutritionPlan plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _limeAccent.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_rounded, color: _limeAccent, size: 20),
              const SizedBox(width: 8),
              const Text("План питания", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text("${plan.calories.toInt()} ккал", style: const TextStyle(color: _limeAccent, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          Text(plan.message, style: const TextStyle(color: _textGrey, fontSize: 13)),
          if (plan.weeksToGoal != null) ...[
            const SizedBox(height: 8),
            Text("Прогноз: цель через ${plan.weeksToGoal} недель", style: const TextStyle(color: _limeAccent, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroItem("Белки", plan.proteinG, Colors.orangeAccent),
              _buildMacroItem("Жиры", plan.fatG, Colors.blueAccent),
              _buildMacroItem("Углеводы", plan.carbsG, Colors.greenAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, double grams, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: _textGrey, fontSize: 11)),
        const SizedBox(height: 4),
        Text("${grams.toInt()}г", style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildWorkoutPlanCard(FitnessGoal goal) {
    final title = _getWorkoutTitle(goal);
    final description = _getWorkoutDescription(goal);

    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center_rounded, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                const Text("Тренировочный план", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showYodaEcosystemSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _limeAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _limeAccent.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      "Подробнее",
                      style: TextStyle(color: _limeAccent, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(color: _textGrey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showYodaEcosystemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).padding.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 28),
            // Заголовок
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFD4FF45), Color(0xFF8FD400)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, color: Colors.black, size: 22),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Экосистема Yoda", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    Text("Следующий уровень тренировок", style: TextStyle(color: _textGrey, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Карточка Yoda Run
            _buildEcoCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A2A1A), Color(0xFF0F1F0F)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderColor: _limeAccent.withValues(alpha: 0.3),
              icon: Icons.directions_run_rounded,
              iconColor: _limeAccent,
              badge: "APP",
              badgeColor: _limeAccent,
              title: "Yoda Run",
              subtitle: "Умный бег с ИИ-тренером",
              features: const ["GPS-трекинг маршрутов", "ИИ строит план бега", "Анализ темпа и пульса"],
              buttonLabel: "Скачать бесплатно",
              buttonColor: _limeAccent,
              buttonTextColor: Colors.black,
            ),

            const SizedBox(height: 16),

            // Карточка Yoda Band
            _buildEcoCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1F)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderColor: const Color(0xFF4A7DFF).withValues(alpha: 0.4),
              icon: Icons.watch_rounded,
              iconColor: const Color(0xFF4A7DFF),
              badge: "NEW",
              badgeColor: const Color(0xFF4A7DFF),
              title: "Yoda Band",
              subtitle: "Умный браслет нового поколения",
              features: const ["Мониторинг восстановления 24/7", "HRV, SpO₂, стресс-индекс", "Интеграция с Yoda Health"],
              buttonLabel: "Узнать больше",
              buttonColor: const Color(0xFF4A7DFF),
              buttonTextColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoCard({
    required Gradient gradient,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String badge,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required List<String> features,
    required String buttonLabel,
    required Color buttonColor,
    required Color buttonTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(badge, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    Text(subtitle, style: TextStyle(color: iconColor.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: iconColor, size: 16),
                const SizedBox(width: 10),
                Text(f, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonTextColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  String _getWorkoutTitle(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.weightLoss: return "3x Кардио + 2x Силовая (Full Body)";
      case FitnessGoal.maintenance: return "3-4x Смешанные тренировки";
      case FitnessGoal.massGain: return "Push / Pull / Legs (3-4 раза в неделю)";
      case FitnessGoal.aggressiveWeightLoss: return "4x Силовая + Ежедневное кардио";
    }
  }

  String _getWorkoutDescription(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.weightLoss: return "Фокус на сжигание калорий и поддержание тонуса мышц. Ходьба 10к шагов ежедневно.";
      case FitnessGoal.maintenance: return "Поддержание формы, работа над выносливостью и гибкостью.";
      case FitnessGoal.massGain: return "Акцент на прогрессию весов в базовых упражнениях и профицит калорий.";
      case FitnessGoal.aggressiveWeightLoss: return "Высокая интенсивность для максимального рельефа при сохранении мышц.";
    }
  }

  Widget _buildStatBox(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(
                  color: _limeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu(BuildContext context, UserProfile? profile) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline_rounded, "Личные данные", () {
            if (profile != null) {
              context.push('/profile/edit', extra: profile);
            }
          }),
          _buildDivider(),
          _buildMenuItem(Icons.bluetooth_connected_rounded, "Мои устройства", () => context.push('/profile/my-devices')),
          _buildDivider(),
          _buildMenuItem(Icons.straighten_rounded, "Единицы измерения", () => _showUnitsBottomSheet(context)),
          _buildDivider(),
          _buildMenuItem(Icons.notifications_none_rounded, "Напоминания", () => context.push('/profile/reminders')),
          _buildDivider(),
          _buildMenuItem(Icons.help_outline_rounded, "Помощь и поддержка", () => _showComingSoon(context)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF4A7DFF), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: _textGrey,
        size: 24,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 20),
      child: Divider(
        color: Colors.white.withValues(alpha: 0.05),
        height: 1,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          _showLogoutDialog(context);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Выйти из аккаунта",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bContext) => Container(
        decoration: const BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 24),
            const Text(
              "Выход из аккаунта",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Вы уверены, что хотите выйти? Локальные данные профиля будут удалены.",
              textAlign: TextAlign.center,
              style: TextStyle(color: _textGrey, fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: TextButton(
                      onPressed: () => Navigator.pop(bContext),
                      child: const Text("Отмена", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(bContext);
                        context.read<ProfileBloc>().add(const ProfileClearRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                        foregroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Выйти", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUnitsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Единицы измерения",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildUnitRadio("Метрическая (кг, см)", true, bContext),
                const SizedBox(height: 12),
                _buildUnitRadio("Имперская (фунты, футы)", false, bContext),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnitRadio(String title, bool isSelected, BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pop();
        // Тут можно было бы менять настройки, но пока просто визуал
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? _limeAccent.withValues(alpha: 0.1) : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _limeAccent : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? _limeAccent : _textGrey,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : _textGrey,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
