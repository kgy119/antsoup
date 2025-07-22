import 'package:antsoup/common/widgets/appbar/appbar.dart';
import 'package:antsoup/common/widgets/custom_shapes/contaioners/primary_header_contaner.dart';
import 'package:antsoup/common/widgets/list_tiles/setting_menu_tile.dart';
import 'package:antsoup/common/widgets/text/section_heading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/list_tiles/user_profile_tile.dart';
import '../../../../features/authentication/controllers/auth_controller.dart';
import '../../../../features/messaging/services/fcm_service.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/loader/loaders.dart';
import '../../../authentication/services/auth_storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// AppBar
                  TAppBar(title: Text('My Profile', style: Theme.of(context).textTheme.headlineMedium!.apply(color: TColors.white))),

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
                  /// Account Setting
                  const TSectionHeading(title: 'Account Settings', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TSettingsMenuTile(
                    icon: Iconsax.notification,
                    title: 'Notifications',
                    subTitle: 'Set any kind of notification message',
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ),

                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// 토픽 구독 관리 섹션
                  const TSectionHeading(title: '알림 설정', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  if (Get.isRegistered<FCMService>()) ...[
                    /// 공지사항 알림만 유지
                    Builder(
                      builder: (context) {
                        final authStorage = Get.find<AuthStorageService>();
                        final isSubscribed = authStorage.isTopicSubscribed('announcements');

                        return TSettingsMenuTile(
                          icon: Iconsax.speaker,
                          title: '공지사항 알림',
                          subTitle: '중요한 공지사항을 받아보세요',
                          trailing: Switch(
                            value: isSubscribed,
                            onChanged: (value) async {
                              final fcmService = Get.find<FCMService>();
                              if (value) {
                                await fcmService.subscribeToTopic('announcements');
                              } else {
                                await fcmService.unsubscribeFromTopic('announcements');
                              }
                              await authStorage.saveTopicSubscription('announcements', value);
                            },
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Logout Button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () => _showLogoutDialog(context, authController),
                      child: authController.isLoading.value
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('처리 중...'),
                        ],
                      )
                          : const Text('Logout'),
                    ),
                  )),

                  const SizedBox(height: TSizes.spaceBtwSections),
                  Center(
                    child: TextButton(
                      onPressed: () => _showDeleteAccountDialog(context, authController),
                      child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections * 2.5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 로그아웃 확인 다이얼로그
  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                authController.signOut();
              },
              child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// 계정 삭제 확인 다이얼로그
  void _showDeleteAccountDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('계정 삭제'),
          content: const Text('정말 계정을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                authController.deleteAccount();
              },
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}