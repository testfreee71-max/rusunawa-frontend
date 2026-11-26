import '../services/api_service.dart';

class RoomRepository {
  RoomRepository(this.api);
  final ApiService api;
  Future<List<Map<String, dynamic>>> list({String? search, String? gender}) => api.all('rooms', query: {if (search != null) 'search': search, if (gender != null) 'gender': gender});
  Future<Map<String, dynamic>> detail(String id) async => Map<String, dynamic>.from((await api.request('rooms/${Uri.encodeComponent(id)}'))['data'] as Map);
}
