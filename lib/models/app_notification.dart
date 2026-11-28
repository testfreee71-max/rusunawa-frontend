enum NotificationType { approved, document, processing }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse(
      json["created_at"]?.toString() ?? "",
    )?.toLocal();
    final time = date == null ? "-" : "${date.day}/${date.month}/${date.year}";
    return AppNotification(
      id: json["id"].toString(),
      title: json["title"]?.toString() ?? "",
      message: json["message"]?.toString() ?? "",
      type: switch (json["type"]) {
        "approved" => NotificationType.approved,
        "document" => NotificationType.document,
        _ => NotificationType.processing,
      },
      time: time,
      isRead: json["is_read"] == true || json["is_read"] == 1,
    );
  }
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String time;
  final bool isRead;

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? time,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
    );
  }
}
