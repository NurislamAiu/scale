import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scale/features/scale/presentation/bloc/scale_bloc.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_scale/core/di/injection.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/services.dart'; // For HapticFeedback
import '../widgets/stat_card.dart';
import 'dart:math' as math;

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _isSaving = false;
  bool _isSaved = false;
  bool _hasSavedCurrentWeight = false; // Флаг, чтобы скрыть кнопку после сохранения

  void _handleSave(double weight) async {
    HapticFeedback.mediumImpact();
    setState(() { _isSaving = true; });

    // Отправляем событие в BLoC для сохранения в историю
    final lastMeasurement = context.read<ScaleBloc>().state.lastMeasurement;
    if (lastMeasurement != null) {
      context.read<ScaleBloc>().add(ScaleMeasurementSaved(lastMeasurement));
    }
    
    // Анимация для пользователя
    await Future.delayed(const Duration(milliseconds: 1200));
    
    HapticFeedback.heavyImpact();
    setState(() { 
      _isSaving = false; 
      _isSaved = true; 
    });
    
    // Держим анимацию успеха 2 секунды, затем прячем кнопку
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      setState(() { 
        _isSaved = false; 
        _hasSavedCurrentWeight = true; // Убираем кнопку с экрана
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (kDebugMode) print('[HomePage] initState: Adding ScaleStarted event');
    context.read<ScaleBloc>().add(const ScaleStarted());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) print('[HomePage] App resumed. Restarting BLE scan.');
      // Когда приложение возвращается из фона, пинаем BLoC, чтобы он перезапустил сканирование
      context.read<ScaleBloc>().add(const ScaleStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: BlocConsumer<ScaleBloc, ScaleState>(
          listener: (context, state) {
            // Если началось новое измерение или весы освободились, сбрасываем флаг скрытия кнопки
            if (state.status == ScaleStatus.weighing || state.status == ScaleStatus.ready) {
              if (_hasSavedCurrentWeight) {
                setState(() {
                  _hasSavedCurrentWeight = false;
                });
              }
            }
          },
          builder: (context, state) {
            if (kDebugMode) print('[HomePage] Rebuilding with state: ${state.status}');
            
            if (state.status == ScaleStatus.permissionDenied || state.status == ScaleStatus.error) {
              return _buildErrorState(state.errorMessage ?? "Произошла ошибка.");
            }

            return Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            _buildLiveConnectionStatus(context, state),
                            const SizedBox(height: 40),
                            _buildCircularWeightDisplay(state),
                            const SizedBox(height: 40),
                            _buildStatsGrid(state),
                            const SizedBox(height: 120), // Большой отступ снизу, чтобы контент не прятался за плавающей кнопкой
                          ],
                        ),
                      ),
                      // Плавающая кнопка сохранения (прячется, если вес уже сохранен)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        bottom: (state.status == ScaleStatus.stabilized && !_hasSavedCurrentWeight) ? 24.0 : -120.0,
                        left: 20,
                        right: 20,
                        child: _buildFloatingSaveButton(state.lastMeasurement?.weightKg ?? 0.0),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Text(
            "Yoda Health",
            style: TextStyle(
              color: _limeAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: _limeAccent),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLiveConnectionStatus(BuildContext context, ScaleState state) {
    final isConnected = state.status == ScaleStatus.ready ||
        state.status == ScaleStatus.weighing ||
        state.status == ScaleStatus.stabilized;

    return GestureDetector(
      onTap: isConnected ? () => _showDeviceDetailsBottomSheet(context, state) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isConnected ? _limeAccent : Colors.redAccent,
                shape: BoxShape.circle,
                boxShadow: isConnected
                    ? [BoxShadow(color: _limeAccent.withOpacity(0.5), blurRadius: 6)]
                    : [],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isConnected ? "Подключено" : "Подключение...",
              style: const TextStyle(
                color: _textGrey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceDetailsBottomSheet(BuildContext context, ScaleState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        // Достаем профиль из getIt, чтобы получить целевой вес
        final profileBloc = getIt<ProfileBloc>();
        final targetWeight = profileBloc.state.profile?.targetWeightKg;
        final currentWeight = state.lastMeasurement?.weightKg ?? 0.0;

        String progressValue = "--";
        IconData progressIcon = Icons.trending_flat_rounded;
        Color progressColor = _textGrey;

        if (targetWeight != null && currentWeight > 0) {
          final difference = currentWeight - targetWeight;
          if (difference > 0) {
            progressValue = "Осталось ${difference.toStringAsFixed(1)} кг";
            progressIcon = Icons.trending_down_rounded;
            progressColor = const Color(0xFF30D158); // Зеленый - надо сбросить
          } else if (difference < 0) {
            progressValue = "Осталось ${difference.abs().toStringAsFixed(1)} кг";
            progressIcon = Icons.trending_up_rounded;
            progressColor = const Color(0xFF0A84FF); // Синий - надо набрать (если цель на массу)
          } else {
            progressValue = "Цель достигнута!";
            progressIcon = Icons.emoji_events_rounded;
            progressColor = const Color(0xFFFFD60A); // Желтый/Золотой
          }
        } else if (targetWeight == null) {
          progressValue = "Цель не задана";
        }

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ползунок (drag handle)
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Крутой визуальный рендер весов (нарисован кодом!)
              Stack(
                alignment: Alignment.center,
                children: [
                  // Неоновое свечение под весами
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _limeAccent.withOpacity(0.12),
                          blurRadius: 50,
                          spreadRadius: 10,
                        )
                      ]
                    ),
                  ),
                  // Корпус весов (Улучшенный реалистичный дизайн)
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF38383A), Color(0xFF1C1C1E)],
                      ),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30, offset: const Offset(0, 15)),
                      ]
                    ),
                    child: Stack(
                      children: [
                        // Имитация скрытого узора датчиков (кольца)
                        Center(
                          child: Container(
                            width: 80, 
                            height: 80, 
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, 
                              border: Border.all(color: Colors.white.withOpacity(0.03), width: 1)
                            )
                          )
                        ),
                        // Декоративная линия симметрии
                        Center(child: Container(width: 1, height: 160, color: Colors.white.withOpacity(0.015))),

                        // Металлические датчики по углам
                        Positioned(top: 14, left: 14, child: _buildElectrode()),
                        Positioned(top: 14, right: 14, child: _buildElectrode()),
                        Positioned(bottom: 14, left: 14, child: _buildElectrode()),
                        Positioned(bottom: 14, right: 14, child: _buildElectrode()),
                        
                        // Мини-дисплей весов (Перемещен НАВЕРХ)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 14), // Отступ сверху
                            width: 58,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF050505), // Очень темный фон экрана
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                              boxShadow: const [
                                BoxShadow(color: Colors.black87, blurRadius: 6, spreadRadius: 1), // Эффект утопленности
                              ],
                            ),
                            child: Center(
                              child: Text(
                                currentWeight > 0 ? currentWeight.toStringAsFixed(2) : "0.00", 
                                style: const TextStyle(
                                  color: _limeAccent, 
                                  fontWeight: FontWeight.w900, 
                                  fontSize: 14,
                                  fontFamily: 'Courier',
                                  letterSpacing: 1.0,
                                  shadows: [Shadow(color: _limeAccent, blurRadius: 6)] // Неоновое свечение самих цифр
                                )
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Название устройства
              const Text(
                "Yoda1 Smart Scale",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Статус
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _limeAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: _limeAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text("Синхронизировано", style: TextStyle(color: _limeAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Карточки с информацией (Цель и Прогресс)
              Row(
                children: [
                  Expanded(
                    child: _buildDeviceInfoCard(
                      Icons.flag_rounded, 
                      "Моя цель", 
                      targetWeight != null ? "${targetWeight.toStringAsFixed(1)} кг" : "--", 
                      const Color(0xFFBF5AF2) // Фиолетовый
                    )
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDeviceInfoCard(
                      progressIcon, 
                      "Прогресс", 
                      progressValue, 
                      progressColor
                    )
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Кнопка отключения
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    // Пока просто закрывает шторку, в будущем можно добавить ScaleDisconnectRequested
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    "Отключить устройство",
                    style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildElectrode() {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.02),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
    );
  }

  Widget _buildDeviceInfoCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414), // Темнее чем фон шторки
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Color(0xFFA0A0A5), fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value, 
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getSmoothBmiColor(double bmi) {
    if (bmi <= 0) return _limeAccent;
    
    if (bmi < 18.5) {
      // Плавный переход от Желтого к Салатовому на границе нормы
      double t = (bmi - 16.0) / (18.5 - 16.0);
      return Color.lerp(const Color(0xFFFFD60A), _limeAccent, t.clamp(0.0, 1.0)) ?? _limeAccent;
    } else if (bmi < 25.0) {
      // Плавный переход от Салатового к Оранжевому
      double t = (bmi - 23.5) / (25.0 - 23.5);
      return Color.lerp(_limeAccent, const Color(0xFFFF9F0A), t.clamp(0.0, 1.0)) ?? const Color(0xFFFF9F0A);
    } else if (bmi < 30.0) {
      // Плавный переход от Оранжевого к Красному
      double t = (bmi - 28.5) / (30.0 - 28.5);
      return Color.lerp(const Color(0xFFFF9F0A), const Color(0xFFFF453A), t.clamp(0.0, 1.0)) ?? const Color(0xFFFF453A);
    } else {
      return const Color(0xFFFF453A); // Красный
    }
  }

  String _getBmiLabel(double bmi) {
    if (bmi <= 0) return "Ожидание...";
    if (bmi < 18.5) return "Дефицит массы";
    if (bmi < 25.0) return "Нормальный вес";
    if (bmi < 30.0) return "Избыточный вес";
    if (bmi < 35.0) return "Ожирение I ст.";
    if (bmi < 40.0) return "Ожирение II ст.";
    return "Ожирение III ст.";
  }

  Widget _buildCircularWeightDisplay(ScaleState state) {
    final targetWeight = state.lastMeasurement?.weightKg ?? 0.0;
    
    String statusText = "Встаньте на весы";
    if (state.status == ScaleStatus.weighing) {
      statusText = "Измерение...";
    } else if (state.status == ScaleStatus.stabilized) {
      statusText = "Измерено";
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: targetWeight),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, animatedWeight, child) {
        // Достаем профиль из КОНТЕКСТА, а не создаем новый
        final profileBloc = context.read<ProfileBloc>();
        final heightMeters = profileBloc.state.profile?.heightMeters ?? 1.75;
        
        final currentBmi = animatedWeight > 0 ? (animatedWeight / (heightMeters * heightMeters)) : 0.0;
        final dynamicColor = _getSmoothBmiColor(currentBmi);
        final progress = animatedWeight > 0 ? (animatedWeight / 120.0).clamp(0.01, 1.0) : 0.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 280, // Детальный циферблат
              height: 280,
              child: CustomPaint(
                painter: WeightDialPainter(
                  progress: progress,
                  activeColor: dynamicColor, // Динамический цвет шкалы!
                  inactiveColor: const Color(0xFF2C2C2E),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  statusText,
                  style: const TextStyle(color: _textGrey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  animatedWeight > 0 ? animatedWeight.toStringAsFixed(2) : "0.00",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    height: 1.0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    shadows: [Shadow(color: dynamicColor.withOpacity(0.4), blurRadius: 12)], // Свечение текста под цвет!
                  ),
                ),
                const Text(
                  "кг",
                  style: const TextStyle(color: _textGrey, fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                // Динамическая подсказка (Лейбл)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(_getBmiLabel(currentBmi)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: dynamicColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getBmiLabel(currentBmi),
                      style: TextStyle(
                        color: dynamicColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid(ScaleState state) {
    final bodyComp = state.bodyComposition;
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
          color: const Color(0xFFFF9F0A), // Оранжевый
          description: "Доля жира от общей массы тела. Жир необходим организму для запасания энергии и защиты внутренних органов.",
        ),
        StatCard(
          label: "Вода (%)",
          value: bodyComp != null ? "${bodyComp.bodyWaterPercent.toStringAsFixed(1)}%" : "0.0%",
          icon: Icons.water_drop_outlined,
          color: const Color(0xFF0A84FF), // Голубой
          description: "Общее количество жидкости в организме. Поддержание водного баланса помогает организму нормально функционировать.",
        ),
        StatCard(
          label: "Мышцы",
          value: bodyComp != null ? "${bodyComp.muscleMassKg.toStringAsFixed(1)} кг" : "0.0 кг",
          icon: Icons.fitness_center_outlined,
          color: const Color(0xFFBF5AF2), // Фиолетовый
          description: "Расчетный вес мышц в вашем теле. Включает скелетные и гладкие мышцы, а также содержащуюся в них воду.",
        ),
        StatCard(
          label: "ИМТ",
          value: bodyComp != null ? bodyComp.bmi.toStringAsFixed(1) : "0.0",
          icon: Icons.accessibility_new_outlined,
          color: const Color(0xFF30D158), // Зеленый
          description: "Индекс массы тела (ИМТ) — величина, позволяющая оценить степень соответствия массы человека и его роста.",
        ),
        StatCard(
          label: "Висцерал. жир",
          value: bodyComp != null ? bodyComp.visceralFatRating.toString() : "0",
          icon: Icons.local_fire_department_outlined,
          color: const Color(0xFFFF453A), // Красный
          description: "Жир, скапливающийся в брюшной полости вокруг внутренних органов. Меньшее значение обычно означает лучшее здоровье.",
        ),
        StatCard(
          label: "Базовый обмен",
          value: bodyComp != null ? "${bodyComp.bmr.toInt()} ккал" : "0 ккал",
          icon: Icons.bolt_outlined,
          color: const Color(0xFFFFD60A), // Желтый
          description: "Базовый уровень метаболизма (BMR) — минимальное количество калорий, необходимое организму для работы в состоянии покоя.",
        ),
        StatCard(
          label: "Расход энергии",
          value: bodyComp != null ? "${bodyComp.tdee.toInt()} ккал" : "0 ккал",
          icon: Icons.directions_run_outlined,
          color: const Color(0xFF64D2FF), // Циан
          description: "Общий суточный расход энергии (TDEE) — оценка количества калорий, сжигаемых вами за день, включая любую активность.",
        ),
        StatCard(
          label: "Идеальный вес",
          value: bodyComp != null ? "${bodyComp.idealWeightKg.toStringAsFixed(1)} кг" : "0.0 кг",
          icon: Icons.star_outline_rounded,
          color: _limeAccent, // Фирменный салатовый
          description: "Рассчитанный целевой здоровый вес на основе вашего текущего роста, возраста и пола.",
        ),
      ],
    );
  }

  Widget _buildFloatingSaveButton(double weight) {
    return GestureDetector(
      onTap: (_isSaving || _isSaved) ? null : () => _handleSave(weight),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: _isSaved ? const Color(0xFF30D158) : _limeAccent,
          borderRadius: BorderRadius.circular(_isSaved ? 32 : 20),
          boxShadow: [
            BoxShadow(
              color: (_isSaved ? const Color(0xFF30D158) : _limeAccent).withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            )
          ]
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation, 
                child: FadeTransition(opacity: animation, child: child)
              );
            },
            child: _isSaved
                ? const Row(
                    key: ValueKey("saved"),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.black, size: 28),
                      SizedBox(width: 8),
                      Text("СОХРАНЕНО", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ],
                  )
                : _isSaving
                    ? const SizedBox(
                        key: ValueKey("saving"),
                        width: 28, height: 28,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                      )
                    : Row(
                        key: ValueKey("save"),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_rounded, color: Colors.black, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            "СОХРАНИТЬ ${weight.toStringAsFixed(2)} КГ",
                            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 18, color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ScaleBloc>().add(const ScaleStarted()),
            style: ElevatedButton.styleFrom(backgroundColor: _limeAccent, foregroundColor: Colors.black),
            child: const Text('Повторить'),
          )
        ],
      ),
    );
  }
}

class WeightDialPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  WeightDialPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final totalTicks = 80; // 80 делений по кругу
    final tickLength = 10.0;
    final majorTickLength = 18.0;
    final startAngle = -math.pi / 2; // Начинаем сверху

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 1. Рисуем внешний круг с делениями (циферблат)
    for (int i = 0; i < totalTicks; i++) {
      final isMajor = i % 10 == 0; // Каждое 10-е деление - крупное
      final currentTickLength = isMajor ? majorTickLength : tickLength;
      final angle = startAngle + (i / totalTicks) * 2 * math.pi;

      final isTickActive = (i / totalTicks) <= progress && progress > 0;

      if (isTickActive) {
        paint.color = activeColor;
        paint.strokeWidth = isMajor ? 3.0 : 2.0;
      } else {
        paint.color = inactiveColor;
        paint.strokeWidth = isMajor ? 2.5 : 1.5;
      }

      final innerPoint = Offset(
        center.dx + (radius - currentTickLength) * math.cos(angle),
        center.dy + (radius - currentTickLength) * math.sin(angle),
      );

      final outerPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.drawLine(innerPoint, outerPoint, paint);
    }

    // 2. Рисуем внутреннюю светящуюся линию прогресса
    final innerRadius = radius - majorTickLength - 14;
    final rect = Rect.fromCircle(center: center, radius: innerRadius);

    // Фоновая темная линия (трек)
    final trackPaint = Paint()
      ..color = inactiveColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, innerRadius, trackPaint);

    if (progress > 0) {
      // Свечение вокруг активной линии
      final glowPaint = Paint()
        ..color = activeColor.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawArc(rect, startAngle, 2 * math.pi * progress, false, glowPaint);

      // Сама яркая линия прогресса
      final progressPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, 2 * math.pi * progress, false, progressPaint);

      // Яркая светящаяся точка на конце (как иголка спидометра)
      final tipAngle = startAngle + 2 * math.pi * progress;
      final tipOffset = Offset(
        center.dx + innerRadius * math.cos(tipAngle),
        center.dy + innerRadius * math.sin(tipAngle),
      );

      final dotGlow = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      canvas.drawCircle(tipOffset, 7.0, dotGlow);

      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(tipOffset, 4.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WeightDialPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
