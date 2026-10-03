import 'create_lactation_dto.dart';

/// Тело `POST /lactations/batch`.
///
/// Бэкенд сохраняет пакет одной транзакцией: одна некорректная запись или
/// чужая корова откатывает весь пакет целиком.
class CreateLactationBatchDto {
  /// Ограничение бэкенда (`@Size(max = 100)`). Больше — только несколькими
  /// пакетами.
  static const maxRecords = 100;

  final List<CreateLactationDto> records;

  const CreateLactationBatchDto({required this.records});

  Map<String, dynamic> toJson() {
    if (records.isEmpty || records.length > maxRecords) {
      throw ArgumentError.value(
        records.length,
        'records',
        'Batch must contain 1..$maxRecords records',
      );
    }
    // toJson каждой записи валидирует литры: пакет с заведомо плохой записью
    // не уходит в сеть, раз сервер всё равно отклонил бы его целиком.
    return {'records': records.map((record) => record.toJson()).toList()};
  }
}
