import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/http/image_upload_service.dart';
import '../../../utils/loader/loaders.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../authentication/models/user_model.dart';
import '../../authentication/services/auth_storage_service.dart';
import '../../authentication/services/firestore_user_service.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final _authController = AuthController.instance;
  final _picker = ImagePicker();

  // 로딩 상태
  final RxBool isImageUploading = false.obs;
  final RxBool isUpdating = false.obs;

  // 텍스트 컨트롤러들
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  /// 컨트롤러 초기화
  void _initializeControllers() {
    final user = _authController.currentUser.value;
    if (user != null) {
      nameController.text = user.name;
      emailController.text = user.email;
      phoneController.text = user.phoneNumber ?? '';
    }
  }

  /// 프로필 이미지 변경
  Future<void> changeProfileImage() async {
    try {
      // 이미지 선택 다이얼로그 표시
      await _showImageSourceDialog();
    } catch (e) {
      print('이미지 선택 오류: $e');
      TLoaders.errorSnacBar(
        title: '이미지 선택 실패',
        message: '이미지를 선택하는 중 오류가 발생했습니다.',
      );
    }
  }

  /// 이미지 소스 선택 다이얼로그
  Future<void> _showImageSourceDialog() async {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '프로필 이미지 변경',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: '카메라',
                  onTap: () => _pickImageFromCamera(),
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: '갤러리',
                  onTap: () => _pickImageFromGallery(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                child: const Text('취소'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 소스 옵션 위젯
  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  /// 카메라에서 이미지 선택
  Future<void> _pickImageFromCamera() async {
    Get.back(); // 바텀시트 닫기
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (pickedFile != null) {
      await _uploadProfileImage(File(pickedFile.path));
    }
  }

  /// 갤러리에서 이미지 선택
  Future<void> _pickImageFromGallery() async {
    Get.back(); // 바텀시트 닫기
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (pickedFile != null) {
      await _uploadProfileImage(File(pickedFile.path));
    }
  }

  /// APM 서버에 이미지 업로드
  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      isImageUploading.value = true;

      final user = _authController.currentUser.value;
      if (user == null) return;

      // APM 서버에 이미지 업로드
      final result = await TImageUploadService.uploadProfileImage(
        imageFile: imageFile,
        userId: user.uid,
      );

      if (result['success'] == true) {
        final imageUrl = result['file_url'];

        // 새로운 사용자 객체 생성
        final updatedUser = user.copyWith(profilePicture: imageUrl);

        // 강제로 상태 업데이트 (trigger rebuild)
        _authController.currentUser.value = UserModel.empty(); // 빈 객체로 초기화
        await Future.delayed(const Duration(milliseconds: 100)); // 잠시 대기
        _authController.currentUser.value = updatedUser; // 새 데이터 설정

        // Firestore 업데이트 (백그라운드)
        _authController.updateUserInfo(updatedUser);

        TLoaders.successSnacBar(
          title: '이미지 업데이트',
          message: '프로필 이미지가 성공적으로 변경되었습니다.',
        );

      } else {
        throw Exception(result['message'] ?? '업로드 실패');
      }

    } catch (e) {
      print('이미지 업로드 오류: $e');
      TLoaders.errorSnacBar(
        title: '업로드 실패',
        message: '이미지 업로드 중 오류가 발생했습니다.',
      );
    } finally {
      isImageUploading.value = false;
    }
  }

  /// 이름 수정 다이얼로그
  void showEditNameDialog() {
    final tempController = TextEditingController(text: nameController.text);

    Get.dialog(
      AlertDialog(
        title: const Text('이름 수정'),
        content: TextField(
          controller: tempController,
          decoration: const InputDecoration(
            labelText: '이름',
            border: OutlineInputBorder(),
            hintText: '새로운 이름을 입력하세요',
          ),
          autofocus: true,
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isUpdating.value
                ? null
                : () async {
              final newName = tempController.text.trim();
              if (newName.isNotEmpty && newName != nameController.text) {
                Get.back();
                await _updateUserField('name', newName);
              } else {
                Get.back();
              }
            },
            child: isUpdating.value
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('저장'),
          )),
        ],
      ),
    );
  }

  /// 전화번호 수정 다이얼로그
  void showEditPhoneDialog() {
    final tempController = TextEditingController(text: phoneController.text);

    Get.dialog(
      AlertDialog(
        title: const Text('전화번호 수정'),
        content: TextField(
          controller: tempController,
          decoration: const InputDecoration(
            labelText: '전화번호',
            border: OutlineInputBorder(),
            hintText: '010-1234-5678',
            prefixText: '+82 ',
          ),
          keyboardType: TextInputType.phone,
          autofocus: true,
          maxLength: 15,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isUpdating.value
                ? null
                : () async {
              final newPhone = tempController.text.trim();
              Get.back();
              await _updateUserField('phoneNumber', newPhone);
            },
            child: isUpdating.value
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('저장'),
          )),
        ],
      ),
    );
  }

  /// 사용자 필드 업데이트
  Future<void> _updateUserField(String fieldName, String value) async {
    try {
      isUpdating.value = true;

      final user = _authController.currentUser.value;
      if (user == null) return;

      UserModel updatedUser;
      switch (fieldName) {
        case 'name':
          updatedUser = user.copyWith(name: value);
          nameController.text = value;
          break;
        case 'phoneNumber':
          updatedUser = user.copyWith(phoneNumber: value);
          phoneController.text = value;
          break;
        default:
          return;
      }

      // 1. 로컬 상태 즉시 업데이트 (UI 반영)
      _authController.currentUser.value = updatedUser;

      // 2. Firestore와 로컬 저장소는 백그라운드에서 처리 (await 없이)
      _updateFirestoreInBackground(updatedUser);

      // 3. 즉시 성공 메시지 표시
      TLoaders.successSnacBar(
        title: '정보 업데이트',
        message: '프로필 정보가 성공적으로 변경되었습니다.',
      );

    } catch (e) {
      TLoaders.errorSnacBar(
        title: '업데이트 실패',
        message: '정보 변경 중 오류가 발생했습니다.',
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// 백그라운드 Firestore 업데이트 (UI 블로킹 없이)
  void _updateFirestoreInBackground(UserModel updatedUser) async {
    try {
      final firestoreUserService = Get.find<FirestoreUserService>();
      final authStorage = Get.find<AuthStorageService>();

      await firestoreUserService.updateUser(updatedUser);
      await authStorage.updateUserInfo(updatedUser);

      print('백그라운드 Firestore 업데이트 완료');
    } catch (e) {
      print('백그라운드 Firestore 업데이트 실패: $e');
      // 실패해도 UI는 이미 업데이트됨
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}