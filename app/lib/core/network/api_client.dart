import 'package:dio/dio.dart';
import '../../app/config/app_config.dart';
import '../services/storage_service.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  late final Dio _authDio; // 用于需要认证的请求

  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    // 带认证的 Dio 实例
    _authDio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 添加认证拦截器
    _authDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = StorageService.instance.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));

    _authDio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;
  Dio get authDio => _authDio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.delete<T>(path, queryParameters: queryParameters);
  }

  // 认证请求方法
  Future<Response<T>> authGet<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _authDio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> authPost<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _authDio.post<T>(path, data: data, queryParameters: queryParameters);
  }
}
