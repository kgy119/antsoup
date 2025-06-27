import 'package:get/get.dart';
import '../../../utils/local_storage/storage_utility.dart';
import '../models/user_model.dart';

/// 인증 정보 영구 저장 서비스
class AuthStorageService extends GetxService {
  static AuthStorageService get instance => Get.find();

  final _localStorage = TLocalStorage();

  // Storage Keys
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _currentUserKey = 'current_user';
  static const String _authProviderKey = 'auth_provider';
  static const String _loginTimestampKey = 'login_timestamp';
  static const String _lastActiveKey = 'last_active';

  /// 로그인 정보 저장
  Future<void> saveLoginState({
    required UserModel user,
    required SocialAuthProvider provider,
  }) async {
    try {
      // 로그인 상태 저장
      await _localStorage.saveData(_isLoggedInKey, true);

      // 사용자 정보 저장
      await _localStorage.saveData(_currentUserKey, user.toJson());

      // 인증 제공자 저장
      await _localStorage.saveData(_authProviderKey, provider.name);

      // 로그인 시간 저장
      await _localStorage.saveData(_loginTimestampKey, DateTime.now().millisecondsSinceEpoch);

      // 마지막 활동 시간 저장
      await _localStorage.saveData(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);

      print('로그인 정보 저장 완료');
    } catch (e) {
      print('로그인 정보 저장 실패: $e');
    }
  }

  /// 로그인 상태 확인
  bool isLoggedIn() {
    try {
      final isLoggedIn = _localStorage.readData<bool>(_isLoggedInKey) ?? false;

      if (!isLoggedIn) return false;

      // 추가 검증: 사용자 정보가 존재하는지 확인
      final userData = _localStorage.readData<Map<String, dynamic>>(_currentUserKey);

      return userData != null && userData.isNotEmpty;
    } catch (e) {
      print('로그인 상태 확인 실패: $e');
      return false;
    }
  }

  /// 저장된 사용자 정보 가져오기
  UserModel? getSavedUser() {
    try {
      if (!isLoggedIn()) return null;

      final userData = _localStorage.readData<Map<String, dynamic>>(_currentUserKey);

      if (userData == null) return null;

      return UserModel.fromJson(userData);
    } catch (e) {
      print('저장된 사용자 정보 로드 실패: $e');
      return null;
    }
  }

  /// 저장된 인증 제공자 가져오기
  SocialAuthProvider? getSavedAuthProvider() {
    try {
      final providerName = _localStorage.readData<String>(_authProviderKey);

      if (providerName == null) return null;

      return SocialAuthProvider.values.firstWhere(
            (provider) => provider.name == providerName,
        orElse: () => SocialAuthProvider.google,
      );
    } catch (e) {
      print('저장된 인증 제공자 로드 실패: $e');
      return null;
    }
  }

  /// 로그인 시간 가져오기
  DateTime? getLoginTime() {
    try {
      final timestamp = _localStorage.readData<int>(_loginTimestampKey);

      if (timestamp == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      print('로그인 시간 로드 실패: $e');
      return null;
    }
  }

  /// 마지막 활동 시간 업데이트
  Future<void> updateLastActive() async {
    try {
      await _localStorage.saveData(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('마지막 활동 시간 업데이트 실패: $e');
    }
  }

  /// 마지막 활동 시간 가져오기
  DateTime? getLastActive() {
    try {
      final timestamp = _localStorage.readData<int>(_lastActiveKey);

      if (timestamp == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      print('마지막 활동 시간 로드 실패: $e');
      return null;
    }
  }

  /// 사용자 정보 업데이트 (프로필 수정 등)
  Future<void> updateUserInfo(UserModel updatedUser) async {
    try {
      await _localStorage.saveData(_currentUserKey, updatedUser.toJson());
      await updateLastActive();

      print('사용자 정보 업데이트 완료');
    } catch (e) {
      print('사용자 정보 업데이트 실패: $e');
    }
  }

  /// 로그인 정보 완전 삭제 (로그아웃 시)
  Future<void> clearLoginState() async {
    try {
      await _localStorage.removeData(_isLoggedInKey);
      await _localStorage.removeData(_currentUserKey);
      await _localStorage.removeData(_authProviderKey);
      await _localStorage.removeData(_loginTimestampKey);
      await _localStorage.removeData(_lastActiveKey);

      print('로그인 정보 삭제 완료');
    } catch (e) {
      print('로그인 정보 삭제 실패: $e');
    }
  }

  /// 세션 유효성 검사 (선택적 - 보안이 중요한 경우)
  bool isSessionValid({Duration? maxInactivity}) {
    try {
      if (!isLoggedIn()) return false;

      // 최대 비활성 시간 체크 (기본: 30일)
      maxInactivity ??= const Duration(days: 30);

      final lastActive = getLastActive();
      if (lastActive == null) return false;

      final now = DateTime.now();
      final timeSinceLastActive = now.difference(lastActive);

      if (timeSinceLastActive > maxInactivity) {
        print('세션 만료됨: ${timeSinceLastActive.inDays}일 동안 비활성');
        return false;
      }

      return true;
    } catch (e) {
      print('세션 유효성 검사 실패: $e');
      return false;
    }
  }

  /// 디버그 정보 출력
  void printStorageInfo() {
    print('=== 인증 저장소 정보 ===');
    print('로그인 상태: ${isLoggedIn()}');
    print('사용자 정보: ${getSavedUser()?.email ?? 'None'}');
    print('인증 제공자: ${getSavedAuthProvider()?.name ?? 'None'}');
    print('로그인 시간: ${getLoginTime()}');
    print('마지막 활동: ${getLastActive()}');
    print('세션 유효: ${isSessionValid()}');
    print('========================');
  }
}