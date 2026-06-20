import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';

const Color _bgColor = Color(0xFF141414);
const Color _cardColor = Color(0xFF1C1C1E);
const Color _limeAccent = Color(0xFFD4FF45);
const Color _textGrey = Color(0xFFA0A0A5);

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late Sex _selectedSex;
  late ActivityLevel _selectedActivity;
  late FitnessGoal _selectedGoal;
  late TextEditingController _heightController;
  late TextEditingController _ageController;
  late TextEditingController _targetController;

  @override
  void initState() {
    super.initState();
    _selectedSex = widget.profile.sex;
    _selectedActivity = widget.profile.activityLevel;
    _selectedGoal = widget.profile.fitnessGoal;
    _heightController = TextEditingController(text: widget.profile.heightCm.toString());
    _ageController = TextEditingController(text: widget.profile.ageYears.toString());
    _targetController = TextEditingController(
      text: widget.profile.targetWeightKg?.toStringAsFixed(1) ?? '',
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _ageController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final height = int.tryParse(_heightController.text) ?? widget.profile.heightCm;
    final age = int.tryParse(_ageController.text) ?? widget.profile.ageYears;
    final targetText = _targetController.text.replaceAll(',', '.');
    final target = double.tryParse(targetText);

    final updatedProfile = widget.profile.copyWith(
      sex: _selectedSex,
      heightCm: height,
      ageYears: age,
      targetWeightKg: target,
      activityLevel: _selectedActivity,
      fitnessGoal: _selectedGoal,
    );

    context.read<ProfileBloc>().add(ProfileSaveRequested(updatedProfile));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Личные данные",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ваш пол",
              style: TextStyle(color: _textGrey, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildGenderButton("Мужчина", Icons.male_rounded, Sex.male),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGenderButton("Женщина", Icons.female_rounded, Sex.female),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildInputField("Рост (см)", _heightController, "175", TextInputType.number),
            const SizedBox(height: 24),
            _buildInputField("Возраст (лет)", _ageController, "25", TextInputType.number),
            const SizedBox(height: 24),
            _buildInputField("Целевой вес (кг)", _targetController, "Не указан", const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 32),
            const Text(
              "Ваша цель",
              style: TextStyle(color: _textGrey, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildGoalSelector(),
            const SizedBox(height: 32),
            const Text(
              "Активность",
              style: TextStyle(color: _textGrey, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildActivitySelector(),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _limeAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  "СОХРАНИТЬ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGenderButton(String title, IconData icon, Sex sex) {
    final isSelected = _selectedSex == sex;
    return GestureDetector(
      onTap: () => setState(() => _selectedSex = sex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _limeAccent : Colors.white.withValues(alpha: 0.05),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? _limeAccent : _textGrey, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : _textGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSelector() {
    final goals = {
      FitnessGoal.weightLoss: "Похудение",
      FitnessGoal.maintenance: "Поддержание",
      FitnessGoal.massGain: "Набор массы",
      FitnessGoal.aggressiveWeightLoss: "Сушка",
    };

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: goals.entries.map((e) {
            final isSelected = _selectedGoal == e.key;
            return ListTile(
              onTap: () => setState(() => _selectedGoal = e.key),
              title: Text(
                e.value,
                style: TextStyle(
                  color: isSelected ? _limeAccent : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected 
                  ? const Icon(Icons.check_circle_rounded, color: _limeAccent)
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivitySelector() {
    final activities = {
      ActivityLevel.sedentary: "Сидячий (без тренировок)",
      ActivityLevel.light: "Легкий (1-3 тренировки)",
      ActivityLevel.moderate: "Умеренный (3-5 тренировок)",
      ActivityLevel.active: "Активный (6-7 тренировок)",
      ActivityLevel.veryActive: "Экстремальный (2 раза в день)",
    };

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: activities.entries.map((e) {
            final isSelected = _selectedActivity == e.key;
            return ListTile(
              onTap: () => setState(() => _selectedActivity = e.key),
              title: Text(
                e.value,
                style: TextStyle(
                  color: isSelected ? _limeAccent : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected 
                  ? const Icon(Icons.check_circle_rounded, color: _limeAccent)
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, TextInputType keyboardType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: _textGrey, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            cursorColor: _limeAccent,
          ),
        ),
      ],
    );
  }
}
