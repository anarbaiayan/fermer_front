import 'package:flutter/foundation.dart';

/// Состояние фильтров каталога аптеки.
///
/// `companyId` поддерживается только через `/pharmacy/drugs` (у `/catalog` его
/// нет), поэтому провайдер каталога переключает источник в зависимости от него.
@immutable
class PharmacyFilter {
  final String search;
  final int? actionId;
  final int? companyId;

  const PharmacyFilter({this.search = '', this.actionId, this.companyId});

  bool get isEmpty =>
      search.trim().isEmpty && actionId == null && companyId == null;

  PharmacyFilter copyWith({
    String? search,
    int? actionId,
    int? companyId,
    bool clearAction = false,
    bool clearCompany = false,
  }) {
    return PharmacyFilter(
      search: search ?? this.search,
      actionId: clearAction ? null : (actionId ?? this.actionId),
      companyId: clearCompany ? null : (companyId ?? this.companyId),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PharmacyFilter &&
      other.search == search &&
      other.actionId == actionId &&
      other.companyId == companyId;

  @override
  int get hashCode => Object.hash(search, actionId, companyId);
}
