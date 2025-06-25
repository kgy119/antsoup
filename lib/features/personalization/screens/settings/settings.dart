import 'package:antsoup/common/widgets/appbar/appbar.dart';
import 'package:antsoup/common/widgets/custom_shapes/contaioners/primary_header_contaner.dart';
import 'package:antsoup/common/widgets/list_tiles/setting_menu_tile.dart';
import 'package:antsoup/common/widgets/text/section_heading.dart';
import 'package:antsoup/features/personalization/controllers/settings_controller.dart';
import 'package:antsoup/features/personalization/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/list_tiles/user_profile_tile.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.put(SettingsController());
    final userController = Get.put(UserController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// AppBar
                  TAppBar(
                    title: Text(
                      '프로필',
                      style: Theme.of(context).textTheme.headlineMedium!.apply(color: TColors.white),
                    ),
                  ),

                  /// User Profile Card
                  const TUserProfileTitle(),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),

            /// Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  /// Notification Settings
                  const TSectionHeading(title: '알림 설정', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  Obx(() => TSettingsMenuTile(
                    icon: Iconsax.notification,
                    title: '푸시 알림',
                    subTitle: '앱 알림 허용',
                    trailing: Switch(
                      value: settingsController.pushNotifications.value,
                      onChanged: (value) => settingsController.togglePushNotifications(value),
                    ),
                  )),
                  Obx(() => TSettingsMenuTile(
                    icon: Iconsax.discount_shape,
                    title: '프로모션 알림',
                    subTitle: '할인 및 이벤트 알림',
                    trailing: Switch(
                      value: settingsController.promotionalNotifications.value,
                      onChanged: (value) => settingsController.togglePromotionalNotifications(value),
                    ),
                  )),

                  /// Account Actions
                  const SizedBox(height: TSizes.spaceBtwSections),
                  const TSectionHeading(title: '계정 관리', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  TSettingsMenuTile(
                    icon: Iconsax.user_remove,
                    title: '계정 삭제',
                    subTitle: '계정 및 모든 데이터 영구 삭제',
                    onTap: () => settingsController.showDeleteAccountDialog(),
                  ),

                  /// Logout Button
                  const SizedBox(height: TSizes.spaceBtwSections),
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: settingsController.isLoading.value
                          ? null
                          : () => settingsController.logout(),
                      child: settingsController.isLoading.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('로그아웃'),
                    ),
                  )),
                  const SizedBox(height: TSizes.spaceBtwSections * 2.5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}