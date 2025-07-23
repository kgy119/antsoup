import 'package:antsoup/common/widgets/appbar/appbar.dart';
import 'package:antsoup/common/widgets/images/t_circular_image.dart';
import 'package:antsoup/common/widgets/text/section_heading.dart';
import 'package:antsoup/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:antsoup/features/personalization/controllers/profile_controller.dart';
import 'package:antsoup/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/auth_helper.dart';
import '../../../../utils/helpers/time_helper.dart';
import '../../../authentication/controllers/auth_controller.dart';
import '../../../authentication/models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final profileController = Get.put(ProfileController());

    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Obx(() {
            final user = authController.currentUser.value;

            if (user == null) {
              return const Center(
                child: Text('사용자 정보를 불러올 수 없습니다.'),
              );
            }

            final networkImage = user.profilePicture ?? '';
            final image = networkImage.isNotEmpty ? networkImage : TImages.user;

            return Column(
              children: [
                /// Profile Picture
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Obx(() => profileController.isImageUploading.value
                          ? Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : TCircularImage(
                        image: image,
                        isNetworkImage: networkImage.isNotEmpty,
                        width: 120,
                        height: 120,
                        padding: 0,
                        fit: BoxFit.cover,
                      )),
                      TextButton(
                          onPressed: () => profileController.changeProfileImage(),
                          child: const Text('Change Profile Picture')
                      ),
                    ],
                  ),
                ),

                /// Details
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                const Divider(),
                const SizedBox(height: TSizes.spaceBtwItems),

                /// Heading Profile Info
                const TSectionHeading(title: 'Profile Information', showActionButton: false),
                const SizedBox(height: TSizes.spaceBtwItems),

                /// 이메일 (수정 불가)
                TProfileMenu(
                  onPress: () {
                    // 이메일은 수정 불가 (서드파티 로그인이므로)
                    Get.dialog(
                      AlertDialog(
                        title: const Text('이메일 변경 불가'),
                        content: const Text('로그인 계정의 이메일은 변경할 수 없습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  },
                  title: 'E-mail',
                  value: user.email,
                  showIcon: false,
                ),

                /// 이름 부분 (디버그 추가)
                Obx(() {
                  final currentName = authController.currentUser.value?.name ?? '';
                  print('ProfileScreen 렌더링 - 현재 이름: $currentName');

                  return TProfileMenu(
                    onPress: profileController.isUpdating.value
                        ? null
                        : () => profileController.showEditNameDialog(),
                    title: 'Name',
                    value: currentName,
                    showIcon: true,
                    icon: profileController.isUpdating.value
                        ? Icons.hourglass_empty
                        : Iconsax.edit,
                  );
                }),

                /// 전화번호 (수정 가능)
                Obx(() {
                  final user = authController.currentUser.value;
                  return TProfileMenu(
                    onPress: profileController.isUpdating.value
                        ? null
                        : () => profileController.showEditPhoneDialog(),
                    title: 'Phone',
                    value: user?.phoneNumber?.isNotEmpty == true
                        ? user!.phoneNumber!
                        : '전화번호를 등록해주세요',
                    showIcon: true,
                    icon: profileController.isUpdating.value
                        ? Icons.hourglass_empty
                        : Iconsax.edit,
                  );
                }),

                // 가입일 (Member Since를 Profile Information에 편입)
                TProfileMenu(
                  onPress: () {},
                  title: 'Since',
                  value: TTimeHelper.formatDateKorean(user.createdAt),
                  showIcon: false,
                ),

                const Divider(),
                const SizedBox(height: TSizes.spaceBtwItems),

              ],
            );
          }),
        ),
      ),
    );
  }

}