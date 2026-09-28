import 'package:flutter/foundation.dart';

/// Раздел «Финансы» (пункт в «Ещё» и маршруты `/finance/**`).
///
/// Пока модуль работает на моковых данных, он есть только в debug, чтобы
/// демо-цифры не попали в релиз. Когда модуль подключён к API, флаг
/// становится `true`.
const bool kFinanceEnabled = kDebugMode;
