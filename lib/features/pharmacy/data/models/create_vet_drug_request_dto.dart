/// Тело запроса `POST /api/pharmacy/requests`.
///
/// `contactPhone` можно оставить пустым — бэк подставит телефон из профиля.
/// В `comment` кладём введённый пользователем адрес доставки / хозяйство
/// (отдельного поля адреса в модели заявки нет).
class CreateVetDrugRequestDto {
  final int drugId;
  final int quantity;
  final String? comment;
  final String? contactPhone;

  const CreateVetDrugRequestDto({
    required this.drugId,
    required this.quantity,
    this.comment,
    this.contactPhone,
  });

  Map<String, dynamic> toJson() {
    final comment = this.comment?.trim();
    final phone = contactPhone?.trim();
    return {
      'drugId': drugId,
      'quantity': quantity,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
      if (phone != null && phone.isNotEmpty) 'contactPhone': phone,
    };
  }
}
