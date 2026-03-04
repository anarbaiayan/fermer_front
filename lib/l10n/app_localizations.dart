import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Fermer+'**
  String get appTitle;

  /// No description provided for @farmName.
  ///
  /// In ru, this message translates to:
  /// **'Название фермы'**
  String get farmName;

  /// No description provided for @navHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get navHome;

  /// No description provided for @navHerd.
  ///
  /// In ru, this message translates to:
  /// **'Стадо'**
  String get navHerd;

  /// No description provided for @navEvents.
  ///
  /// In ru, this message translates to:
  /// **'События'**
  String get navEvents;

  /// No description provided for @navRation.
  ///
  /// In ru, this message translates to:
  /// **'Рацион'**
  String get navRation;

  /// No description provided for @navLactation.
  ///
  /// In ru, this message translates to:
  /// **'Лактация'**
  String get navLactation;

  /// No description provided for @drawerProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get drawerProfile;

  /// No description provided for @drawerSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get drawerSettings;

  /// No description provided for @drawerFaq.
  ///
  /// In ru, this message translates to:
  /// **'Часто задаваемые\nвопросы'**
  String get drawerFaq;

  /// No description provided for @drawerSupport.
  ///
  /// In ru, this message translates to:
  /// **'Служба поддержки'**
  String get drawerSupport;

  /// No description provided for @drawerReferral.
  ///
  /// In ru, this message translates to:
  /// **'Реферальная\nпрограмма'**
  String get drawerReferral;

  /// No description provided for @drawerLogout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти с аккаунта'**
  String get drawerLogout;

  /// No description provided for @drawerLogoutConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Вы действительно\nхотите выйти из Fermer+?'**
  String get drawerLogoutConfirm;

  /// No description provided for @drawerLogoutButton.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get drawerLogoutButton;

  /// No description provided for @dialogOk.
  ///
  /// In ru, this message translates to:
  /// **'Ок'**
  String get dialogOk;

  /// No description provided for @dialogCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get dialogCancel;

  /// No description provided for @dialogDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get dialogDelete;

  /// No description provided for @dialogClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get dialogClose;

  /// No description provided for @dialogUnderstood.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get dialogUnderstood;

  /// No description provided for @errorPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: {error}'**
  String errorPrefix(String error);

  /// No description provided for @errorLoadingList.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка при загрузке списка'**
  String get errorLoadingList;

  /// No description provided for @errorLoadingStats.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка при загрузке статистики:\n{error}'**
  String errorLoadingStats(String error);

  /// No description provided for @errorLoadingQuantity.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка при загрузке данных по количеству:\n{error}'**
  String errorLoadingQuantity(String error);

  /// No description provided for @errorLoadingData.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка при загрузке: {error}'**
  String errorLoadingData(String error);

  /// No description provided for @errorLoading.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка при загрузке'**
  String get errorLoading;

  /// No description provided for @errorDeletion.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка удаления: {error}'**
  String errorDeletion(String error);

  /// No description provided for @errorAddingEvent.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка при добавлении события: {error}'**
  String errorAddingEvent(String error);

  /// No description provided for @errorTypes.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка типов: {error}'**
  String errorTypes(String error);

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In ru, this message translates to:
  /// **'Сохранение...'**
  String get saving;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @continueText.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continueText;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'ВХОД'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите информацию для входа в личный кабинет'**
  String get loginSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In ru, this message translates to:
  /// **'ВОЙТИ'**
  String get loginButton;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get loginPhoneLabel;

  /// No description provided for @loginPhoneHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер'**
  String get loginPhoneHint;

  /// No description provided for @loginPhoneError.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный номер телефона'**
  String get loginPhoneError;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordError.
  ///
  /// In ru, this message translates to:
  /// **'Неверный пароль. Попробуйте ввести снова.'**
  String get loginPasswordError;

  /// No description provided for @loginForgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In ru, this message translates to:
  /// **'Ещё нет аккаунта?'**
  String get loginNoAccount;

  /// No description provided for @loginRegisterHint.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрируйтесь для использования платформы Fermer+'**
  String get loginRegisterHint;

  /// No description provided for @loginRegisterButton.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get loginRegisterButton;

  /// No description provided for @registerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите информацию для регистрации'**
  String get registerSubtitle;

  /// No description provided for @registerFirstName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get registerFirstName;

  /// No description provided for @registerFirstNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите имя'**
  String get registerFirstNameHint;

  /// No description provided for @registerLastName.
  ///
  /// In ru, this message translates to:
  /// **'Фамилия'**
  String get registerLastName;

  /// No description provided for @registerLastNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите фамилию'**
  String get registerLastNameHint;

  /// No description provided for @registerFarmName.
  ///
  /// In ru, this message translates to:
  /// **'Название фермы'**
  String get registerFarmName;

  /// No description provided for @registerFarmNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите название фермы'**
  String get registerFarmNameHint;

  /// No description provided for @registerFillAll.
  ///
  /// In ru, this message translates to:
  /// **'Заполните все поля'**
  String get registerFillAll;

  /// No description provided for @registerStep1.
  ///
  /// In ru, this message translates to:
  /// **'Шаг 1'**
  String get registerStep1;

  /// No description provided for @registerStep2.
  ///
  /// In ru, this message translates to:
  /// **'Шаг 2'**
  String get registerStep2;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте номер телефона, на который придет код верификации для сброса пароля'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordGetCode.
  ///
  /// In ru, this message translates to:
  /// **'Получить код'**
  String get forgotPasswordGetCode;

  /// No description provided for @forgotPasswordCodeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Код верификации'**
  String get forgotPasswordCodeTitle;

  /// No description provided for @forgotPasswordCodeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите 4-значный код верификации для сброса пароля'**
  String get forgotPasswordCodeSubtitle;

  /// No description provided for @forgotPasswordResetButton.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить пароль'**
  String get forgotPasswordResetButton;

  /// No description provided for @forgotPasswordNewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите новый пароль'**
  String get forgotPasswordNewTitle;

  /// No description provided for @forgotPasswordNewSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Установите новый пароль для входа в приложение'**
  String get forgotPasswordNewSubtitle;

  /// No description provided for @forgotPasswordNewLabel.
  ///
  /// In ru, this message translates to:
  /// **'Новый пароль'**
  String get forgotPasswordNewLabel;

  /// No description provided for @forgotPasswordNewHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите новый пароль'**
  String get forgotPasswordNewHint;

  /// No description provided for @forgotPasswordConfirmLabel.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение пароля'**
  String get forgotPasswordConfirmLabel;

  /// No description provided for @forgotPasswordConfirmHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль повторно'**
  String get forgotPasswordConfirmHint;

  /// No description provided for @forgotPasswordSetButton.
  ///
  /// In ru, this message translates to:
  /// **'Установить пароль'**
  String get forgotPasswordSetButton;

  /// No description provided for @forgotPasswordSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Новый пароль успешно\nустановлен!'**
  String get forgotPasswordSuccess;

  /// No description provided for @forgotPasswordGoLogin.
  ///
  /// In ru, this message translates to:
  /// **'Войти в Fermer +'**
  String get forgotPasswordGoLogin;

  /// No description provided for @homeSummary.
  ///
  /// In ru, this message translates to:
  /// **'Сводка'**
  String get homeSummary;

  /// No description provided for @homeHerd.
  ///
  /// In ru, this message translates to:
  /// **'Стадо'**
  String get homeHerd;

  /// No description provided for @homeAnimalStatuses.
  ///
  /// In ru, this message translates to:
  /// **'Статусы животных'**
  String get homeAnimalStatuses;

  /// No description provided for @homeHerdHealth.
  ///
  /// In ru, this message translates to:
  /// **'Здоровье стада'**
  String get homeHerdHealth;

  /// No description provided for @homeHealthy.
  ///
  /// In ru, this message translates to:
  /// **'Здоровые'**
  String get homeHealthy;

  /// No description provided for @homeSick.
  ///
  /// In ru, this message translates to:
  /// **'Больные'**
  String get homeSick;

  /// No description provided for @homeDataUpdating.
  ///
  /// In ru, this message translates to:
  /// **'Данные обновляются...'**
  String get homeDataUpdating;

  /// No description provided for @homeTabNotImplemented.
  ///
  /// In ru, this message translates to:
  /// **'Контент для вкладки {index} ещё не реализован'**
  String homeTabNotImplemented(int index);

  /// No description provided for @searchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск скота'**
  String get searchHint;

  /// No description provided for @searchByNameOrTag.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по имени или бирке'**
  String get searchByNameOrTag;

  /// No description provided for @summaryTabBrief.
  ///
  /// In ru, this message translates to:
  /// **'Краткая'**
  String get summaryTabBrief;

  /// No description provided for @summaryTabQuantity.
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get summaryTabQuantity;

  /// No description provided for @summaryTabCondition.
  ///
  /// In ru, this message translates to:
  /// **'Состояние'**
  String get summaryTabCondition;

  /// No description provided for @summaryTabIncome.
  ///
  /// In ru, this message translates to:
  /// **'Доходы/Расходы'**
  String get summaryTabIncome;

  /// No description provided for @summaryTabMilk.
  ///
  /// In ru, this message translates to:
  /// **'Молоко'**
  String get summaryTabMilk;

  /// No description provided for @summaryTabRation.
  ///
  /// In ru, this message translates to:
  /// **'Рацион/Запасы'**
  String get summaryTabRation;

  /// No description provided for @herdSummaryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сводка стада'**
  String get herdSummaryTitle;

  /// No description provided for @herdTotalAnimals.
  ///
  /// In ru, this message translates to:
  /// **'Всего животных: {count}'**
  String herdTotalAnimals(int count);

  /// No description provided for @herdUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Обновлено: {time}'**
  String herdUpdated(String time);

  /// No description provided for @herdDetails.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get herdDetails;

  /// No description provided for @herdTotalCount.
  ///
  /// In ru, this message translates to:
  /// **'Всего: {count}'**
  String herdTotalCount(int count);

  /// No description provided for @herdTotalCattle.
  ///
  /// In ru, this message translates to:
  /// **'Всего скота: {count}'**
  String herdTotalCattle(int count);

  /// No description provided for @statusLactating.
  ///
  /// In ru, this message translates to:
  /// **'Дойные'**
  String get statusLactating;

  /// No description provided for @statusDryPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Сухостой'**
  String get statusDryPeriod;

  /// No description provided for @statusOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открытые'**
  String get statusOpen;

  /// No description provided for @statusInseminated.
  ///
  /// In ru, this message translates to:
  /// **'Осемененные'**
  String get statusInseminated;

  /// No description provided for @quantityTitle.
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get quantityTitle;

  /// No description provided for @groupsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Группы'**
  String get groupsTitle;

  /// No description provided for @groupsTotalCount.
  ///
  /// In ru, this message translates to:
  /// **'Всего групп: {count}'**
  String groupsTotalCount(int count);

  /// No description provided for @groupsView.
  ///
  /// In ru, this message translates to:
  /// **'Посмотреть'**
  String get groupsView;

  /// No description provided for @groupCows.
  ///
  /// In ru, this message translates to:
  /// **'Коровы'**
  String get groupCows;

  /// No description provided for @groupHeifers.
  ///
  /// In ru, this message translates to:
  /// **'Тёлки'**
  String get groupHeifers;

  /// No description provided for @groupBulls.
  ///
  /// In ru, this message translates to:
  /// **'Быки'**
  String get groupBulls;

  /// No description provided for @groupCalves.
  ///
  /// In ru, this message translates to:
  /// **'Телята'**
  String get groupCalves;

  /// No description provided for @timeJustNow.
  ///
  /// In ru, this message translates to:
  /// **'только что'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In ru, this message translates to:
  /// **'{minutes} мин назад'**
  String timeMinutesAgo(int minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In ru, this message translates to:
  /// **'{hours} ч назад'**
  String timeHoursAgo(int hours);

  /// No description provided for @timeDaysAgo.
  ///
  /// In ru, this message translates to:
  /// **'{days} д назад'**
  String timeDaysAgo(int days);

  /// No description provided for @timeOneHourAgo.
  ///
  /// In ru, this message translates to:
  /// **'1 час назад'**
  String get timeOneHourAgo;

  /// No description provided for @herdAllCattle.
  ///
  /// In ru, this message translates to:
  /// **'Весь скот'**
  String get herdAllCattle;

  /// No description provided for @herdAnimalList.
  ///
  /// In ru, this message translates to:
  /// **'Список животных'**
  String get herdAnimalList;

  /// No description provided for @herdLoadingFilter.
  ///
  /// In ru, this message translates to:
  /// **'Загружаем данные для фильтра...'**
  String get herdLoadingFilter;

  /// No description provided for @emptyHerdTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ваш список пустует'**
  String get emptyHerdTitle;

  /// No description provided for @emptyHerdSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте первую карточку своего животного'**
  String get emptyHerdSubtitle;

  /// No description provided for @emptySearchTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get emptySearchTitle;

  /// No description provided for @emptySearchSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте изменить запрос'**
  String get emptySearchSubtitle;

  /// No description provided for @addAnimal.
  ///
  /// In ru, this message translates to:
  /// **'Добавить животное'**
  String get addAnimal;

  /// No description provided for @animalInfo.
  ///
  /// In ru, this message translates to:
  /// **'Информация о животном'**
  String get animalInfo;

  /// No description provided for @animalMainInfo.
  ///
  /// In ru, this message translates to:
  /// **'Основная информация'**
  String get animalMainInfo;

  /// No description provided for @animalTag.
  ///
  /// In ru, this message translates to:
  /// **'Бирка'**
  String get animalTag;

  /// No description provided for @animalBirthDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата рождения'**
  String get animalBirthDate;

  /// No description provided for @animalAge.
  ///
  /// In ru, this message translates to:
  /// **'Возраст'**
  String get animalAge;

  /// No description provided for @animalCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get animalCategory;

  /// No description provided for @animalBreed.
  ///
  /// In ru, this message translates to:
  /// **'Порода'**
  String get animalBreed;

  /// No description provided for @animalGroup.
  ///
  /// In ru, this message translates to:
  /// **'Группа'**
  String get animalGroup;

  /// No description provided for @animalHealthStatus.
  ///
  /// In ru, this message translates to:
  /// **'Состояние здоровья'**
  String get animalHealthStatus;

  /// No description provided for @animalNoName.
  ///
  /// In ru, this message translates to:
  /// **'Без имени'**
  String get animalNoName;

  /// No description provided for @animalDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить животное?'**
  String get animalDeleteTitle;

  /// No description provided for @animalDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Это действие нельзя отменить. Вы уверены?'**
  String get animalDeleteConfirm;

  /// No description provided for @animalDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Животное удалено'**
  String get animalDeleted;

  /// No description provided for @reproStatusNotInseminated.
  ///
  /// In ru, this message translates to:
  /// **'Не осеменена'**
  String get reproStatusNotInseminated;

  /// No description provided for @reproStatusInseminated.
  ///
  /// In ru, this message translates to:
  /// **'Осеменена'**
  String get reproStatusInseminated;

  /// No description provided for @reproStatusPregnant.
  ///
  /// In ru, this message translates to:
  /// **'Беременна'**
  String get reproStatusPregnant;

  /// No description provided for @reproStatusDry.
  ///
  /// In ru, this message translates to:
  /// **'Сухостой'**
  String get reproStatusDry;

  /// No description provided for @reproStatusNearCalving.
  ///
  /// In ru, this message translates to:
  /// **'Скоро отёл'**
  String get reproStatusNearCalving;

  /// No description provided for @reproStatusFresh.
  ///
  /// In ru, this message translates to:
  /// **'Свежая'**
  String get reproStatusFresh;

  /// No description provided for @reproStatusFreshCow.
  ///
  /// In ru, this message translates to:
  /// **'Свежая корова'**
  String get reproStatusFreshCow;

  /// No description provided for @reproStatusNotPregnant.
  ///
  /// In ru, this message translates to:
  /// **'Не беременна'**
  String get reproStatusNotPregnant;

  /// No description provided for @prodStateLactation.
  ///
  /// In ru, this message translates to:
  /// **'Лактация'**
  String get prodStateLactation;

  /// No description provided for @prodStateDry.
  ///
  /// In ru, this message translates to:
  /// **'Сухостой'**
  String get prodStateDry;

  /// No description provided for @prodStateFattening.
  ///
  /// In ru, this message translates to:
  /// **'Откорм'**
  String get prodStateFattening;

  /// No description provided for @prodStateFatteningFull.
  ///
  /// In ru, this message translates to:
  /// **'На откорме'**
  String get prodStateFatteningFull;

  /// No description provided for @prodStateBreeding.
  ///
  /// In ru, this message translates to:
  /// **'Племенная'**
  String get prodStateBreeding;

  /// No description provided for @prodStateBreedingFull.
  ///
  /// In ru, this message translates to:
  /// **'Племенное использование'**
  String get prodStateBreedingFull;

  /// No description provided for @prodStateUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестно'**
  String get prodStateUnknown;

  /// No description provided for @milkLastYield.
  ///
  /// In ru, this message translates to:
  /// **'Последний надой\n(л/день)'**
  String get milkLastYield;

  /// No description provided for @milkLastYieldDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата последнего\nнадоя'**
  String get milkLastYieldDate;

  /// No description provided for @milkAvg7Days.
  ///
  /// In ru, this message translates to:
  /// **'Средний надой\nза 7 дней'**
  String get milkAvg7Days;

  /// No description provided for @milkAvg30Days.
  ///
  /// In ru, this message translates to:
  /// **'Средний надой\nза 30 дней'**
  String get milkAvg30Days;

  /// No description provided for @milkPeakCurrent.
  ///
  /// In ru, this message translates to:
  /// **'Пик надоя\n(текущая лактация)'**
  String get milkPeakCurrent;

  /// No description provided for @eventsTitle.
  ///
  /// In ru, this message translates to:
  /// **'События'**
  String get eventsTitle;

  /// No description provided for @eventsTasks.
  ///
  /// In ru, this message translates to:
  /// **'Задачи'**
  String get eventsTasks;

  /// No description provided for @eventsCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Завершенные'**
  String get eventsCompleted;

  /// No description provided for @eventsOverdue.
  ///
  /// In ru, this message translates to:
  /// **'Просроченные'**
  String get eventsOverdue;

  /// No description provided for @eventsNone.
  ///
  /// In ru, this message translates to:
  /// **'Нет событий'**
  String get eventsNone;

  /// No description provided for @eventsDateStart.
  ///
  /// In ru, this message translates to:
  /// **'Дата начала'**
  String get eventsDateStart;

  /// No description provided for @eventsDateEnd.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания'**
  String get eventsDateEnd;

  /// No description provided for @eventsAlreadyCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Уже завершено'**
  String get eventsAlreadyCompleted;

  /// No description provided for @eventsCompleteEvent.
  ///
  /// In ru, this message translates to:
  /// **'Завершить событие'**
  String get eventsCompleteEvent;

  /// No description provided for @eventsEventCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Событие завершено'**
  String get eventsEventCompleted;

  /// No description provided for @eventsDeleteEvent.
  ///
  /// In ru, this message translates to:
  /// **'Удалить событие'**
  String get eventsDeleteEvent;

  /// No description provided for @eventsDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить событие?'**
  String get eventsDeleteConfirm;

  /// No description provided for @eventsCannotUndo.
  ///
  /// In ru, this message translates to:
  /// **'Действие нельзя отменить'**
  String get eventsCannotUndo;

  /// No description provided for @eventsDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Событие удалено'**
  String get eventsDeleted;

  /// No description provided for @eventsAdded.
  ///
  /// In ru, this message translates to:
  /// **'Событие добавлено'**
  String get eventsAdded;

  /// No description provided for @addEventTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить событие'**
  String get addEventTitle;

  /// No description provided for @addEventType.
  ///
  /// In ru, this message translates to:
  /// **'Событие'**
  String get addEventType;

  /// No description provided for @addEventDropdownHint.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать из списка'**
  String get addEventDropdownHint;

  /// No description provided for @addEventPickDate.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дату события'**
  String get addEventPickDate;

  /// No description provided for @addEventComment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий (опционально)'**
  String get addEventComment;

  /// No description provided for @addEventSelectType.
  ///
  /// In ru, this message translates to:
  /// **'Выберите тип события'**
  String get addEventSelectType;

  /// No description provided for @addEventSelectDate.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дату события'**
  String get addEventSelectDate;

  /// No description provided for @addEventEnterName.
  ///
  /// In ru, this message translates to:
  /// **'Введите название события'**
  String get addEventEnterName;

  /// No description provided for @addEventSelectHeatStart.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дату начала охоты'**
  String get addEventSelectHeatStart;

  /// No description provided for @addEventEnterCalfTag.
  ///
  /// In ru, this message translates to:
  /// **'Введите бирку телёнка'**
  String get addEventEnterCalfTag;

  /// No description provided for @addEventSelectCalfGender.
  ///
  /// In ru, this message translates to:
  /// **'Выберите пол телёнка'**
  String get addEventSelectCalfGender;

  /// No description provided for @addEventEnterCalfWeight.
  ///
  /// In ru, this message translates to:
  /// **'Введите вес телёнка при рождении'**
  String get addEventEnterCalfWeight;

  /// No description provided for @eventDateVaccination.
  ///
  /// In ru, this message translates to:
  /// **'Дата вакцинации'**
  String get eventDateVaccination;

  /// No description provided for @eventDateTreatment.
  ///
  /// In ru, this message translates to:
  /// **'Дата обработки'**
  String get eventDateTreatment;

  /// No description provided for @eventDateIllness.
  ///
  /// In ru, this message translates to:
  /// **'Дата заболевания'**
  String get eventDateIllness;

  /// No description provided for @eventDateWeighing.
  ///
  /// In ru, this message translates to:
  /// **'Дата взвешивания'**
  String get eventDateWeighing;

  /// No description provided for @eventDateInsemination.
  ///
  /// In ru, this message translates to:
  /// **'Дата\nосеменения'**
  String get eventDateInsemination;

  /// No description provided for @eventDateCheck.
  ///
  /// In ru, this message translates to:
  /// **'Дата проверки'**
  String get eventDateCheck;

  /// No description provided for @eventDateHornProcessing.
  ///
  /// In ru, this message translates to:
  /// **'Дата обработки'**
  String get eventDateHornProcessing;

  /// No description provided for @eventDateCalving.
  ///
  /// In ru, this message translates to:
  /// **'Дата отела'**
  String get eventDateCalving;

  /// No description provided for @eventDatePregnancy.
  ///
  /// In ru, this message translates to:
  /// **'Дата\nстельности'**
  String get eventDatePregnancy;

  /// No description provided for @eventDateStart.
  ///
  /// In ru, this message translates to:
  /// **'Дата начала'**
  String get eventDateStart;

  /// No description provided for @eventDateSync.
  ///
  /// In ru, this message translates to:
  /// **'Дата синхронизации'**
  String get eventDateSync;

  /// No description provided for @eventDateWeaning.
  ///
  /// In ru, this message translates to:
  /// **'Дата отъема'**
  String get eventDateWeaning;

  /// No description provided for @eventDateHoofTrimming.
  ///
  /// In ru, this message translates to:
  /// **'Дата расчистки'**
  String get eventDateHoofTrimming;

  /// No description provided for @eventDateGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Дата события'**
  String get eventDateGeneric;

  /// No description provided for @eventActionHeat.
  ///
  /// In ru, this message translates to:
  /// **'Проверка на охоту'**
  String get eventActionHeat;

  /// No description provided for @eventActionPregnancy.
  ///
  /// In ru, this message translates to:
  /// **'Провести проверку на стельность'**
  String get eventActionPregnancy;

  /// No description provided for @eventActionDryPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Запланирован перевод в сухостой'**
  String get eventActionDryPeriod;

  /// No description provided for @eventActionWeighing.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендуется провести взвешивание'**
  String get eventActionWeighing;

  /// No description provided for @eventActionVaccination.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендуется провести вакцинацию'**
  String get eventActionVaccination;

  /// No description provided for @eventActionIllness.
  ///
  /// In ru, this message translates to:
  /// **'Провести лечение/осмотр'**
  String get eventActionIllness;

  /// No description provided for @eventActionHoof.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендуется расчистка копыт'**
  String get eventActionHoof;

  /// No description provided for @eventActionAntiparasitic.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендуется обработка от паразитов'**
  String get eventActionAntiparasitic;

  /// No description provided for @eventActionCalving.
  ///
  /// In ru, this message translates to:
  /// **'Контроль после отела'**
  String get eventActionCalving;

  /// No description provided for @eventActionInsemination.
  ///
  /// In ru, this message translates to:
  /// **'Запланировано осеменение'**
  String get eventActionInsemination;

  /// No description provided for @eventActionWeaning.
  ///
  /// In ru, this message translates to:
  /// **'Запланирован отъем'**
  String get eventActionWeaning;

  /// No description provided for @eventActionDefault.
  ///
  /// In ru, this message translates to:
  /// **'Пришло время выполнить событие'**
  String get eventActionDefault;

  /// No description provided for @eventOverdueHint.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендуется выполнить как можно скорее'**
  String get eventOverdueHint;

  /// No description provided for @fieldVaccine.
  ///
  /// In ru, this message translates to:
  /// **'Вакцина'**
  String get fieldVaccine;

  /// No description provided for @fieldVaccineHint.
  ///
  /// In ru, this message translates to:
  /// **'Наименование вакцины'**
  String get fieldVaccineHint;

  /// No description provided for @fieldWeightKg.
  ///
  /// In ru, this message translates to:
  /// **'Вес (кг)'**
  String get fieldWeightKg;

  /// No description provided for @fieldWeightHint.
  ///
  /// In ru, this message translates to:
  /// **'Результат взвешивания'**
  String get fieldWeightHint;

  /// No description provided for @fieldDiagnosis.
  ///
  /// In ru, this message translates to:
  /// **'Диагноз'**
  String get fieldDiagnosis;

  /// No description provided for @fieldDiagnosisHint.
  ///
  /// In ru, this message translates to:
  /// **'Название заболевания'**
  String get fieldDiagnosisHint;

  /// No description provided for @fieldDrug.
  ///
  /// In ru, this message translates to:
  /// **'Препарат'**
  String get fieldDrug;

  /// No description provided for @fieldDrugHint.
  ///
  /// In ru, this message translates to:
  /// **'Название препарата'**
  String get fieldDrugHint;

  /// No description provided for @fieldDosage.
  ///
  /// In ru, this message translates to:
  /// **'Дозировка'**
  String get fieldDosage;

  /// No description provided for @fieldDosageHint.
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get fieldDosageHint;

  /// No description provided for @fieldTreatmentDuration.
  ///
  /// In ru, this message translates to:
  /// **'Длительность лечения (дни)'**
  String get fieldTreatmentDuration;

  /// No description provided for @fieldEndDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания'**
  String get fieldEndDate;

  /// No description provided for @fieldSelectDate.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дату'**
  String get fieldSelectDate;

  /// No description provided for @fieldMaleTag.
  ///
  /// In ru, this message translates to:
  /// **'Бирка самца'**
  String get fieldMaleTag;

  /// No description provided for @fieldFemaleTag.
  ///
  /// In ru, this message translates to:
  /// **'Бирка самки'**
  String get fieldFemaleTag;

  /// No description provided for @fieldEnterTagNumber.
  ///
  /// In ru, this message translates to:
  /// **'Укажите номер бирки'**
  String get fieldEnterTagNumber;

  /// No description provided for @fieldSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Успешность'**
  String get fieldSuccess;

  /// No description provided for @fieldSuccessful.
  ///
  /// In ru, this message translates to:
  /// **'Успешно'**
  String get fieldSuccessful;

  /// No description provided for @fieldUnsuccessful.
  ///
  /// In ru, this message translates to:
  /// **'Безуспешно'**
  String get fieldUnsuccessful;

  /// No description provided for @fieldDifficulty.
  ///
  /// In ru, this message translates to:
  /// **'Сложность'**
  String get fieldDifficulty;

  /// No description provided for @fieldEasy.
  ///
  /// In ru, this message translates to:
  /// **'Лёгкий'**
  String get fieldEasy;

  /// No description provided for @fieldMedium.
  ///
  /// In ru, this message translates to:
  /// **'Средний'**
  String get fieldMedium;

  /// No description provided for @fieldHard.
  ///
  /// In ru, this message translates to:
  /// **'Тяжелый'**
  String get fieldHard;

  /// No description provided for @fieldCalfTag.
  ///
  /// In ru, this message translates to:
  /// **'Бирка телёнка'**
  String get fieldCalfTag;

  /// No description provided for @fieldCalfTagHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер бирки'**
  String get fieldCalfTagHint;

  /// No description provided for @fieldCalfName.
  ///
  /// In ru, this message translates to:
  /// **'Имя телёнка'**
  String get fieldCalfName;

  /// No description provided for @fieldCalfNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите имя телёнка'**
  String get fieldCalfNameHint;

  /// No description provided for @fieldCalfGender.
  ///
  /// In ru, this message translates to:
  /// **'Пол телёнка'**
  String get fieldCalfGender;

  /// No description provided for @fieldCalfGenderHint.
  ///
  /// In ru, this message translates to:
  /// **'Выберите'**
  String get fieldCalfGenderHint;

  /// No description provided for @fieldMale.
  ///
  /// In ru, this message translates to:
  /// **'Самец'**
  String get fieldMale;

  /// No description provided for @fieldFemale.
  ///
  /// In ru, this message translates to:
  /// **'Самка'**
  String get fieldFemale;

  /// No description provided for @fieldBirthWeight.
  ///
  /// In ru, this message translates to:
  /// **'Вес при рождении (кг)'**
  String get fieldBirthWeight;

  /// No description provided for @fieldBirthWeightHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите вес'**
  String get fieldBirthWeightHint;

  /// No description provided for @fieldHeatStartDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата начала'**
  String get fieldHeatStartDate;

  /// No description provided for @fieldHeatEndDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата конца'**
  String get fieldHeatEndDate;

  /// No description provided for @fieldHeatStart.
  ///
  /// In ru, this message translates to:
  /// **'Начало охоты'**
  String get fieldHeatStart;

  /// No description provided for @fieldHeatEnd.
  ///
  /// In ru, this message translates to:
  /// **'Конец охоты'**
  String get fieldHeatEnd;

  /// No description provided for @fieldDrugNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите название препарата'**
  String get fieldDrugNameHint;

  /// No description provided for @fieldDosageHint2.
  ///
  /// In ru, this message translates to:
  /// **'Введите дозировку'**
  String get fieldDosageHint2;

  /// No description provided for @selectCattleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выбор скота'**
  String get selectCattleTitle;

  /// No description provided for @selectCattleSelected.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано: {count}'**
  String selectCattleSelected(int count);

  /// No description provided for @selectCattleAll.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать все'**
  String get selectCattleAll;

  /// No description provided for @selectCattleClear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get selectCattleClear;

  /// No description provided for @selectCattleDone.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get selectCattleDone;

  /// No description provided for @selectCattleNoTag.
  ///
  /// In ru, this message translates to:
  /// **'Без бирки'**
  String get selectCattleNoTag;

  /// No description provided for @rationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Рационы/Запасы'**
  String get rationsTitle;

  /// No description provided for @rationsFeedStock.
  ///
  /// In ru, this message translates to:
  /// **'Запасы корма'**
  String get rationsFeedStock;

  /// No description provided for @rationsConcentrates.
  ///
  /// In ru, this message translates to:
  /// **'Концентраты'**
  String get rationsConcentrates;

  /// No description provided for @rationsSucculentFeed.
  ///
  /// In ru, this message translates to:
  /// **'Сочный корм'**
  String get rationsSucculentFeed;

  /// No description provided for @rationsRoughage.
  ///
  /// In ru, this message translates to:
  /// **'Грубые корма'**
  String get rationsRoughage;

  /// No description provided for @rationsAdditives.
  ///
  /// In ru, this message translates to:
  /// **'Добавки'**
  String get rationsAdditives;

  /// No description provided for @rationsListTitle.
  ///
  /// In ru, this message translates to:
  /// **'Список рационов'**
  String get rationsListTitle;

  /// No description provided for @rationsNotGenerated.
  ///
  /// In ru, this message translates to:
  /// **'Рационы пока не сгенерированы'**
  String get rationsNotGenerated;

  /// No description provided for @rationsNoMatch.
  ///
  /// In ru, this message translates to:
  /// **'Нет рационов, подходящих для этого животного'**
  String get rationsNoMatch;

  /// No description provided for @rationsDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Рацион удалён'**
  String get rationsDeleted;

  /// No description provided for @rationsEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ваш список пустует'**
  String get rationsEmptyTitle;

  /// No description provided for @rationsEmptySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Для отображения списка рационов,\nдобавьте Ваш запас корма'**
  String get rationsEmptySubtitle;

  /// No description provided for @rationsAddFeedStock.
  ///
  /// In ru, this message translates to:
  /// **'Добавить запасы корма'**
  String get rationsAddFeedStock;

  /// No description provided for @rationStatusActive.
  ///
  /// In ru, this message translates to:
  /// **'Активный'**
  String get rationStatusActive;

  /// No description provided for @rationStatusNeedsAttention.
  ///
  /// In ru, this message translates to:
  /// **'Требует внимания'**
  String get rationStatusNeedsAttention;

  /// No description provided for @rationDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить рацион?'**
  String get rationDeleteTitle;

  /// No description provided for @rationDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить этот рацион? Это действие нельзя отменить.'**
  String get rationDeleteConfirm;

  /// No description provided for @rationCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория: {category}'**
  String rationCategory(String category);

  /// No description provided for @rationPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Период: {period}'**
  String rationPeriod(String period);

  /// No description provided for @rationDailyCost.
  ///
  /// In ru, this message translates to:
  /// **'Стоимость/день: {cost} тг.'**
  String rationDailyCost(String cost);

  /// No description provided for @rationFeedType.
  ///
  /// In ru, this message translates to:
  /// **'Вид корма: {names}'**
  String rationFeedType(String names);

  /// No description provided for @rationDailyNorm.
  ///
  /// In ru, this message translates to:
  /// **'Норма в день: {kg} кг'**
  String rationDailyNorm(String kg);

  /// No description provided for @rationInfoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Информация о рационе'**
  String get rationInfoTitle;

  /// No description provided for @rationMainInfo.
  ///
  /// In ru, this message translates to:
  /// **'Основная информация рациона'**
  String get rationMainInfo;

  /// No description provided for @rationCategoryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get rationCategoryLabel;

  /// No description provided for @rationPeriodLabel.
  ///
  /// In ru, this message translates to:
  /// **'Период'**
  String get rationPeriodLabel;

  /// No description provided for @rationDailyCostLabel.
  ///
  /// In ru, this message translates to:
  /// **'Стоимость в день'**
  String get rationDailyCostLabel;

  /// No description provided for @rationDailyCostValue.
  ///
  /// In ru, this message translates to:
  /// **'{cost} тг.'**
  String rationDailyCostValue(String cost);

  /// No description provided for @rationStatusLabel.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get rationStatusLabel;

  /// No description provided for @rationDailyNormLabel.
  ///
  /// In ru, this message translates to:
  /// **'Норма в день'**
  String get rationDailyNormLabel;

  /// No description provided for @rationDailyNormValue.
  ///
  /// In ru, this message translates to:
  /// **'{kg} кг'**
  String rationDailyNormValue(String kg);

  /// No description provided for @rationFeedsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Кормы рациона'**
  String get rationFeedsTitle;

  /// No description provided for @rationNeedKg.
  ///
  /// In ru, this message translates to:
  /// **'Потребность (кг)'**
  String get rationNeedKg;

  /// No description provided for @rationCostKgTg.
  ///
  /// In ru, this message translates to:
  /// **'Стоимость (кг/тг)'**
  String get rationCostKgTg;

  /// No description provided for @rationDailyExpense.
  ///
  /// In ru, this message translates to:
  /// **'Суточный расход (тг)'**
  String get rationDailyExpense;

  /// No description provided for @inventoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Запасы'**
  String get inventoryTitle;

  /// No description provided for @inventoryTotalFeed.
  ///
  /// In ru, this message translates to:
  /// **'Всего корма: {kg} кг'**
  String inventoryTotalFeed(String kg);

  /// No description provided for @inventoryFeedDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Корм удалён'**
  String get inventoryFeedDeleted;

  /// No description provided for @inventoryDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить корм?'**
  String get inventoryDeleteTitle;

  /// No description provided for @inventoryDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить этот корм? Это действие нельзя отменить.'**
  String get inventoryDeleteConfirm;

  /// No description provided for @lactationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лактация'**
  String get lactationTitle;

  /// No description provided for @lactationMilkPerDay.
  ///
  /// In ru, this message translates to:
  /// **'Молоко за день: {liters} л.'**
  String lactationMilkPerDay(String liters);

  /// No description provided for @lactationQuantity.
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get lactationQuantity;

  /// No description provided for @lactationCowMilking.
  ///
  /// In ru, this message translates to:
  /// **'Надой коровы'**
  String get lactationCowMilking;

  /// No description provided for @lactationFarmMilking.
  ///
  /// In ru, this message translates to:
  /// **'Надой по ферме'**
  String get lactationFarmMilking;

  /// No description provided for @lactationDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get lactationDate;

  /// No description provided for @lactationTime.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get lactationTime;

  /// No description provided for @lactationMilkingTime.
  ///
  /// In ru, this message translates to:
  /// **'Время доения'**
  String get lactationMilkingTime;

  /// No description provided for @lactationMorning.
  ///
  /// In ru, this message translates to:
  /// **'Утро'**
  String get lactationMorning;

  /// No description provided for @lactationEvening.
  ///
  /// In ru, this message translates to:
  /// **'Вечер'**
  String get lactationEvening;

  /// No description provided for @lactationCowTag.
  ///
  /// In ru, this message translates to:
  /// **'Бирка коровы'**
  String get lactationCowTag;

  /// No description provided for @lactationEnterInfo.
  ///
  /// In ru, this message translates to:
  /// **'Введите информацию'**
  String get lactationEnterInfo;

  /// No description provided for @lactationMilkAmount.
  ///
  /// In ru, this message translates to:
  /// **'Количество молока'**
  String get lactationMilkAmount;

  /// No description provided for @lactationEnterMilk.
  ///
  /// In ru, this message translates to:
  /// **'Введите количество молока (литры)'**
  String get lactationEnterMilk;

  /// No description provided for @lactationSuccessAdd.
  ///
  /// In ru, this message translates to:
  /// **'Информация успешно\nдобавлена и отображена\nв разделе \"Лактация\"'**
  String get lactationSuccessAdd;

  /// No description provided for @lactationGoToList.
  ///
  /// In ru, this message translates to:
  /// **'Перейти к списку'**
  String get lactationGoToList;

  /// No description provided for @lactationAddBulkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить надой за ферму'**
  String get lactationAddBulkTitle;

  /// No description provided for @lactationBulkSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Данные надоя по ферме\nуспешно добавлены!'**
  String get lactationBulkSuccess;

  /// No description provided for @lactationEnterCowCount.
  ///
  /// In ru, this message translates to:
  /// **'Укажите количество подоенных коров'**
  String get lactationEnterCowCount;

  /// No description provided for @lactationEnterTotalMilk.
  ///
  /// In ru, this message translates to:
  /// **'Укажите всего молока (л)'**
  String get lactationEnterTotalMilk;

  /// No description provided for @lactationMilkedCows.
  ///
  /// In ru, this message translates to:
  /// **'Подоено коров'**
  String get lactationMilkedCows;

  /// No description provided for @lactationTotalMilk.
  ///
  /// In ru, this message translates to:
  /// **'Всего молока'**
  String get lactationTotalMilk;

  /// No description provided for @lactationCalfUsed.
  ///
  /// In ru, this message translates to:
  /// **'Использовано для\nтелят'**
  String get lactationCalfUsed;

  /// No description provided for @lactationUnfitMilk.
  ///
  /// In ru, this message translates to:
  /// **'Непригодное\nмолоко'**
  String get lactationUnfitMilk;

  /// No description provided for @lactationAccountingWeek.
  ///
  /// In ru, this message translates to:
  /// **'За неделю'**
  String get lactationAccountingWeek;

  /// No description provided for @lactationAccountingMonth.
  ///
  /// In ru, this message translates to:
  /// **'За месяц'**
  String get lactationAccountingMonth;

  /// No description provided for @lactationAccountingPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Период'**
  String get lactationAccountingPeriod;

  /// No description provided for @lactationDateStartPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Дата начала периода'**
  String get lactationDateStartPeriod;

  /// No description provided for @lactationDateEndPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Дата конца периода'**
  String get lactationDateEndPeriod;

  /// No description provided for @lactationSelectDate.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дату'**
  String get lactationSelectDate;

  /// No description provided for @notFoundTitle.
  ///
  /// In ru, this message translates to:
  /// **'Страница не найдена'**
  String get notFoundTitle;

  /// No description provided for @notFoundGoHome.
  ///
  /// In ru, this message translates to:
  /// **'Вернуться домой'**
  String get notFoundGoHome;

  /// No description provided for @registerPasswordMin.
  ///
  /// In ru, this message translates to:
  /// **'Минимум 6 символов'**
  String get registerPasswordMin;

  /// No description provided for @registerPasswordsMismatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get registerPasswordsMismatch;

  /// No description provided for @registerErrorGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка регистрации. Попробуйте снова.'**
  String get registerErrorGeneric;

  /// No description provided for @registerButton.
  ///
  /// In ru, this message translates to:
  /// **'ЗАРЕГИСТРИРОВАТЬСЯ'**
  String get registerButton;

  /// No description provided for @registerSuccessTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вы успешно\nзарегистрировались\nв Fermer+!'**
  String get registerSuccessTitle;

  /// No description provided for @registerSuccessMessage.
  ///
  /// In ru, this message translates to:
  /// **'Для того, чтобы начать использовать\nприложение, нажмите на кнопку\n\"Начать работу\"'**
  String get registerSuccessMessage;

  /// No description provided for @registerSuccessButton.
  ///
  /// In ru, this message translates to:
  /// **'Начать работу'**
  String get registerSuccessButton;
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
      <String>['kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
