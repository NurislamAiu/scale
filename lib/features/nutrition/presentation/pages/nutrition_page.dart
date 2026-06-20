import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_scale/features/nutrition/presentation/bloc/nutrition_bloc.dart';
import 'package:smart_scale/features/nutrition/presentation/sheets/ai_ingredients_sheet.dart';
import 'package:smart_scale/features/nutrition/presentation/sheets/calorie_calculator_sheet.dart';
import 'package:smart_scale/features/nutrition/presentation/sheets/progress_calendar_sheet.dart';
import 'package:smart_scale/features/nutrition/presentation/widgets/ai_analysis_card.dart';
import 'package:smart_scale/features/nutrition/presentation/widgets/macro_grid.dart';
import 'package:smart_scale/features/nutrition/presentation/widgets/meal_list.dart';
import 'package:smart_scale/features/nutrition/presentation/widgets/nutrition_actions.dart';
import 'package:smart_scale/features/nutrition/presentation/widgets/nutrition_app_bar.dart';
import 'package:smart_scale/features/nutrition/presentation/widgets/nutrition_summary_card.dart';
import 'package:smart_scale/features/nutrition/presentation/widgets/nutrition_theme.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionBloc, NutritionState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: nutritionBgColor,
          body: SafeArea(
            child: Column(
              children: [
                NutritionAppBar(
                  state: state,
                  onCalendarTap: () => _showProgressCalendar(context, state),
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    children: [
                      NutritionSummaryCard(state: state),
                      const SizedBox(height: 16),
                      NutritionActions(
                        onSearchTap: () => _showCalorieCalculator(context),
                        onAiTap: () => _showAiIngredientsCalculator(context),
                      ),
                      const SizedBox(height: 18),
                      MacroGrid(state: state),
                      const SizedBox(height: 18),
                      AiAnalysisCard(state: state),
                      const SizedBox(height: 24),
                      MealList(
                        state: state,
                        onAddMeal: (type, replaceMealId) {
                          _showCalorieCalculator(
                            context,
                            initialType: type,
                            replaceMealId: replaceMealId,
                          );
                        },
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

  void _showProgressCalendar(BuildContext context, NutritionState state) {
    final nutritionBloc = context.read<NutritionBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ProgressCalendarSheet(
        initialDate: state.selectedDate,
        onDateSelected: (date) {
          nutritionBloc.add(NutritionDateChanged(date));
        },
      ),
    );
  }

  void _showAiIngredientsCalculator(BuildContext context) {
    final nutritionBloc = context.read<NutritionBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: nutritionBloc,
        child: const AiIngredientsSheet(),
      ),
    );
  }

  void _showCalorieCalculator(
    BuildContext context, {
    MealType? initialType,
    String? replaceMealId,
  }) {
    final nutritionBloc = context.read<NutritionBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: nutritionBloc,
        child: CalorieCalculatorSheet(
          initialType: initialType,
          replaceMealId: replaceMealId,
        ),
      ),
    );
  }
}
