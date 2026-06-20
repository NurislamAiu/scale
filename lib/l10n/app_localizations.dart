import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Yoda'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get home;

  /// No description provided for @analytics.
  ///
  /// In ru, this message translates to:
  /// **'Анализ'**
  String get analytics;

  /// No description provided for @nutrition.
  ///
  /// In ru, this message translates to:
  /// **'Питание'**
  String get nutrition;

  /// No description provided for @profile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profile;

  /// No description provided for @connected.
  ///
  /// In ru, this message translates to:
  /// **'Подключено'**
  String get connected;

  /// No description provided for @connecting.
  ///
  /// In ru, this message translates to:
  /// **'Подключение...'**
  String get connecting;

  /// No description provided for @yodaSmartScale.
  ///
  /// In ru, this message translates to:
  /// **'Умные весы Yoda'**
  String get yodaSmartScale;

  /// No description provided for @synchronized.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизировано'**
  String get synchronized;

  /// No description provided for @myGoal.
  ///
  /// In ru, this message translates to:
  /// **'Моя цель'**
  String get myGoal;

  /// No description provided for @progress.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс'**
  String get progress;

  /// No description provided for @disconnectDevice.
  ///
  /// In ru, this message translates to:
  /// **'Отключить устройство'**
  String get disconnectDevice;

  /// No description provided for @waitOnScale.
  ///
  /// In ru, this message translates to:
  /// **'Встаньте на весы'**
  String get waitOnScale;

  /// No description provided for @measuring.
  ///
  /// In ru, this message translates to:
  /// **'Измерение...'**
  String get measuring;

  /// No description provided for @measured.
  ///
  /// In ru, this message translates to:
  /// **'Измерено'**
  String get measured;

  /// No description provided for @kg.
  ///
  /// In ru, this message translates to:
  /// **'кг'**
  String get kg;

  /// No description provided for @kcal.
  ///
  /// In ru, this message translates to:
  /// **'ккал'**
  String get kcal;

  /// No description provided for @protein.
  ///
  /// In ru, this message translates to:
  /// **'Белки'**
  String get protein;

  /// No description provided for @fats.
  ///
  /// In ru, this message translates to:
  /// **'Жиры'**
  String get fats;

  /// No description provided for @carbs.
  ///
  /// In ru, this message translates to:
  /// **'Углеводы'**
  String get carbs;

  /// No description provided for @saveWeight.
  ///
  /// In ru, this message translates to:
  /// **'СОХРАНИТЬ {weight} КГ'**
  String saveWeight(Object weight);

  /// No description provided for @saved.
  ///
  /// In ru, this message translates to:
  /// **'СОХРАНЕНО'**
  String get saved;

  /// No description provided for @saving.
  ///
  /// In ru, this message translates to:
  /// **'СОХРАНЕНИЕ'**
  String get saving;

  /// No description provided for @history.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get history;

  /// No description provided for @today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get yesterday;

  /// No description provided for @remaining.
  ///
  /// In ru, this message translates to:
  /// **'Осталось'**
  String get remaining;

  /// No description provided for @caloriesPerDay.
  ///
  /// In ru, this message translates to:
  /// **'ккал в день'**
  String get caloriesPerDay;

  /// No description provided for @aiTip.
  ///
  /// In ru, this message translates to:
  /// **'AI Совет'**
  String get aiTip;

  /// No description provided for @meals.
  ///
  /// In ru, this message translates to:
  /// **'Приемы пищи'**
  String get meals;

  /// No description provided for @breakfast.
  ///
  /// In ru, this message translates to:
  /// **'Завтрак'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In ru, this message translates to:
  /// **'Обед'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In ru, this message translates to:
  /// **'Ужин'**
  String get dinner;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @subscription.
  ///
  /// In ru, this message translates to:
  /// **'Подписка'**
  String get subscription;

  /// No description provided for @unlockPro.
  ///
  /// In ru, this message translates to:
  /// **'Разблокировать PRO'**
  String get unlockPro;

  /// No description provided for @unlimitedAi.
  ///
  /// In ru, this message translates to:
  /// **'Безлимитный ИИ и аналитика'**
  String get unlimitedAi;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @calculator.
  ///
  /// In ru, this message translates to:
  /// **'Калькулятор'**
  String get calculator;

  /// No description provided for @searchFood.
  ///
  /// In ru, this message translates to:
  /// **'Поиск еды'**
  String get searchFood;

  /// No description provided for @aiRecipe.
  ///
  /// In ru, this message translates to:
  /// **'ИИ Рецепт'**
  String get aiRecipe;

  /// No description provided for @calculateViaAi.
  ///
  /// In ru, this message translates to:
  /// **'РАССЧИТАТЬ ЧЕРЕЗ ИИ'**
  String get calculateViaAi;

  /// No description provided for @ingredientsHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: 2 яйца, 100г курицы...'**
  String get ingredientsHint;

  /// No description provided for @limitReached.
  ///
  /// In ru, this message translates to:
  /// **'Лимит достигнут'**
  String get limitReached;

  /// No description provided for @proFeatures.
  ///
  /// In ru, this message translates to:
  /// **'Безлимитные запросы и персональные инсайты'**
  String get proFeatures;

  /// No description provided for @paywallTitle.
  ///
  /// In ru, this message translates to:
  /// **'Yoda PRO'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Разблокируйте полную мощь ИИ'**
  String get paywallSubtitle;

  /// No description provided for @annualSubscription.
  ///
  /// In ru, this message translates to:
  /// **'ГОДОВАЯ ПОДПИСКА'**
  String get annualSubscription;

  /// No description provided for @monthlySubscription.
  ///
  /// In ru, this message translates to:
  /// **'МЕСЯЧНАЯ ПОДПИСКА'**
  String get monthlySubscription;

  /// No description provided for @bestValue.
  ///
  /// In ru, this message translates to:
  /// **'ВЫГОДНО'**
  String get bestValue;

  /// No description provided for @tryFree.
  ///
  /// In ru, this message translates to:
  /// **'ПОПРОБОВАТЬ БЕСПЛАТНО'**
  String get tryFree;

  /// No description provided for @sevenDaysFree.
  ///
  /// In ru, this message translates to:
  /// **'7 дней бесплатно, далее по тарифу'**
  String get sevenDaysFree;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
