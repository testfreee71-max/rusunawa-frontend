import '../models/room.dart';
import '../repositories/room_repository.dart';
import 'auth_view_model.dart';

class RoomViewModel {
  RoomViewModel(this.repository);

  final RoomRepository repository;

  bool loading = false;
  String? error;
  List<Room> rooms = [];

  bool favoriteBusy = false;
  String? favoriteError;

  bool filterLoading = false;
  String? filterError;
  List<Room> filteredRooms = [];

  int _generation = 0;
  int _filterGeneration = 0;

  void resetFilters() {
    _filterGeneration++;
    filteredRooms = [];
    filterLoading = false;
    filterError = null;
  }

  void reset() {
    _generation++;
    rooms = [];
    loading = false;
    error = null;
    favoriteBusy = false;
    favoriteError = null;
    resetFilters();
  }

  Future<void> load() async {
    if (loading || favoriteBusy) return;

    final generation = _generation;

    loading = true;
    error = null;

    try {
      final result = (await repository.list()).map(Room.fromJson).toList();

      if (generation == _generation) {
        rooms = result;
      }
    } catch (e) {
      if (generation == _generation) {
        error = AuthViewModel.message(e);
      }
    } finally {
      if (generation == _generation) {
        loading = false;
      }
    }
  }

  Future<void> loadFiltered({
    String? building,
    int? minCapacity,
    String? gender,
    bool? available,
    String? sort,
  }) async {
    final generation = ++_filterGeneration;

    filterLoading = true;
    filterError = null;

    try {
      final result = (await repository.list(
        building: building,
        minCapacity: minCapacity,
        gender: gender,
        available: available,
        sort: sort,
      )).map(Room.fromJson).toList();

      if (generation == _filterGeneration) {
        filteredRooms = result.map((room) {
          final index = rooms.indexWhere((item) => item.id == room.id);

          return index == -1
              ? room
              : room.copyWith(isFavorite: rooms[index].isFavorite);
        }).toList();
      }
    } catch (e) {
      if (generation == _filterGeneration) {
        filterError = AuthViewModel.message(e);
      }
    } finally {
      if (generation == _filterGeneration) {
        filterLoading = false;
      }
    }
  }

  Future<bool> toggleFavorite(String roomId) async {
    if (favoriteBusy || loading) return false;

    final index = rooms.indexWhere((room) => room.id == roomId);

    if (index == -1) return false;

    final generation = _generation;
    final wasFavorite = rooms[index].isFavorite;

    favoriteBusy = true;
    favoriteError = null;

    try {
      if (wasFavorite) {
        await repository.removeFavorite(roomId);
      } else {
        await repository.addFavorite(roomId);
      }

      if (generation != _generation) return false;

      rooms = rooms.map((room) {
        return room.id == roomId
            ? room.copyWith(isFavorite: !wasFavorite)
            : room;
      }).toList();

      filteredRooms = filteredRooms.map((room) {
        return room.id == roomId
            ? room.copyWith(isFavorite: !wasFavorite)
            : room;
      }).toList();

      return true;
    } catch (e) {
      if (generation == _generation) {
        favoriteError = AuthViewModel.message(e);
      }

      return false;
    } finally {
      if (generation == _generation) {
        favoriteBusy = false;
      }
    }
  }
}
