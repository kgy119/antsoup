import 'package:antsoup/utils/constants/colors.dart';
import 'package:antsoup/utils/constants/image_strings.dart';
import 'package:antsoup/utils/constants/sizes.dart';
import 'package:antsoup/utils/constants/text_strings.dart';
import 'package:antsoup/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/social_login_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: dark ? TColors.black : TColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                /// 상단 여백
                const SizedBox(height: TSizes.spaceBtwItems),

                /// 로고 및 환영 메시지 섹션
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      /// 앱 로고
                      Container(
                        padding: const EdgeInsets.all(TSizes.lg),
                        decoration: BoxDecoration(
                          color: dark ? TColors.dark.withOpacity(0.1) : TColors.light,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Image(
                          height: 100,
                          image: AssetImage(dark ? TImages.lightAppLogo : TImages.darkAppLogo),
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      /// 환영 텍스트
                      Text(
                        TTexts.loginTitle,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: TSizes.sm),
                      Text(
                        TTexts.loginSubTitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: dark ? TColors.darkGrey : TColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwItems),

                /// 로그인 카드
                Container(
                  padding: const EdgeInsets.all(TSizes.lg),
                  decoration: BoxDecoration(
                    color: dark ? TColors.dark : TColors.white,
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: dark ? TColors.darkGrey : TColors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      /// 서드파티 로그인 버튼들
                      Column(
                        children: [
                          /// 구글 로그인 - 실제 구현 연결
                          Obx(() => SocialLoginButton(
                            text: controller.isLoading.value ? '로그인 중...' : '구글로 계속하기',
                            onPressed: controller.isLoading.value
                                ? () {}
                                : () => controller.signInWithGoogle(),
                            backgroundColor: dark ? TColors.darkContainer : const Color(0xFFF8F9FA),
                            textColor: dark ? TColors.white : TColors.dark,
                            borderColor: dark ? TColors.darkGrey : const Color(0xFFDADCE0),
                          )),
                          const SizedBox(height: TSizes.spaceBtwItems),

                          /// 카카오 로그인 - 임시 (다음 단계에서 구현)
                          SocialLoginButton(
                            text: '카카오로 계속하기',
                            onPressed: () => _handleKakaoLogin(),
                            backgroundColor: const Color(0xFFFEE500),
                            textColor: Colors.black,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems),

                          /// 네이버 로그인 - 임시 (다음 단계에서 구현)
                          SocialLoginButton(
                            text: '네이버로 계속하기',
                            onPressed: () => _handleNaverLogin(),
                            backgroundColor: const Color(0xFF03C75A),
                            textColor: Colors.white,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems),

                          /// 페이스북 로그인 - 임시 (다음 단계에서 구현)
                          SocialLoginButton(
                            text: '페이스북으로 계속하기',
                            onPressed: () => _handleFacebookLogin(),
                            backgroundColor: const Color(0xFF1877F2),
                            textColor: Colors.white,
                          ),

                          /// 애플 로그인 (iOS에서만 표시) - 임시 (다음 단계에서 구현)
                          if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                            const SizedBox(height: TSizes.spaceBtwItems),
                            SocialLoginButton(
                              text: '애플로 계속하기',
                              onPressed: () => _handleAppleLogin(),
                              backgroundColor: dark ? Colors.white : Colors.black,
                              textColor: dark ? Colors.black : Colors.white,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwSections),

                /// 이용약관 및 개인정보처리방침
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark ? TColors.darkGrey : TColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: '로그인 시 '),
                        TextSpan(
                          text: '이용약관',
                          style: TextStyle(
                            color: TColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' 및 '),
                        TextSpan(
                          text: '개인정보처리방침',
                          style: TextStyle(
                            color: TColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: '에\n동의하게 됩니다.'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwSections),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 임시 로그인 핸들러들 (다음 단계에서 실제 구현)
  void _handleKakaoLogin() {
    print('카카오 로그인 시도 - 아직 구현되지 않음');
    // TODO: 카카오 로그인 구현
  }

  void _handleNaverLogin() {
    print('네이버 로그인 시도 - 아직 구현되지 않음');
    // TODO: 네이버 로그인 구현
  }

  void _handleFacebookLogin() {
    print('Facebook 로그인 시도 - 아직 구현되지 않음');
    // TODO: Facebook 로그인 구현
  }

  void _handleAppleLogin() {
    print('Apple 로그인 시도 - 아직 구현되지 않음');
    // TODO: Apple 로그인 구현
  }
}