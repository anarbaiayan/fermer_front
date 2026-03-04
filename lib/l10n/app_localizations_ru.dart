// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Fermer+';

  @override
  String get farmName => 'Название фермы';

  @override
  String get navHome => 'Главная';

  @override
  String get navHerd => 'Стадо';

  @override
  String get navEvents => 'События';

  @override
  String get navRation => 'Рацион';

  @override
  String get navLactation => 'Лактация';

  @override
  String get drawerProfile => 'Профиль';

  @override
  String get drawerSettings => 'Настройки';

  @override
  String get drawerFaq => 'Часто задаваемые\nвопросы';

  @override
  String get drawerSupport => 'Служба поддержки';

  @override
  String get drawerReferral => 'Реферальная\nпрограмма';

  @override
  String get drawerLogout => 'Выйти с аккаунта';

  @override
  String get drawerLogoutConfirm =>
      'Вы действительно\nхотите выйти из Fermer+?';

  @override
  String get drawerLogoutButton => 'Выйти';

  @override
  String get dialogOk => 'Ок';

  @override
  String get dialogCancel => 'Отменить';

  @override
  String get dialogDelete => 'Удалить';

  @override
  String get dialogClose => 'Закрыть';

  @override
  String get dialogUnderstood => 'Понятно';

  @override
  String errorPrefix(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get errorLoadingList => 'Ошибка при загрузке списка';

  @override
  String errorLoadingStats(String error) {
    return 'Ошибка при загрузке статистики:\n$error';
  }

  @override
  String errorLoadingQuantity(String error) {
    return 'Ошибка при загрузке данных по количеству:\n$error';
  }

  @override
  String errorLoadingData(String error) {
    return 'Ошибка при загрузке: $error';
  }

  @override
  String get errorLoading => 'Ошибка при загрузке';

  @override
  String errorDeletion(String error) {
    return 'Ошибка удаления: $error';
  }

  @override
  String errorAddingEvent(String error) {
    return 'Ошибка при добавлении события: $error';
  }

  @override
  String errorTypes(String error) {
    return 'Ошибка типов: $error';
  }

  @override
  String get retry => 'Повторить';

  @override
  String get save => 'Сохранить';

  @override
  String get saving => 'Сохранение...';

  @override
  String get add => 'Добавить';

  @override
  String get continueText => 'Продолжить';

  @override
  String get loginTitle => 'ВХОД';

  @override
  String get loginSubtitle => 'Введите информацию для входа в личный кабинет';

  @override
  String get loginButton => 'ВОЙТИ';

  @override
  String get loginPhoneLabel => 'Номер телефона';

  @override
  String get loginPhoneHint => 'Введите номер';

  @override
  String get loginPhoneError => 'Введите корректный номер телефона';

  @override
  String get loginPasswordLabel => 'Пароль';

  @override
  String get loginPasswordError => 'Неверный пароль. Попробуйте ввести снова.';

  @override
  String get loginForgotPassword => 'Забыли пароль?';

  @override
  String get loginNoAccount => 'Ещё нет аккаунта?';

  @override
  String get loginRegisterHint =>
      'Зарегистрируйтесь для использования платформы Fermer+';

  @override
  String get loginRegisterButton => 'Зарегистрироваться';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get registerSubtitle => 'Введите информацию для регистрации';

  @override
  String get registerFirstName => 'Имя';

  @override
  String get registerFirstNameHint => 'Введите имя';

  @override
  String get registerLastName => 'Фамилия';

  @override
  String get registerLastNameHint => 'Введите фамилию';

  @override
  String get registerFarmName => 'Название фермы';

  @override
  String get registerFarmNameHint => 'Введите название фермы';

  @override
  String get registerFillAll => 'Заполните все поля';

  @override
  String get registerStep1 => 'Шаг 1';

  @override
  String get registerStep2 => 'Шаг 2';

  @override
  String get forgotPasswordTitle => 'Забыли пароль?';

  @override
  String get forgotPasswordSubtitle =>
      'Проверьте номер телефона, на который придет код верификации для сброса пароля';

  @override
  String get forgotPasswordGetCode => 'Получить код';

  @override
  String get forgotPasswordCodeTitle => 'Код верификации';

  @override
  String get forgotPasswordCodeSubtitle =>
      'Введите 4-значный код верификации для сброса пароля';

  @override
  String get forgotPasswordResetButton => 'Сбросить пароль';

  @override
  String get forgotPasswordNewTitle => 'Введите новый пароль';

  @override
  String get forgotPasswordNewSubtitle =>
      'Установите новый пароль для входа в приложение';

  @override
  String get forgotPasswordNewLabel => 'Новый пароль';

  @override
  String get forgotPasswordNewHint => 'Введите новый пароль';

  @override
  String get forgotPasswordConfirmLabel => 'Подтверждение пароля';

  @override
  String get forgotPasswordConfirmHint => 'Введите пароль повторно';

  @override
  String get forgotPasswordSetButton => 'Установить пароль';

  @override
  String get forgotPasswordSuccess => 'Новый пароль успешно\nустановлен!';

  @override
  String get forgotPasswordGoLogin => 'Войти в Fermer +';

  @override
  String get homeSummary => 'Сводка';

  @override
  String get homeHerd => 'Стадо';

  @override
  String get homeAnimalStatuses => 'Статусы животных';

  @override
  String get homeHerdHealth => 'Здоровье стада';

  @override
  String get homeHealthy => 'Здоровые';

  @override
  String get homeSick => 'Больные';

  @override
  String get homeDataUpdating => 'Данные обновляются...';

  @override
  String homeTabNotImplemented(int index) {
    return 'Контент для вкладки $index ещё не реализован';
  }

  @override
  String get searchHint => 'Поиск скота';

  @override
  String get searchByNameOrTag => 'Поиск по имени или бирке';

  @override
  String get summaryTabBrief => 'Краткая';

  @override
  String get summaryTabQuantity => 'Количество';

  @override
  String get summaryTabCondition => 'Состояние';

  @override
  String get summaryTabIncome => 'Доходы/Расходы';

  @override
  String get summaryTabMilk => 'Молоко';

  @override
  String get summaryTabRation => 'Рацион/Запасы';

  @override
  String get herdSummaryTitle => 'Сводка стада';

  @override
  String herdTotalAnimals(int count) {
    return 'Всего животных: $count';
  }

  @override
  String herdUpdated(String time) {
    return 'Обновлено: $time';
  }

  @override
  String get herdDetails => 'Подробнее';

  @override
  String herdTotalCount(int count) {
    return 'Всего: $count';
  }

  @override
  String herdTotalCattle(int count) {
    return 'Всего скота: $count';
  }

  @override
  String get statusLactating => 'Дойные';

  @override
  String get statusDryPeriod => 'Сухостой';

  @override
  String get statusOpen => 'Открытые';

  @override
  String get statusInseminated => 'Осемененные';

  @override
  String get quantityTitle => 'Количество';

  @override
  String get groupsTitle => 'Группы';

  @override
  String groupsTotalCount(int count) {
    return 'Всего групп: $count';
  }

  @override
  String get groupsView => 'Посмотреть';

  @override
  String get groupCows => 'Коровы';

  @override
  String get groupHeifers => 'Тёлки';

  @override
  String get groupBulls => 'Быки';

  @override
  String get groupCalves => 'Телята';

  @override
  String get timeJustNow => 'только что';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes мин назад';
  }

  @override
  String timeHoursAgo(int hours) {
    return '$hours ч назад';
  }

  @override
  String timeDaysAgo(int days) {
    return '$days д назад';
  }

  @override
  String get timeOneHourAgo => '1 час назад';

  @override
  String get herdAllCattle => 'Весь скот';

  @override
  String get herdAnimalList => 'Список животных';

  @override
  String get herdLoadingFilter => 'Загружаем данные для фильтра...';

  @override
  String get emptyHerdTitle => 'Ваш список пустует';

  @override
  String get emptyHerdSubtitle => 'Добавьте первую карточку своего животного';

  @override
  String get emptySearchTitle => 'Ничего не найдено';

  @override
  String get emptySearchSubtitle => 'Попробуйте изменить запрос';

  @override
  String get addAnimal => 'Добавить животное';

  @override
  String get animalInfo => 'Информация о животном';

  @override
  String get animalMainInfo => 'Основная информация';

  @override
  String get animalTag => 'Бирка';

  @override
  String get animalBirthDate => 'Дата рождения';

  @override
  String get animalAge => 'Возраст';

  @override
  String get animalCategory => 'Категория';

  @override
  String get animalBreed => 'Порода';

  @override
  String get animalGroup => 'Группа';

  @override
  String get animalHealthStatus => 'Состояние здоровья';

  @override
  String get animalNoName => 'Без имени';

  @override
  String get animalDeleteTitle => 'Удалить животное?';

  @override
  String get animalDeleteConfirm => 'Это действие нельзя отменить. Вы уверены?';

  @override
  String get animalDeleted => 'Животное удалено';

  @override
  String get reproStatusNotInseminated => 'Не осеменена';

  @override
  String get reproStatusInseminated => 'Осеменена';

  @override
  String get reproStatusPregnant => 'Беременна';

  @override
  String get reproStatusDry => 'Сухостой';

  @override
  String get reproStatusNearCalving => 'Скоро отёл';

  @override
  String get reproStatusFresh => 'Свежая';

  @override
  String get reproStatusFreshCow => 'Свежая корова';

  @override
  String get reproStatusNotPregnant => 'Не беременна';

  @override
  String get prodStateLactation => 'Лактация';

  @override
  String get prodStateDry => 'Сухостой';

  @override
  String get prodStateFattening => 'Откорм';

  @override
  String get prodStateFatteningFull => 'На откорме';

  @override
  String get prodStateBreeding => 'Племенная';

  @override
  String get prodStateBreedingFull => 'Племенное использование';

  @override
  String get prodStateUnknown => 'Неизвестно';

  @override
  String get milkLastYield => 'Последний надой\n(л/день)';

  @override
  String get milkLastYieldDate => 'Дата последнего\nнадоя';

  @override
  String get milkAvg7Days => 'Средний надой\nза 7 дней';

  @override
  String get milkAvg30Days => 'Средний надой\nза 30 дней';

  @override
  String get milkPeakCurrent => 'Пик надоя\n(текущая лактация)';

  @override
  String get eventsTitle => 'События';

  @override
  String get eventsTasks => 'Задачи';

  @override
  String get eventsCompleted => 'Завершенные';

  @override
  String get eventsOverdue => 'Просроченные';

  @override
  String get eventsNone => 'Нет событий';

  @override
  String get eventsDateStart => 'Дата начала';

  @override
  String get eventsDateEnd => 'Дата окончания';

  @override
  String get eventsAlreadyCompleted => 'Уже завершено';

  @override
  String get eventsCompleteEvent => 'Завершить событие';

  @override
  String get eventsEventCompleted => 'Событие завершено';

  @override
  String get eventsDeleteEvent => 'Удалить событие';

  @override
  String get eventsDeleteConfirm => 'Удалить событие?';

  @override
  String get eventsCannotUndo => 'Действие нельзя отменить';

  @override
  String get eventsDeleted => 'Событие удалено';

  @override
  String get eventsAdded => 'Событие добавлено';

  @override
  String get addEventTitle => 'Добавить событие';

  @override
  String get addEventType => 'Событие';

  @override
  String get addEventDropdownHint => 'Выбрать из списка';

  @override
  String get addEventPickDate => 'Выберите дату события';

  @override
  String get addEventComment => 'Комментарий (опционально)';

  @override
  String get addEventSelectType => 'Выберите тип события';

  @override
  String get addEventSelectDate => 'Выберите дату события';

  @override
  String get addEventEnterName => 'Введите название события';

  @override
  String get addEventSelectHeatStart => 'Выберите дату начала охоты';

  @override
  String get addEventEnterCalfTag => 'Введите бирку телёнка';

  @override
  String get addEventSelectCalfGender => 'Выберите пол телёнка';

  @override
  String get addEventEnterCalfWeight => 'Введите вес телёнка при рождении';

  @override
  String get eventDateVaccination => 'Дата вакцинации';

  @override
  String get eventDateTreatment => 'Дата обработки';

  @override
  String get eventDateIllness => 'Дата заболевания';

  @override
  String get eventDateWeighing => 'Дата взвешивания';

  @override
  String get eventDateInsemination => 'Дата\nосеменения';

  @override
  String get eventDateCheck => 'Дата проверки';

  @override
  String get eventDateHornProcessing => 'Дата обработки';

  @override
  String get eventDateCalving => 'Дата отела';

  @override
  String get eventDatePregnancy => 'Дата\nстельности';

  @override
  String get eventDateStart => 'Дата начала';

  @override
  String get eventDateSync => 'Дата синхронизации';

  @override
  String get eventDateWeaning => 'Дата отъема';

  @override
  String get eventDateHoofTrimming => 'Дата расчистки';

  @override
  String get eventDateGeneric => 'Дата события';

  @override
  String get eventActionHeat => 'Проверка на охоту';

  @override
  String get eventActionPregnancy => 'Провести проверку на стельность';

  @override
  String get eventActionDryPeriod => 'Запланирован перевод в сухостой';

  @override
  String get eventActionWeighing => 'Рекомендуется провести взвешивание';

  @override
  String get eventActionVaccination => 'Рекомендуется провести вакцинацию';

  @override
  String get eventActionIllness => 'Провести лечение/осмотр';

  @override
  String get eventActionHoof => 'Рекомендуется расчистка копыт';

  @override
  String get eventActionAntiparasitic => 'Рекомендуется обработка от паразитов';

  @override
  String get eventActionCalving => 'Контроль после отела';

  @override
  String get eventActionInsemination => 'Запланировано осеменение';

  @override
  String get eventActionWeaning => 'Запланирован отъем';

  @override
  String get eventActionDefault => 'Пришло время выполнить событие';

  @override
  String get eventOverdueHint => 'Рекомендуется выполнить как можно скорее';

  @override
  String get fieldVaccine => 'Вакцина';

  @override
  String get fieldVaccineHint => 'Наименование вакцины';

  @override
  String get fieldWeightKg => 'Вес (кг)';

  @override
  String get fieldWeightHint => 'Результат взвешивания';

  @override
  String get fieldDiagnosis => 'Диагноз';

  @override
  String get fieldDiagnosisHint => 'Название заболевания';

  @override
  String get fieldDrug => 'Препарат';

  @override
  String get fieldDrugHint => 'Название препарата';

  @override
  String get fieldDosage => 'Дозировка';

  @override
  String get fieldDosageHint => 'Количество';

  @override
  String get fieldTreatmentDuration => 'Длительность лечения (дни)';

  @override
  String get fieldEndDate => 'Дата окончания';

  @override
  String get fieldSelectDate => 'Выберите дату';

  @override
  String get fieldMaleTag => 'Бирка самца';

  @override
  String get fieldFemaleTag => 'Бирка самки';

  @override
  String get fieldEnterTagNumber => 'Укажите номер бирки';

  @override
  String get fieldSuccess => 'Успешность';

  @override
  String get fieldSuccessful => 'Успешно';

  @override
  String get fieldUnsuccessful => 'Безуспешно';

  @override
  String get fieldDifficulty => 'Сложность';

  @override
  String get fieldEasy => 'Лёгкий';

  @override
  String get fieldMedium => 'Средний';

  @override
  String get fieldHard => 'Тяжелый';

  @override
  String get fieldCalfTag => 'Бирка телёнка';

  @override
  String get fieldCalfTagHint => 'Введите номер бирки';

  @override
  String get fieldCalfName => 'Имя телёнка';

  @override
  String get fieldCalfNameHint => 'Введите имя телёнка';

  @override
  String get fieldCalfGender => 'Пол телёнка';

  @override
  String get fieldCalfGenderHint => 'Выберите';

  @override
  String get fieldMale => 'Самец';

  @override
  String get fieldFemale => 'Самка';

  @override
  String get fieldBirthWeight => 'Вес при рождении (кг)';

  @override
  String get fieldBirthWeightHint => 'Введите вес';

  @override
  String get fieldHeatStartDate => 'Дата начала';

  @override
  String get fieldHeatEndDate => 'Дата конца';

  @override
  String get fieldHeatStart => 'Начало охоты';

  @override
  String get fieldHeatEnd => 'Конец охоты';

  @override
  String get fieldDrugNameHint => 'Введите название препарата';

  @override
  String get fieldDosageHint2 => 'Введите дозировку';

  @override
  String get selectCattleTitle => 'Выбор скота';

  @override
  String selectCattleSelected(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get selectCattleAll => 'Выбрать все';

  @override
  String get selectCattleClear => 'Очистить';

  @override
  String get selectCattleDone => 'Готово';

  @override
  String get selectCattleNoTag => 'Без бирки';

  @override
  String get rationsTitle => 'Рационы/Запасы';

  @override
  String get rationsFeedStock => 'Запасы корма';

  @override
  String get rationsConcentrates => 'Концентраты';

  @override
  String get rationsSucculentFeed => 'Сочный корм';

  @override
  String get rationsRoughage => 'Грубые корма';

  @override
  String get rationsAdditives => 'Добавки';

  @override
  String get rationsListTitle => 'Список рационов';

  @override
  String get rationsNotGenerated => 'Рационы пока не сгенерированы';

  @override
  String get rationsNoMatch => 'Нет рационов, подходящих для этого животного';

  @override
  String get rationsDeleted => 'Рацион удалён';

  @override
  String get rationsEmptyTitle => 'Ваш список пустует';

  @override
  String get rationsEmptySubtitle =>
      'Для отображения списка рационов,\nдобавьте Ваш запас корма';

  @override
  String get rationsAddFeedStock => 'Добавить запасы корма';

  @override
  String get rationStatusActive => 'Активный';

  @override
  String get rationStatusNeedsAttention => 'Требует внимания';

  @override
  String get rationDeleteTitle => 'Удалить рацион?';

  @override
  String get rationDeleteConfirm =>
      'Вы уверены, что хотите удалить этот рацион? Это действие нельзя отменить.';

  @override
  String rationCategory(String category) {
    return 'Категория: $category';
  }

  @override
  String rationPeriod(String period) {
    return 'Период: $period';
  }

  @override
  String rationDailyCost(String cost) {
    return 'Стоимость/день: $cost тг.';
  }

  @override
  String rationFeedType(String names) {
    return 'Вид корма: $names';
  }

  @override
  String rationDailyNorm(String kg) {
    return 'Норма в день: $kg кг';
  }

  @override
  String get rationInfoTitle => 'Информация о рационе';

  @override
  String get rationMainInfo => 'Основная информация рациона';

  @override
  String get rationCategoryLabel => 'Категория';

  @override
  String get rationPeriodLabel => 'Период';

  @override
  String get rationDailyCostLabel => 'Стоимость в день';

  @override
  String rationDailyCostValue(String cost) {
    return '$cost тг.';
  }

  @override
  String get rationStatusLabel => 'Статус';

  @override
  String get rationDailyNormLabel => 'Норма в день';

  @override
  String rationDailyNormValue(String kg) {
    return '$kg кг';
  }

  @override
  String get rationFeedsTitle => 'Кормы рациона';

  @override
  String get rationNeedKg => 'Потребность (кг)';

  @override
  String get rationCostKgTg => 'Стоимость (кг/тг)';

  @override
  String get rationDailyExpense => 'Суточный расход (тг)';

  @override
  String get inventoryTitle => 'Запасы';

  @override
  String inventoryTotalFeed(String kg) {
    return 'Всего корма: $kg кг';
  }

  @override
  String get inventoryFeedDeleted => 'Корм удалён';

  @override
  String get inventoryDeleteTitle => 'Удалить корм?';

  @override
  String get inventoryDeleteConfirm =>
      'Вы уверены, что хотите удалить этот корм? Это действие нельзя отменить.';

  @override
  String get lactationTitle => 'Лактация';

  @override
  String lactationMilkPerDay(String liters) {
    return 'Молоко за день: $liters л.';
  }

  @override
  String get lactationQuantity => 'Количество';

  @override
  String get lactationCowMilking => 'Надой коровы';

  @override
  String get lactationFarmMilking => 'Надой по ферме';

  @override
  String get lactationDate => 'Дата';

  @override
  String get lactationTime => 'Время';

  @override
  String get lactationMilkingTime => 'Время доения';

  @override
  String get lactationMorning => 'Утро';

  @override
  String get lactationEvening => 'Вечер';

  @override
  String get lactationCowTag => 'Бирка коровы';

  @override
  String get lactationEnterInfo => 'Введите информацию';

  @override
  String get lactationMilkAmount => 'Количество молока';

  @override
  String get lactationEnterMilk => 'Введите количество молока (литры)';

  @override
  String get lactationSuccessAdd =>
      'Информация успешно\nдобавлена и отображена\nв разделе \"Лактация\"';

  @override
  String get lactationGoToList => 'Перейти к списку';

  @override
  String get lactationAddBulkTitle => 'Добавить надой за ферму';

  @override
  String get lactationBulkSuccess =>
      'Данные надоя по ферме\nуспешно добавлены!';

  @override
  String get lactationEnterCowCount => 'Укажите количество подоенных коров';

  @override
  String get lactationEnterTotalMilk => 'Укажите всего молока (л)';

  @override
  String get lactationMilkedCows => 'Подоено коров';

  @override
  String get lactationTotalMilk => 'Всего молока';

  @override
  String get lactationCalfUsed => 'Использовано для\nтелят';

  @override
  String get lactationUnfitMilk => 'Непригодное\nмолоко';

  @override
  String get lactationAccountingWeek => 'За неделю';

  @override
  String get lactationAccountingMonth => 'За месяц';

  @override
  String get lactationAccountingPeriod => 'Период';

  @override
  String get lactationDateStartPeriod => 'Дата начала периода';

  @override
  String get lactationDateEndPeriod => 'Дата конца периода';

  @override
  String get lactationSelectDate => 'Выберите дату';

  @override
  String get notFoundTitle => 'Страница не найдена';

  @override
  String get notFoundGoHome => 'Вернуться домой';

  @override
  String get registerPasswordMin => 'Минимум 6 символов';

  @override
  String get registerPasswordsMismatch => 'Пароли не совпадают';

  @override
  String get registerErrorGeneric => 'Ошибка регистрации. Попробуйте снова.';

  @override
  String get registerButton => 'ЗАРЕГИСТРИРОВАТЬСЯ';

  @override
  String get registerSuccessTitle =>
      'Вы успешно\nзарегистрировались\nв Fermer+!';

  @override
  String get registerSuccessMessage =>
      'Для того, чтобы начать использовать\nприложение, нажмите на кнопку\n\"Начать работу\"';

  @override
  String get registerSuccessButton => 'Начать работу';
}
