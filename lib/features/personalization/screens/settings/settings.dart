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

                  /// FCM 설정 섹션
                  const TSectionHeading(title: 'FCM 설정 (테스트)', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // FCM 서비스가 등록되어 있는지 확인 후 표시
                  if (Get.isRegistered<FCMService>())
                    Obx(() {
                      final fcmService = Get.find<FCMService>();
                      return Column(
                        children: [
                          TSettingsMenuTile(
                            icon: Iconsax.code,
                            title: 'FCM 토큰 상태',
                            subTitle: fcmService.fcmToken.value.isNotEmpty
                                ? '토큰: ${fcmService.fcmToken.value.substring(0, 20)}...'
                                : '토큰이 없습니다',
                            trailing: Icon(
                              fcmService.fcmToken.value.isNotEmpty ? Iconsax.tick_circle : Iconsax.close_circle,
                              color: fcmService.fcmToken.value.isNotEmpty ? TColors.success : TColors.error,
                            ),
                          ),

                          TSettingsMenuTile(
                            icon: Iconsax.shield_tick,
                            title: '알림 권한',
                            subTitle: fcmService.isNotificationEnabled.value ? '허용됨' : '거부됨',
                            trailing: Switch(
                              value: fcmService.isNotificationEnabled.value,
                              onChanged: (value) => fcmService.requestPermissionAgain(),
                            ),
                          ),

                          TSettingsMenuTile(
                            icon: Iconsax.send_1,
                            title: '테스트 알림 보내기',
                            subTitle: 'FCM 테스트 알림을 보냅니다',
                            onTap: () => fcmService.sendTestNotification(),
                          ),

                          TSettingsMenuTile(
                            icon: Iconsax.refresh,
                            title: 'FCM 토큰 새로고침',
                            subTitle: 'FCM 토큰을 새로 발급받습니다',
                            onTap: () => fcmService.refreshToken(),
                          ),

                          TSettingsMenuTile(
                            icon: Iconsax.information,
                            title: 'FCM 디버그 정보',
                            subTitle: '콘솔에 FCM 정보를 출력합니다',
                            onTap: () => fcmService.printFCMInfo(),
                          ),
                        ],
                      );
                    })
                  else
                    TSettingsMenuTile(
                      icon: Iconsax.warning_2,
                      title: 'FCM 서비스 없음',
                      subTitle: 'FCM 서비스가 초기화되지 않았습니다',
                      trailing: const Icon(Iconsax.close_circle, color: TColors.error),
                    ),

                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// 토픽 구독 관리 섹션
                  const TSectionHeading(title: '알림 구독 관리', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  if (Get.isRegistered<FCMService>()) ...[
                    TSettingsMenuTile(
                      icon: Iconsax.speaker,
                      title: '공지사항 알림',
                      subTitle: '중요한 공지사항을 받아보세요',
                      trailing: Switch(
                        value: true, // 실제로는 구독 상태를 확인해야 함
                        onChanged: (value) async {
                          final fcmService = Get.find<FCMService>();
                          if (value) {
                            await fcmService.subscribeToTopic('announcements');
                          } else {
                            await fcmService.unsubscribeFromTopic('announcements');
                          }
                        },
                      ),
                    ),

                    TSettingsMenuTile(
                      icon: Iconsax.chart,
                      title: '주식 알림',
                      subTitle: '주식 관련 알림을 받아보세요',
                      trailing: Switch(
                        value: true, // 실제로는 구독 상태를 확인해야 함
                        onChanged: (value) async {
                          final fcmService = Get.find<FCMService>();
                          if (value) {
                            await fcmService.subscribeToTopic('stock_alerts');
                          } else {
                            await fcmService.unsubscribeFromTopic('stock_alerts');
                          }
                        },
                      ),
                    ),

                    TSettingsMenuTile(
                      icon: Iconsax.message,
                      title: '채팅 알림',
                      subTitle: '새로운 메시지 알림을 받아보세요',
                      trailing: Switch(
                        value: true, // 실제로는 구독 상태를 확인해야 함
                        onChanged: (value) async {
                          final fcmService = Get.find<FCMService>();
                          if (value) {
                            await fcmService.subscribeToTopic('chat_notifications');
                          } else {
                            await fcmService.unsubscribeFromTopic('chat_notifications');
                          }
                        },
                      ),
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