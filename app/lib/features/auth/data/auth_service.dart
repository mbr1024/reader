import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import 'auth_models.dart';

/// 认证服务
/// 封装登录、注册、登出等API调用
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  AuthService._();
  
  final _api = ApiClient.instance;
  final _storage = StorageService.instance;
  
  /// 邮箱登录
  Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      final authResponse = AuthResponse.fromJson(response.data);
      
      // 保存认证信息
      await _storage.saveAuth(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.user.id,
      );
      
      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 手机号登录
  Future<AuthResponse> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _api.post('/auth/login', data: {
        'phone': phone,
        'password': password,
      });
      
      final authResponse = AuthResponse.fromJson(response.data);
      
      await _storage.saveAuth(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.user.id,
      );
      
      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 注册
  Future<AuthResponse> register({
    String? email,
    String? phone,
    required String password,
    String? nickname,
  }) async {
    try {
      final response = await _api.post('/auth/register', data: {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'password': password,
        if (nickname != null) 'nickname': nickname,
      });
      
      final authResponse = AuthResponse.fromJson(response.data);
      
      await _storage.saveAuth(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.user.id,
      );
      
      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 登出
  Future<void> logout() async {
    try {
      final refreshToken = _storage.refreshToken;
      if (refreshToken != null) {
        await _api.post('/auth/logout', data: {
          'refreshToken': refreshToken,
        });
      }
    } catch (_) {
      // 忽略登出API错误
    } finally {
      await _storage.clearAuth();
    }
  }
  
  /// 刷新Token
  Future<void> refreshToken() async {
    final refreshToken = _storage.refreshToken;
    if (refreshToken == null) {
      throw AuthException('未登录');
    }
    
    try {
      final response = await _api.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      
      final authResponse = AuthResponse.fromJson(response.data);
      
      await _storage.saveAuth(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.user.id,
      );
    } on DioException catch (e) {
      await _storage.clearAuth();
      throw _handleError(e);
    }
  }
  
  /// 是否已登录
  bool get isLoggedIn => _storage.isLoggedIn;
  
  /// 处理错误
  String _handleError(DioException e) {
    if (e.response?.data is Map) {
      final message = e.response?.data['message'];
      if (message is String) return message;
      if (message is List && message.isNotEmpty) return message.first.toString();
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '网络连接超时，请检查网络';
      case DioExceptionType.connectionError:
        return '无法连接服务器，请检查网络';
      default:
        if (e.response?.statusCode == 401) {
          return '邮箱或密码错误';
        } else if (e.response?.statusCode == 409) {
          return '该账号已存在';
        }
        return '登录失败，请稍后重试';
    }
  }
}

/// 认证异常
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}
