import 'package:dio/dio.dart';
import '../models/booking.dart';
import '../repositories/booking_repository.dart';
import 'auth_view_model.dart';

class BookingViewModel {
  BookingViewModel(this.repository);
  final BookingRepository repository;
  List<Booking> bookings = [];
  bool loading = false;
  String? error;
  int _generation = 0;
  void reset() { _generation++; bookings = []; loading = false; error = null; }
  Future<void> load() async {
    if (loading) return;
    final generation = _generation;
    loading = true; error = null;
    try {
      final result = (await repository.list()).map(Booking.fromJson).toList();
      if (generation == _generation) bookings = result;
    } catch (e) {
      if (generation == _generation) error = AuthViewModel.message(e);
    } finally {
      if (generation == _generation) loading = false;
    }
  }
  Future<Booking> create(Map<String, dynamic> fields) async {
    final result = Booking.fromJson(await repository.create(fields));
    bookings = [result, ...bookings.where((b) => b.id != result.id)];
    return result;
  }
  Future<void> cancel(String id) async {
    await repository.cancel(id);
    bookings = bookings.map((b) => b.id == id ? b.copyWith(status: BookingStatus.cancelled) : b).toList();
  }
  static Map<String, String> fieldErrors(Object e) {
    if (e is DioException && e.response?.statusCode == 422) {
      final body = e.response?.data;
      if (body is Map && body['errors'] is Map) {
        return (body['errors'] as Map).map((key, value) => MapEntry(key.toString(), value is List ? value.join('\n') : value.toString()));
      }
    }
    return {};
  }
}
