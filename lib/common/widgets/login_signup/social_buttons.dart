import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/authentication/controllers/auth_controller.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';


class TSocialButtons extends StatelessWidget {
  const TSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthenticationController());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// Google Button
        Obx(() => Container(
          decoration: BoxDecoration(
            border: Border.all(color: TColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: controller.isGoogleLoading.value
                ? null
                : () => controller.signInWithGoogle(),
            icon: controller.isGoogleLoading.value
                ? const SizedBox(
              width: TSizes.iconMd,
              height: TSizes.iconMd,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
              ),
            )
                : const Image(
              width: TSizes.iconMd,
              height: TSizes.iconMd,
              image: AssetImage(TImages.google),
            ),
          ),
        )),
        const SizedBox(width: TSizes.spaceBtwItems),

        /// Facebook Button
        Obx(() => Container(
          decoration: BoxDecoration(
            border: Border.all(color: TColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: controller.isFacebookLoading.value
                ? null
                : () => controller.signInWithFacebook(),
            icon: controller.isFacebookLoading.value
                ? const SizedBox(
              width: TSizes.iconMd,
              height: TSizes.iconMd,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
              ),
            )
                : const Image(
              width: TSizes.iconMd,
              height: TSizes.iconMd,
              image: AssetImage(TImages.facebook),
            ),
          ),
        )),
      ],
    );
  }
}