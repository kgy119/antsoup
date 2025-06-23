import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/local_storage/storage_utility.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  // API 기본 URL - 실제 서버 주소로 변경 필요
  static const String _baseUrl = 'http://antsoup.co.kr/api';

  final _localStorage = TLocalStorage();

  // 현재 로그인된 사용자
  final Rx<UserModel> _currentUser = UserModel.empty().obs;
  UserModel get currentUser => _currentUser.value;

  @override
  void onReady() {
    super.onReady();
    // 앱 시작 시 저장된 사용자 정보 로드
    loadUserFromStorage();
  }

  /// 로컬 저장소에서 사용자 정보 로드
  void loadUserFromStorage() {
    try {
      final userData = _localStorage.readData<Map<String, dynamic>>('user');
      if (userData != null) {
        _currentUser.value = UserModel.fromJson(userData);
      }
    } catch (e) {
      // 에러 발생 시 빈 사용자로 설정
      _currentUser.value = UserModel.empty();
    }
  }

  /// 사용자 정보를 로컬 저장소에 저장
  Future<void> saveUserToStorage(UserModel user) async {
    try {
      await _localStorage.saveData('user', user.toJson());
      _currentUser.value = user;
    } catch (e) {
      throw TExceptions('사용자 정보 저장에 실패했습니다.');
    }
  }

  /// 로컬 저장소에서 사용자 정보 삭제
  Future<void> removeUserFromStorage() async {
    try {
      await _localStorage.removeData('user');
      await _localStorage.removeData('auth_token');
      _currentUser.value = UserModel.empty();
    } catch (e) {
      throw TExceptions('사용자 정보 삭제에 실패했습니다.');
    }
  }

  /// 회원가입
  Future<UserModel> signUp({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      // 사용자명 중복 확인
      await _checkUsernameAvailability(username);

      // 이메일 중복 확인
      await _checkEmailAvailability(email);

      final user = UserModel(
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        provider: 'local',
        emailVerified: false, // 가입 시에는 미인증 상태
        phoneVerified: false,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(user.toSignUpJson(password)),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newUser = UserModel.fromJson(data['user']);

        // 토큰이 있다면 저장 (임시 토큰일 수 있음)
        if (data['token'] != null) {
          await _localStorage.saveData('auth_token', data['token']);
        }

        // 사용자 정보 저장
        await saveUserToStorage(newUser);

        // 이메일 인증 자동 전송
        try {
          await sendEmailVerification();
        } catch (e) {
          // 이메일 전송 실패해도 회원가입은 성공으로 처리
          print('이메일 인증 전송 실패: $e');
        }

        return newUser;
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('네트워크 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  /// 사용자명 중복 확인
  Future<void> _checkUsernameAvailability(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/check-username?username=$username'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exists'] == true) {
          throw TExceptions('이미 사용 중인 사용자명입니다.');
        }
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      // 네트워크 오류 등은 무시하고 진행
    }
  }

  /// 이메일 중복 확인
  Future<void> _checkEmailAvailability(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/check-email?email=$email'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exists'] == true) {
          throw TExceptions('이미 가입된 이메일 주소입니다.');
        }
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      // 네트워크 오류 등은 무시하고 진행
    }
  }

  /// 로그인
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(data['user']);

        // 토큰 저장
        if (data['token'] != null) {
          await _localStorage.saveData('auth_token', data['token']);
        }

        // 사용자 정보 저장
        await saveUserToStorage(user);

        return user;
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('네트워크 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  /// 구글 로그인
  Future<UserModel> signInWithGoogle({
    required String googleToken,
    String? username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'google_token': googleToken,
          if (username != null) 'username': username,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(data['user']);

        // 토큰 저장
        if (data['token'] != null) {
          await _localStorage.saveData('auth_token', data['token']);
        }

        // 사용자 정보 저장
        await saveUserToStorage(user);

        return user;
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('구글 로그인 중 오류가 발생했습니다.');
    }
  }

  /// 페이스북 로그인
  Future<UserModel> signInWithFacebook({
    required String facebookToken,
    String? username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/facebook'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'facebook_token': facebookToken,
          if (username != null) 'username': username,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(data['user']);

        // 토큰 저장
        if (data['token'] != null) {
          await _localStorage.saveData('auth_token', data['token']);
        }

        // 사용자 정보 저장
        await saveUserToStorage(user);

        return user;
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('페이스북 로그인 중 오류가 발생했습니다.');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token != null) {
        // 서버에 로그아웃 요청
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      }

      // 로컬 저장소에서 사용자 정보 제거
      await removeUserFromStorage();
    } catch (e) {
      // 에러가 발생해도 로컬 정보는 삭제
      await removeUserFromStorage();
      throw TExceptions('로그아웃 중 오류가 발생했습니다.');
    }
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/password-reset'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('네트워크 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  /// 이메일 인증 전송
  Future<void> sendEmailVerification() async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-email'),
        headers: {
          'Content-Type': 'application/json',
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
      throw TExceptions('네트워크 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  /// 현재 사용자 정보 가져오기
  Future<UserModel> getCurrentUser() async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(data['user']);
        await saveUserToStorage(user);
        return user;
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('사용자 정보를 가져오는 중 오류가 발생했습니다.');
    }
  }

  /// 사용자 정보 업데이트
  Future<UserModel> updateUser(Map<String, dynamic> userData) async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/auth/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(userData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final updatedUser = UserModel.fromJson(data['user']);
        await saveUserToStorage(updatedUser);
        return updatedUser;
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('네트워크 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  /// 이메일 인증 확인
  Future<void> verifyEmail(String verificationCode) async {
    try {
      final token = _localStorage.readData<String>('auth_token');

      if (token == null) {
        throw TExceptions('로그인이 필요합니다.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-email-confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({'verification_code': verificationCode}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // 사용자 정보 업데이트
        final updatedUser = currentUser.copyWith(emailVerified: true);
        await saveUserToStorage(updatedUser);
      } else {
        throw TExceptions(_parseErrorMessage(data));
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('이메일 인증 중 오류가 발생했습니다.');
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

  /// 로그인 상태 확인
  bool get isLoggedIn => currentUser.isNotEmpty;

  /// 토큰 가져오기
  String? get authToken => _localStorage.readData<String>('auth_token');

}