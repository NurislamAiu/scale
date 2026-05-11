import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // Profile State
  Sex _selectedSex = Sex.male;
  double _heightCm = 175;
  double _ageYears = 30;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  final TextEditingController _targetWeightController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _saveProfile();
    }
  }

  void _saveProfile() {
    final targetWeightText = _targetWeightController.text.replaceAll(',', '.');
    final targetWeight = double.tryParse(targetWeightText);

    final profile = UserProfile(
      heightCm: _heightCm.toInt(),
      ageYears: _ageYears.toInt(),
      sex: _selectedSex,
      targetWeightKg: targetWeight,
      activityLevel: _activityLevel,
    );

    context.read<ProfileBloc>().add(ProfileSaveRequested(profile));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide back button
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildGenderPage(),
                  _buildMetricPage(
                    title: 'Ваш рост',
                    subtitle: 'Для расчета ИМТ и идеального веса.',
                    value: _heightCm,
                    unit: 'см',
                    min: 100,
                    max: 230,
                    onChanged: (v) => setState(() => _heightCm = v),
                  ),
                  _buildMetricPage(
                    title: 'Ваш возраст',
                    subtitle: 'Для оценки скорости метаболизма (BMR).',
                    value: _ageYears,
                    unit: 'лет',
                    min: 10,
                    max: 100,
                    onChanged: (v) => setState(() => _ageYears = v),
                  ),
                  _buildTargetPage(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Row(
        children: List.generate(_totalPages, (index) {
          final isActive = index <= _currentPage;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? _limeAccent : _cardColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomControls() {
    final isLastPage = _currentPage == _totalPages - 1;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: _limeAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            isLastPage ? "ЗАВЕРШИТЬ" : "ПРОДОЛЖИТЬ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({required String title, required String subtitle, required Widget child}) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 16, color: _textGrey)),
          const SizedBox(height: 48),
          child,
        ],
      ),
    );
  }

  Widget _buildGenderPage() {
    return _buildContent(
      title: "Расскажите о себе",
      subtitle: "Давайте настроим приложение под ваши параметры.",
      child: Row(
        children: [
          _buildSelectionCard('Мужчина', Icons.male_rounded, _selectedSex == Sex.male, () => setState(() => _selectedSex = Sex.male)),
          const SizedBox(width: 16),
          _buildSelectionCard('Женщина', Icons.female_rounded, _selectedSex == Sex.female, () => setState(() => _selectedSex = Sex.female)),
        ],
      ),
    );
  }

  Widget _buildSelectionCard(String title, IconData icon, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 170,
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: selected ? _limeAccent : Colors.white.withOpacity(0.05), width: 2),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _limeAccent.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: selected ? _limeAccent : _textGrey),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 18,
                  color: selected ? _limeAccent : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricPage({
    required String title,
    required String subtitle,
    required double value,
    required String unit,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return _buildContent(
      title: title,
      subtitle: subtitle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(
                  unit,
                  style: const TextStyle(fontSize: 20, color: _textGrey, fontWeight: FontWeight.w600),
                )
              ],
            ),
            const SizedBox(height: 24),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 10,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                activeTrackColor: _limeAccent,
                inactiveTrackColor: Colors.white.withOpacity(0.05),
                thumbColor: _limeAccent,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetPage() {
    return _buildContent(
      title: "Ваша цель",
      subtitle: "Какой ваш целевой вес? (необязательно)",
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: TextField(
          controller: _targetWeightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w800, color: Colors.white),
          decoration: const InputDecoration(
            hintText: "00.0",
            hintStyle: TextStyle(color: _textGrey),
            border: InputBorder.none,
            suffixText: "кг",
            suffixStyle: TextStyle(fontSize: 20, color: _textGrey, fontWeight: FontWeight.w600),
          ),
          cursorColor: _limeAccent,
        ),
      ),
    );
  }
}
