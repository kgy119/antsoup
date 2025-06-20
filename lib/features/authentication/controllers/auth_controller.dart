import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/loader/loaders.dart';
import '../../../utils/validators/validation.dart';
import '../../../navigation_menu.dart';
import '../screens/login/login.dart';
import '../screens/signup/verify_email.dart';
import '../screens/signup/signup.dart';

class AuthenticationController extends GetxController {
  static AuthenticationController get instance => Get.find();

  // Repository
  final _authRepository = Get.put(AuthenticationRepository());

  // Form Controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  // Form Keys
  final signupFormKey = GlobalKey<FormState>();
  final loginFormKey = GlobalKey<FormState>();

  // Loading States
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool isFacebookLoading = false.obs;

  // Privacy Policy & Terms
  final RxBool privacyPolicyAccepted = false.obs;

  // 현재 사용자
  UserModel get currentUser => _authRepository.currentUser;
  bool get isLoggedIn => _authRepository.isLoggedIn;

  @override
  void onClose() {
    // Controllers 정리
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.onClose();
  }

  /// 회원가입
  Future<void> signUp() async {
    try {
      // 폼 유효성 검사
      if (!signupFormKey.currentState!.validate()) return;

      // 개인정보 처리방침 동의 확인
      if (!privacyPolicyAccepted.value) {
        TLoaders.warningSnacBar(
          title: '약관 동의 필요',
          message: '개인정보 처리방침 및 이용약관에 동의해주세요.',
        );
        return;
      }

      // 로딩 시작
      isLoading.value = true;

      // 회원가입 처리
      final user = await _authRepository.signUp(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        phoneNumber: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
      );

      // 성공 메시지
      TLoaders.successSnacBar(
        title: '회원가입 성공!',
        message: '계정이 성공적으로 생성되었습니다.',
      );

      // 이메일 인증 화면으로 이동
      Get.to(() => const VerifyEmailScreen());

    } catch (e) {
      // 에러 처리
      String errorMessage = '회원가입 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '회원가입 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 로그인
  Future<void> signIn() async {
    try {
      // 폼 유효성 검사
      if (!loginFormKey.currentState!.validate()) return;

      // 로딩 시작
      isLoading.value = true;

      // 로그인 처리
      final user = await _authRepository.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 성공 메시지
      TLoaders.successSnacBar(
        title: '로그인 성공!',
        message: '환영합니다, ${user.username}님!',
      );

      // 메인 화면으로 이동
      Get.offAll(() => const NavigationMenu());

    } catch (e) {
      // 에러 처리
      String errorMessage = '로그인 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '로그인 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 구글 로그인
  Future<void> signInWithGoogle() async {
    try {
      // 로딩 시작
      isGoogleLoading.value = true;

      // TODO: Google Sign-In 패키지 구현
      // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // if (googleUser == null) return; // 사용자가 취소한 경우

      // final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      // final String? googleToken = googleAuth.accessToken;

      // 임시로 토큰 시뮬레이션 (실제로는 위 코드 사용)
      const String googleToken = 'temporary_google_token';

      // 서버에 구글 로그인 요청
      final user = await _authRepository.signInWithGoogle(
        googleToken: googleToken,
      );

      // 성공 메시지
      TLoaders.successSnacBar(
        title: '구글 로그인 성공!',
        message: '환영합니다, ${user.username}님!',
      );

      // 메인 화면으로 이동
      Get.offAll(() => const NavigationMenu());

    } catch (e) {
      // 에러 처리
      String errorMessage = '구글 로그인 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '구글 로그인 실패',
        message: errorMessage,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  /// 페이스북 로그인
  Future<void> signInWithFacebook() async {
    try {
      // 로딩 시작
      isFacebookLoading.value = true;

      // TODO: Facebook Sign-In 패키지 구현
      // final LoginResult result = await FacebookAuth.instance.login();
      // if (result.status != LoginStatus.success) return;

      // final String? facebookToken = result.accessToken?.token;

      // 임시로 토큰 시뮬레이션 (실제로는 위 코드 사용)
      const String facebookToken = 'temporary_facebook_token';

      // 서버에 페이스북 로그인 요청
      final user = await _authRepository.signInWithFacebook(
        facebookToken: facebookToken,
      );

      // 성공 메시지
      TLoaders.successSnacBar(
        title: '페이스북 로그인 성공!',
        message: '환영합니다, ${user.username}님!',
      );

      // 메인 화면으로 이동
      Get.offAll(() => const NavigationMenu());

    } catch (e) {
      // 에러 처리
      String errorMessage = '페이스북 로그인 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '페이스북 로그인 실패',
        message: errorMessage,
      );
    } finally {
      isFacebookLoading.value = false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      // 로딩 시작
      isLoading.value = true;

      // 로그아웃 처리
      await _authRepository.signOut();

      // 성공 메시지
      TLoaders.successSnacBar(
        title: '로그아웃 완료',
        message: '안전하게 로그아웃되었습니다.',
      );

      // 로그인 화면으로 이동
      Get.offAll(() => const LoginScreen());

    } catch (e) {
      // 에러 처리 (에러가 발생해도 로그인 화면으로 이동)
      String errorMessage = '로그아웃 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '로그아웃 오류',
        message: errorMessage,
      );

      // 강제로 로그인 화면으로 이동
      Get.offAll(() => const LoginScreen());
    } finally {
      isLoading.value = false;
    }
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // 이메일 유효성 검사
      if (TValidator.validateEmail(email) != null) {
        TLoaders.errorSnacBar(
          title: '유효하지 않은 이메일',
          message: '올바른 이메일 주소를 입력해주세요.',
        );
        return;
      }

      // 로딩 시작
      isLoading.value = true;

      // 비밀번호 재설정 이메일 전송
      await _authRepository.sendPasswordResetEmail(email);

      // 성공 메시지
      TLoaders.successSnacBar(
        title: '이메일 전송 완료',
        message: '비밀번호 재설정 링크가 이메일로 전송되었습니다.',
      );

    } catch (e) {
      // 에러 처리
      String errorMessage = '이메일 전송 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '이메일 전송 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 이메일 인증 전송
  Future<void> sendEmailVerification() async {
    try {
      // 로딩 시작
      isLoading.value = true;

      // 이메일 인증 전송
      await _authRepository.sendEmailVerification();

      // 성공 메시지
      TLoaders.successSnacBar(
        title: '인증 이메일 전송',
        message: '이메일 인증 링크가 전송되었습니다.',
      );

    } catch (e) {
      // 에러 처리
      String errorMessage = '이메일 인증 전송 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '이메일 인증 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 폼 초기화
  void clearForms() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    firstNameController.clear();
    lastNameController.clear();
    privacyPolicyAccepted.value = false;
  }

  /// 이메일 유효성 검사
  String? validateEmail(String? email) {
    return TValidator.validateEmail(email);
  }

  /// 비밀번호 유효성 검사
  String? validatePassword(String? password) {
    return TValidator.validatePassword(password);
  }

  /// 전화번호 유효성 검사
  String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return null; // 선택사항
    return TValidator.validatePhoneNumber(phoneNumber);
  }

  /// 사용자명 유효성 검사
  String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return '사용자명을 입력해주세요.';
    }
    if (username.length < 3) {
      return '사용자명은 최소 3자 이상이어야 합니다.';
    }
    if (username.length > 20) {
      return '사용자명은 최대 20자까지 가능합니다.';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return '사용자명은 영문, 숫자, 언더스코어(_)만 사용 가능합니다.';
    }
    return null;
  }

  /// 이름 유효성 검사
  String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return '이름을 입력해주세요.';
    }
    if (name.length < 2) {
      return '이름은 최소 2자 이상이어야 합니다.';
    }
    return null;
  }
}