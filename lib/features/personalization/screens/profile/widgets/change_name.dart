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
        title: Text('이름 변경'),
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
                '실명을 사용하시면 친구들이 회원님을 알아보기 쉽습니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// First Name Field
              TextFormField(
                controller: controller.firstNameController,
                validator: controller.validateFirstName,
                decoration: const InputDecoration(
                  labelText: '이름',
                  prefixIcon: Icon(Iconsax.user),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              /// Last Name Field
              TextFormField(
                controller: controller.lastNameController,
                validator: controller.validateLastName,
                decoration: const InputDecoration(
                  labelText: '성',
                  prefixIcon: Icon(Iconsax.user),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),

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