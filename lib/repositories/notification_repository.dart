import "../services/api_service.dart";

class NotificationRepository {
  NotificationRepository(this.api);
  final ApiService api;
  Future<List<Map<String, dynamic>>> list() => api.all("notifications");
  Future<void> markRead(String id) async {
    await api.request(
      "notifications/${Uri.encodeComponent(id)}/read",
      method: "PATCH",
    );
  }

  Future<void> markAllRead() async {
    await api.request("notifications/read-all", method: "PATCH");
  }
}
