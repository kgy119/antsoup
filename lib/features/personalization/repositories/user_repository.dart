import 'dart:convert';
import 'package:antsoup/features/authentication/models/user_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/local_storage/storage_utility.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  // API 기본 URL
  static const String _baseUrl = 'http://antsoup.co.kr/api';

  final _localStorage = TLocalStorage();

  /// 현재 사용자 정보 가져오기 (서버에서 최신 정보)
  Future<UserModel> getCurrentUser() async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/user.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true && data['user'] != null) {
          return UserModel.fromJson(data['user']);
        } else {
          throw TExceptions(data['message'] ?? '사용자 정보를 가져올 수 없습니다.');
        }
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('사용자 정보를 가져오는 중 오류가 발생했습니다.');
    }
  }

  /// 사용자 프로필 업데이트
  Future<UserModel> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/auth/user.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(userData),
      );

      final data = jsonDecode(response.body);
      print("response.statusCode : ${response.statusCode}");
      if (response.statusCode == 200) {
        print("data['user'] : ${data['user']}");
        if (data['success'] == true && data['user'] != null) {
          return UserModel.fromJson(data['user']);
        } else {
          throw TExceptions(data['message'] ?? '프로필 업데이트에 실패했습니다.');
        }
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('프로필 업데이트 중 오류가 발생했습니다.');
    }
  }

  /// 프로필 이미지 업로드
  Future<String> uploadProfileImage(XFile imageFile) async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/user/upload-profile-image.php'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // 이미지 파일 추가
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['image_url'] as String;
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('이미지 업로드 중 오류가 발생했습니다.');
    }
  }

  /// 비밀번호 변경
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/user/change-password.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('비밀번호 변경 중 오류가 발생했습니다.');
    }
  }

  /// 계정 삭제
  Future<void> deleteAccount(String password) async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/user/delete-account.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('계정 삭제 중 오류가 발생했습니다.');
    }
  }

  /// 주소 목록 가져오기
  Future<List<AddressModel>> getUserAddresses() async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/user/addresses.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> addressesJson = data['addresses'];
        return addressesJson.map((json) => AddressModel.fromJson(json)).toList();
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('주소 목록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  /// 주소 추가
  Future<AddressModel> addAddress(Map<String, dynamic> addressData) async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/user/addresses.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(addressData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return AddressModel.fromJson(data['address']);
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('주소 추가 중 오류가 발생했습니다.');
    }
  }

  /// 주소 업데이트
  Future<AddressModel> updateAddress(int addressId, Map<String, dynamic> addressData) async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/user/addresses.php?id=$addressId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(addressData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AddressModel.fromJson(data['address']);
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('주소 업데이트 중 오류가 발생했습니다.');
    }
  }

  /// 주소 삭제
  Future<void> deleteAddress(int addressId) async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/user/addresses.php?id=$addressId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('주소 삭제 중 오류가 발생했습니다.');
    }
  }

  /// 기본 주소 설정
  Future<void> setDefaultAddress(int addressId) async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/user/addresses.php?id=$addressId&action=set_default'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('기본 주소 설정 중 오류가 발생했습니다.');
    }
  }

  /// 사용자 설정 가져오기
  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/user/settings.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['settings'] as Map<String, dynamic>;
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('설정 정보를 가져오는 중 오류가 발생했습니다.');
    }
  }

  /// 사용자 설정 업데이트
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/user/settings.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(settings),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('설정 업데이트 중 오류가 발생했습니다.');
    }
  }

  /// 에러 메시지 파싱
  String _parseErrorMessage(Map<String, dynamic> data) {
    if (data['message'] != null) {
      return data['message'];
    } else if (data['error'] != null) {
      return data['error'];
    } else if (data['errors'] != null && data['errors'] is Map) {
      final errors = data['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
      return firstError.toString();
    }
    return '알 수 없는 오류가 발생했습니다.';
  }
}

/// 주소 모델
class AddressModel {
  final int? id;
  final String name;
  final String phoneNumber;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
      isDefault: (json['is_default'] as int? ?? 0) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'street': street,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'is_default': isDefault ? 1 : 0,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  AddressModel copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullAddress => '$street, $city, $state $postalCode, $country';

  @override
  String toString() {
    return 'AddressModel{id: $id, name: $name, fullAddress: $fullAddress}';
  }
}