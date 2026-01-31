/// 登录响应模型
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserInfo user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// 用户信息模型
class UserInfo {
  final String id;
  final String? email;
  final String? phone;
  final String? nickname;
  final String? avatar;

  UserInfo({
    required this.id,
    this.email,
    this.phone,
    this.nickname,
    this.avatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  String get displayName => nickname ?? email ?? phone ?? '用户';
}
