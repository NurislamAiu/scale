import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scale/core/presentation/bloc/language_bloc.dart';
import 'package:smart_scale/features/profile/domain/usecases/fitness_advisor.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/scale/domain/usecases/body_composition_calculator.dart';
import 'package:smart_scale/features/scale/presentation/bloc/scale_bloc.dart';

import '../../../../l10n/app_localizations.dart';
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
                if (profile != null)
                  _buildRecommendationsSection(context, profile),
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
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PaywallPage()));
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
              child:
                  const Icon(Icons.auto_awesome, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Разблокировать PRO",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "Безлимитный ИИ и аналитика",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.black, size: 28),
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
                border: Border.all(
                    color: _limeAccent.withValues(alpha: 0.5), width: 2),
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
          "Yoda",
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

  Widget _buildRecommendationsSection(
      BuildContext context, UserProfile profile) {
    return BlocBuilder<ScaleBloc, ScaleState>(
      builder: (context, scaleState) {
        final currentWeight = scaleState.lastMeasurement?.weightKg ?? 70.0;
        final comp = BodyCompositionCalculator.calculate(
            weightKg: currentWeight, profile: profile);
        final plan =
            FitnessAdvisor.getNutritionPlan(profile, currentWeight, comp.tdee);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Рекомендации",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  _getGoalLabel(profile.fitnessGoal),
                  style: const TextStyle(
                      color: _limeAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
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
              const Icon(Icons.restaurant_rounded,
                  color: _limeAccent, size: 20),
              const SizedBox(width: 8),
              const Text("План питания",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Text("${plan.calories.toInt()} ккал",
                  style: const TextStyle(
                      color: _limeAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          Text(plan.message,
              style: const TextStyle(color: _textGrey, fontSize: 13)),
          if (plan.weeksToGoal != null) ...[
            const SizedBox(height: 8),
            Text("Прогноз: цель через ${plan.weeksToGoal} недель",
                style: const TextStyle(
                    color: _limeAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
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
        Text("${grams.toInt()}г",
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold)),
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
                const Icon(Icons.fitness_center_rounded,
                    color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                const Text("Тренировочный план",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showYodaEcosystemSheet(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _limeAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: _limeAccent.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      "Подробнее",
                      style: TextStyle(
                          color: _limeAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description,
                style: const TextStyle(color: _textGrey, fontSize: 13)),
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
      enableDrag: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Color(0xFF0E0E10),
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
                0, 16, 0, MediaQuery.of(ctx).padding.bottom + 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 24),

                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

// Кнопка X
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                // Бейдж NEW
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _limeAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: _limeAccent.withValues(alpha: 0.35)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, color: _limeAccent, size: 14),
                      SizedBox(width: 4),
                      Text("ТОЛЬКО ЧТО ВЫШЕЛ",
                          style: TextStyle(
                              color: _limeAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Заголовок
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Yoda Band",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "Первый браслет, который знает тебя лучше, чем ты сам",
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 15,
                        height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 36),

                // SVG браслет

                SizedBox(
                  width: 190,
                  height: 190,
                  child: CustomPaint(painter: _YodaBandPainter()),
                ),

                const SizedBox(height: 36),

                // Метрики
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _buildMetricChip("HRV", "Восстановление"),
                      const SizedBox(width: 10),
                      _buildMetricChip("SpO₂", "Кислород крови"),
                      const SizedBox(width: 10),
                      _buildMetricChip("24/7", "Мониторинг"),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Фичи — воронка
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildBandFeature(
                        Icons.favorite_rounded,
                        const Color(0xFFFF5C7A),
                        "Умное восстановление",
                        "Анализирует сон, стресс и нагрузку — говорит, когда тренироваться, а когда отдохнуть",
                      ),
                      const SizedBox(height: 16),
                      _buildBandFeature(
                        Icons.bolt_rounded,
                        _limeAccent,
                        "ИИ-тренер на запястье",
                        "Синхронизируется с Yoda и даёт персональные рекомендации в реальном времени",
                      ),
                      const SizedBox(height: 16),
                      _buildBandFeature(
                        Icons.nights_stay_rounded,
                        const Color(0xFF9B8FFF),
                        "Анализ сна как у pro-спортсменов",
                        "REM, глубокий сон, микро-пробуждения — точность медицинского уровня",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Социальное доказательство
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.07)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              5,
                              (_) => const Icon(Icons.star_rounded,
                                  color: _limeAccent, size: 18)),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '"После Yoda Band я понял, почему всегда уставал на тренировках — я просто не восстанавливался"',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text("— Алексей, 31 год · марафонец",
                            style: TextStyle(color: _textGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // CTA кнопки
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _limeAccent,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("ХОЧУ YODA BAND",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      letterSpacing: 0.3)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Пока не сейчас",
                            style: TextStyle(color: _textGrey, fontSize: 13)),
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

  Widget _buildMetricChip(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _limeAccent.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: _limeAccent,
                    fontSize: 17,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: _textGrey,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildBandFeature(
      IconData icon, Color color, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(desc,
                  style: const TextStyle(
                      color: _textGrey, fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  String _getWorkoutTitle(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.weightLoss:
        return "3x Кардио + 2x Силовая (Full Body)";
      case FitnessGoal.maintenance:
        return "3-4x Смешанные тренировки";
      case FitnessGoal.massGain:
        return "Push / Pull / Legs (3-4 раза в неделю)";
      case FitnessGoal.aggressiveWeightLoss:
        return "4x Силовая + Ежедневное кардио";
    }
  }

  String _getWorkoutDescription(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.weightLoss:
        return "Фокус на сжигание калорий и поддержание тонуса мышц. Ходьба 10к шагов ежедневно.";
      case FitnessGoal.maintenance:
        return "Поддержание формы, работа над выносливостью и гибкостью.";
      case FitnessGoal.massGain:
        return "Акцент на прогрессию весов в базовых упражнениях и профицит калорий.";
      case FitnessGoal.aggressiveWeightLoss:
        return "Высокая интенсивность для максимального рельефа при сохранении мышц.";
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
    final l10n = AppLocalizations.of(context)!;
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
          _buildMenuItem(Icons.language_rounded, l10n.language,
              () => _showLanguageBottomSheet(context)),
          _buildDivider(),
          _buildMenuItem(Icons.bluetooth_connected_rounded, "Мои устройства",
              () => context.push('/profile/my-devices')),
          _buildDivider(),
          _buildMenuItem(Icons.straighten_rounded, "Единицы измерения",
              () => _showUnitsBottomSheet(context)),
          _buildDivider(),
          _buildMenuItem(Icons.notifications_none_rounded, "Напоминания",
              () => context.push('/profile/reminders')),
          _buildDivider(),
          _buildMenuItem(Icons.help_outline_rounded, "Помощь и поддержка",
              () => _showComingSoon(context)),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(l10n.language,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildLanguageOption(context, "Русский", const Locale('ru')),
            const SizedBox(height: 12),
            _buildLanguageOption(context, "English", const Locale('en')),
            const SizedBox(height: 12),
            _buildLanguageOption(context, "Қазақша", const Locale('kk')),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String title, Locale locale) {
    final isSelected = Localizations.localeOf(context).languageCode == locale.languageCode;

    return GestureDetector(
      onTap: () {
        context.read<LanguageBloc>().add(LanguageChanged(locale));
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _limeAccent.withValues(alpha: 0.1) : _bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected
                  ? _limeAccent
                  : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Text(title,
                style: TextStyle(
                    color: isSelected ? Colors.white : _textGrey,
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: _limeAccent, size: 20),
          ],
        ),
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
        padding:
            const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 48),
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
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
                      child: const Text("Отмена",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
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
                        context
                            .read<ProfileBloc>()
                            .add(const ProfileClearRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.redAccent.withValues(alpha: 0.1),
                        foregroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Выйти",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
          color: isSelected
              ? _limeAccent.withValues(alpha: 0.1)
              : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? _limeAccent : Colors.white.withValues(alpha: 0.05),
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

class _YodaBandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // --- Ремешок верхний ---
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 22, cy - 100, 44, 72), const Radius.circular(8)),
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF0A0A0A),
            const Color(0xFF1F1F1F),
            const Color(0xFF181818),
            const Color(0xFF1F1F1F),
            const Color(0xFF0A0A0A),
          ],
          stops: const [0.0, 0.12, 0.5, 0.88, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(cx - 22, cy - 100, 44, 72)),
    );

    // --- Ремешок нижний ---
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 22, cy + 28, 44, 72), const Radius.circular(8)),
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF0A0A0A),
            const Color(0xFF1F1F1F),
            const Color(0xFF181818),
            const Color(0xFF1F1F1F),
            const Color(0xFF0A0A0A),
          ],
          stops: const [0.0, 0.12, 0.5, 0.88, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(cx - 22, cy + 28, 44, 72)),
    );

    // --- Weave текстура ---
    final weavePaint = Paint()
      ..color = const Color(0xFF080808)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final weaveFill = Paint()..color = const Color(0xFF131313);

    void drawWeave(double fromY, double toY) {
      for (double row = fromY; row < toY; row += 7) {
        for (double col = cx - 22; col < cx + 22; col += 9) {
          final c1 = Offset(col + 4.5, row + 3.5);
          canvas.drawOval(
              Rect.fromCenter(center: c1, width: 6.5, height: 4.8), weaveFill);
          canvas.drawOval(
              Rect.fromCenter(center: c1, width: 6.5, height: 4.8), weavePaint);
        }
        for (double col = cx - 17.5; col < cx + 22; col += 9) {
          final c2 = Offset(col + 4.5, row + 7);
          canvas.drawOval(
              Rect.fromCenter(center: c2, width: 6.5, height: 4.8), weaveFill);
          canvas.drawOval(
              Rect.fromCenter(center: c2, width: 6.5, height: 4.8), weavePaint);
        }
      }
    }

    drawWeave(cy - 100, cy - 28);
    drawWeave(cy + 28, cy + 100);

    // --- Боковые тени ремешков ---
    canvas.drawRect(
      Rect.fromLTWH(cx - 22, cy - 100, 12, 200),
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xCC080808), const Color(0x00080808)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(cx - 22, cy - 100, 12, 200)),
    );
    canvas.drawRect(
      Rect.fromLTWH(cx + 10, cy - 100, 12, 200),
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0x00080808), const Color(0xCC080808)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(cx + 10, cy - 100, 12, 200)),
    );

    // --- Тень корпуса ---
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 28, cy - 30, 56, 88), const Radius.circular(12)),
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8)
        ..color = Colors.black.withOpacity(0.5),
    );

    // --- Левая рейка ---
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 29, cy - 28, 10, 84), const Radius.circular(5)),
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFF080808), const Color(0xFF222222)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(cx - 29, cy - 28, 10, 84)),
    );

    // --- Правая рейка ---
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + 19, cy - 28, 10, 84), const Radius.circular(5)),
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFF222222), const Color(0xFF080808)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(cx + 19, cy - 28, 10, 84)),
    );

    // --- Корпус основной ---
    canvas.drawRect(
      Rect.fromLTWH(cx - 22, cy - 28, 44, 84),
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF141414),
            const Color(0xFF252525),
            const Color(0xFF202020),
            const Color(0xFF252525),
            const Color(0xFF141414),
          ],
          stops: const [0.0, 0.1, 0.5, 0.9, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(cx - 22, cy - 28, 44, 84)),
    );

    // --- Экранная часть ---
    canvas.drawRect(
      Rect.fromLTWH(cx - 22, cy - 28, 44, 88),
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFF141414), const Color(0xFF111111)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(cx - 22, cy - 28, 44, 48)),
    );

    // --- Logo bar ---
    canvas.drawRect(
      Rect.fromLTWH(cx - 22, cy + 41, 44, 15),
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF303030),
            const Color(0xFF282828),
            const Color(0xFF1A1A1A),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(cx - 22, cy + 21, 44, 35)),
    );

    // --- Верхний highlight ---
    canvas.drawRect(
      Rect.fromLTWH(cx - 22, cy - 28, 44, 2),
      Paint()..color = const Color(0xFF303030),
    );

    // --- Нижний край ---
    canvas.drawRect(
      Rect.fromLTWH(cx - 22, cy + 54, 44, 2),
      Paint()..color = const Color(0xFF111111),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
