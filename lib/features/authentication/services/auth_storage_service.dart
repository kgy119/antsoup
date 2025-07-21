import 'package:get/get.dart';
import '../../../utils/local_storage/storage_utility.dart';
import '../models/user_model.dart';

/// 인증 정보 영구 저장 서비스 (Firestore용으로 수정)
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

      // 사용자 정보 저장 (Firestore UID 기반)
      await _localStorage.saveData(_currentUserKey, user.toJson());

      // 인증 제공자 저장
      await _localStorage.saveData(_authProviderKey, provider.name);

      // 로그인 시간 저장
      await _localStorage.saveData(_loginTimestampKey, DateTime.now().millisecondsSinceEpoch);

      // 마지막 활동 시간 저장
      await _localStorage.saveData(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);

      print('로그인 정보 저장 완료 (UID: ${user.uid})');
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

      // UID가 있는지 확인 (Firestore 문서 ID)
      return userData != null &&
          userData.isNotEmpty &&
          userData['uid'] != null &&
          userData['uid'].toString().isNotEmpty;
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

      // UserModel.fromJson으로 복원
      return UserModel.fromJson(userData);
    } catch (e) {
      print('저장된 사용자 정보 로드 실패: $e');
      return null;
    }
  }

  /// 저장된 UID 가져오기
  String? getSavedUID() {
    try {
      final userData = _localStorage.readData<Map<String, dynamic>>(_currentUserKey);
      return userData?['uid'];
    } catch (e) {
      print('저장된 UID 로드 실패: $e');
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

      print('사용자 정보 업데이트 완료 (UID: ${updatedUser.uid})');
    } catch (e) {
      print('사용자 정보 업데이트 실패: $e');
    }
  }

  /// 특정 사용자 필드 업데이트
  Future<void> updateUserField(String fieldName, dynamic value) async {
    try {
      final userData = _localStorage.readData<Map<String, dynamic>>(_currentUserKey);

      if (userData != null) {
        userData[fieldName] = value;
        userData['updated_at'] = DateTime.now().toIso8601String();

        await _localStorage.saveData(_currentUserKey, userData);
        await updateLastActive();

        print('사용자 필드 업데이트 완료: $fieldName');
      }
    } catch (e) {
      print('사용자 필드 업데이트 실패: $e');
    }
  }

  /// FCM 토큰 업데이트
  Future<void> updateFCMToken(String fcmToken) async {
    try {
      await updateUserField('fcm_token', fcmToken);
      print('FCM 토큰 업데이트 완료');
    } catch (e) {
      print('FCM 토큰 업데이트 실패: $e');
    }
  }

  /// 푸시 알림 설정 업데이트
  Future<void> updatePushNotificationSettings(bool enabled) async {
    try {
      await updateUserField('push_notifications', enabled);
      print('푸시 알림 설정 업데이트 완료: $enabled');
    } catch (e) {
      print('푸시 알림 설정 업데이트 실패: $e');
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

  /// 사용자가 신규 가입자인지 확인
  bool isNewUser() {
    try {
      final loginTime = getLoginTime();
      if (loginTime == null) return false;

      // 로그인한 지 24시간 이내면 신규 사용자로 간주
      final now = DateTime.now();
      final timeSinceLogin = now.difference(loginTime);

      return timeSinceLogin.inHours < 24;
    } catch (e) {
      print('신규 사용자 확인 실패: $e');
      return false;
    }
  }

  /// 로그인 유지 시간 계산
  Duration getLoginDuration() {
    try {
      final loginTime = getLoginTime();
      if (loginTime == null) return Duration.zero;

      return DateTime.now().difference(loginTime);
    } catch (e) {
      print('로그인 유지 시간 계산 실패: $e');
      return Duration.zero;
    }
  }

  /// 저장된 데이터 크기 계산 (디버그용)
  Map<String, int> getStorageSizes() {
    try {
      final userData = _localStorage.readData<Map<String, dynamic>>(_currentUserKey);

      return {
        'user_data_size': userData?.toString().length ?? 0,
        'total_keys': 5, // 저장하는 키의 총 개수
      };
    } catch (e) {
      print('저장소 크기 계산 실패: $e');
      return {'user_data_size': 0, 'total_keys': 0};
    }
  }

  /// 디버그 정보 출력
  void printStorageInfo() {
    print('=== 인증 저장소 정보 (Firestore용) ===');
    print('로그인 상태: ${isLoggedIn()}');

    final savedUser = getSavedUser();
    print('사용자 UID: ${savedUser?.uid ?? 'None'}');
    print('사용자 이메일: ${savedUser?.email ?? 'None'}');
    print('사용자 이름: ${savedUser?.name ?? 'None'}');

    print('인증 제공자: ${getSavedAuthProvider()?.name ?? 'None'}');
    print('로그인 시간: ${getLoginTime()}');
    print('마지막 활동: ${getLastActive()}');
    print('세션 유효: ${isSessionValid()}');
    print('신규 사용자: ${isNewUser()}');
    print('로그인 유지 시간: ${getLoginDuration()}');

    final sizes = getStorageSizes();
    print('저장된 데이터 크기: ${sizes['user_data_size']}자');
    print('========================================');
  }
}