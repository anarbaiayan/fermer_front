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
  String get navMore => 'Ещё';

  @override
  String get morePrimarySection => 'Основные разделы';

  @override
  String get moreFarmSection => 'Управление фермой';

  @override
  String get moreAccountSection => 'Аккаунт и поддержка';

  @override
  String get drawerProfile => 'Профиль';

  @override
  String get drawerSettings => 'Настройки';

  @override
  String get drawerFaq => 'Часто задаваемые\nвопросы';

  @override
  String get drawerSupport => 'Служба поддержки';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsViewArchived => 'Посмотреть архив';

  @override
  String get notificationsArchivedTitle => 'Архив уведомлений';

  @override
  String get notificationsEmpty => 'Уведомлений пока нет';

  @override
  String get notificationsArchivedEmpty => 'Архив уведомлений пуст';

  @override
  String get notificationsTagLabel => 'Бирка';

  @override
  String get notificationsArchiveAction => 'В архив';

  @override
  String get supportMessageTitle => 'Есть вопрос или предложение?';

  @override
  String get supportMessageSubtitle => 'Напишите нам в WhatsApp.';

  @override
  String get supportWriteWhatsapp => 'Написать в WhatsApp';

  @override
  String get supportOpenWhatsappError => 'Не удалось открыть WhatsApp';

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
  String get dialogOk => 'ОК';

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
  String get loginRestoreAccount => 'Восстановить аккаунт';

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
  String get restoreAccountTitle => 'Восстановить аккаунт';

  @override
  String get restoreAccountSubtitle =>
      'Введите номер телефона и пароль от удалённого аккаунта, чтобы снова получить доступ к профилю.';

  @override
  String get restoreAccountButton => 'Восстановить аккаунт';

  @override
  String get restoreAccountPasswordRequired => 'Введите пароль';

  @override
  String get restoreAccountSuccessTitle => 'Аккаунт успешно\nвосстановлен!';

  @override
  String get restoreAccountSuccessMessage =>
      'Теперь вы можете снова войти в Fermer+.';

  @override
  String get restoreAccountGoLogin => 'Перейти ко входу';

  @override
  String get homeSummary => 'Сводка';

  @override
  String get homeHerd => 'Стадо';

  @override
  String get homeQuickActions => 'Быстрые действия';

  @override
  String get homeActionEvent => 'Событие';

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
  String get rationsForAnimalTitle => 'Рацион животного';

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
  String get rationCategoryBull => 'Бык';

  @override
  String get rationCategoryCow => 'Корова';

  @override
  String get rationCategoryHeifer => 'Тёлка';

  @override
  String get rationCategoryCalf => 'Теленок';

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
  String get rationRecommendationsLabel => 'Рекомендации';

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
  String get rationMinKgLabel => 'Мин (кг)';

  @override
  String get rationMaxKgLabel => 'Макс (кг)';

  @override
  String get rationPriceKgLabel => 'Цена (кг/тг)';

  @override
  String get rationNoteLabel => 'Заметка';

  @override
  String get inventoryTitle => 'Запасы';

  @override
  String get inventoryQuantityLabel => 'Количество';

  @override
  String get inventoryStocksListTitle => 'Список запасов';

  @override
  String inventoryTotalFeed(String kg) {
    return 'Всего корма: $kg кг';
  }

  @override
  String get inventoryTypeLabel => 'Тип корма';

  @override
  String get inventoryPriceLabel => 'Цена';

  @override
  String get inventoryRemainingLabel => 'Остаток';

  @override
  String unitLitersValue(Object value) {
    return '$value л';
  }

  @override
  String unitKgValue(Object value) {
    return '$value кг';
  }

  @override
  String unitPricePerKgValue(Object value) {
    return '$value ₸/кг';
  }

  @override
  String get inventoryDeleteFeedButton => 'Удалить корм';

  @override
  String get inventoryFeedDeleted => 'Корм удалён';

  @override
  String get inventoryDeleteTitle => 'Удалить корм?';

  @override
  String get inventoryDeleteConfirm =>
      'Вы уверены, что хотите удалить этот корм? Это действие нельзя отменить.';

  @override
  String get addUserRationsTitle => 'Добавление вида корма';

  @override
  String get addUserRationsSelectAtLeastOne => 'Выберите хотя бы один корм';

  @override
  String get addUserRationsUpdatedSuccess => 'Запасы успешно\nобновлены!';

  @override
  String get addUserRationsGoToList => 'Перейти к списку';

  @override
  String get addUserRationsTabFromCatalog => 'Из каталога';

  @override
  String get addUserRationsTabCustomFeed => 'Свой корм';

  @override
  String get addUserRationsCustomNameLabel => 'Название (RU)';

  @override
  String get addUserRationsCustomNameHint => 'Введите название';

  @override
  String get addUserRationsCustomNameKkLabel => 'Название (KK)';

  @override
  String get addUserRationsCustomNameKkHint => 'Введите название на казахском';

  @override
  String get addUserRationsCustomTypeLabel => 'Тип корма';

  @override
  String get addUserRationsCustomTypeHint => 'Выберите тип';

  @override
  String get addUserRationsCustomPriceLabel => 'Цена за кг (тг)';

  @override
  String get addUserRationsCustomPriceHint => 'Введите цену';

  @override
  String get addUserRationsCustomSave => 'Добавить';

  @override
  String get addUserRationsCustomNameRequired => 'Введите название корма';

  @override
  String get addUserRationsCustomNameKkRequired =>
      'Введите название корма на казахском';

  @override
  String get addUserRationsCustomPriceInvalid =>
      'Введите корректную цену (больше 0)';

  @override
  String get addUserRationsCustomAdded => 'Пользовательский корм добавлен';

  @override
  String get settingsLanguageTitle => 'Язык приложения';

  @override
  String get settingsLanguageSubtitle => 'Выберите язык интерфейса';

  @override
  String get settingsLanguageRu => 'Русский';

  @override
  String get settingsLanguageKk => 'Қазақша';

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
  String get authUserExists => 'Пользователь с таким номером уже существует';

  @override
  String get authInvalidCredentials => 'Неверный номер телефона или пароль';

  @override
  String get authUserNotFound => 'Пользователь с таким номером не найден';

  @override
  String get authLoginFailed => 'Не удалось войти. Попробуйте ещё раз';

  @override
  String get authRegisterInvalidData => 'Некорректные данные регистрации';

  @override
  String get authRegisterFailed =>
      'Не удалось зарегистрироваться. Попробуйте ещё раз';

  @override
  String get authLoginNetwork =>
      'Не удалось войти. Проверьте подключение к интернету';

  @override
  String get authRegisterNetwork =>
      'Не удалось зарегистрироваться. Проверьте интернет';

  @override
  String get authDeleteAccountFailed =>
      'Не удалось удалить аккаунт. Попробуйте ещё раз.';

  @override
  String get authRestoreAccountFailed =>
      'Не удалось восстановить аккаунт. Попробуйте ещё раз.';

  @override
  String get registerSuccessTitle =>
      'Вы успешно\nзарегистрировались\nв Fermer+!';

  @override
  String get registerSuccessMessage =>
      'Для того, чтобы начать использовать\nприложение, нажмите на кнопку\n\"Начать работу\"';

  @override
  String get registerSuccessButton => 'Начать работу';

  @override
  String get dateSelect => 'Выберите дату';

  @override
  String get dateEnterFull => 'Введите дату полностью';

  @override
  String get dateInvalid => 'Неверная дата';

  @override
  String dateRangeError(Object from, Object to) {
    return 'Дата должна быть в диапазоне $from - $to';
  }

  @override
  String get dateEnterLabel => 'Введите дату';

  @override
  String get dateInputHint => 'dd.MM.yyyy';

  @override
  String get bulkEventSuccessTitle => 'Массовое событие\nуспешно создано!';

  @override
  String get bulkEventSuccessMessage =>
      'Все данные сохранены.\nВы можете изменить их позже.';

  @override
  String get addBulkEventTitle => 'Добавить массовое событие';

  @override
  String get selectCategoryHint => 'Выберите категорию';

  @override
  String get eventActionMating => 'Покрытие';

  @override
  String get eventActionSynchronization => 'Синхронизация';

  @override
  String get eventActionPregnancyNotConfirmed => 'Стельность не подтверждена';

  @override
  String get eventActionHornProcessing => 'Обработка рогов';

  @override
  String get eventTypeNameVaccination => 'Вакцинация';

  @override
  String get eventTypeNameIllnessTreatment => 'Болезнь/Лечение';

  @override
  String get eventTypeNameWeighing => 'Взвешивание';

  @override
  String get eventTypeNameHoofTrimming => 'Расчистка копыт';

  @override
  String get eventTypeNameAntiparasiticTreatment => 'Противопаразитное лечение';

  @override
  String get eventTypeNameOther => 'Другое';

  @override
  String get eventTypeNameCalving => 'Отёл';

  @override
  String get eventTypeNameInsemination => 'Осеменение/ИО';

  @override
  String get eventTypeNameDryPeriod => 'Сухостой';

  @override
  String get eventTypeNameHeatPeriod => 'Период охоты';

  @override
  String get eventTypeNameSynchronization => 'Синхронизация';

  @override
  String get eventTypeNameMating => 'Покрытие';

  @override
  String get eventTypeNamePregnancyConfirmation => 'Подтверждение стельности';

  @override
  String get eventTypeNamePregnancyNotConfirmed =>
      'Беременность не подтверждена';

  @override
  String get eventTypeNameHornProcessing => 'Обработка рога';

  @override
  String get eventTypeNameWeaning => 'Отъём';

  @override
  String daysValue(Object value) {
    return '$value дней';
  }

  @override
  String get fieldEndDateOptional => 'Дата окончания\n(необязательно)';

  @override
  String get fieldEventName => 'Название события';

  @override
  String get animalDataNotLoaded => 'Данные животного не загружены';

  @override
  String get breedRequiredOnStep1 =>
      'Порода не указана. Вернитесь на шаг 1 и заполните породу.';

  @override
  String get animalCreatedSuccessTitle =>
      'Карточка животного\nуспешно создана!';

  @override
  String get animalCreatedSuccessMessage =>
      'Все данные сохранены.\nВы можете изменить их позже в карточке животного.';

  @override
  String get animalAdditionalInfo => 'Дополнительная информация';

  @override
  String get actionsTitle => 'Действия';

  @override
  String get skipText => 'Пропустить';

  @override
  String get animalCategoryUnknown => 'Невозможно определить категорию';

  @override
  String animalCategoryWithAge(Object category, Object ageMonths) {
    return 'Категория: $category, $ageMonths мес.';
  }

  @override
  String get breedTypeDairy => 'Молочная';

  @override
  String get breedTypeMeat => 'Мясная';

  @override
  String get breedTypeMixed => 'Комбинированная';

  @override
  String get breedTypeLocal => 'Местная';

  @override
  String get animalRequiredFields => 'Заполните имя, бирку и дату рождения';

  @override
  String get animalNoIdReturned => 'Сервер не вернул id животного';

  @override
  String get animalCreateError => 'Ошибка при создании животного';

  @override
  String get selectGender => 'Выберите пол';

  @override
  String get genderFemale => 'Женский';

  @override
  String get genderMale => 'Мужской';

  @override
  String get breedHint => 'Введите породу';

  @override
  String get breedTypeLabel => 'Тип породы';

  @override
  String get breedTypeHint => 'Выберите тип породы';

  @override
  String get creating => 'Создание...';

  @override
  String get dateOutOfRange => 'Дата вне допустимого диапазона';

  @override
  String get animalUpdatedSuccessTitle =>
      'Карточка животного\nуспешно обновлена!';

  @override
  String get animalInfoEditTitle => 'Редактирование карточки';

  @override
  String showAllCount(Object count) {
    return 'Показать все ($count)';
  }

  @override
  String get hideText => 'Скрыть';

  @override
  String get rationGenerating => 'Генерируется рацион...';

  @override
  String get rationRegeneratedSuccess => 'Рацион успешно\nсгенерирован заново!';

  @override
  String get rationUpdatedSaved => 'Обновленные данные сохранены.';

  @override
  String get prodStateDryPhase1 => 'Сухостой (фаза 1)';

  @override
  String get prodStateDryPhase2 => 'Сухостой (фаза 2)';

  @override
  String get milkTotalCurrent => 'Всего молока\n(текущая лактация)';

  @override
  String get lastCalvingDate => 'Последний отел';

  @override
  String get lastInseminationDate => 'Последнее\nосеменение';

  @override
  String get pregnancyLabel => 'Беременность';

  @override
  String get reproductiveStatusLabel => 'Репродуктивный статус';

  @override
  String get productionStatusLabel => 'Производственный статус';

  @override
  String get firstInseminationDate => 'Первое\nосеменение';

  @override
  String get expectedCalvingDate => 'Планируемая дата\nотела';

  @override
  String get bullPurposeLabel => 'Назначение';

  @override
  String get rationRegenerateTitle => 'Сгенерировать рацион повторно';

  @override
  String get rationApproxMinute => 'Примерно 1 минута';

  @override
  String get rationViewTitle => 'Посмотреть рацион';

  @override
  String get rationChooseSubtitle => 'Выберите рацион';

  @override
  String get upcomingEventsTitle => 'Ближайшие события';

  @override
  String daysUntilShort(Object days) {
    return 'через $days дн';
  }

  @override
  String get eventsDeleteConfirmComplete => 'Завершить событие?';

  @override
  String eventsMarkCompleted(Object title) {
    return 'Отметить \"$title\" как выполненное?';
  }

  @override
  String ageMonthsCompact(Object months) {
    return '$months мес.';
  }

  @override
  String ageYearsCompact(Object years) {
    return '$years г.';
  }

  @override
  String ageYearsMonthsCompact(Object years, Object months) {
    return '$years г. $months мес.';
  }

  @override
  String get healthHealthy => 'Здоров';

  @override
  String get healthSick => 'Болен';

  @override
  String get healthUnderTreatment => 'На лечении';

  @override
  String get healthQuarantine => 'Карантин';

  @override
  String get healthRecovering => 'Выздоравливает';

  @override
  String get bullPurposeBreeding => 'Племенной';

  @override
  String get bullPurposeFattening => 'На откорме';

  @override
  String get milkProductivityTitle => 'Молочная продуктивность коровы';

  @override
  String get milkProductivityHint =>
      'Добавьте надой (утро/вечер), чтобы вести лактацию.';

  @override
  String get profileMyTitle => 'Мой профиль';

  @override
  String get profileFarmLabel => 'Ферма';

  @override
  String get profileResetPasswordTitle => 'Сбросить пароль';

  @override
  String get profileResetPasswordHint => 'При необходимости измените пароль';

  @override
  String get profileEmailTitle => 'E-mail address';

  @override
  String get profileEmailAddHint => 'Добавьте адрес своей электронной почты';

  @override
  String get profileDeleteAccountButton => 'Удалить';

  @override
  String get profileDeleteAccountConfirm =>
      'Удалить аккаунт?\nПозже вы сможете восстановить его на экране входа.';

  @override
  String get profileDeleteAccountSuccessTitle => 'Аккаунт удалён';

  @override
  String get profileDeleteAccountSuccessMessage =>
      'Вы сможете восстановить его позже на экране входа.';

  @override
  String get eventTaskHeatPeriod => 'Проверка на охоту';

  @override
  String get eventTaskPregnancyCheck => 'Провести проверку на стельность';

  @override
  String get eventTaskDryPeriod => 'Запланирован перевод в сухостой';

  @override
  String get eventTaskWeighing => 'Рекомендуется провести взвешивание';

  @override
  String get eventTaskVaccination => 'Рекомендуется провести вакцинацию';

  @override
  String get eventTaskTreatment => 'Провести лечение/осмотр';

  @override
  String get eventTaskHoofTrimming => 'Рекомендуется расчистка копыт';

  @override
  String get eventTaskAntiparasitic => 'Рекомендуется обработка от паразитов';

  @override
  String get eventTaskCalvingFollowUp => 'Контроль после отела';

  @override
  String get eventTaskInsemination => 'Запланировано осеменение';

  @override
  String get eventTaskWeaning => 'Запланирован отъём';

  @override
  String get eventTaskDefault => 'Пришло время выполнить событие';

  @override
  String get drawerPharmacy => 'Аптека';

  @override
  String get pharmacyTitle => 'Аптека';

  @override
  String get pharmacySearchHint => 'Поиск препарата';

  @override
  String get pharmacyFilterAllProducers => 'Все производители';

  @override
  String get pharmacyFilterAllActions => 'Все действия';

  @override
  String get pharmacyFilterAll => 'Все';

  @override
  String get pharmacyMyRequests => 'Мои заявки';

  @override
  String get pharmacyRetry => 'Повторить';

  @override
  String get pharmacyEmptyCatalogTitle => 'Ничего не найдено';

  @override
  String get pharmacyEmptyCatalogSubtitle =>
      'Попробуйте изменить запрос или сбросить фильтры';

  @override
  String pharmacyOffers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count предложений',
      many: '$count предложений',
      few: '$count предложения',
      one: '$count предложение',
    );
    return '$_temp0';
  }

  @override
  String pharmacyPriceFrom(String price) {
    return 'от $price';
  }

  @override
  String get pharmacyActiveIngredient => 'Действующее вещество';

  @override
  String get pharmacyPricesByProducer => 'Цены производителей';

  @override
  String get pharmacyBestPrice => 'Выгодно';

  @override
  String get pharmacyQuantity => 'Количество';

  @override
  String get pharmacyTotal => 'Итого';

  @override
  String get pharmacyOrder => 'Заказать';

  @override
  String get pharmacyNoOffers => 'Нет доступных предложений';

  @override
  String get pharmacyOrderTitle => 'Оформление заказа';

  @override
  String get pharmacyOrderAddressLabel => 'Адрес доставки / хозяйство';

  @override
  String get pharmacyOrderAddressHint =>
      'Например: Акмолинская обл., КХ «Дала»';

  @override
  String get pharmacyOrderPhoneLabel => 'Телефон для связи';

  @override
  String get pharmacyOrderPhoneHint => '+7 (___) ___-__-__';

  @override
  String get pharmacyOrderConfirm => 'Подтвердить заказ';

  @override
  String get pharmacyOrderSuccessTitle => 'Заказ отправлен!';

  @override
  String get pharmacyOrderSuccessMessage =>
      'Менеджер свяжется с вами для подтверждения и оплаты';

  @override
  String get pharmacyOrderBackToCatalog => 'Вернуться в каталог';

  @override
  String get pharmacyRequestsTitle => 'Мои заявки';

  @override
  String get pharmacyRequestsEmptyTitle => 'У вас пока нет заявок';

  @override
  String get pharmacyRequestsEmptySubtitle =>
      'Оформите заявку в каталоге аптеки';

  @override
  String get pharmacyRequestComment => 'Комментарий';

  @override
  String get pharmacyRequestPhone => 'Телефон';

  @override
  String pharmacyQuantityShort(int value) {
    return '$value шт.';
  }

  @override
  String get pharmacyStatusNew => 'Новая';

  @override
  String get pharmacyStatusInProgress => 'В обработке';

  @override
  String get pharmacyStatusDone => 'Выполнена';

  @override
  String get pharmacyStatusCancelled => 'Отменена';

  @override
  String get pharmacyStatusUnknown => '—';

  @override
  String get pharmacyHomeCardTitle => 'Аптека';

  @override
  String get pharmacyHomeCardSubtitle => 'Ветпрепараты и заявки на заказ';
}
