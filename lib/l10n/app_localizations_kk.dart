// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'Fermer+';

  @override
  String get farmName => 'Ферма атауы';

  @override
  String get navHome => 'Басты бет';

  @override
  String get navHerd => 'Табын';

  @override
  String get navEvents => 'Оқиғалар';

  @override
  String get navRation => 'Рацион';

  @override
  String get navLactation => 'Лактация';

  @override
  String get drawerProfile => 'Профиль';

  @override
  String get drawerSettings => 'Баптаулар';

  @override
  String get drawerFaq => 'Жиі қойылатын\nсұрақтар';

  @override
  String get drawerSupport => 'Қолдау қызметі';

  @override
  String get drawerReferral => 'Рефералдық\nбағдарлама';

  @override
  String get drawerLogout => 'Аккаунттан шығу';

  @override
  String get drawerLogoutConfirm =>
      'Сіз шынымен\nFermer+ жүйесінен шығуды қалайсыз ба?';

  @override
  String get drawerLogoutButton => 'Шығу';

  @override
  String get dialogOk => 'Жарайды';

  @override
  String get dialogCancel => 'Бас тарту';

  @override
  String get dialogDelete => 'Жою';

  @override
  String get dialogClose => 'Жабу';

  @override
  String get dialogUnderstood => 'Түсінікті';

  @override
  String errorPrefix(String error) {
    return 'Қате: $error';
  }

  @override
  String get errorLoadingList => 'Тізімді жүктеу кезінде қате';

  @override
  String errorLoadingStats(String error) {
    return 'Статистиканы жүктеу кезінде қате:\n$error';
  }

  @override
  String errorLoadingQuantity(String error) {
    return 'Сан бойынша деректерді жүктеу кезінде қате:\n$error';
  }

  @override
  String errorLoadingData(String error) {
    return 'Жүктеу кезінде қате: $error';
  }

  @override
  String get errorLoading => 'Жүктеу кезінде қате';

  @override
  String errorDeletion(String error) {
    return 'Жою қатесі: $error';
  }

  @override
  String errorAddingEvent(String error) {
    return 'Оқиғаны қосу кезінде қате: $error';
  }

  @override
  String errorTypes(String error) {
    return 'Типтер қатесі: $error';
  }

  @override
  String get retry => 'Қайталау';

  @override
  String get save => 'Сақтау';

  @override
  String get saving => 'Сақталуда...';

  @override
  String get add => 'Қосу';

  @override
  String get continueText => 'Жалғастыру';

  @override
  String get loginTitle => 'КІРУ';

  @override
  String get loginSubtitle => 'Жеке кабинетке кіру үшін ақпаратты енгізіңіз';

  @override
  String get loginButton => 'КІРУ';

  @override
  String get loginPhoneLabel => 'Телефон нөмірі';

  @override
  String get loginPhoneHint => 'Нөмірді енгізіңіз';

  @override
  String get loginPhoneError => 'Дұрыс телефон нөмірін енгізіңіз';

  @override
  String get loginPasswordLabel => 'Құпиясөз';

  @override
  String get loginPasswordError => 'Қате құпиясөз. Қайта енгізіп көріңіз.';

  @override
  String get loginForgotPassword => 'Құпиясөзді ұмыттыңыз ба?';

  @override
  String get loginNoAccount => 'Аккаунтыңыз жоқ па?';

  @override
  String get loginRegisterHint =>
      'Fermer+ платформасын пайдалану үшін тіркеліңіз';

  @override
  String get loginRegisterButton => 'Тіркелу';

  @override
  String get registerTitle => 'Тіркелу';

  @override
  String get registerSubtitle => 'Тіркелу үшін ақпаратты енгізіңіз';

  @override
  String get registerFirstName => 'Аты';

  @override
  String get registerFirstNameHint => 'Атыңызды енгізіңіз';

  @override
  String get registerLastName => 'Тегі';

  @override
  String get registerLastNameHint => 'Тегіңізді енгізіңіз';

  @override
  String get registerFarmName => 'Ферма атауы';

  @override
  String get registerFarmNameHint => 'Ферма атауын енгізіңіз';

  @override
  String get registerFillAll => 'Барлық өрістерді толтырыңыз';

  @override
  String get registerStep1 => '1-қадам';

  @override
  String get registerStep2 => '2-қадам';

  @override
  String get forgotPasswordTitle => 'Құпиясөзді ұмыттыңыз ба?';

  @override
  String get forgotPasswordSubtitle =>
      'Құпиясөзді қалпына келтіру үшін верификация коды келетін телефон нөмірін тексеріңіз';

  @override
  String get forgotPasswordGetCode => 'Код алу';

  @override
  String get forgotPasswordCodeTitle => 'Верификация коды';

  @override
  String get forgotPasswordCodeSubtitle =>
      'Құпиясөзді қалпына келтіру үшін 4 таңбалы кодты енгізіңіз';

  @override
  String get forgotPasswordResetButton => 'Құпиясөзді қалпына келтіру';

  @override
  String get forgotPasswordNewTitle => 'Жаңа құпиясөз енгізіңіз';

  @override
  String get forgotPasswordNewSubtitle =>
      'Қосымшаға кіру үшін жаңа құпиясөз орнатыңыз';

  @override
  String get forgotPasswordNewLabel => 'Жаңа құпиясөз';

  @override
  String get forgotPasswordNewHint => 'Жаңа құпиясөз енгізіңіз';

  @override
  String get forgotPasswordConfirmLabel => 'Құпиясөзді растау';

  @override
  String get forgotPasswordConfirmHint => 'Құпиясөзді қайта енгізіңіз';

  @override
  String get forgotPasswordSetButton => 'Құпиясөз орнату';

  @override
  String get forgotPasswordSuccess => 'Жаңа құпиясөз\nсәтті орнатылды!';

  @override
  String get forgotPasswordGoLogin => 'Fermer+ жүйесіне кіру';

  @override
  String get homeSummary => 'Шолу';

  @override
  String get homeHerd => 'Табын';

  @override
  String get homeAnimalStatuses => 'Жануар статустары';

  @override
  String get homeHerdHealth => 'Табын денсаулығы';

  @override
  String get homeHealthy => 'Дені сау';

  @override
  String get homeSick => 'Ауру';

  @override
  String get homeDataUpdating => 'Деректер жаңартылуда...';

  @override
  String homeTabNotImplemented(int index) {
    return '$index қойындысының мазмұны әлі іске асырылмаған';
  }

  @override
  String get searchHint => 'Малды іздеу';

  @override
  String get searchByNameOrTag => 'Аты немесе бирка бойынша іздеу';

  @override
  String get summaryTabBrief => 'Қысқаша';

  @override
  String get summaryTabQuantity => 'Саны';

  @override
  String get summaryTabCondition => 'Жағдайы';

  @override
  String get summaryTabIncome => 'Кіріс/Шығыс';

  @override
  String get summaryTabMilk => 'Сүт';

  @override
  String get summaryTabRation => 'Рацион/Қор';

  @override
  String get herdSummaryTitle => 'Табын шолуы';

  @override
  String herdTotalAnimals(int count) {
    return 'Барлық жануарлар: $count';
  }

  @override
  String herdUpdated(String time) {
    return 'Жаңартылды: $time';
  }

  @override
  String get herdDetails => 'Толығырақ';

  @override
  String herdTotalCount(int count) {
    return 'Барлығы: $count';
  }

  @override
  String herdTotalCattle(int count) {
    return 'Барлық мал: $count';
  }

  @override
  String get statusLactating => 'Сауылатын';

  @override
  String get statusDryPeriod => 'Сухостой';

  @override
  String get statusOpen => 'Ұрықтанбаған';

  @override
  String get statusInseminated => 'Ұрықтандырылған';

  @override
  String get quantityTitle => 'Саны';

  @override
  String get groupsTitle => 'Топтар';

  @override
  String groupsTotalCount(int count) {
    return 'Барлық топтар: $count';
  }

  @override
  String get groupsView => 'Қарау';

  @override
  String get groupCows => 'Сиырлар';

  @override
  String get groupHeifers => 'Қашарлар';

  @override
  String get groupBulls => 'Бұқалар';

  @override
  String get groupCalves => 'Бұзаулар';

  @override
  String get timeJustNow => 'дәл қазір';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes мин бұрын';
  }

  @override
  String timeHoursAgo(int hours) {
    return '$hours сағ бұрын';
  }

  @override
  String timeDaysAgo(int days) {
    return '$days күн бұрын';
  }

  @override
  String get timeOneHourAgo => '1 сағат бұрын';

  @override
  String get herdAllCattle => 'Барлық мал';

  @override
  String get herdAnimalList => 'Жануарлар тізімі';

  @override
  String get herdLoadingFilter => 'Сүзгі деректері жүктелуде...';

  @override
  String get emptyHerdTitle => 'Сіздің тізіміңіз бос';

  @override
  String get emptyHerdSubtitle => 'Алғашқы жануар карточкасын қосыңыз';

  @override
  String get emptySearchTitle => 'Ештеңе табылмады';

  @override
  String get emptySearchSubtitle => 'Іздеу сұранысын өзгертіп көріңіз';

  @override
  String get addAnimal => 'Жануар қосу';

  @override
  String get animalInfo => 'Жануар туралы ақпарат';

  @override
  String get animalMainInfo => 'Негізгі ақпарат';

  @override
  String get animalTag => 'Бирка';

  @override
  String get animalBirthDate => 'Туған күні';

  @override
  String get animalAge => 'Жасы';

  @override
  String get animalCategory => 'Категория';

  @override
  String get animalBreed => 'Тұқымы';

  @override
  String get animalGroup => 'Топ';

  @override
  String get animalHealthStatus => 'Денсаулық жағдайы';

  @override
  String get animalNoName => 'Аты жоқ';

  @override
  String get animalDeleteTitle => 'Жануарды жою?';

  @override
  String get animalDeleteConfirm =>
      'Бұл әрекетті кері қайтару мүмкін емес. Сенімдісіз бе?';

  @override
  String get animalDeleted => 'Жануар жойылды';

  @override
  String get reproStatusNotInseminated => 'Ұрықтанбаған';

  @override
  String get reproStatusInseminated => 'Ұрықтандырылған';

  @override
  String get reproStatusPregnant => 'Буаз';

  @override
  String get reproStatusDry => 'Сухостой';

  @override
  String get reproStatusNearCalving => 'Жақында бұзаулайды';

  @override
  String get reproStatusFresh => 'Жаңа бұзаулаған';

  @override
  String get reproStatusFreshCow => 'Жаңа бұзаулаған сиыр';

  @override
  String get reproStatusNotPregnant => 'Буаз емес';

  @override
  String get prodStateLactation => 'Лактация';

  @override
  String get prodStateDry => 'Сухостой';

  @override
  String get prodStateFattening => 'Бордақылау';

  @override
  String get prodStateFatteningFull => 'Бордақылауда';

  @override
  String get prodStateBreeding => 'Асыл тұқымды';

  @override
  String get prodStateBreedingFull => 'Асыл тұқымдық пайдалану';

  @override
  String get prodStateUnknown => 'Белгісіз';

  @override
  String get milkLastYield => 'Соңғы сауым\n(л/күн)';

  @override
  String get milkLastYieldDate => 'Соңғы сауым\nкүні';

  @override
  String get milkAvg7Days => '7 күндегі\nорташа сауым';

  @override
  String get milkAvg30Days => '30 күндегі\nорташа сауым';

  @override
  String get milkPeakCurrent => 'Ең жоғары сауым\n(ағымдағы лактация)';

  @override
  String get eventsTitle => 'Оқиғалар';

  @override
  String get eventsTasks => 'Тапсырмалар';

  @override
  String get eventsCompleted => 'Аяқталған';

  @override
  String get eventsOverdue => 'Мерзімі өткен';

  @override
  String get eventsNone => 'Оқиғалар жоқ';

  @override
  String get eventsDateStart => 'Басталу күні';

  @override
  String get eventsDateEnd => 'Аяқталу күні';

  @override
  String get eventsAlreadyCompleted => 'Қазірдің өзінде аяқталған';

  @override
  String get eventsCompleteEvent => 'Оқиғаны аяқтау';

  @override
  String get eventsEventCompleted => 'Оқиға аяқталды';

  @override
  String get eventsDeleteEvent => 'Оқиғаны жою';

  @override
  String get eventsDeleteConfirm => 'Оқиғаны жою керек пе?';

  @override
  String get eventsCannotUndo => 'Бұл әрекетті кері қайтару мүмкін емес';

  @override
  String get eventsDeleted => 'Оқиға жойылды';

  @override
  String get eventsAdded => 'Оқиға қосылды';

  @override
  String get addEventTitle => 'Оқиға қосу';

  @override
  String get addEventType => 'Оқиға';

  @override
  String get addEventDropdownHint => 'Тізімнен таңдау';

  @override
  String get addEventPickDate => 'Оқиға күнін таңдаңыз';

  @override
  String get addEventComment => 'Комментарий (міндетті емес)';

  @override
  String get addEventSelectType => 'Оқиға түрін таңдаңыз';

  @override
  String get addEventSelectDate => 'Оқиға күнін таңдаңыз';

  @override
  String get addEventEnterName => 'Оқиға атауын енгізіңіз';

  @override
  String get addEventSelectHeatStart => 'Күйлеудің басталу күнін таңдаңыз';

  @override
  String get addEventEnterCalfTag => 'Бұзаудың биркасын енгізіңіз';

  @override
  String get addEventSelectCalfGender => 'Бұзаудың жынысын таңдаңыз';

  @override
  String get addEventEnterCalfWeight =>
      'Бұзаудың туған кездегі салмағын енгізіңіз';

  @override
  String get eventDateVaccination => 'Вакцинация күні';

  @override
  String get eventDateTreatment => 'Өңдеу күні';

  @override
  String get eventDateIllness => 'Ауру күні';

  @override
  String get eventDateWeighing => 'Өлшеу күні';

  @override
  String get eventDateInsemination => 'Ұрықтандыру\nкүні';

  @override
  String get eventDateCheck => 'Тексеру күні';

  @override
  String get eventDateHornProcessing => 'Мүйіз өңдеу күні';

  @override
  String get eventDateCalving => 'Бұзаулау күні';

  @override
  String get eventDatePregnancy => 'Буаздық\nкүні';

  @override
  String get eventDateStart => 'Басталу күні';

  @override
  String get eventDateSync => 'Синхронизация күні';

  @override
  String get eventDateWeaning => 'Айыру күні';

  @override
  String get eventDateHoofTrimming => 'Тұяқ тазалау күні';

  @override
  String get eventDateGeneric => 'Оқиға күні';

  @override
  String get eventActionHeat => 'Күйлеуді тексеру';

  @override
  String get eventActionPregnancy => 'Буаздықты тексеру';

  @override
  String get eventActionDryPeriod => 'Сухостойға ауыстыру жоспарланған';

  @override
  String get eventActionWeighing => 'Өлшеу жүргізу ұсынылады';

  @override
  String get eventActionVaccination => 'Вакцинация жасау ұсынылады';

  @override
  String get eventActionIllness => 'Емдеу/тексеру жүргізу';

  @override
  String get eventActionHoof => 'Тұяқ тазалау ұсынылады';

  @override
  String get eventActionAntiparasitic => 'Паразиттерге қарсы өңдеу ұсынылады';

  @override
  String get eventActionCalving => 'Бұзаулаудан кейін бақылау';

  @override
  String get eventActionInsemination => 'Ұрықтандыру жоспарланған';

  @override
  String get eventActionWeaning => 'Айыру жоспарланған';

  @override
  String get eventActionDefault => 'Оқиғаны орындау уақыты келді';

  @override
  String get eventOverdueHint => 'Мүмкіндігінше тезірек орындау ұсынылады';

  @override
  String get fieldVaccine => 'Вакцина';

  @override
  String get fieldVaccineHint => 'Вакцина атауы';

  @override
  String get fieldWeightKg => 'Салмақ (кг)';

  @override
  String get fieldWeightHint => 'Өлшеу нәтижесі';

  @override
  String get fieldDiagnosis => 'Диагноз';

  @override
  String get fieldDiagnosisHint => 'Ауру атауы';

  @override
  String get fieldDrug => 'Препарат';

  @override
  String get fieldDrugHint => 'Препарат атауы';

  @override
  String get fieldDosage => 'Дозировка';

  @override
  String get fieldDosageHint => 'Мөлшері';

  @override
  String get fieldTreatmentDuration => 'Емдеу ұзақтығы (күн)';

  @override
  String get fieldEndDate => 'Аяқталу күні';

  @override
  String get fieldSelectDate => 'Күнді таңдаңыз';

  @override
  String get fieldMaleTag => 'Аталық биркасы';

  @override
  String get fieldFemaleTag => 'Аналық биркасы';

  @override
  String get fieldEnterTagNumber => 'Бирка нөмірін енгізіңіз';

  @override
  String get fieldSuccess => 'Сәттілігі';

  @override
  String get fieldSuccessful => 'Сәтті';

  @override
  String get fieldUnsuccessful => 'Сәтсіз';

  @override
  String get fieldDifficulty => 'Қиындық';

  @override
  String get fieldEasy => 'Жеңіл';

  @override
  String get fieldMedium => 'Орташа';

  @override
  String get fieldHard => 'Қиын';

  @override
  String get fieldCalfTag => 'Бұзау биркасы';

  @override
  String get fieldCalfTagHint => 'Бирка нөмірін енгізіңіз';

  @override
  String get fieldCalfName => 'Бұзау аты';

  @override
  String get fieldCalfNameHint => 'Бұзау атын енгізіңіз';

  @override
  String get fieldCalfGender => 'Бұзау жынысы';

  @override
  String get fieldCalfGenderHint => 'Таңдаңыз';

  @override
  String get fieldMale => 'Еркек';

  @override
  String get fieldFemale => 'Ұрғашы';

  @override
  String get fieldBirthWeight => 'Туған кездегі салмақ (кг)';

  @override
  String get fieldBirthWeightHint => 'Салмақты енгізіңіз';

  @override
  String get fieldHeatStartDate => 'Басталу күні';

  @override
  String get fieldHeatEndDate => 'Аяқталу күні';

  @override
  String get fieldHeatStart => 'Күйлеу басталуы';

  @override
  String get fieldHeatEnd => 'Күйлеу аяқталуы';

  @override
  String get fieldDrugNameHint => 'Препарат атауын енгізіңіз';

  @override
  String get fieldDosageHint2 => 'Дозировканы енгізіңіз';

  @override
  String get selectCattleTitle => 'Малды таңдау';

  @override
  String selectCattleSelected(int count) {
    return 'Таңдалды: $count';
  }

  @override
  String get selectCattleAll => 'Барлығын таңдау';

  @override
  String get selectCattleClear => 'Тазалау';

  @override
  String get selectCattleDone => 'Дайын';

  @override
  String get selectCattleNoTag => 'Бирка жоқ';

  @override
  String get rationsTitle => 'Рациондар/Қорлар';

  @override
  String get rationsFeedStock => 'Жем қоры';

  @override
  String get rationsConcentrates => 'Концентраттар';

  @override
  String get rationsSucculentFeed => 'Шырынды жем';

  @override
  String get rationsRoughage => 'Ірі жем';

  @override
  String get rationsAdditives => 'Қоспалар';

  @override
  String get rationsListTitle => 'Рациондар тізімі';

  @override
  String get rationsNotGenerated => 'Рациондар әлі жасалмаған';

  @override
  String get rationsNoMatch => 'Бұл жануарға сәйкес рацион жоқ';

  @override
  String get rationsDeleted => 'Рацион жойылды';

  @override
  String get rationsEmptyTitle => 'Сіздің тізіміңіз бос';

  @override
  String get rationsEmptySubtitle =>
      'Рациондар тізімін көру үшін\nжем қорын қосыңыз';

  @override
  String get rationsAddFeedStock => 'Жем қорын қосу';

  @override
  String get rationStatusActive => 'Белсенді';

  @override
  String get rationStatusNeedsAttention => 'Назар аударуды талап етеді';

  @override
  String get rationDeleteTitle => 'Рационды жою керек пе?';

  @override
  String get rationDeleteConfirm =>
      'Бұл рационды жойғыңыз келетініне сенімдісіз бе? Бұл әрекетті қайтару мүмкін емес.';

  @override
  String rationCategory(String category) {
    return 'Категория: $category';
  }

  @override
  String rationPeriod(String period) {
    return 'Кезең: $period';
  }

  @override
  String rationDailyCost(String cost) {
    return 'Күніне құны: $cost тг.';
  }

  @override
  String rationFeedType(String names) {
    return 'Жем түрі: $names';
  }

  @override
  String rationDailyNorm(String kg) {
    return 'Күндік норма: $kg кг';
  }

  @override
  String get rationInfoTitle => 'Рацион туралы ақпарат';

  @override
  String get rationMainInfo => 'Рационның негізгі ақпараты';

  @override
  String get rationCategoryLabel => 'Категория';

  @override
  String get rationPeriodLabel => 'Кезең';

  @override
  String get rationDailyCostLabel => 'Күндік құны';

  @override
  String rationDailyCostValue(String cost) {
    return '$cost тг.';
  }

  @override
  String get rationStatusLabel => 'Статус';

  @override
  String get rationDailyNormLabel => 'Күндік норма';

  @override
  String rationDailyNormValue(String kg) {
    return '$kg кг';
  }

  @override
  String get rationFeedsTitle => 'Рацион жемдері';

  @override
  String get rationNeedKg => 'Қажеттілік (кг)';

  @override
  String get rationCostKgTg => 'Құны (кг/тг)';

  @override
  String get rationDailyExpense => 'Күндік шығын (тг)';

  @override
  String get inventoryTitle => 'Қор';

  @override
  String inventoryTotalFeed(String kg) {
    return 'Барлық жем: $kg кг';
  }

  @override
  String get inventoryFeedDeleted => 'Жем жойылды';

  @override
  String get inventoryDeleteTitle => 'Жемді жою керек пе?';

  @override
  String get inventoryDeleteConfirm =>
      'Бұл жемді жойғыңыз келетініне сенімдісіз бе? Бұл әрекетті қайтару мүмкін емес.';

  @override
  String get lactationTitle => 'Лактация';

  @override
  String lactationMilkPerDay(String liters) {
    return 'Күндік сүт: $liters л.';
  }

  @override
  String get lactationQuantity => 'Саны';

  @override
  String get lactationCowMilking => 'Сиыр сауымы';

  @override
  String get lactationFarmMilking => 'Ферма бойынша сауым';

  @override
  String get lactationDate => 'Күні';

  @override
  String get lactationTime => 'Уақыты';

  @override
  String get lactationMilkingTime => 'Сауын уақыты';

  @override
  String get lactationMorning => 'Таң';

  @override
  String get lactationEvening => 'Кеш';

  @override
  String get lactationCowTag => 'Сиыр биркасы';

  @override
  String get lactationEnterInfo => 'Ақпарат енгізіңіз';

  @override
  String get lactationMilkAmount => 'Сүт мөлшері';

  @override
  String get lactationEnterMilk => 'Сүт мөлшерін енгізіңіз (литр)';

  @override
  String get lactationSuccessAdd =>
      'Ақпарат сәтті\nқосылды және\n\"Лактация\" бөлімінде көрсетілді';

  @override
  String get lactationGoToList => 'Тізімге өту';

  @override
  String get lactationAddBulkTitle => 'Ферма бойынша сауым қосу';

  @override
  String get lactationBulkSuccess =>
      'Ферма бойынша\nсауын деректері сәтті қосылды!';

  @override
  String get lactationEnterCowCount => 'Сауылған сиыр санын енгізіңіз';

  @override
  String get lactationEnterTotalMilk => 'Жалпы сүт мөлшерін енгізіңіз (л)';

  @override
  String get lactationMilkedCows => 'Сауылған сиыр';

  @override
  String get lactationTotalMilk => 'Жалпы сүт';

  @override
  String get lactationCalfUsed => 'Бұзауларға\nпайдаланылды';

  @override
  String get lactationUnfitMilk => 'Жарамсыз\nсүт';

  @override
  String get lactationAccountingWeek => 'Апта бойынша';

  @override
  String get lactationAccountingMonth => 'Ай бойынша';

  @override
  String get lactationAccountingPeriod => 'Кезең';

  @override
  String get lactationDateStartPeriod => 'Кезеңнің басталу күні';

  @override
  String get lactationDateEndPeriod => 'Кезеңнің аяқталу күні';

  @override
  String get lactationSelectDate => 'Күнді таңдаңыз';

  @override
  String get notFoundTitle => 'Бет табылмады';

  @override
  String get notFoundGoHome => 'Басты бетке оралу';

  @override
  String get registerPasswordMin => 'Кемінде 6 таңба';

  @override
  String get registerPasswordsMismatch => 'Құпиясөздер сәйкес келмейді';

  @override
  String get registerErrorGeneric => 'Тіркелу қатесі. Қайта көріңіз.';

  @override
  String get registerButton => 'ТІРКЕЛУ';

  @override
  String get registerSuccessTitle =>
      'Сіз Fermer+ жүйесінде\nсәтті тіркелдіңіз!';

  @override
  String get registerSuccessMessage =>
      'Қосымшаны қолдануды бастау үшін\n\"Жұмысты бастау\" батырмасын басыңыз';

  @override
  String get registerSuccessButton => 'Жұмысты бастау';
}
