import 'package:dio/dio.dart';
import 'token_storage.dart';

class ApiService {
  ApiService(this.storage) {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      try {
        final token = await storage.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      } catch (error) {
        handler.reject(DioException(requestOptions: options, error: error));
      }
    }));
  }
  final TokenStorage storage;
  final Dio dio = Dio(BaseOptions(
    baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8000/api/'),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
  ));
  Future<Map<String, dynamic>> request(String path, {String method = 'GET', Object? data, Map<String, dynamic>? query}) async {
    final response = await dio.request<Map<String, dynamic>>(path, data: data, queryParameters: query, options: Options(method: method));
    return response.data!;
  }
  Future<List<Map<String, dynamic>>> all(String path, {Map<String, dynamic>? query}) async {
    final result = <Map<String, dynamic>>[];
    var page = 1;
    while (true) {
      final body = await request(path, query: {...?query, 'page': page, 'per_page': 100});
      result.addAll((body['data'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
      final last = (body['meta'] as Map?)?['last_page'] as int? ?? 1;
      if (page >= last) return result;
      page++;
    }
  }
}
