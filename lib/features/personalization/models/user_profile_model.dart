class UserProfileModel {
  final int? id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profilePicture;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? bio;
  final String? website;
  final String? location;
  final String? occupation;
  final String provider;
  final String? providerId;
  final bool emailVerified;
  final bool phoneVerified;
  final String status;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profilePicture,
    this.gender,
    this.dateOfBirth,
    this.bio,
    this.website,
    this.location,
    this.occupation,
    this.provider = 'local',
    this.providerId,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.status = 'active',
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  // JSON에서 UserProfileModel로 변환
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int?,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profilePicture: json['profile_picture'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      occupation: json['occupation'] as String?,
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

  // UserProfileModel에서 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'email': email,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (profilePicture != null) 'profile_picture': profilePicture,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String().split('T')[0],
      if (bio != null) 'bio': bio,
      if (website != null) 'website': website,
      if (location != null) 'location': location,
      if (occupation != null) 'occupation': occupation,
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

  // 업데이트용 JSON (null 값 제외)
  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = {};

    if (firstName != null && firstName!.isNotEmpty) data['first_name'] = firstName;
    if (lastName != null && lastName!.isNotEmpty) data['last_name'] = lastName;
    if (username.isNotEmpty) data['username'] = username;
    if (email.isNotEmpty) data['email'] = email;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) data['phone_number'] = phoneNumber;
    if (profilePicture != null && profilePicture!.isNotEmpty) data['profile_picture'] = profilePicture;
    if (gender != null && gender!.isNotEmpty) data['gender'] = gender;
    if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth!.toIso8601String().split('T')[0];
    if (bio != null && bio!.isNotEmpty) data['bio'] = bio;
    if (website != null && website!.isNotEmpty) data['website'] = website;
    if (location != null && location!.isNotEmpty) data['location'] = location;
    if (occupation != null && occupation!.isNotEmpty) data['occupation'] = occupation;

    return data;
  }

  // UserProfileModel 복사 (수정 시 사용)
  UserProfileModel copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePicture,
    String? gender,
    DateTime? dateOfBirth,
    String? bio,
    String? website,
    String? location,
    String? occupation,
    String? provider,
    String? providerId,
    bool? emailVerified,
    bool? phoneVerified,
    String? status,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      location: location ?? this.location,
      occupation: occupation ?? this.occupation,
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

  // 빈 사용자 프로필 모델
  static UserProfileModel empty() => UserProfileModel(
    id: null,
    username: '',
    email: '',
    firstName: null,
    lastName: null,
    phoneNumber: null,
    profilePicture: null,
    gender: null,
    dateOfBirth: null,
    bio: null,
    website: null,
    location: null,
    occupation: null,
  );

  // 사용자 정보가 있는지 확인
  bool get isNotEmpty => email.isNotEmpty;
  bool get isEmpty => !isNotEmpty;

  // 전체 이름 반환
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username;
    }
  }

  // 이니셜 반환
  String get initials {
    String firstInitial = '';
    String lastInitial = '';

    if (firstName != null && firstName!.isNotEmpty) {
      firstInitial = firstName![0].toUpperCase();
    }
    if (lastName != null && lastName!.isNotEmpty) {
      lastInitial = lastName![0].toUpperCase();
    }

    if (firstInitial.isNotEmpty && lastInitial.isNotEmpty) {
      return firstInitial + lastInitial;
    } else if (firstInitial.isNotEmpty) {
      return firstInitial;
    } else if (lastInitial.isNotEmpty) {
      return lastInitial;
    } else if (username.isNotEmpty) {
      return username[0].toUpperCase();
    } else {
      return 'U';
    }
  }

  // 나이 계산
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // 프로필 완성도 계산
  double get completeness {
    int completed = 0;
    int total = 8;

    if (username.isNotEmpty) completed++;
    if (email.isNotEmpty) completed++;
    if (firstName?.isNotEmpty == true) completed++;
    if (lastName?.isNotEmpty == true) completed++;
    if (phoneNumber?.isNotEmpty == true) completed++;
    if (profilePicture?.isNotEmpty == true) completed++;
    if (gender?.isNotEmpty == true) completed++;
    if (dateOfBirth != null) completed++;

    return completed / total;
  }

  @override
  String toString() {
    return 'UserProfileModel{id: $id, username: $username, email: $email, fullName: $fullName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserProfileModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}