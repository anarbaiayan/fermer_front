import 'drug_offer_dto.dart';
import 'vet_drug_dto.dart';

/// Группа препаратов «одно и то же» (по действующему веществу) с предложениями
/// разных производителей — основная единица списка каталога.
///
/// Может прийти напрямую из `GET /api/pharmacy/catalog` ([DrugGroupDto.fromJson])
/// или быть собрана на клиенте из плоского списка `GET /api/pharmacy/drugs`
/// ([DrugGroupDto.groupFromDrugs]) — правило группировки повторяет бэкенд.
class DrugGroupDto {
  /// Отображаемое название группы (действующее вещество или название препарата).
  final String title;

  /// Действующее вещество, если задано (иначе группа из одного препарата).
  final String? activeIngredient;
  final String? actionName;
  final int offerCount;
  final double? minPrice;
  final double? maxPrice;

  /// Предложения производителей, отсортированы по возрастанию цены.
  final List<DrugOfferDto> offers;

  const DrugGroupDto({
    required this.title,
    this.activeIngredient,
    this.actionName,
    required this.offerCount,
    this.minPrice,
    this.maxPrice,
    required this.offers,
  });

  bool get hasComparison => offerCount > 1;

  /// Первое (самое дешёвое) предложение — бэк сортирует offers по цене.
  DrugOfferDto? get cheapestOffer => offers.isEmpty ? null : offers.first;

  factory DrugGroupDto.fromJson(Map<String, dynamic> json) {
    final offersJson = (json['offers'] as List?) ?? const [];
    return DrugGroupDto(
      title: (json['title'] ?? '').toString(),
      activeIngredient: (json['activeIngredient'] as String?)?.trim(),
      actionName: (json['actionName'] as String?)?.trim(),
      offerCount: (json['offerCount'] as num?)?.toInt() ?? offersJson.length,
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      offers: offersJson
          .cast<Map<String, dynamic>>()
          .map(DrugOfferDto.fromJson)
          .toList(),
    );
  }

  /// Клиентская группировка плоского списка препаратов по тому же правилу,
  /// что и `PharmacyService.getGroupedCatalog`:
  /// ключ — действующее вещество (если есть), иначе название препарата.
  static List<DrugGroupDto> groupFromDrugs(List<VetDrugDto> drugs) {
    final groups = <String, List<VetDrugDto>>{};
    for (final d in drugs) {
      final ingredient = d.activeIngredient;
      final hasIngredient = ingredient != null && ingredient.trim().isNotEmpty;
      final key = hasIngredient
          ? 'ai::${ingredient.trim().toLowerCase()}'
          : 'name::${d.name.trim().toLowerCase()}';
      groups.putIfAbsent(key, () => []).add(d);
    }

    final result = <DrugGroupDto>[];
    for (final groupDrugs in groups.values) {
      final offers =
          groupDrugs
              .map(
                (d) => DrugOfferDto(
                  drugId: d.id,
                  companyId: d.companyId,
                  companyName: d.companyName,
                  name: d.name,
                  packaging: d.packaging,
                  price: d.price,
                  imageUrl: d.imageUrl,
                ),
              )
              .toList()
            ..sort((a, b) {
              if (a.price == null && b.price == null) return 0;
              if (a.price == null) return 1; // null-цены в конец
              if (b.price == null) return -1;
              return a.price!.compareTo(b.price!);
            });

      final first = groupDrugs.first;
      final ingredient = first.activeIngredient;
      final hasIngredient = ingredient != null && ingredient.trim().isNotEmpty;

      final prices = offers
          .map((o) => o.price)
          .whereType<double>()
          .toList(growable: false);
      final min = prices.isEmpty
          ? null
          : prices.reduce((a, b) => a < b ? a : b);
      final max = prices.isEmpty
          ? null
          : prices.reduce((a, b) => a > b ? a : b);

      final actionName = groupDrugs
          .map((d) => d.actionName)
          .firstWhere(
            (a) => a != null && a.trim().isNotEmpty,
            orElse: () => null,
          );

      result.add(
        DrugGroupDto(
          title: hasIngredient ? ingredient.trim() : first.name,
          activeIngredient: hasIngredient ? ingredient.trim() : null,
          actionName: actionName,
          offerCount: offers.length,
          minPrice: min,
          maxPrice: max,
          offers: offers,
        ),
      );
    }

    // Сначала группы, где есть что сравнивать, затем по названию.
    result.sort((a, b) {
      final byCompare = (a.offerCount > 1 ? 0 : 1).compareTo(
        b.offerCount > 1 ? 0 : 1,
      );
      if (byCompare != 0) return byCompare;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return result;
  }
}
