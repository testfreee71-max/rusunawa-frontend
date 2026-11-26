import '../services/api_service.dart';

class BookingRepository {
  BookingRepository(this.api);
  final ApiService api;
  Future<List<Map<String, dynamic>>> list() => api.all('bookings');
  Future<Map<String, dynamic>> detail(String id) async => Map<String, dynamic>.from((await api.request('bookings/${Uri.encodeComponent(id)}'))['data'] as Map);
  Future<Map<String, dynamic>> create(Map<String, dynamic> fields) async => Map<String, dynamic>.from((await api.request('bookings', method: 'POST', data: fields))['data'] as Map);
  Future<void> cancel(String id) async { await api.request('bookings/${Uri.encodeComponent(id)}/cancel', method: 'PATCH'); }
}
