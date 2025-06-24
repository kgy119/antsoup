import 'package:antsoup/common/widgets/appbar/appbar.dart';
import 'package:antsoup/common/widgets/images/t_circular_image.dart';
import 'package:antsoup/common/widgets/text/section_heading.dart';
import 'package:antsoup/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:antsoup/features/personalization/screens/profile/widgets/change_name.dart';
import 'package:antsoup/features/personalization/screens/profile/widgets/change_password.dart';
import 'package:antsoup/features/personalization/controllers/user_controller.dart';
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
                      image: controller.userProfile.value.profilePicture ?? TImages.user,
                      width: 80,
                      height: 80,
                      isNetworkImage: controller.userProfile.value.profilePicture != null,
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
                title: '이름',
                value: controller.userProfile.value.fullName.isEmpty
                    ? '이름을 설정해주세요'
                    : controller.userProfile.value.fullName,
              )),

              Obx(() => TProfileMenu(
                onPress: () => Get.to(() => const ChangeNameScreen()),
                title: '사용자명',
                value: controller.userProfile.value.username,
              )),

              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading Personal Info
              const TSectionHeading(title: '개인 정보', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              Obx(() => TProfileMenu(
                onPress: () {},
                title: '사용자 ID',
                value: controller.userProfile.value.id?.toString() ?? 'N/A',
                icon: Iconsax.copy,
              )),

              Obx(() => TProfileMenu(
                onPress: () {},
                title: '이메일',
                value: controller.userProfile.value.email,
              )),

              Obx(() => TProfileMenu(
                onPress: () => _showPhoneEditDialog(context, controller),
                title: '전화번호',
                value: controller.userProfile.value.phoneNumber ?? '전화번호 추가',
              )),

              Obx(() => TProfileMenu(
                onPress: () => _showGenderSelector(context, controller),
                title: '성별',
                value: controller.userProfile.value.gender ?? '성별 선택',
              )),

              Obx(() => TProfileMenu(
                onPress: () => controller.selectDateOfBirth(context),
                title: '생년월일',
                value: controller.userProfile.value.dateOfBirth != null
                    ? controller.userProfile.value.dateOfBirth.toString().split(' ')[0]
                    : '생년월일 선택',
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

  /// 전화번호 편집 다이얼로그
  void _showPhoneEditDialog(BuildContext context, UserController controller) {
    final TextEditingController phoneController = TextEditingController(
      text: controller.userProfile.value.phoneNumber ?? '',
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

  /// 성별 선택 다이얼로그
  void _showGenderSelector(BuildContext context, UserController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('성별 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('남성'),
              onTap: () {
                controller.selectGender('남성');
                controller.updateProfile();
                Get.back();
              },
            ),
            ListTile(
              title: const Text('여성'),
              onTap: () {
                controller.selectGender('여성');
                controller.updateProfile();
                Get.back();
              },
            ),
            ListTile(
              title: const Text('기타'),
              onTap: () {
                controller.selectGender('기타');
                controller.updateProfile();
                Get.back();
              },
            ),
          ],
        ),
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
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}