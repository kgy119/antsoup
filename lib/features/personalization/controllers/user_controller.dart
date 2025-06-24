import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile_model.dart';
import '../models/user_profile_model.dart';
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
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final genderController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  // Form Keys
  final profileFormKey = GlobalKey<FormState>();

  // Loading States
  final RxBool isLoading = false.obs;
  final RxBool isImageUploading = false.obs;

  // User Profile
  final Rx<UserProfileModel> userProfile = UserProfileModel.empty().obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  @override
  void onClose() {
    // Controllers 정리
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    genderController.dispose();
    dateOfBirthController.dispose();
    super.onClose();
  }

  /// 사용자 프로필 로드
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;

      final profile = await _userRepository.getUserProfile();
      userProfile.value = profile;

      // 컨트롤러에 데이터 설정
      _populateControllers(profile);

    } catch (e) {
      String errorMessage = '프로필 정보를 불러오는 중 오류가 발생했습니다.';
      if (e is TExceptions) {
        errorMessage = e.message;
      }

      TLoaders.errorSnacBar(
        title: '프로필 로드 실패',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 컨트롤러에 데이터 설정
  void _populateControllers(UserProfileModel profile) {
    firstNameController.text = profile.firstName ?? '';
    lastNameController.text = profile.lastName ?? '';
    usernameController.text = profile.username;
    emailController.text = profile.email;
    phoneController.text = profile.phoneNumber ?? '';
    genderController.text = profile.gender ?? '';
    if (profile.dateOfBirth != null) {
      dateOfBirthController.text = profile.dateOfBirth!.toString().split(' ')[0];
    }
  }

  /// 프로필 업데이트
  Future<void> updateProfile() async {
    try {
      // 폼 유효성 검사
      if (!profileFormKey.currentState!.validate()) return;

      isLoading.value = true;

      // 업데이트할 데이터 준비
      final updatedData = {
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'gender': genderController.text.trim(),
        'date_of_birth': dateOfBirthController.text.trim(),
      };

      // 프로필 업데이트
      final updatedProfile = await _userRepository.updateUserProfile(updatedData);
      userProfile.value = updatedProfile;

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

        // 프로필 업데이트
        final updatedProfile = userProfile.value.copyWith(profilePicture: imageUrl);
        userProfile.value = updatedProfile;

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

  /// 날짜 선택
  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: userProfile.value.dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dateOfBirthController.text = picked.toString().split(' ')[0];
    }
  }

  /// 성별 선택
  void selectGender(String gender) {
    genderController.text = gender;
  }

  /// 사용자 정보 새로고침
  Future<void> refreshUserData() async {
    await loadUserProfile();
  }

  /// 유효성 검사 메서드들
  String? validateFirstName(String? firstName) {
    if (firstName == null || firstName.isEmpty) {
      return '이름을 입력해주세요.';
    }
    if (firstName.length < 2) {
      return '이름은 2자 이상이어야 합니다.';
    }
    return null;
  }

  String? validateLastName(String? lastName) {
    if (lastName == null || lastName.isEmpty) {
      return '성을 입력해주세요.';
    }
    if (lastName.length < 1) {
      return '성을 입력해주세요.';
    }
    return null;
  }

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

  /// 전체 이름 반환
  String get fullName {
    final firstName = userProfile.value.firstName ?? '';
    final lastName = userProfile.value.lastName ?? '';
    return '$firstName $lastName'.trim();
  }

  /// 프로필 완성도 계산
  double get profileCompleteness {
    int completed = 0;
    int total = 7;

    if (userProfile.value.firstName?.isNotEmpty == true) completed++;
    if (userProfile.value.lastName?.isNotEmpty == true) completed++;
    if (userProfile.value.username.isNotEmpty) completed++;
    if (userProfile.value.email.isNotEmpty) completed++;
    if (userProfile.value.phoneNumber?.isNotEmpty == true) completed++;
    if (userProfile.value.gender?.isNotEmpty == true) completed++;
    if (userProfile.value.dateOfBirth != null) completed++;

    return completed / total;
  }
}