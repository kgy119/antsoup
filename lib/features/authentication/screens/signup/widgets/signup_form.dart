import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../controllers/auth_controller.dart';
import 'terms_conditions_checkbox.dart';

class TSignupForm extends StatelessWidget {
  const TSignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthenticationController());

    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          /// Email (필수 - UserModel에서 required)
          TextFormField(
            controller: controller.emailController,
            validator: controller.validateEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: TTexts.email,
              prefixIcon: Icon(Iconsax.direct),
              hintText: '인증을 위해 유효한 이메일을 입력해주세요',
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Username (필수 - UserModel에서 required)
          TextFormField(
            controller: controller.usernameController,
            validator: controller.validateUsername,
            decoration: const InputDecoration(
              labelText: TTexts.username,
              prefixIcon: Icon(Iconsax.user_edit),
              hintText: '한글, 영문, 숫자, 언더스코어(_) 사용 가능',
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Phone Number (선택사항 - UserModel에서 nullable)
          TextFormField(
            controller: controller.phoneController,
            validator: controller.validatePhoneNumber,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: TTexts.phoneNo,
              prefixIcon: Icon(Iconsax.call),
              hintText: '선택사항 (예: 010-1234-5678)',
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Password (필수)
          Obx(() => TextFormField(
            controller: controller.passwordController,
            validator: controller.validatePassword,
            obscureText: controller.hidePassword.value,
            decoration: InputDecoration(
              labelText: TTexts.password,
              prefixIcon: const Icon(Iconsax.password_check),
              hintText: '영문, 숫자, 특수문자 포함 6자 이상',
              suffixIcon: IconButton(
                onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye),
              ),
            ),
          )),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Confirm Password (추가)
          Obx(() => TextFormField(
            controller: controller.confirmPasswordController,
            validator: controller.validateConfirmPassword,
            obscureText: controller.hideConfirmPassword.value,
            decoration: InputDecoration(
              labelText: '비밀번호 확인',
              prefixIcon: const Icon(Iconsax.password_check),
              hintText: '위에서 입력한 비밀번호를 다시 입력해주세요',
              suffixIcon: IconButton(
                onPressed: () => controller.hideConfirmPassword.value = !controller.hideConfirmPassword.value,
                icon: Icon(controller.hideConfirmPassword.value ? Iconsax.eye_slash : Iconsax.eye),
              ),
            ),
          )),

          const SizedBox(height: TSizes.spaceBtwSections),

          /// Terms & Conditions Checkbox
          const TTermsAndConditionCheckbox(),
          const SizedBox(height: TSizes.spaceBtwSections),

          /// Sign Up Button
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.signUp(),
              child: controller.isLoading.value
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(TTexts.createAccount),
            ),
          )),
        ],
      ),
    );
  }
}