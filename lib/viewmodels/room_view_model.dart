import '../models/room.dart';
import '../repositories/room_repository.dart';
import 'auth_view_model.dart';

class RoomViewModel {
  RoomViewModel(this.repository);
  final RoomRepository repository;
  bool loading = false;
  String? error;
  List<Room> rooms = [];
  int _generation = 0;
  void reset() { _generation++; rooms = []; loading = false; error = null; }
  Future<void> load() async {
    if (loading) return;
    final generation = _generation;
    loading = true; error = null;
    try {
      final result = (await repository.list()).map(Room.fromJson).toList();
      if (generation == _generation) rooms = result;
    } catch (e) {
      if (generation == _generation) error = AuthViewModel.message(e);
    } finally {
      if (generation == _generation) loading = false;
    }
  }
}
