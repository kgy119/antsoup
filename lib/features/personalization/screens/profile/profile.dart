import 'package:antsoup/common/widgets/appbar/appbar.dart';
import 'package:antsoup/common/widgets/images/t_circular_image.dart';
import 'package:antsoup/common/widgets/text/section_heading.dart';
import 'package:antsoup/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:antsoup/features/personalization/screens/profile/widgets/change_name.dart';
import 'package:antsoup/features/personalization/screens/profile/widgets/change_password.dart';
import 'package:antsoup/features/personalization/controllers/user_controller.dart';
import 'package:antsoup/features/authentication/controllers/auth_controller.dart';
import 'package:antsoup/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/image_strings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    final authController = AuthenticationController.instance;

    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text('프로필'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() => TCircularImage(
                      image: controller.userProfile.profilePicture ?? TImages.user,
                      width: 80,
                      height: 80,
                      isNetworkImage: controller.userProfile.profilePicture != null,
                    )),
                    Obx(() => TextButton(
                      onPressed: controller.isImageUploading.value
                          ? null
                          : () => controller.uploadProfileImage(),
                      child: controller.isImageUploading.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('프로필 사진 변경'),
                    )),
                  ],
                ),
              ),

              /// Details
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading Profile Info
              const TSectionHeading(title: '프로필 정보', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              Obx(() => TProfileMenu(
                onPress: () => Get.to(() => const ChangeNameScreen()),
                title: '사용자명',
                value: controller.userProfile.username.isEmpty
                    ? '사용자명을 설정해주세요'
                    : controller.userProfile.username,
              )),

              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading Personal Info
              const TSectionHeading(title: '개인 정보', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              Obx(() => TProfileMenu(
                onPress: () => _copyToClipboard(controller.userProfile.id?.toString() ?? 'N/A'),
                title: '사용자 ID',
                value: controller.userProfile.id?.toString() ?? 'N/A',
                icon: Iconsax.copy,
              )),

              Obx(() => TProfileMenu(
                onPress: () => _copyToClipboard(controller.userProfile.email.toString()),
                title: '이메일',
                value: controller.userProfile.email.isEmpty
                    ? '이메일을 설정해주세요'
                    : controller.userProfile.email,
                icon: Iconsax.copy, // 정보 아이콘으로 변경
              )),

              Obx(() => TProfileMenu(
                onPress: () => _copyToClipboard(controller.userProfile.phoneNumber.toString()),
                title: '전화번호',
                value: controller.userProfile.phoneNumber ?? '전화번호 추가',
                icon: Iconsax.copy,
              )),

              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Account Status
              const TSectionHeading(title: '계정 상태', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              Obx(() => TProfileMenu(
                onPress: () => _handleEmailVerification(authController),
                title: '이메일 인증',
                value: controller.userProfile.emailVerified ? '인증됨' : '미인증',
                icon: controller.userProfile.emailVerified
                    ? Iconsax.verify
                    : Iconsax.warning_2,
              )),

              Obx(() => TProfileMenu(
                onPress: () {},
                title: '전화번호 인증',
                value: controller.userProfile.phoneVerified ? '인증됨' : '미인증',
                icon: controller.userProfile.phoneVerified
                    ? Iconsax.verify
                    : Iconsax.warning_2,
              )),

              Obx(() => TProfileMenu(
                onPress: () {},
                title: '계정 상태',
                value: controller.userProfile.status,
                icon: Iconsax.status,
              )),

              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Security Section
              const TSectionHeading(title: '보안', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(
                onPress: () => Get.to(() => const ChangePasswordScreen()),
                title: '비밀번호 변경',
                value: '••••••••',
                icon: Iconsax.arrow_right_34,
              ),

              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Profile Completeness
              Obx(() {
                final completeness = controller.profileCompleteness;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '프로필 완성도: ${(completeness * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: TSizes.sm),
                    LinearProgressIndicator(
                      value: completeness,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completeness < 0.5 ? Colors.red :
                        completeness < 0.8 ? Colors.orange : Colors.green,
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: TSizes.spaceBtwSections),

              /// Refresh Button
              Obx(() => ElevatedButton.icon(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.refreshUserData(),
                icon: controller.isLoading.value
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Iconsax.refresh),
                label: const Text('정보 새로고침'),
              )),

              const SizedBox(height: TSizes.spaceBtwItems),

              Center(
                child: TextButton(
                  onPressed: () => _showDeleteAccountDialog(context, controller),
                  child: const Text('계정 삭제', style: TextStyle(color: Colors.red)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 클립보드에 복사
  void _copyToClipboard(String text) {
    // TODO: Clipboard 패키지 사용하여 클립보드에 복사
    Get.snackbar(
      '복사 완료',
      '클립보드에 복사되었습니다.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// 이메일 인증 처리
  void _handleEmailVerification(AuthenticationController authController) {
    final controller = UserController.instance;

    if (!controller.userProfile.emailVerified) {
      Get.dialog(
        AlertDialog(
          title: const Text('이메일 인증'),
          content: const Text('이메일 인증을 진행하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                authController.sendEmailVerification();
              },
              child: const Text('인증 이메일 전송'),
            ),
          ],
        ),
      );
    }
  }

  /// 이메일 정보 표시 (변경 불가 안내)
  void _showEmailInfo(BuildContext context) {
    final controller = UserController.instance;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Iconsax.info_circle, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('이메일 정보'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '현재 이메일: ${controller.userProfile.email}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.warning_2, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '보안상의 이유로 이메일은 변경할 수 없습니다.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '이메일을 변경하려면 고객센터에 문의해주세요.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('확인'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showContactSupport();
            },
            child: const Text('고객센터 문의'),
          ),
        ],
      ),
    );
  }

  /// 고객센터 문의 안내
  void _showContactSupport() {
    Get.dialog(
      AlertDialog(
        title: const Text('고객센터 문의'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이메일 변경을 원하시면 아래 방법으로 문의해주세요:'),
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Iconsax.sms,
              title: '이메일',
              value: 'support@antsoup.co.kr',
            ),
            const SizedBox(height: 8),
            _buildContactItem(
              icon: Iconsax.call,
              title: '전화',
              value: '1588-0000',
            ),
            const SizedBox(height: 8),
            _buildContactItem(
              icon: Iconsax.clock,
              title: '운영시간',
              value: '평일 09:00 - 18:00',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 연락처 정보 아이템
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// 전화번호 편집 다이얼로그
  void _showPhoneEditDialog(BuildContext context, UserController controller) {
    final TextEditingController phoneController = TextEditingController(
      text: controller.userProfile.phoneNumber ?? '',
    );

    Get.dialog(
      AlertDialog(
        title: const Text('전화번호 편집'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: '전화번호',
            hintText: '010-1234-5678',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              controller.phoneController.text = phoneController.text;
              await controller.updateProfile();
              Get.back();
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  /// 계정 삭제 확인 다이얼로그
  void _showDeleteAccountDialog(BuildContext context, UserController controller) {
    final TextEditingController passwordController = TextEditingController();

    Get.dialog(
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
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                Get.back();
                controller.deleteAccount(passwordController.text);
              } else {
                Get.snackbar(
                  '오류',
                  '비밀번호를 입력해주세요.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}