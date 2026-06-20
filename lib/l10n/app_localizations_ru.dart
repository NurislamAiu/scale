// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Yoda';

  @override
  String get home => 'Главная';

  @override
  String get analytics => 'Анализ';

  @override
  String get nutrition => 'Питание';

  @override
  String get profile => 'Профиль';

  @override
  String get connected => 'Подключено';

  @override
  String get connecting => 'Подключение...';

  @override
  String get yodaSmartScale => 'Умные весы Yoda';

  @override
  String get synchronized => 'Синхронизировано';

  @override
  String get myGoal => 'Моя цель';

  @override
  String get progress => 'Прогресс';

  @override
  String get disconnectDevice => 'Отключить устройство';

  @override
  String get waitOnScale => 'Встаньте на весы';

  @override
  String get measuring => 'Измерение...';

  @override
  String get measured => 'Измерено';

  @override
  String get kg => 'кг';

  @override
  String get kcal => 'ккал';

  @override
  String get protein => 'Белки';

  @override
  String get fats => 'Жиры';

  @override
  String get carbs => 'Углеводы';

  @override
  String saveWeight(Object weight) {
    return 'СОХРАНИТЬ $weight КГ';
  }

  @override
  String get saved => 'СОХРАНЕНО';

  @override
  String get saving => 'СОХРАНЕНИЕ';

  @override
  String get history => 'История';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get remaining => 'Осталось';

  @override
  String get caloriesPerDay => 'ккал в день';

  @override
  String get aiTip => 'AI Совет';

  @override
  String get meals => 'Приемы пищи';

  @override
  String get breakfast => 'Завтрак';

  @override
  String get lunch => 'Обед';

  @override
  String get dinner => 'Ужин';

  @override
  String get add => 'Добавить';

  @override
  String get edit => 'Изменить';

  @override
  String get delete => 'Удалить';

  @override
  String get language => 'Язык';

  @override
  String get subscription => 'Подписка';

  @override
  String get unlockPro => 'Разблокировать PRO';

  @override
  String get unlimitedAi => 'Безлимитный ИИ и аналитика';

  @override
  String get logout => 'Выйти из аккаунта';

  @override
  String get cancel => 'Отмена';

  @override
  String get calculator => 'Калькулятор';

  @override
  String get searchFood => 'Поиск еды';

  @override
  String get aiRecipe => 'ИИ Рецепт';

  @override
  String get calculateViaAi => 'РАССЧИТАТЬ ЧЕРЕЗ ИИ';

  @override
  String get ingredientsHint => 'Например: 2 яйца, 100г курицы...';

  @override
  String get limitReached => 'Лимит достигнут';

  @override
  String get proFeatures => 'Безлимитные запросы и персональные инсайты';

  @override
  String get paywallTitle => 'Yoda PRO';

  @override
  String get paywallSubtitle => 'Разблокируйте полную мощь ИИ';

  @override
  String get annualSubscription => 'ГОДОВАЯ ПОДПИСКА';

  @override
  String get monthlySubscription => 'МЕСЯЧНАЯ ПОДПИСКА';

  @override
  String get bestValue => 'ВЫГОДНО';

  @override
  String get tryFree => 'ПОПРОБОВАТЬ БЕСПЛАТНО';

  @override
  String get sevenDaysFree => '7 дней бесплатно, далее по тарифу';
}
