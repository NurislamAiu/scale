// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Yoda';

  @override
  String get home => 'Home';

  @override
  String get analytics => 'Analysis';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get profile => 'Profile';

  @override
  String get connected => 'Connected';

  @override
  String get connecting => 'Connecting...';

  @override
  String get yodaSmartScale => 'Yoda Smart Scale';

  @override
  String get synchronized => 'Synchronized';

  @override
  String get myGoal => 'My Goal';

  @override
  String get progress => 'Progress';

  @override
  String get disconnectDevice => 'Disconnect Device';

  @override
  String get waitOnScale => 'Step on the scale';

  @override
  String get measuring => 'Measuring...';

  @override
  String get measured => 'Measured';

  @override
  String get kg => 'kg';

  @override
  String get kcal => 'kcal';

  @override
  String get protein => 'Protein';

  @override
  String get fats => 'Fats';

  @override
  String get carbs => 'Carbs';

  @override
  String saveWeight(Object weight) {
    return 'SAVE $weight KG';
  }

  @override
  String get saved => 'SAVED';

  @override
  String get saving => 'SAVING';

  @override
  String get history => 'History';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get remaining => 'Remaining';

  @override
  String get caloriesPerDay => 'kcal per day';

  @override
  String get aiTip => 'AI Tip';

  @override
  String get meals => 'Meals';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get language => 'Language';

  @override
  String get subscription => 'Subscription';

  @override
  String get unlockPro => 'Unlock PRO';

  @override
  String get unlimitedAi => 'Unlimited AI and Analytics';

  @override
  String get logout => 'Log out';

  @override
  String get cancel => 'Cancel';

  @override
  String get calculator => 'Calculator';

  @override
  String get searchFood => 'Search Food';

  @override
  String get aiRecipe => 'AI Recipe';

  @override
  String get calculateViaAi => 'CALCULATE VIA AI';

  @override
  String get ingredientsHint => 'E.g.: 2 eggs, 100g chicken...';

  @override
  String get limitReached => 'Limit reached';

  @override
  String get proFeatures => 'Unlimited queries and personal insights';

  @override
  String get paywallTitle => 'Yoda PRO';

  @override
  String get paywallSubtitle => 'Unlock the full power of AI';

  @override
  String get annualSubscription => 'ANNUAL SUBSCRIPTION';

  @override
  String get monthlySubscription => 'MONTHLY SUBSCRIPTION';

  @override
  String get bestValue => 'BEST VALUE';

  @override
  String get tryFree => 'TRY FOR FREE';

  @override
  String get sevenDaysFree => '7 days free, then by tariff';
}
