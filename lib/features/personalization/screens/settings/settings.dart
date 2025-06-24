import 'package:antsoup/common/widgets/appbar/appbar.dart';
import 'package:antsoup/common/widgets/custom_shapes/contaioners/primary_header_contaner.dart';
import 'package:antsoup/common/widgets/list_tiles/setting_menu_tile.dart';
import 'package:antsoup/common/widgets/text/section_heading.dart';
import 'package:antsoup/features/personalization/screens/address/address.dart';
import 'package:antsoup/features/personalization/controllers/settings_controller.dart';
import 'package:antsoup/features/personalization/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/list_tiles/user_profile_tile.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../shop/screens/order/order.dart';

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
                      '계정',
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
                  /// Account Settings
                  const TSectionHeading(title: '계정 설정', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  TSettingsMenuTile(
                    icon: Iconsax.safe_home,
                    title: '내 주소',
                    subTitle: '배송 주소 설정 및 관리',
                    onTap: () => Get.to(() => const UserAddressScreen()),
                  ),
                  const TSettingsMenuTile(
                    icon: Iconsax.shopping_cart,
                    title: '장바구니',
                    subTitle: '상품 추가, 삭제 및 결제 이동',
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.bag_tick,
                    title: '주문 내역',
                    subTitle: '진행 중인 주문 및 완료된 주문',
                    onTap: () => Get.to(() => const OrderScreen()),
                  ),
                  const TSettingsMenuTile(
                    icon: Iconsax.bank,
                    title: '계좌 관리',
                    subTitle: '등록된 계좌로 잔액 출금',
                  ),
                  const TSettingsMenuTile(
                    icon: Iconsax.discount_shape,
                    title: '쿠폰함',
                    subTitle: '할인 쿠폰 목록 및 관리',
                  ),
                  const TSettingsMenuTile(
                    icon: Iconsax.notification,
                    title: '알림 설정',
                    subTitle: '알림 메시지 및 설정 관리',
                  ),
                  const TSettingsMenuTile(
                    icon: Iconsax.security_card,
                    title: '계정 보안',
                    subTitle: '데이터 사용 및 연결된 계정 관리',
                  ),

                  /// App Settings
                  const SizedBox(height: TSizes.spaceBtwSections),
                  const TSectionHeading(title: '앱 설정', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  TSettingsMenuTile(
                    icon: Iconsax.document_upload,
                    title: '데이터 업로드',
                    subTitle: '클라우드 Firebase에 데이터 업로드',
                    onTap: () => settingsController.uploadDataToCloud(),
                  ),
                  Obx(() => TSettingsMenuTile(
                    icon: Iconsax.location,
                    title: '위치 정보',
                    subTitle: '위치 기반 추천 설정',
                    trailing: Switch(
                      value: settingsController.geoLocationEnabled.value,
                      onChanged: (value) => settingsController.toggleGeoLocation(value),
                    ),
                  )),
                  Obx(() => TSettingsMenuTile(
                    icon: Iconsax.security_user,
                    title: '안전 모드',
                    subTitle: '모든 연령대에 안전한 검색 결과',
                    trailing: Switch(
                      value: settingsController.safeModeEnabled.value,
                      onChanged: (value) => settingsController.toggleSafeMode(value),
                    ),
                  )),
                  Obx(() => TSettingsMenuTile(
                    icon: Iconsax.image,
                    title: 'HD 이미지 품질',
                    subTitle: '고화질 이미지 설정',
                    trailing: Switch(
                      value: settingsController.hdImageQualityEnabled.value,
                      onChanged: (value) => settingsController.toggleHdImageQuality(value),
                    ),
                  )),

                  /// Appearance Settings
                  const SizedBox(height: TSizes.spaceBtwSections),
                  const TSectionHeading(title: '화면 설정', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  Obx(() => TSettingsMenuTile(
                    icon: Iconsax.moon,
                    title: '다크 모드',
                    subTitle: '어두운 테마 사용',
                    trailing: Switch(
                      value: settingsController.darkModeEnabled.value,
                      onChanged: (value) => settingsController.toggleDarkMode(value),
                    ),
                  )),
                  Obx(() => TSettingsMenuTile(
                    icon: Iconsax.language_square,
                    title: '언어',
                    subTitle: settingsController.currentLanguageName,
                    onTap: () => _showLanguageSelector(context, settingsController),
                  )),
                  Obx(() => TSettingsMenuTile(
                    icon: Iconsax.dollar_circle,
                    title: '통화',
                    subTitle: settingsController.currentCurrencyName,
                    onTap: () => _showCurrencySelector(context, settingsController),
                  )),

                  /// Notification Settings
                  const SizedBox(height: TSizes.spaceBtwSections),
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
                    icon: Iconsax.sms,
                    title: '이메일 알림',
                    subTitle: '이메일로 알림 받기',
                    trailing: Switch(
                      value: settingsController.emailNotifications.value,
                      onChanged: (value) => settingsController.toggleEmailNotifications(value),
                    ),
                  )),
                  Obx(() => TSettingsMenuTile(
                    icon: Iconsax.bag_tick,
                    title: '주문 알림',
                    subTitle: '주문 상태 알림',
                    trailing: Switch(
                      value: settingsController.orderNotifications.value,
                      onChanged: (value) => settingsController.toggleOrderNotifications(value),
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

                  /// Privacy Settings
                  const SizedBox(height: TSizes.spaceBtwSections),
                  const TSectionHeading(title: '개인정보 설정', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  Obx(() => TSettingsMenuTile(
                    icon: Iconsax.profile_circle,
                    title: '프로필 공개',
                    subTitle: '다른 사용자에게 프로필 공개',
                    trailing: Switch(
                      value: settingsController.profilePublic.value,
                      onChanged: (value) => settingsController.toggleProfilePublic(value),
                    ),
                  )),
                  Obx(() => TSettingsMenuTile(
                    icon: Iconsax.status,
                    title: '온라인 상태 표시',
                    subTitle: '접속 상태 표시',
                    trailing: Switch(
                      value: settingsController.showOnlineStatus.value,
                      onChanged: (value) => settingsController.toggleShowOnlineStatus(value),
                    ),
                  )),
                  Obx(() => TSettingsMenuTile(
                    icon: Iconsax.message,
                    title: '낯선 사람 메시지 허용',
                    subTitle: '모르는 사람의 메시지 허용',
                    trailing: Switch(
                      value: settingsController.allowMessageFromStrangers.value,
                      onChanged: (value) => settingsController.toggleAllowMessageFromStrangers(value),
                    ),
                  )),

                  /// Account Actions
                  const SizedBox(height: TSizes.spaceBtwSections),
                  const TSectionHeading(title: '계정 관리', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  TSettingsMenuTile(
                    icon: Iconsax.refresh,
                    title: '설정 초기화',
                    subTitle: '모든 설정을 기본값으로 되돌리기',
                    onTap: () => settingsController.resetSettings(),
                  ),
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

  /// 언어 선택 다이얼로그
  void _showLanguageSelector(BuildContext context, SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('언어 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.availableLanguages.map((language) {
            return ListTile(
              title: Text(language['name']!),
              leading: Radio<String>(
                value: language['code']!,
                groupValue: controller.selectedLanguage.value,
                onChanged: (value) {
                  if (value != null) {
                    controller.changeLanguage(value);
                    Get.back();
                  }
                },
              ),
              onTap: () {
                controller.changeLanguage(language['code']!);
                Get.back();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  /// 통화 선택 다이얼로그
  void _showCurrencySelector(BuildContext context, SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('통화 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.availableCurrencies.map((currency) {
            return ListTile(
              title: Text(currency['name']!),
              leading: Radio<String>(
                value: currency['code']!,
                groupValue: controller.selectedCurrency.value,
                onChanged: (value) {
                  if (value != null) {
                    controller.changeCurrency(value);
                    Get.back();
                  }
                },
              ),
              onTap: () {
                controller.changeCurrency(currency['code']!);
                Get.back();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}