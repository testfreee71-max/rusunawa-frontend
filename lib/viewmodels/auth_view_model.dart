import 'package:dio/dio.dart';
import '../repositories/auth_repository.dart';
import '../models/user_profile.dart';

class AuthViewModel {
  AuthViewModel(this.repository);
  final AuthRepository repository;
  String? error;
  static UserProfile parse(Map<String, dynamic> json) => UserProfile(
    nim: json['nim']?.toString() ?? '', name: json['name']?.toString() ?? '',
    email: json['email']?.toString() ?? '', phone: json['phone']?.toString() ?? '',
    studyProgram: json['study_program']?.toString() ?? '',
    birthDate: DateTime.tryParse(json['birth_date']?.toString() ?? ''),
    gender: json['gender']?.toString() ?? '', address: json['address']?.toString() ?? '',
  );
  static String message(Object e) {
    if (e is DioException) {
      final body = e.response?.data;
      if (body is Map) {
        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          return errors.values.map((v) => v is List ? v.join(', ') : v.toString()).join('\n');
        }
        if (body['message'] is String) return body['message'] as String;
      }
      if (e.response == null) return 'Tidak dapat menghubungi server. Coba lagi.';
      return 'Permintaan gagal (${e.response?.statusCode}).';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
  Future<UserProfile?> authenticate(Future<Map<String, dynamic>> Function() action) async {
    error = null;
    try { return parse(await action()); }
    catch (e) { error = message(e); return null; }
  }
  Future<UserProfile?> restore() async {
    error = null;
    try {
      final token = await repository.api.storage.read();
      if (token == null || token.isEmpty) return null;
      return parse(await repository.profile());
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        await repository.api.storage.clear();
      }
      error = message(e);
      return null;
    }
  }
}
