import '../services/api_service.dart';

class RoomRepository {
  RoomRepository(this.api);

  final ApiService api;

  Future<List<Map<String, dynamic>>> list({
    String? search,
    String? gender,
    String? building,
    int? minCapacity,
    bool? available,
    String? sort,
  }) => api.all(
    'rooms',
    query: {
      'search': ?search,
      'gender': ?gender,
      'building': ?building,
      'min_capacity': ?minCapacity,
      if (available != null) 'available': available ? 1 : 0,
      'sort': ?sort,
    },
  );

  Future<Map<String, dynamic>> detail(String id) async =>
      Map<String, dynamic>.from(
        (await api.request('rooms/${Uri.encodeComponent(id)}'))['data'] as Map,
      );

  Future<List<Map<String, dynamic>>> getFavorites() => api.all('favorites');

  Future<void> addFavorite(String roomId) async {
    await api.request('favorites', method: 'POST', data: {'room_id': roomId});
  }

  Future<void> removeFavorite(String roomId) async {
    await api.request(
      'favorites/${Uri.encodeComponent(roomId)}',
      method: 'DELETE',
    );
  }
}
