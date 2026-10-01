import 'package:flutter/foundation.dart';

/// Раздел «Финансы» (пункт в «Ещё» и маршруты `/finance/**`).
///
/// Модуль подключён к API, но на проде (`fer-mer-plus.ru`) `/api/finance/**`
/// ещё нет: ветка бэкенда `finance` не выкачена. Поэтому раздел есть только
/// в debug. Когда бэкенд выкатят, флаг становится `true`.
const bool kFinanceEnabled = kDebugMode;
