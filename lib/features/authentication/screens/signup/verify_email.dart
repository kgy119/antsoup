import 'dart:async';
import 'package:antsoup/common/widgets/success_screen/success_screen.dart';
import 'package:antsoup/features/authentication/controllers/auth_controller.dart';
import 'package:antsoup/utils/constants/image_strings.dart';
import 'package:antsoup/utils/constants/sizes.dart';
import 'package:antsoup/utils/constants/text_strings.dart';
import 'package:antsoup/utils/helpers/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../login/login.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startEmailVerificationCheck() {
    // 5초마다 이메일 인증 상태 확인
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      AuthenticationController.instance.checkEmailVerificationStatus();
    });
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60; // 60초 쿨다운
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthenticationController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () => Get.offAll(() => const LoginScreen()),
              icon: const Icon(CupertinoIcons.clear)
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Image
              Image(image: const AssetImage(TImages.deliveredEmailIllustration), width: THelperFunctions.screenWidth() * 0.6),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Title & SubTitle
              Text(TTexts.confirmEmail, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(widget.email, style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(TTexts.confirmEmailSubTitle, style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Continue Button
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () => Get.to(() => SuccessScreen(
                        image: TImages.staticSuccessIllustration,
                        title: TTexts.yourAccountCreatedTitle,
                        subTitle: TTexts.yourAccountCreatedSubTitle,
                        onPressed: () => Get.offAll(() => const LoginScreen()),
                      ),
                      ),
                      child: const Text(TTexts.tContinue))),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Resend Email Button
              SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _resendCooldown > 0
                        ? null
                        : () {
                      controller.sendEmailVerification();
                      _startResendCooldown();
                    },
                    child: Text(
                        _resendCooldown > 0
                            ? '${TTexts.resendEmail} ($_resendCooldown초 후 재전송 가능)'
                            : TTexts.resendEmail
                    ),
                  )
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Check Email Status Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => controller.checkEmailVerificationStatus(),
                  child: const Text('이메일 인증 확인'),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              /// Help Text
              Text(
                '이메일이 오지 않았나요?\n스팸함을 확인하거나 위의 "이메일 재전송" 버튼을 눌러주세요.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}