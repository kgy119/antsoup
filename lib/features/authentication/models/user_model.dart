class UserModel {
  final int? id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? profilePicture;
  final String provider;
  final String? providerId;
  final bool emailVerified;
  final bool phoneVerified;
  final String status;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.profilePicture,
    this.provider = 'local',
    this.providerId,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.status = 'active',
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  // JSON에서 UserModel로 변환
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      username: json['username'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      profilePicture: json['profile_picture'] as String?,
      provider: json['provider'] as String? ?? 'local',
      providerId: json['provider_id'] as String?,
      emailVerified: (json['email_verified'] as int? ?? 0) == 1,
      phoneVerified: (json['phone_verified'] as int? ?? 0) == 1,
      status: json['status'] as String? ?? 'active',
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // UserModel에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (profilePicture != null) 'profile_picture': profilePicture,
      'provider': provider,
      if (providerId != null) 'provider_id': providerId,
      'email_verified': emailVerified ? 1 : 0,
      'phone_verified': phoneVerified ? 1 : 0,
      'status': status,
      if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // 회원가입용 JSON (비밀번호 포함)
  Map<String, dynamic> toSignUpJson(String password) {
    return {
      'username': username,
      'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      'password': password,
      if (profilePicture != null) 'profile_picture': profilePicture,
      'provider': provider,
      if (providerId != null) 'provider_id': providerId,
    };
  }

  // UserModel 복사 (수정 시 사용)
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    String? provider,
    String? providerId,
    bool? emailVerified,
    bool? phoneVerified,
    String? status,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      provider: provider ?? this.provider,
      providerId: providerId ?? this.providerId,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      status: status ?? this.status,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 빈 사용자 모델 (로그아웃 시 사용)
  static UserModel empty() => UserModel(
    id: null,
    username: '',
    email: '',
    phoneNumber: null,
    profilePicture: null,
  );

  // 사용자가 로그인되어 있는지 확인
  bool get isNotEmpty => email.isNotEmpty;
  bool get isEmpty => !isNotEmpty;

  @override
  String toString() {
    return 'UserModel{id: $id, username: $username, email: $email, provider: $provider}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}