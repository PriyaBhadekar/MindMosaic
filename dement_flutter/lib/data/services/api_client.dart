import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../storage/local_storage.dart';

class ApiClient {
  static Dio? _dio;

  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {

          final token = LocalStorage.getToken();

          print("========== TOKEN ==========");
          print(token);
          print("===========================");

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print("========== HEADERS ==========");
          print(options.headers);
          print("=============================");

          return handler.next(options);
        },
      ),
    );

    return dio;
  }

  static void reset() => _dio = null;

  static Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? params}) async {
    final response = await dio.get(path, queryParameters: params);
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> post(String path,
      {dynamic data}) async {
    final response = await dio.post(path, data: data);
    return response.data as Map<String, dynamic>;
  }

  // static Future<Map<String, dynamic>> put(String path,
  //     {dynamic data}) async {
  //   final response = await dio.put(path, data: data);
  //   return response.data as Map<String, dynamic>;
  // }

  static Future<Map<String, dynamic>> patch(String path,
      {dynamic data}) async {
    final response = await dio.patch(path, data: data);
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    final response = await dio.delete(path);
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> postMultipart(
      String path, FormData formData) async {
    final response = await dio.post(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> putMultipart(
      String path, FormData formData) async {
    final response = await dio.put(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data as Map<String, dynamic>;
  }

  // Build full URL for static files
  static String buildFileUrl(String? path) {
    if (path == null) return '';
    // Convert local file path to accessible URL
    final cleanPath = path.replaceAll('\\', '/');
    return 'http://localhost:8080/$cleanPath';
  }

  static Future<dynamic> put(
      String endpoint, {

        dynamic data,

      }) async {

    final response = await dio.put(
      endpoint,
      data: data,
    );

    return response.data;
  }
}