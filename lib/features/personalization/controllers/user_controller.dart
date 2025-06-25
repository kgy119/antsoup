import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:antsoup/features/authentication/models/user_model.dart';
import '../repositories/user_repository.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../../utils/exceptions/exceptions.dart';
import '../../../utils/loader/loaders.dart';
import '../../../utils/validators/validation.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  // Repository
  final _userRepository = Get.put(UserRepository());
  final _authController = AuthenticationController.instance;

  // Form Controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Form Keys
  final profileFormKey = GlobalKey<FormState>();

  // Loading States
  final RxBool isLoading = false.obs;
  final RxBool isImageUploading = false.obs;

  // User Profile (UserController가 관리하는 독립적인 사용자 정보)
  final Rx<UserModel> _userProfile = UserModel.empty().obs;
  UserModel get userProfile => _userProfile.value;

  @override
  void onInit() {
    super.onInit();
    // AuthController의 사용자 정보를 기반으로 초기화
    _initializeFromAuth();

    // AuthController의 사용자 정보 변경을 감시
    ever(_authController.userObservable, (UserModel user) {
      _syncWithAuthController(user);
    });
  }

  @override
  void onClose() {
    // Controllers 정리
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  /// AuthController에서 사용자 정보 초기화
  void _initializeFromAuth() {
    final authUser = _authController.currentUser;
    if (authUser.isNotEmpty) {
      _userProfile.value = authUser;
      _populateControllers(authUser);
    }
  }

  /// AuthController와 동기화
  void _syncWithAuthController(UserModel authUser) {
    if (authUser.isNotEmpty) {
      _userProfile.value = authUser;
      _populateControllers(authUser);
    } else {
      _userProfile.value = UserModel.empty();
      _clearControllers();
    }
  }

  /// 컨트롤러에 데이터 설정
  void _populateControllers(UserModel profile) {
    usernameController.text = profile.username;
    emailController.text = profile.email;
    phoneController.text = profile.phoneNumber ?? '';
  }

  /// 컨트롤러 초기화
  void _clearControllers() {
    usernameController.clear();
    emailController.clear();
    phoneController.clear();
  }

  /// 프로필 업데이트 (이메일 제외)
  Future<void> updateProfile() async {
    try {
      // 폼 유효성 검사
      if (!profileFormKey.currentState!.validate()) return;

      isLoading.value = true;

      // 업데이트할 데이터 준비 (이메일 제외)
      final updatedData = {
        'username': usernameController.text.trim(),
        'phone_number': phoneController.text.trim(),
      };

      // 프로필 업데이트
      final updatedProfile = await _userRepository.updateUserProfile(updatedData);

      // 1. UserController의 사용자 정보 업데이트
      _userProfile.value = updatedProfile;

      // 2. AuthController의 사용자 정보도 동기화
      await _authController.saveUserToStorage(updatedProfile);

      // 성공 메시지
      TLoaders.successSnacBar(
        title: '프로필 업데이트 성공',
        message: '프로필 정보가 성공적으로 업데이트되었습니다.',
      );

    } catch (e) {
      String errorMessage = '프로필 업데이트 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '프로필 업데이트 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 프로필 이미지 업로드
  Future<void> uploadProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (image != null) {
        isImageUploading.value = true;

        // 이미지 업로드
        final imageUrl = await _userRepository.uploadProfileImage(image);

        // 1. UserController의 사용자 정보 업데이트
        final updatedProfile = _userProfile.value.copyWith(profilePicture: imageUrl);
        _userProfile.value = updatedProfile;

        // 2. AuthController의 사용자 정보도 동기화
        await _authController.saveUserToStorage(updatedProfile);

        // 서버에 업데이트
        await _userRepository.updateUserProfile({'profile_picture': imageUrl});

        TLoaders.successSnacBar(
          title: '프로필 이미지 업데이트',
          message: '프로필 이미지가 성공적으로 업데이트되었습니다.',
        );
      }

    } catch (e) {
      String errorMessage = '이미지 업로드 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '이미지 업로드 실패',
        message: errorMessage,
      );
    } finally {
      isImageUploading.value = false;
    }
  }

  /// 비밀번호 변경
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      isLoading.value = true;

      await _userRepository.changePassword(currentPassword, newPassword);

      TLoaders.successSnacBar(
        title: '비밀번호 변경 완료',
        message: '비밀번호가 성공적으로 변경되었습니다.',
      );

    } catch (e) {
      String errorMessage = '비밀번호 변경 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '비밀번호 변경 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 계정 삭제
  Future<void> deleteAccount(String password) async {
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

  /// 사용자 정보 새로고침 (서버에서 최신 정보 가져와서 업데이트)
  Future<void> refreshUserData() async {
    try {
      isLoading.value = true;

      // 서버에서 최신 사용자 정보 가져오기
      final updatedUser = await _userRepository.getCurrentUser();

      // 1. UserController의 사용자 정보 업데이트
      _userProfile.value = updatedUser;
      _populateControllers(updatedUser);

      // 2. AuthController에도 업데이트된 정보 저장
      await _authController.saveUserToStorage(updatedUser);

    } catch (e) {
      String errorMessage = '사용자 정보 새로고침 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '새로고침 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 유효성 검사 메서드들
  String? validateUsername(String? username) {
    return TValidator.validateUsername(username);
  }

  String? validateEmail(String? email) {
    return TValidator.validateEmail(email);
  }

  String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      return TValidator.validatePhoneNumber(phoneNumber);
    }
    return null; // 선택사항이므로 빈 값 허용
  }

  String? validatePassword(String? password) {
    return TValidator.validatePassword(password);
  }

  /// 전체 이름 반환 (UserModel의 fullName 사용)
  String get fullName => _userProfile.value.fullName;

  /// 프로필 완성도 계산 (이메일 제외)
  double get profileCompleteness {
    int completed = 0;
    int total = 2; // username, phoneNumber (이메일 제외)

    if (_userProfile.value.username.isNotEmpty) completed++;
    if (_userProfile.value.phoneNumber?.isNotEmpty == true) completed++;

    return completed / total;
  }

  /// 사용자 정보 스트림 (UI에서 사용자 정보 변경을 실시간으로 감지)
  Stream<UserModel> get userStream => _userProfile.stream;
}