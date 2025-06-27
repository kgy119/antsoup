// lib/features/authentication/controllers/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../navigation_menu.dart';
import '../../../utils/loader/loaders.dart';
import '../models/user_model.dart';
import '../screens/login/login.dart';
import '../services/google_auth_service.dart';
import '../services/auth_storage_service.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final _googleAuthService = GoogleAuthService.instance;
  final _authStorage = AuthStorageService.instance;

  // 현재 사용자 상태
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  @override
  void onReady() {
    super.onReady();
    // 앱이 완전히 로드된 후 활동 시간 업데이트
    _updateLastActive();
  }

  /// 앱 시작 시 인증 상태 초기화
  void _initializeAuth() async {
    try {
      print('=== 인증 상태 초기화 시작 ===');

      // 1. 저장된 로그인 상태 확인
      final savedUser = _authStorage.getSavedUser();
      final isSessionValid = _authStorage.isSessionValid();

      print('저장된 사용자: ${savedUser?.email}');
      print('세션 유효성: $isSessionValid');

      if (savedUser != null && isSessionValid) {
        // 저장된 사용자 정보로 상태 복원
        currentUser.value = savedUser;
        print('저장된 로그인 상태 복원됨');

        // Firebase 인증 상태도 확인
        _checkFirebaseAuthState();
      } else {
        // 세션이 유효하지 않으면 정리
        if (savedUser != null && !isSessionValid) {
          await _authStorage.clearLoginState();
          print('만료된 세션 정리됨');
        }
      }

      // 2. Firebase 인증 상태 변화 감지 설정
      _googleAuthService.authStateChanges.listen(_handleAuthStateChange);

      isInitialized.value = true;
      print('=== 인증 상태 초기화 완료 ===');

    } catch (e) {
      print('인증 초기화 에러: $e');
      isInitialized.value = true;
    }
  }

  /// Firebase 인증 상태 변화 처리
  void _handleAuthStateChange(User? firebaseUser) async {
    try {
      if (firebaseUser != null) {
        // Firebase 사용자가 있는 경우
        final userModel = _googleAuthService.getCurrentUserModel();

        if (userModel != null) {
          currentUser.value = userModel;

          // 새로운 로그인이면 저장
          if (_authStorage.getSavedUser()?.uid != userModel.uid) {
            await _authStorage.saveLoginState(
              user: userModel,
              provider: SocialAuthProvider.google,
            );
            print('새로운 로그인 정보 저장됨');
          } else {
            // 기존 사용자면 활동 시간만 업데이트
            await _authStorage.updateLastActive();
          }
        }
      } else {
        // Firebase 사용자가 없는 경우
        // 저장된 사용자 정보가 있다면 유지 (앱 재시작 시 Firebase 복원 전까지)
        if (currentUser.value == null) {
          await _authStorage.clearLoginState();
        }
      }
    } catch (e) {
      print('인증 상태 변화 처리 에러: $e');
    }
  }

  /// Firebase 인증 상태 확인 및 복원
  void _checkFirebaseAuthState() async {
    try {
      final firebaseUser = _googleAuthService.currentUser;
      final savedUser = currentUser.value;

      if (firebaseUser == null && savedUser != null) {
        // Firebase 세션이 없지만 저장된 사용자가 있는 경우
        // Silent 로그인 시도 (Google Sign-In이 자동으로 처리)
        print('Firebase 세션 복원 시도...');

        // Google Sign-In의 자동 로그인 시도는 백그라운드에서 처리됨
        // 여기서는 저장된 상태를 유지
      }
    } catch (e) {
      print('Firebase 상태 확인 에러: $e');
    }
  }

  /// Google 로그인
  Future<void> signInWithGoogle() async {
    if (isLoading.value) {
      print('이미 로그인 진행 중입니다.');
      return;
    }

    try {
      isLoading.value = true;
      print('Google 로그인 시작...');

      // Google 로그인 실행
      final userCredential = await _googleAuthService.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        final userModel = _googleAuthService.getCurrentUserModel();

        if (userModel != null) {
          // 사용자 상태 업데이트
          currentUser.value = userModel;

          // 로그인 정보 영구 저장
          await _authStorage.saveLoginState(
            user: userModel,
            provider: SocialAuthProvider.google,
          );

          print('Google 로그인 및 저장 완료!');

          TLoaders.successSnacBar(
            title: '로그인 성공!',
            message: '환영합니다, ${userModel.name}님!',
          );

          // 메인 화면으로 이동
          await Future.delayed(const Duration(milliseconds: 500));
          Get.offAll(() => const NavigationMenu());
        }
      } else {
        print('Google 로그인이 취소되었습니다.');
        TLoaders.customToast(message: '로그인이 취소되었습니다.');
      }
    } catch (e) {
      print('Google 로그인 에러: $e');

      String errorMessage = '로그인 중 오류가 발생했습니다.';
      if (e.toString().contains('network')) {
        errorMessage = '네트워크 연결을 확인해주세요.';
      } else if (e.toString().contains('cancel')) {
        errorMessage = '로그인이 취소되었습니다.';
      }

      TLoaders.errorSnacBar(
        title: '로그인 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      print('로그아웃 시작...');

      // Firebase 및 Google Sign-In 로그아웃
      await _googleAuthService.signOut();

      // 저장된 로그인 정보 삭제
      await _authStorage.clearLoginState();

      // 상태 초기화
      currentUser.value = null;

      print('로그아웃 완료');

      TLoaders.successSnacBar(
        title: '로그아웃',
        message: '성공적으로 로그아웃되었습니다.',
      );

      // 로그인 화면으로 이동
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      print('로그아웃 에러: $e');
      TLoaders.errorSnacBar(
        title: '로그아웃 실패',
        message: '로그아웃 중 오류가 발생했습니다.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 계정 삭제
  Future<void> deleteAccount() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      print('계정 삭제 시작...');

      // 재인증
      await _googleAuthService.reauthenticate();

      // Firebase 계정 삭제
      await _googleAuthService.deleteAccount();

      // 저장된 모든 정보 삭제
      await _authStorage.clearLoginState();

      // 상태 초기화
      currentUser.value = null;

      print('계정 삭제 완료');

      TLoaders.successSnacBar(
        title: '계정 삭제',
        message: '계정이 성공적으로 삭제되었습니다.',
      );

      // 로그인 화면으로 이동
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      print('계정 삭제 에러: $e');
      TLoaders.errorSnacBar(
        title: '계정 삭제 실패',
        message: '계정 삭제 중 오류가 발생했습니다.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 마지막 활동 시간 업데이트
  void _updateLastActive() async {
    try {
      if (isLoggedIn) {
        await _authStorage.updateLastActive();
      }
    } catch (e) {
      print('활동 시간 업데이트 에러: $e');
    }
  }

  /// 사용자 정보 업데이트
  Future<void> updateUserInfo(UserModel updatedUser) async {
    try {
      currentUser.value = updatedUser;
      await _authStorage.updateUserInfo(updatedUser);
      print('사용자 정보 업데이트 완료');
    } catch (e) {
      print('사용자 정보 업데이트 에러: $e');
    }
  }

  /// 로그인 상태 확인
  bool get isLoggedIn {
    return currentUser.value != null &&
        _authStorage.isLoggedIn() &&
        _authStorage.isSessionValid();
  }

  /// 저장소 정보 디버그 출력
  void debugStorageInfo() {
    _authStorage.printStorageInfo();
  }
}