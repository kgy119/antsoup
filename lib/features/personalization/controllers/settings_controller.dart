import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/user_repository.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/loader/loaders.dart';
import '../../../utils/local_storage/storage_utility.dart';

class SettingsController extends GetxController {
  static SettingsController get instance => Get.find();

  // Repository & Controllers
  final _userRepository = Get.put(UserRepository());
  final _authController = AuthenticationController.instance;
  final _localStorage = TLocalStorage();

  // Loading States
  final RxBool isLoading = false.obs;

  // Notification Settings
  final RxBool emailNotifications = true.obs;
  final RxBool pushNotifications = true.obs;
  final RxBool orderNotifications = true.obs;
  final RxBool promotionalNotifications = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  /// UserController 안전하게 가져오기
  UserController? get _userController {
    try {
      return Get.find<UserController>();
    } catch (e) {
      // UserController가 없으면 null 반환
      return null;
    }
  }

  /// 설정 로드
  Future<void> loadSettings() async {
    try {
      isLoading.value = true;

      // 로컬 저장소에서 설정 로드
      _loadLocalSettings();

      // 로그인된 사용자가 있는 경우에만 서버에서 설정 로드
      if (_authController.isLoggedIn) {
        try {
          final serverSettings = await _userRepository.getUserSettings();
          _applyServerSettings(serverSettings);
        } catch (e) {
          // 서버 설정 로드 실패 시 로컬 설정만 사용
          print('서버 설정 로드 실패: $e');
        }
      }

    } catch (e) {
      print('설정 로드 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 로컬 설정 로드
  void _loadLocalSettings() {
    emailNotifications.value = _localStorage.readData('emailNotifications') ?? true;
    pushNotifications.value = _localStorage.readData('pushNotifications') ?? true;
    orderNotifications.value = _localStorage.readData('orderNotifications') ?? true;
    promotionalNotifications.value = _localStorage.readData('promotionalNotifications') ?? false;
  }

  /// 서버 설정 적용
  void _applyServerSettings(Map<String, dynamic> settings) {
    if (settings['email_notifications'] != null) {
      emailNotifications.value = settings['email_notifications'];
    }
    if (settings['push_notifications'] != null) {
      pushNotifications.value = settings['push_notifications'];
    }
    if (settings['order_notifications'] != null) {
      orderNotifications.value = settings['order_notifications'];
    }
    if (settings['promotional_notifications'] != null) {
      promotionalNotifications.value = settings['promotional_notifications'];
    }
  }

  /// 이메일 알림 설정 토글
  Future<void> toggleEmailNotifications(bool value) async {
    emailNotifications.value = value;
    await _saveLocalSetting('emailNotifications', value);

    // 로그인된 사용자의 경우 서버에도 저장
    if (_authController.isLoggedIn) {
      await _saveServerSetting('email_notifications', value);
    }
  }

  /// 푸시 알림 설정 토글
  Future<void> togglePushNotifications(bool value) async {
    pushNotifications.value = value;
    await _saveLocalSetting('pushNotifications', value);

    // 로그인된 사용자의 경우 서버에도 저장
    if (_authController.isLoggedIn) {
      await _saveServerSetting('push_notifications', value);
    }
  }

  /// 주문 알림 설정 토글
  Future<void> toggleOrderNotifications(bool value) async {
    orderNotifications.value = value;
    await _saveLocalSetting('orderNotifications', value);

    // 로그인된 사용자의 경우 서버에도 저장
    if (_authController.isLoggedIn) {
      await _saveServerSetting('order_notifications', value);
    }
  }

  /// 프로모션 알림 설정 토글
  Future<void> togglePromotionalNotifications(bool value) async {
    promotionalNotifications.value = value;
    await _saveLocalSetting('promotionalNotifications', value);

    // 로그인된 사용자의 경우 서버에도 저장
    if (_authController.isLoggedIn) {
      await _saveServerSetting('promotional_notifications', value);
    }
  }

  /// 로컬 설정 저장
  Future<void> _saveLocalSetting(String key, dynamic value) async {
    try {
      await _localStorage.saveData(key, value);
    } catch (e) {
      print('로컬 설정 저장 실패: $e');
    }
  }

  /// 서버 설정 저장
  Future<void> _saveServerSetting(String key, dynamic value) async {
    try {
      await _userRepository.updateUserSettings({key: value});
    } catch (e) {
      print('서버 설정 저장 실패: $e');
      // 서버 저장 실패해도 로컬은 유지
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      // 확인 다이얼로그
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('로그아웃'),
            ),
          ],
        ),
      );

      if (result == true) {
        await _authController.signOut();
      }
    } catch (e) {
      TLoaders.errorSnacBar(
        title: '로그아웃 실패',
        message: '로그아웃 중 오류가 발생했습니다.',
      );
    }
  }

  /// 계정 삭제 확인
  Future<void> showDeleteAccountDialog() async {
    final TextEditingController passwordController = TextEditingController();

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('계정 삭제', style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '정말로 계정을 삭제하시겠습니까?\n\n'
                  '이 작업은 되돌릴 수 없으며, 모든 데이터가 영구적으로 삭제됩니다.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호 확인',
                hintText: '계정 삭제를 위해 비밀번호를 입력해주세요',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                Get.back(result: true);
                _deleteAccount(passwordController.text);
              } else {
                TLoaders.warningSnacBar(
                  title: '비밀번호 필요',
                  message: '비밀번호를 입력해주세요.',
                );
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 계정 삭제 실행
  Future<void> _deleteAccount(String password) async {
    try {
      isLoading.value = true;

      await _userRepository.deleteAccount(password);

      TLoaders.successSnacBar(
        title: '계정 삭제 완료',
        message: '계정이 성공적으로 삭제되었습니다.',
      );

      // 로그아웃 처리
      await _authController.signOut();

    } catch (e) {
      String errorMessage = '계정 삭제 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '계정 삭제 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 현재 사용자 정보 가져오기 (UserController에서)
  get currentUser {
    final userController = _userController;
    if (userController != null) {
      return userController.userProfile;
    }
    // UserController가 없으면 AuthController에서 직접 가져오기
    return _authController.currentUser;
  }

  /// 로그인 상태 확인
  bool get isLoggedIn => _authController.isLoggedIn;
}