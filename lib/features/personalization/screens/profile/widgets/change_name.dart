import 'package:antsoup/common/widgets/appbar/appbar.dart';
import 'package:antsoup/features/personalization/controllers/user_controller.dart';
import 'package:antsoup/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangeNameScreen extends StatelessWidget {
  const ChangeNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text('프로필 변경'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: controller.profileFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Instructions
              Text(
                '사용자명과 이메일, 전화번호를 변경할 수 있습니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Username Field
              TextFormField(
                controller: controller.usernameController,
                validator: controller.validateUsername,
                decoration: const InputDecoration(
                  labelText: '사용자명',
                  prefixIcon: Icon(Iconsax.user_edit),
                  hintText: '다른 사용자들이 볼 수 있는 고유한 이름',
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              /// Phone Number Field
              TextFormField(
                controller: controller.phoneController,
                validator: controller.validatePhoneNumber,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '전화번호 (선택사항)',
                  prefixIcon: Icon(Iconsax.call),
                  hintText: '010-1234-5678',
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Save Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.updateProfile(),
                  child: controller.isLoading.value
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text('저장'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}