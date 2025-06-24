import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/user_repository.dart';
import '../../authentication/controllers/auth_controller.dart';
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

  // App Settings
  final RxBool geoLocationEnabled = false.obs;
  final RxBool safeModeEnabled = true.obs;
  final RxBool hdImageQualityEnabled = true.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool darkModeEnabled = false.obs;
  final RxString selectedLanguage = 'ko'.obs;
  final RxString selectedCurrency = 'KRW'.obs;

  // Privacy Settings
  final RxBool profilePublic = true.obs;
  final RxBool showOnlineStatus = true.obs;
  final RxBool allowMessageFromStrangers = false.obs;

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

  /// 설정 로드
  Future<void> loadSettings() async {
    try {
      isLoading.value = true;

      // 로컬 저장소에서 설정 로드
      _loadLocalSettings();

      // 서버에서 설정 로드
      final serverSettings = await _userRepository.getUserSettings();
      _applyServerSettings(serverSettings);

    } catch (e) {
      // 서버 설정 로드 실패 시 로컬 설정만 사용
      print('서버 설정 로드 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 로컬 설정 로드
  void _loadLocalSettings() {
    geoLocationEnabled.value = _localStorage.readData('geoLocationEnabled') ?? false;
    safeModeEnabled.value = _localStorage.readData('safeModeEnabled') ?? true;
    hdImageQualityEnabled.value = _localStorage.readData('hdImageQualityEnabled') ?? true;
    notificationsEnabled.value = _localStorage.readData('notificationsEnabled') ?? true;
    darkModeEnabled.value = _localStorage.readData('darkModeEnabled') ?? false;
    selectedLanguage.value = _localStorage.readData('selectedLanguage') ?? 'ko';
    selectedCurrency.value = _localStorage.readData('selectedCurrency') ?? 'KRW';

    profilePublic.value = _localStorage.readData('profilePublic') ?? true;
    showOnlineStatus.value = _localStorage.readData('showOnlineStatus') ?? true;
    allowMessageFromStrangers.value = _localStorage.readData('allowMessageFromStrangers') ?? false;

    emailNotifications.value = _localStorage.readData('emailNotifications') ?? true;
    pushNotifications.value = _localStorage.readData('pushNotifications') ?? true;
    orderNotifications.value = _localStorage.readData('orderNotifications') ?? true;
    promotionalNotifications.value = _localStorage.readData('promotionalNotifications') ?? false;
  }

  /// 서버 설정 적용
  void _applyServerSettings(Map<String, dynamic> settings) {
    if (settings['geo_location_enabled'] != null) {
      geoLocationEnabled.value = settings['geo_location_enabled'];
    }
    if (settings['safe_mode_enabled'] != null) {
      safeModeEnabled.value = settings['safe_mode_enabled'];
    }
    if (settings['hd_image_quality_enabled'] != null) {
      hdImageQualityEnabled.value = settings['hd_image_quality_enabled'];
    }
    if (settings['notifications_enabled'] != null) {
      notificationsEnabled.value = settings['notifications_enabled'];
    }
    if (settings['profile_public'] != null) {
      profilePublic.value = settings['profile_public'];
    }
    if (settings['show_online_status'] != null) {
      showOnlineStatus.value = settings['show_online_status'];
    }
    if (settings['allow_message_from_strangers'] != null) {
      allowMessageFromStrangers.value = settings['allow_message_from_strangers'];
    }
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

  /// 위치 정보 설정 토글
  Future<void> toggleGeoLocation(bool value) async {
    geoLocationEnabled.value = value;
    await _saveLocalSetting('geoLocationEnabled', value);
    await _saveServerSetting('geo_location_enabled', value);
  }

  /// 안전 모드 설정 토글
  Future<void> toggleSafeMode(bool value) async {
    safeModeEnabled.value = value;
    await _saveLocalSetting('safeModeEnabled', value);
    await _saveServerSetting('safe_mode_enabled', value);
  }

  /// HD 이미지 품질 설정 토글
  Future<void> toggleHdImageQuality(bool value) async {
    hdImageQualityEnabled.value = value;
    await _saveLocalSetting('hdImageQualityEnabled', value);
    await _saveServerSetting('hd_image_quality_enabled', value);
  }

  /// 알림 설정 토글
  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    await _saveLocalSetting('notificationsEnabled', value);
    await _saveServerSetting('notifications_enabled', value);
  }

  /// 다크 모드 설정 토글
  Future<void> toggleDarkMode(bool value) async {
    darkModeEnabled.value = value;
    await _saveLocalSetting('darkModeEnabled', value);
    // 다크 모드는 로컬 설정만 저장

    // 테마 변경 적용
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  /// 프로필 공개 설정 토글
  Future<void> toggleProfilePublic(bool value) async {
    profilePublic.value = value;
    await _saveLocalSetting('profilePublic', value);
    await _saveServerSetting('profile_public', value);
  }

  /// 온라인 상태 표시 설정 토글
  Future<void> toggleShowOnlineStatus(bool value) async {
    showOnlineStatus.value = value;
    await _saveLocalSetting('showOnlineStatus', value);
    await _saveServerSetting('show_online_status', value);
  }

  /// 낯선 사람 메시지 허용 설정 토글
  Future<void> toggleAllowMessageFromStrangers(bool value) async {
    allowMessageFromStrangers.value = value;
    await _saveLocalSetting('allowMessageFromStrangers', value);
    await _saveServerSetting('allow_message_from_strangers', value);
  }

  /// 이메일 알림 설정 토글
  Future<void> toggleEmailNotifications(bool value) async {
    emailNotifications.value = value;
    await _saveLocalSetting('emailNotifications', value);
    await _saveServerSetting('email_notifications', value);
  }

  /// 푸시 알림 설정 토글
  Future<void> togglePushNotifications(bool value) async {
    pushNotifications.value = value;
    await _saveLocalSetting('pushNotifications', value);
    await _saveServerSetting('push_notifications', value);
  }

  /// 주문 알림 설정 토글
  Future<void> toggleOrderNotifications(bool value) async {
    orderNotifications.value = value;
    await _saveLocalSetting('orderNotifications', value);
    await _saveServerSetting('order_notifications', value);
  }

  /// 프로모션 알림 설정 토글
  Future<void> togglePromotionalNotifications(bool value) async {
    promotionalNotifications.value = value;
    await _saveLocalSetting('promotionalNotifications', value);
    await _saveServerSetting('promotional_notifications', value);
  }

  /// 언어 변경
  Future<void> changeLanguage(String languageCode) async {
    selectedLanguage.value = languageCode;
    await _saveLocalSetting('selectedLanguage', languageCode);

    // 앱 언어 변경
    Locale locale;
    switch (languageCode) {
      case 'en':
        locale = const Locale('en', 'US');
        break;
      case 'ko':
        locale = const Locale('ko', 'KR');
        break;
      case 'ja':
        locale = const Locale('ja', 'JP');
        break;
      default:
        locale = const Locale('ko', 'KR');
    }

    Get.updateLocale(locale);

    TLoaders.successSnacBar(
      title: '언어 변경',
      message: '언어가 변경되었습니다.',
    );
  }

  /// 통화 변경
  Future<void> changeCurrency(String currencyCode) async {
    selectedCurrency.value = currencyCode;
    await _saveLocalSetting('selectedCurrency', currencyCode);

    TLoaders.successSnacBar(
      title: '통화 변경',
      message: '통화가 $currencyCode(으)로 변경되었습니다.',
    );
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

  /// 데이터 업로드 (백업)
  Future<void> uploadDataToCloud() async {
    try {
      isLoading.value = true;

      // 현재 설정들을 서버에 백업
      final allSettings = {
        'geo_location_enabled': geoLocationEnabled.value,
        'safe_mode_enabled': safeModeEnabled.value,
        'hd_image_quality_enabled': hdImageQualityEnabled.value,
        'notifications_enabled': notificationsEnabled.value,
        'profile_public': profilePublic.value,
        'show_online_status': showOnlineStatus.value,
        'allow_message_from_strangers': allowMessageFromStrangers.value,
        'email_notifications': emailNotifications.value,
        'push_notifications': pushNotifications.value,
        'order_notifications': orderNotifications.value,
        'promotional_notifications': promotionalNotifications.value,
      };

      await _userRepository.updateUserSettings(allSettings);

      TLoaders.successSnacBar(
        title: '데이터 업로드 완료',
        message: '설정 데이터가 클라우드에 성공적으로 업로드되었습니다.',
      );

    } catch (e) {
      String errorMessage = '데이터 업로드 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '데이터 업로드 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
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

  /// 설정 초기화
  Future<void> resetSettings() async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('설정 초기화'),
          content: const Text('모든 설정을 기본값으로 초기화하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('초기화'),
            ),
          ],
        ),
      );

      if (result == true) {
        // 기본값으로 초기화
        geoLocationEnabled.value = false;
        safeModeEnabled.value = true;
        hdImageQualityEnabled.value = true;
        notificationsEnabled.value = true;
        darkModeEnabled.value = false;
        selectedLanguage.value = 'ko';
        selectedCurrency.value = 'KRW';

        profilePublic.value = true;
        showOnlineStatus.value = true;
        allowMessageFromStrangers.value = false;

        emailNotifications.value = true;
        pushNotifications.value = true;
        orderNotifications.value = true;
        promotionalNotifications.value = false;

        // 로컬 저장소 초기화
        await _localStorage.clearAll();

        TLoaders.successSnacBar(
          title: '설정 초기화 완료',
          message: '모든 설정이 기본값으로 초기화되었습니다.',
        );
      }
    } catch (e) {
      TLoaders.errorSnacBar(
        title: '설정 초기화 실패',
        message: '설정 초기화 중 오류가 발생했습니다.',
      );
    }
  }

  /// 사용 가능한 언어 목록
  List<Map<String, String>> get availableLanguages => [
    {'code': 'ko', 'name': '한국어'},
    {'code': 'en', 'name': 'English'},
    {'code': 'ja', 'name': '日本語'},
  ];

  /// 사용 가능한 통화 목록
  List<Map<String, String>> get availableCurrencies => [
    {'code': 'KRW', 'name': '원 (₩)'},
    {'code': 'USD', 'name': '달러 (\$)'},
    {'code': 'EUR', 'name': '유로 (€)'},
    {'code': 'JPY', 'name': '엔 (¥)'},
  ];

  /// 현재 언어 이름
  String get currentLanguageName {
    final lang = availableLanguages.firstWhere(
          (lang) => lang['code'] == selectedLanguage.value,
      orElse: () => {'name': '한국어'},
    );
    return lang['name']!;
  }

  /// 현재 통화 이름
  String get currentCurrencyName {
    final currency = availableCurrencies.firstWhere(
          (curr) => curr['code'] == selectedCurrency.value,
      orElse: () => {'name': '원 (₩)'},
    );
    return currency['name']!;
  }
}