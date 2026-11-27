import '../services/api_service.dart';

class AuthRepository {
  AuthRepository(this.api);

  final ApiService api;

  Future<Map<String, dynamic>> login(
      String identifier,
      String password, {
        bool rememberMe = true,
      }) =>
      _authenticate(
        'login',
        {
          'identifier': identifier,
          'password': password,
        },
        rememberMe: rememberMe,
      );

  Future<Map<String, dynamic>> register(
      Map<String, dynamic> fields,
      ) =>
      _authenticate('register', fields);

  Future<Map<String, dynamic>> _authenticate(
      String path,
      Map<String, dynamic> fields, {
        bool rememberMe = true,
      }) async {
    final body = await api.request(
      path,
      method: 'POST',
      data: fields,
    );

    final data = Map<String, dynamic>.from(
      body['data'] as Map,
    );

    await api.storage.save(
      data['token'] as String,
      rememberMe: rememberMe,
    );

    return Map<String, dynamic>.from(
      data['user'] as Map,
    );
  }

  Future<Map<String, dynamic>> profile() async =>
      Map<String, dynamic>.from(
        (await api.request('profile'))['data'] as Map,
      );

  Future<void> logout() async {
    try {
      await api.request('logout', method: 'POST');
    } finally {
      await api.storage.clear();
    }
  }
}