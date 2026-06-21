import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_scale/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_scale/features/scale/domain/entities/body_composition.dart';
import 'package:smart_scale/features/scale/domain/entities/scale_measurement.dart';
import 'package:smart_scale/features/scale/domain/usecases/body_composition_calculator.dart';
import 'package:smart_scale/features/scale/presentation/widgets/stat_card.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

const Color _greenAccent = Color(0xFF30D158);
const Color _redAccent = Color(0xFFFF453A);

const Map<int, int> _rangeSize = {
  0: 7,    // Неделя
  1: 30,   // Месяц
  2: 12,   // Год
};

enum AnalyticsMetric {
  weight,
  bodyFat,
  muscleMass,
  bmi,
  water,
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  static DateTime _startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static int _daysBetween(DateTime from, DateTime to) =>
      _startOfDay(to).difference(_startOfDay(from)).inDays;

  static int _slotsForRange(int rangeIndex) => _rangeSize[rangeIndex] ?? 7;

  BodyComposition? _calculateComposition(ScaleMeasurement measurement, UserProfile? profile) {
    if (profile == null) return null;
    return BodyCompositionCalculator.calculate(
      weightKg: measurement.weightKg,
      profile: profile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Аналитика",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 2),
            Text(
              "Тренды и состав тела",
              style: TextStyle(color: _textGrey, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: _cardColor,
              foregroundColor: _limeAccent,
            ),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<AnalyticsBloc>().add(const AnalyticsLoadRequested()),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          final profile = profileState.profile;

          return BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, state) {
              if (state.status == AnalyticsStatus.loading ||
                  state.status == AnalyticsStatus.initial) {
                return const Center(child: CircularProgressIndicator(color: _limeAccent));
              }
              if (state.status == AnalyticsStatus.error) {
                return Center(
                  child: Text(
                    "Ошибка: ${state.errorMessage}",
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }
              if (state.allMeasurements.isEmpty) {
                return _buildEmptyState();
              }

              final allDesc = [...state.allMeasurements]
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
              final filteredDesc = [...state.filteredMeasurements]
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

              final latestComp = filteredDesc.isNotEmpty
                  ? _calculateComposition(filteredDesc.first, profile)
                  : null;

              return RefreshIndicator(
                onRefresh: () async => context
                    .read<AnalyticsBloc>()
                    .add(const AnalyticsLoadRequested()),
                color: _limeAccent,
                backgroundColor: _cardColor,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildTimeRangeSelector(context, state.selectedTimeRangeIndex),
                      const SizedBox(height: 32),
                      _buildMainStat(filteredDesc),
                      const SizedBox(height: 24),
                      _buildMetricSelector(context, state.selectedMetricIndex),
                      const SizedBox(height: 16),
                      _buildChart(context, filteredDesc, state.selectedTimeRangeIndex, state.selectedMetricIndex, profile),
                      const SizedBox(height: 32),
                      _buildMiniStatsRow(filteredDesc),
                      const SizedBox(height: 32),
                      const Text(
                        "Состав тела",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatsGrid(latestComp),
                      const SizedBox(height: 40),
                      const Text(
                        "История измерений",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHistoryList(allDesc, profile),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context, int selectedIndex) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          _buildRangeButton(context, "Неделя", 0, selectedIndex),
          _buildRangeButton(context, "Месяц", 1, selectedIndex),
          _buildRangeButton(context, "Год", 2, selectedIndex),
        ],
      ),
    );
  }

  Widget _buildRangeButton(
      BuildContext context,
      String title,
      int index,
      int selectedIndex,
      ) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => context
            .read<AnalyticsBloc>()
            .add(AnalyticsTimeRangeChanged(index)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _limeAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : _textGrey,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricSelector(BuildContext context, int selectedIndex) {
    final metrics = [
      "Вес",
      "Жир",
      "Мышцы",
      "ИМТ",
      "Вода",
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: metrics.asMap().entries.map((entry) {
          final isSelected = selectedIndex == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) => context
                  .read<AnalyticsBloc>()
                  .add(AnalyticsMetricChanged(entry.key)),
              selectedColor: _limeAccent,
              backgroundColor: _cardColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? _limeAccent : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainStat(List<ScaleMeasurement> data) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            "Нет данных за этот период",
            style: TextStyle(color: _textGrey),
          ),
        ),
      );
    }

    final latestWeight = data.first.weightKg;
    final oldestWeight = data.last.weightKg;
    final diff = latestWeight - oldestWeight;
    final diffColor = diff < -0.05
        ? _greenAccent
        : (diff > 0.05 ? _redAccent : _textGrey);
    final diffIcon = diff < -0.05
        ? Icons.arrow_downward_rounded
        : (diff > 0.05
        ? Icons.arrow_upward_rounded
        : Icons.trending_flat_rounded);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Вес за период",
                style: TextStyle(
                  color: _textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    latestWeight.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "кг",
                    style: TextStyle(
                      color: _textGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                "${data.length} измерений",
                style: const TextStyle(
                  color: _textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (data.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: diffColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(diffIcon, color: diffColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${diff.abs().toStringAsFixed(1)} кг",
                    style: TextStyle(color: diffColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChart(
      BuildContext context,
      List<ScaleMeasurement> data,
      int rangeIndex,
      int metricIndex,
      UserProfile? profile,
      ) {
    if (data.isEmpty) {
      return _chartPlaceholder("Нет данных за этот период");
    }

    final spots = _getSpotsForRange(data, rangeIndex, metricIndex, profile);

    if (spots.length < 2) {
      return _chartPlaceholder(
        "Недостаточно данных,\nсделай ещё одно измерение",
      );
    }

    // ===== Y bounds =====
    double minY = spots.map((s) => s.y).reduce(math.min);
    double maxY = spots.map((s) => s.y).reduce(math.max);
    if ((maxY - minY).abs() < 0.01) {
      minY -= 1;
      maxY += 1;
    } else {
      final padding = (maxY - minY) * 0.15;
      minY -= padding;
      maxY += padding;
    }
    double yInterval = (maxY - minY) / 4;
    if (yInterval <= 0) yInterval = 1.0;

    final slots = _slotsForRange(rangeIndex);
    const minX = 0.0;
    final maxX = (slots - 1).toDouble();

    final double bottomInterval = switch (rangeIndex) {
      0 => 1.0,    // неделя — каждый день
      1 => 6.0,    // месяц — 5 лейблов
      2 => 2.0,    // год — каждые 2 месяца
      _ => 1.0,
    };

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(12, 24, 24, 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          minX: minX,
          maxX: maxX,
          clipData: const FlClipData.none(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withValues(alpha: 0.05),
              strokeWidth: 1,
              dashArray: const [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: yInterval,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max || value == meta.min) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value.toStringAsFixed(metricIndex == 0 || metricIndex == 2 ? 0 : 1),
                      style: const TextStyle(color: _textGrey, fontSize: 12),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: bottomInterval,
                getTitlesWidget: (value, meta) =>
                    _getBottomTitle(value, meta, rangeIndex),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.2,
              preventCurveOverShooting: true,
              color: _limeAccent,
              barWidth: 4,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 5,
                      color: _bgColor,
                      strokeWidth: 2.5,
                      strokeColor: _limeAccent,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    _limeAccent.withValues(alpha: 0.3),
                    _limeAccent.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => _limeAccent,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final unit = switch (metricIndex) {
                    0 => "кг",
                    1 => "%",
                    2 => "кг",
                    3 => "",
                    4 => "%",
                    _ => "",
                  };
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)} $unit',
                    const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _chartPlaceholder(String text) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text,
            style: const TextStyle(color: _textGrey),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  List<FlSpot> _getSpotsForRange(List<ScaleMeasurement> data, int rangeIndex, int metricIndex, UserProfile? profile) {
    if (data.isEmpty) return [];
    final now = DateTime.now();

    final Map<int, List<double>> buckets = {};
    final int slots = _slotsForRange(rangeIndex);

    for (final m in data) {
      final int? bucketKey = switch (rangeIndex) {
        0 || 1 => () {
          final daysAgo = _daysBetween(m.timestamp, now);
          return (daysAgo >= 0 && daysAgo < slots) ? daysAgo : null;
        }(),
        2 => () {
          final monthsAgo = (now.year * 12 + now.month) -
              (m.timestamp.year * 12 + m.timestamp.month);
          return (monthsAgo >= 0 && monthsAgo < slots) ? monthsAgo : null;
        }(),
        _ => null,
      };
      if (bucketKey == null) continue;

      double val = m.weightKg;
      if (metricIndex > 0 && profile != null) {
        final comp = BodyCompositionCalculator.calculate(weightKg: m.weightKg, profile: profile);
        val = switch (metricIndex) {
          1 => comp.bodyFatPercent,
          2 => comp.muscleMassKg,
          3 => comp.bmi,
          4 => comp.bodyWaterPercent,
          _ => m.weightKg,
        };
      } else if (metricIndex > 0 && profile == null) {
        continue; // Cannot calculate without profile
      }

      (buckets[bucketKey] ??= []).add(val);
    }

    final spots = buckets.entries.map((entry) {
      final x = (slots - 1 - entry.key).toDouble();
      final avgY = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return FlSpot(x, double.parse(avgY.toStringAsFixed(2)));
    }).toList();

    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
  }

  Widget _getBottomTitle(double value, TitleMeta meta, int rangeIndex) {
    const style = TextStyle(color: _textGrey, fontSize: 11);
    final now = DateTime.now();
    final intValue = value.round();
    final slots = _slotsForRange(rangeIndex);

    if ((value - intValue).abs() > 0.01) return const SizedBox();
    if (intValue < 0 || intValue >= slots) return const SizedBox();

    if (rangeIndex == 0) {
      final daysAgo = (slots - 1) - intValue;
      final day = _startOfDay(now).subtract(Duration(days: daysAgo));
      return SideTitleWidget(
        meta: meta,
        space: 6,
        child: Text(DateFormat('EEE', 'ru_RU').format(day), style: style),
      );
    }

    if (rangeIndex == 1) {
      final daysAgo = (slots - 1) - intValue;
      final date = _startOfDay(now).subtract(Duration(days: daysAgo));
      return SideTitleWidget(
        meta: meta,
        space: 6,
        child: Text(DateFormat('dd.MM').format(date), style: style),
      );
    }

    if (rangeIndex == 2) {
      final monthsAgo = (slots - 1) - intValue;
      final monthDate = DateTime(now.year, now.month - monthsAgo);
      return SideTitleWidget(
        meta: meta,
        space: 6,
        child: Text(DateFormat('LLL', 'ru_RU').format(monthDate), style: style),
      );
    }

    return const SizedBox();
  }

  Widget _buildMiniStatsRow(List<ScaleMeasurement> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    final weights = data.map((m) => m.weightKg).toList();
    final avgWeight = weights.reduce((a, b) => a + b) / weights.length;
    final minWeight = weights.reduce(math.min);
    final maxWeight = weights.reduce(math.max);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildMiniStatCard(
            Icons.monitor_weight_rounded,
            "Средний вес",
            "${avgWeight.toStringAsFixed(1)} кг",
            const Color(0xFF0A84FF),
          ),
          const SizedBox(width: 12),
          _buildMiniStatCard(
            Icons.arrow_downward_rounded,
            "Минимум",
            "${minWeight.toStringAsFixed(1)} кг",
            _greenAccent,
          ),
          const SizedBox(width: 12),
          _buildMiniStatCard(
            Icons.arrow_upward_rounded,
            "Максимум",
            "${maxWeight.toStringAsFixed(1)} кг",
            _redAccent,
          ),
          const SizedBox(width: 12),
          _buildMiniStatCard(
            Icons.numbers_rounded,
            "Измерений",
            "${data.length}",
            _limeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(IconData icon, String title, String value, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: _textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BodyComposition? bodyComp) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.15,
      children: [
        StatCard(
          label: "Жир (%)",
          value: bodyComp != null ? "${bodyComp.bodyFatPercent.toStringAsFixed(1)}%" : "0.0%",
          icon: Icons.monitor_weight_outlined,
          color: const Color(0xFFFF9F0A),
          description: "Доля жира от общей массы тела. Жир необходим организму для запасания энергии и защиты внутренних органов.",
        ),
        StatCard(
          label: "Вода (%)",
          value: bodyComp != null ? "${bodyComp.bodyWaterPercent.toStringAsFixed(1)}%" : "0.0%",
          icon: Icons.water_drop_outlined,
          color: const Color(0xFF0A84FF),
          description: "Общее количество жидкости в организме. Поддержание водного баланса помогает организму нормально функционировать.",
        ),
        StatCard(
          label: "Мышцы",
          value: bodyComp != null ? "${bodyComp.muscleMassKg.toStringAsFixed(1)} кг" : "0.0 кг",
          icon: Icons.fitness_center_outlined,
          color: const Color(0xFFBF5AF2),
          description: "Расчетный вес мышц в вашем теле. Включает скелетные и гладкие мышцы, а также содержащуюся в них воду.",
        ),
        StatCard(
          label: "ИМТ",
          value: bodyComp != null ? bodyComp.bmi.toStringAsFixed(1) : "0.0",
          icon: Icons.accessibility_new_outlined,
          color: const Color(0xFF30D158),
          description: "Индекс массы тела (ИМТ) — величина, позволяющая оценить степень соответствия массы человека и его роста.",
        ),
        StatCard(
          label: "Висцерал. жир",
          value: bodyComp != null ? bodyComp.visceralFatRating.toString() : "0",
          icon: Icons.local_fire_department_outlined,
          color: const Color(0xFFFF453A),
          description: "Жир, скапливающийся в брюшной полости вокруг внутренних органов. Меньшее значение обычно означает лучшее здоровье.",
        ),
        StatCard(
          label: "Базовый обмен",
          value: bodyComp != null ? "${bodyComp.bmr.toInt()} ккал" : "0 ккал",
          icon: Icons.bolt_outlined,
          color: const Color(0xFFFFD60A),
          description: "Базовый уровень метаболизма (BMR) — минимальное количество калорий, необходимое организму для работы в состоянии покоя.",
        ),
        StatCard(
          label: "Расход энергии",
          value: bodyComp != null ? "${bodyComp.tdee.toInt()} ккал" : "0 ккал",
          icon: Icons.directions_run_outlined,
          color: const Color(0xFF64D2FF),
          description: "Общий суточный расход энергии (TDEE) — оценка количества калорий, сжигаемых вами за день, включая любую активность.",
        ),
        StatCard(
          label: "Идеальный вес",
          value: bodyComp != null ? "${bodyComp.idealWeightKg.toStringAsFixed(1)} кг" : "0.0 кг",
          icon: Icons.star_outline_rounded,
          color: _limeAccent,
          description: "Рассчитанный целевой здоровый вес на основе вашего текущего роста, возраста и пола.",
        ),
      ],
    );
  }

  Widget _buildHistoryList(List<ScaleMeasurement> data, UserProfile? profile) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.white.withValues(alpha: 0.05),
          height: 1,
          indent: 20,
          endIndent: 20,
        ),
        itemBuilder: (context, index) {
          final m = data[index];
          final prev = (index + 1 < data.length) ? data[index + 1] : null;
          final diff = prev != null ? m.weightKg - prev.weightKg : 0.0;
          final hasDiff = diff.abs() >= 0.05;
          final diffPositive = diff > 0;

          final comp = _calculateComposition(m, profile);

          return Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: Row(
                children: [
                  Text(
                    "${m.weightKg.toStringAsFixed(2)} кг",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (comp != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _limeAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Жир: ${comp.bodyFatPercent.toStringAsFixed(1)}%",
                        style: const TextStyle(color: _limeAccent, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                DateFormat('d MMMM, HH:mm', 'ru_RU').format(m.timestamp),
                style: const TextStyle(color: _textGrey, fontSize: 13),
              ),
              trailing: hasDiff
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    diffPositive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: diffPositive ? _redAccent : _greenAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${diff.abs().toStringAsFixed(1)} кг",
                    style: TextStyle(
                      color: diffPositive ? _redAccent : _greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 80, color: _textGrey),
            SizedBox(height: 24),
            Text(
              "Нет данных для аналитики",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Сохраняйте свои измерения на главном экране, и здесь появятся красивые графики вашего прогресса.",
              style: TextStyle(color: _textGrey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
