class PushNotificationPayload {
  const PushNotificationPayload({
    required this.notificationId,
    required this.type,
    required this.cattleId,
    required this.title,
    required this.body,
  });

  final String? notificationId;
  final String? type;
  final int? cattleId;
  final String? title;
  final String? body;

  factory PushNotificationPayload.fromMessage({
    required Map<String, dynamic> data,
    String? title,
    String? body,
  }) {
    final cattleIdValue = data['cattleId']?.toString();
    return PushNotificationPayload(
      notificationId: data['notificationId']?.toString(),
      type: data['type']?.toString(),
      cattleId: cattleIdValue == null ? null : int.tryParse(cattleIdValue),
      title: title,
      body: body,
    );
  }

  factory PushNotificationPayload.fromJson(Map<String, dynamic> json) {
    final cattleIdValue = json['cattleId'];
    return PushNotificationPayload(
      notificationId: json['notificationId'] as String?,
      type: json['type'] as String?,
      cattleId: cattleIdValue is int
          ? cattleIdValue
          : int.tryParse(cattleIdValue?.toString() ?? ''),
      title: json['title'] as String?,
      body: json['body'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'notificationId': notificationId,
    'type': type,
    'cattleId': cattleId,
    'title': title,
    'body': body,
  };
}
