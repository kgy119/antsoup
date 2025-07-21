import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../navigation_menu.dart';
import '../../../utils/loader/loaders.dart';
import '../../messaging/services/fcm_service.dart';
import '../models/user_model.dart';
import '../screens/login/login.dart';
import '../services/google_auth_service.dart';
import '../services/auth_storage_service.dart';
import '../services/firestore_user_service.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final _googleAuthService = GoogleAuthService.instance;
  final _authStorage = AuthStorageService.instance;
  final _firestoreUserService = FirestoreUserService.instance;

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
        print('저장된 로그인 상태 복원 시도...');

        // Firestore에서 최신 사용자 정보 확인
        try {
          final firestoreUser = await _firestoreUserService.getUser(savedUser.uid);

          if (firestoreUser != null) {
            // Firestore에서 최신 정보로 업데이트
            currentUser.value = firestoreUser;

            // 로컬 저장소도 최신 정보로 업데이트
            await _authStorage.updateUserInfo(firestoreUser);

            // FCM 서비스 초기화 (기존 로그인 복원 시)
            await _initializeFCMService();

            print('Firestore에서 최신 사용자 정보 복원됨');
          } else {
            // Firestore에 정보가 없으면 저장된 정보 사용
            currentUser.value = savedUser;
            print('저장된 사용자 정보로 복원됨');
          }
        } catch (e) {
          // Firestore 조회 실패 시 저장된 정보 사용
          print('Firestore 조회 실패, 저장된 정보 사용: $e');
          currentUser.value = savedUser;
        }

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
        print('Firebase 인증 상태 변화: 로그인됨 (${firebaseUser.uid})');

        // Firestore에서 사용자 정보 가져오기
        final userModel = await _firestoreUserService.getUser(firebaseUser.uid);

        if (userModel != null) {
          currentUser.value = userModel;

          // 새로운 로그인이면 저장
          final savedUID = _authStorage.getSavedUID();
          if (savedUID != userModel.uid) {
            await _authStorage.saveLoginState(
              user: userModel,
              provider: SocialAuthProvider.google,
            );
            print('새로운 로그인 정보 저장됨');
          } else {
            // 기존 사용자면 활동 시간만 업데이트
            await _authStorage.updateLastActive();
            await _firestoreUserService.updateLastLogin(userModel.uid);
          }
        } else {
          // Firestore에 정보가 없으면 Firebase Auth 정보로 생성
          print('Firestore에 사용자 정보 없음 - 생성 중...');
          final newUser = UserModel.fromSocialAuth(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? '',
            authProvider: SocialAuthProvider.google,
            profilePicture: firebaseUser.photoURL,
            phoneNumber: firebaseUser.phoneNumber,
          );

          await _firestoreUserService.createUser(newUser);
          currentUser.value = newUser;

          await _authStorage.saveLoginState(
            user: newUser,
            provider: SocialAuthProvider.google,
          );
        }
      } else {
        print('Firebase 인증 상태 변화: 로그아웃됨');
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
        print('Firebase 세션 복원 필요 - 저장된 상태 유지');
        // Google Sign-In의 자동 로그인 시도는 백그라운드에서 처리됨
      }
    } catch (e) {
      print('Firebase 상태 확인 에러: $e');
    }
  }

  /// Google 로그인
  signInWithGoogle() async {
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
        print('Google 로그인 성공, Firestore에서 사용자 정보 조회...');

        // Firestore에서 최신 사용자 정보 가져오기
        final userModel = await _firestoreUserService.getUser(userCredential.user!.uid);

        if (userModel != null) {
          // 사용자 상태 업데이트
          currentUser.value = userModel;

          // 로그인 정보 영구 저장
          await _authStorage.saveLoginState(
            user: userModel,
            provider: SocialAuthProvider.google,
          );

          // FCM 서비스 초기화 및 토큰 업데이트
          await _initializeFCMService();

          print('Google 로그인 및 Firestore 동기화 완료!');

          TLoaders.successSnacBar(
            title: '로그인 성공!',
            message: '환영합니다, ${userModel.name}님!',
          );

          // 메인 화면으로 이동
          await Future.delayed(const Duration(milliseconds: 500));
          Get.offAll(() => const NavigationMenu());
        } else {
          // Firestore에 사용자 정보가 없는 경우 (이미 Google Auth Service에서 생성됨)
          print('Firestore 사용자 정보 조회 실패 - 재시도...');

          // 잠시 후 다시 시도
          await Future.delayed(const Duration(milliseconds: 1000));
          final retryUser = await _firestoreUserService.getUser(userCredential.user!.uid);

          if (retryUser != null) {
            currentUser.value = retryUser;
            await _authStorage.saveLoginState(
              user: retryUser,
              provider: SocialAuthProvider.google,
            );

            // FCM 서비스 초기화 및 토큰 업데이트
            await _initializeFCMService();

            TLoaders.successSnacBar(
              title: '로그인 성공!',
              message: '환영합니다, ${retryUser.name}님!',
            );

            Get.offAll(() => const NavigationMenu());
          } else {
            throw Exception('Firestore 사용자 정보 생성 실패');
          }
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
      } else if (e.toString().contains('Firestore')) {
        errorMessage = '사용자 정보 저장 중 오류가 발생했습니다.';
      }

      TLoaders.errorSnacBar(
        title: '로그인 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// FCM 서비스 초기화 (로그인 후 호출)
  Future<void> _initializeFCMService() async {
    try {
      print('FCM 서비스 연동 시작...');

      // FCM 서비스가 등록되어 있는지 확인
      if (Get.isRegistered<FCMService>()) {
        final fcmService = Get.find<FCMService>();

        // FCM 토큰이 있으면 사용자 정보에 업데이트
        if (fcmService.fcmToken.value.isNotEmpty) {
          await updateFCMToken(fcmService.fcmToken.value);
          print('기존 FCM 토큰 업데이트 완료');
        } else {
          // FCM 토큰이 없으면 잠시 후 다시 시도
          await Future.delayed(const Duration(milliseconds: 2000));
          if (fcmService.fcmToken.value.isNotEmpty) {
            await updateFCMToken(fcmService.fcmToken.value);
            print('지연된 FCM 토큰 업데이트 완료');
          }
        }

        // 기본 토픽들 구독 (선택사항)
        await _subscribeToDefaultTopics(fcmService);

      } else {
        print('FCM 서비스가 등록되지 않음');
      }

      print('FCM 서비스 연동 완료');
    } catch (e) {
      print('FCM 서비스 연동 실패: $e');
      // FCM 연동 실패는 로그인 자체를 막지 않음
    }
  }

  /// 기본 토픽 구독
  Future<void> _subscribeToDefaultTopics(FCMService fcmService) async {
    try {
      // 모든 사용자용 공지사항 토픽
      await fcmService.subscribeToTopic('announcements');

      // 주식 관련 알림 토픽 (사용자가 관심있는 경우)
      await fcmService.subscribeToTopic('stock_alerts');

      print('기본 토픽 구독 완료');
    } catch (e) {
      print('기본 토픽 구독 실패: $e');
    }
  }



  /// 로그아웃
  Future<void> signOut() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      print('로그아웃 시작...');

      // 현재 사용자 UID 저장 (로그아웃 전 Firestore 업데이트용)
      final currentUID = currentUser.value?.uid;

      // Firebase 및 Google Sign-In 로그아웃
      await _googleAuthService.signOut();

      // Firestore에 마지막 활동 시간 업데이트 (선택사항)
      if (currentUID != null) {
        try {
          await _firestoreUserService.updateLastLogin(currentUID);
        } catch (e) {
          print('로그아웃 시 Firestore 업데이트 실패: $e');
          // 실패해도 로그아웃은 계속 진행
        }
      }

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

      final currentUID = currentUser.value?.uid;
      if (currentUID == null) {
        throw Exception('삭제할 사용자 정보를 찾을 수 없습니다.');
      }

      // 재인증
      print('계정 삭제를 위한 재인증 시작...');
      await _googleAuthService.reauthenticate();

      // Firestore에서 사용자 데이터 삭제
      print('Firestore에서 사용자 데이터 삭제...');
      await _firestoreUserService.deleteUser(currentUID);

      // Firebase Auth에서 계정 삭제
      print('Firebase Auth에서 계정 삭제...');
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

      String errorMessage = '계정 삭제 중 오류가 발생했습니다.';
      if (e.toString().contains('재인증')) {
        errorMessage = '재인증이 필요합니다. 다시 시도해주세요.';
      } else if (e.toString().contains('Firestore')) {
        errorMessage = '사용자 데이터 삭제 중 오류가 발생했습니다.';
      }

      TLoaders.errorSnacBar(
        title: '계정 삭제 실패',
        message: errorMessage,
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

        // Firestore에도 업데이트
        final uid = currentUser.value?.uid;
        if (uid != null) {
          await _firestoreUserService.updateLastLogin(uid);
        }
      }
    } catch (e) {
      print('활동 시간 업데이트 에러: $e');
    }
  }

  /// 사용자 정보 업데이트
  Future<void> updateUserInfo(UserModel updatedUser) async {
    try {
      print('사용자 정보 업데이트 시작...');

      // Firestore 업데이트
      await _firestoreUserService.updateUser(updatedUser);

      // 로컬 상태 업데이트
      currentUser.value = updatedUser;

      // 로컬 저장소 업데이트
      await _authStorage.updateUserInfo(updatedUser);

      print('사용자 정보 업데이트 완료');

      TLoaders.successSnacBar(
        title: '프로필 업데이트',
        message: '프로필이 성공적으로 업데이트되었습니다.',
      );
    } catch (e) {
      print('사용자 정보 업데이트 에러: $e');
      TLoaders.errorSnacBar(
        title: '업데이트 실패',
        message: '프로필 업데이트 중 오류가 발생했습니다.',
      );
    }
  }

  /// 특정 필드만 업데이트
  Future<void> updateUserField(String fieldName, dynamic value) async {
    try {
      final uid = currentUser.value?.uid;
      if (uid == null) return;

      // Firestore 업데이트
      await _firestoreUserService.updateUserField(uid, {fieldName: value});

      // 로컬 저장소 업데이트
      await _authStorage.updateUserField(fieldName, value);

      // 현재 사용자 정보 새로고침
      await refreshCurrentUser();

      print('사용자 필드 업데이트 완료: $fieldName');
    } catch (e) {
      print('사용자 필드 업데이트 에러: $e');
    }
  }

  /// 현재 사용자 정보 새로고침 (Firestore에서)
  Future<void> refreshCurrentUser() async {
    try {
      final uid = currentUser.value?.uid;
      if (uid == null) return;

      final updatedUser = await _firestoreUserService.getUser(uid);
      if (updatedUser != null) {
        currentUser.value = updatedUser;
        await _authStorage.updateUserInfo(updatedUser);
        print('사용자 정보 새로고침 완료');
      }
    } catch (e) {
      print('사용자 정보 새로고침 에러: $e');
    }
  }

  /// FCM 토큰 업데이트
  Future<void> updateFCMToken(String fcmToken) async {
    try {
      final uid = currentUser.value?.uid;
      if (uid == null) return;

      await _firestoreUserService.updateFCMToken(uid, fcmToken);
      await _authStorage.updateFCMToken(fcmToken);

      print('FCM 토큰 업데이트 완료');
    } catch (e) {
      print('FCM 토큰 업데이트 에러: $e');
    }
  }

  /// 푸시 알림 설정 업데이트
  Future<void> updatePushNotificationSettings(bool enabled) async {
    try {
      await updateUserField('push_notifications', enabled);

      TLoaders.successSnacBar(
        title: '알림 설정',
        message: enabled ? '푸시 알림이 활성화되었습니다.' : '푸시 알림이 비활성화되었습니다.',
      );
    } catch (e) {
      print('푸시 알림 설정 업데이트 에러: $e');
      TLoaders.errorSnacBar(
        title: '설정 실패',
        message: '알림 설정 변경 중 오류가 발생했습니다.',
      );
    }
  }

  /// 로그인 상태 확인
  bool get isLoggedIn {
    return currentUser.value != null &&
        _authStorage.isLoggedIn() &&
        _authStorage.isSessionValid();
  }

  /// 신규 사용자 여부 확인
  bool get isNewUser {
    return _authStorage.isNewUser();
  }

  /// 로그인 유지 시간
  Duration get loginDuration {
    return _authStorage.getLoginDuration();
  }

  /// 사용자 활성화 상태 토글 (관리자용)
  Future<void> toggleUserActiveStatus(bool isActive) async {
    try {
      final uid = currentUser.value?.uid;
      if (uid == null) return;

      await _firestoreUserService.toggleUserActiveStatus(uid, isActive);
      await refreshCurrentUser();

      TLoaders.successSnacBar(
        title: '계정 상태 변경',
        message: isActive ? '계정이 활성화되었습니다.' : '계정이 비활성화되었습니다.',
      );
    } catch (e) {
      print('사용자 활성화 상태 변경 에러: $e');
      TLoaders.errorSnacBar(
        title: '상태 변경 실패',
        message: '계정 상태 변경 중 오류가 발생했습니다.',
      );
    }
  }

  /// 저장소 정보 디버그 출력
  void debugStorageInfo() {
    _authStorage.printStorageInfo();
    print('=== 현재 컨트롤러 상태 ===');
    print('현재 사용자: ${currentUser.value?.email}');
    print('로딩 상태: ${isLoading.value}');
    print('초기화 상태: ${isInitialized.value}');
    print('로그인 상태: $isLoggedIn');
    print('신규 사용자: $isNewUser');
    print('===========================');
  }

  /// 앱 종료 시 정리 작업
  @override
  void onClose() {
    // 마지막 활동 시간 업데이트
    _updateLastActive();
    super.onClose();
  }
}