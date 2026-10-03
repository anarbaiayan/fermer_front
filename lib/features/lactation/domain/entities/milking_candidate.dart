/// Корова, доступная для контрольного надоя (шаг 1).
///
/// Намеренно легковесная: список должен оставаться отзывчивым на 500+ животных,
/// поэтому здесь только поля, нужные для поиска, фильтров и компактной строки.
class MilkingCandidate {
  final int id;
  final String tagNumber;
  final String name;
  final bool isLactating;
  final String? animalGroup;

  /// Предпосчитанная строка для поиска: фильтрация идёт по всему датасету на
  /// каждый введённый символ, поэтому lowercase не считаем заново.
  final String searchIndex;

  MilkingCandidate({
    required this.id,
    required this.tagNumber,
    required this.name,
    required this.isLactating,
    required this.animalGroup,
  }) : searchIndex = '${tagNumber.toLowerCase()} ${name.toLowerCase()}';
}
