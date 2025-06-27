import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../features/authentication/controllers/auth_controller.dart';
import '../../features/authentication/services/auth_storage_service.dart';

/// 앱 생명주기를 관리하여 사용자 활동 시간을 추적
class AppLifecycleHandler extends WidgetsBindingObserver {
  static AppLifecycleHandler? _instance;
  static AppLifecycleHandler get instance => _instance ??= AppLifecycleHandler._();

  AppLifecycleHandler._();

  bool _isInitialized = false;

  /// 생명주기 관찰자 초기화
  void initialize() {
    if (!_isInitialized) {
      WidgetsBinding.instance.addObserver(this);
      _isInitialized = true;
      print('앱 생명주기 관찰자 초기화됨');
    }
  }

  /// 생명주기 관찰자 해제
  void dispose() {
    if (_isInitialized) {
      WidgetsBinding.instance.removeObserver(this);
      _isInitialized = false;
      print('앱 생명주기 관찰자 해제됨');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print('앱 상태 변경: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        _onAppHidden();
        break;
    }
  }

  /// 앱이 활성화될 때 (포그라운드로 돌아올 때)
  void _onAppResumed() {
    print('앱 활성화됨');
    _updateUserActivity();
    _validateSession();
  }

  /// 앱이 일시정지될 때 (백그라운드로 갈 때)
  void _onAppPaused() {
    print('앱 일시정지됨');
    _updateUserActivity();
  }

  /// 앱이 비활성화될 때
  void _onAppInactive() {
    print('앱 비활성화됨');
    _updateUserActivity();
  }

  /// 앱이 숨겨질 때
  void _onAppHidden() {
    print('앱 숨겨짐');
    _updateUserActivity();
  }

  /// 앱이 완전히 종료될 때
  void _onAppDetached() {
    print('앱 종료됨');
    _updateUserActivity();
  }

  /// 사용자 활동 시간 업데이트
  void _updateUserActivity() {
    try {
      final authController = Get.find<AuthController>();
      final authStorage = Get.find<AuthStorageService>();

      if (authController.isLoggedIn) {
        authStorage.updateLastActive();
        print('사용자 활동 시간 업데이트됨');
      }
    } catch (e) {
      print('사용자 활동 시간 업데이트 실패: $e');
    }
  }

  /// 세션 유효성 검증
  void _validateSession() {
    try {
      final authController = Get.find<AuthController>();
      final authStorage = Get.find<AuthStorageService>();

      if (authController.currentUser.value != null) {
        // 세션이 유효한지 확인
        if (!authStorage.isSessionValid()) {
          print('세션이 만료됨 - 자동 로그아웃');
          authController.signOut();
        } else {
          print('세션 유효성 확인됨');
        }
      }
    } catch (e) {
      print('세션 유효성 검증 실패: $e');
    }
  }
}