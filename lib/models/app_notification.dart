enum NotificationType {
  approved,
  document,
  processing,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    required this.isRead,
  });

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