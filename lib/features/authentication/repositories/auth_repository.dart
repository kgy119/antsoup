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
      final user = UserModel(
        username: username,
        email: email,
        phoneNumber: phoneNumber,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toSignUpJson(password)),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newUser = UserModel.fromJson(data['user']);

        // 토큰이 있다면 저장
        if (data['token'] != null) {
          await _localStorage.saveData('auth_token', data['token']);
        }

        // 사용자 정보 저장
        await saveUserToStorage(newUser);

        return newUser;
      } else {
        throw TExceptions(data['message'] ?? '회원가입에 실패했습니다.');
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('네트워크 오류가 발생했습니다. 다시 시도해주세요.');
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
        headers: {'Content-Type': 'application/json'},
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
        throw TExceptions(data['message'] ?? '로그인에 실패했습니다.');
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
        headers: {'Content-Type': 'application/json'},
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
        throw TExceptions(data['message'] ?? '구글 로그인에 실패했습니다.');
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
        headers: {'Content-Type': 'application/json'},
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
        throw TExceptions(data['message'] ?? '페이스북 로그인에 실패했습니다.');
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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw TExceptions(data['message'] ?? '비밀번호 재설정 이메일 전송에 실패했습니다.');
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
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw TExceptions(data['message'] ?? '이메일 인증 전송에 실패했습니다.');
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('네트워크 오류가 발생했습니다. 다시 시도해주세요.');
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
        },
        body: jsonEncode(userData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final updatedUser = UserModel.fromJson(data['user']);
        await saveUserToStorage(updatedUser);
        return updatedUser;
      } else {
        throw TExceptions(data['message'] ?? '사용자 정보 업데이트에 실패했습니다.');
      }
    } catch (e) {
      if (e is TExceptions) rethrow;
      throw TExceptions('네트워크 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  /// 로그인 상태 확인
  bool get isLoggedIn => currentUser.isNotEmpty;

  /// 토큰 가져오기
  String? get authToken => _localStorage.readData<String>('auth_token');
}