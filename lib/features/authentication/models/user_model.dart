/// 서드파티 로그인 제공자 열거형
enum AuthProvider {
  google,
  kakao,
  naver,
  facebook,
  apple,
}

/// 사용자 모델 - 서드파티 로그인 전용
class UserModel {
  final int? id; // 서버 DB의 auto increment ID
  final String uid; // 제공자에서 제공한 고유 ID
  final String email;
  final String name; // 서드파티에서 가져온 닉네임
  final String? profilePicture; // 프로필 이미지 URL
  final String? phoneNumber; // 전화번호 (선택사항)
  final AuthProvider authProvider; // 로그인한 제공자
  final bool isActive; // 계정 활성화 상태
  final DateTime createdAt; // 계정 생성일
  final DateTime updatedAt; // 마지막 업데이트일
  final DateTime? lastLoginAt; // 마지막 로그인일
  final bool pushNotifications; // 푸시 알림 설정
  final String? fcmToken; // Firebase Cloud Messaging 토큰

  const UserModel({
    this.id,
    required this.uid,
    required this.email,
    required this.name,
    this.profilePicture,
    this.phoneNumber,
    required this.authProvider,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.pushNotifications = true,
    this.fcmToken,
  });

  /// 빈 사용자 모델
  static UserModel empty() => UserModel(
    uid: '',
    email: '',
    name: '',
    authProvider: AuthProvider.google,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  /// 서드파티 로그인 정보로 사용자 모델 생성
  factory UserModel.fromSocialAuth({
    required String uid,
    required String email,
    required String name,
    required AuthProvider authProvider,
    String? profilePicture,
    String? phoneNumber,
  }) {
    final now = DateTime.now();

    return UserModel(
      uid: uid,
      email: email,
      name: name,
      profilePicture: profilePicture,
      phoneNumber: phoneNumber,
      authProvider: authProvider,
      createdAt: now,
      updatedAt: now,
      lastLoginAt: now,
    );
  }

  /// 서버 API용 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'email': email,
      'name': name,
      'profile_picture': profilePicture,
      'phone_number': phoneNumber,
      'auth_provider': authProvider.name,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'push_notifications': pushNotifications ? 1 : 0,
      'fcm_token': fcmToken,
    };
  }

  /// 서버 API용 등록 JSON (id 제외)
  Map<String, dynamic> toCreateJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// 서버 응답 JSON에서 사용자 모델 생성
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profilePicture: json['profile_picture'],
      phoneNumber: json['phone_number'],
      authProvider: _parseAuthProvider(json['auth_provider']),
      isActive: _parseBool(json['is_active']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      lastLoginAt: json['last_login_at'] != null
          ? _parseDateTime(json['last_login_at'])
          : null,
      pushNotifications: _parseBool(json['push_notifications']),
      fcmToken: json['fcm_token'],
    );
  }

  /// 사용자 정보 업데이트를 위한 copyWith
  UserModel copyWith({
    int? id,
    String? uid,
    String? email,
    String? name,
    String? profilePicture,
    String? phoneNumber,
    AuthProvider? authProvider,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? pushNotifications,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      authProvider: authProvider ?? this.authProvider,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  /// 로그인 시간 업데이트
  UserModel updateLastLogin() {
    return copyWith(
      lastLoginAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 프로필 이미지가 있는지 확인
  bool get hasProfilePicture => profilePicture?.isNotEmpty == true;

  /// 전화번호가 있는지 확인
  bool get hasPhoneNumber => phoneNumber?.isNotEmpty == true;

  /// 헬퍼 메서드들
  static AuthProvider _parseAuthProvider(dynamic value) {
    if (value == null) return AuthProvider.google;

    switch (value.toString().toLowerCase()) {
      case 'google':
        return AuthProvider.google;
      case 'kakao':
        return AuthProvider.kakao;
      case 'naver':
        return AuthProvider.naver;
      case 'facebook':
        return AuthProvider.facebook;
      case 'apple':
        return AuthProvider.apple;
      default:
        return AuthProvider.google;
    }
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  String toString() {
    return 'UserModel(id: $id, uid: $uid, email: $email, name: $name, authProvider: $authProvider)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}