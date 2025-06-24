import 'package:antsoup/common/widgets/appbar/appbar.dart';
import 'package:antsoup/features/personalization/controllers/user_controller.dart';
import 'package:antsoup/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final RxBool _hideCurrentPassword = true.obs;
  final RxBool _hideNewPassword = true.obs;
  final RxBool _hideConfirmPassword = true.obs;
  final RxBool _isLoading = false.obs;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text('비밀번호 변경'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Instructions
              Text(
                '보안을 위해 정기적으로 비밀번호를 변경하는 것을 권장합니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Current Password Field
              Obx(() => TextFormField(
                controller: _currentPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '현재 비밀번호를 입력해주세요.';
                  }
                  return null;
                },
                obscureText: _hideCurrentPassword.value,
                decoration: InputDecoration(
                  labelText: '현재 비밀번호',
                  prefixIcon: const Icon(Iconsax.password_check),
                  suffixIcon: IconButton(
                    onPressed: () => _hideCurrentPassword.value = !_hideCurrentPassword.value,
                    icon: Icon(_hideCurrentPassword.value ? Iconsax.eye_slash : Iconsax.eye),
                  ),
                ),
              )),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              /// New Password Field
              Obx(() => TextFormField(
                controller: _newPasswordController,
                validator: controller.validatePassword,
                obscureText: _hideNewPassword.value,
                decoration: InputDecoration(
                  labelText: '새 비밀번호',
                  prefixIcon: const Icon(Iconsax.password_check),
                  hintText: '영문, 숫자, 특수문자 포함 6자 이상',
                  suffixIcon: IconButton(
                    onPressed: () => _hideNewPassword.value = !_hideNewPassword.value,
                    icon: Icon(_hideNewPassword.value ? Iconsax.eye_slash : Iconsax.eye),
                  ),
                ),
              )),
              const SizedBox(height: TSizes.spaceBtwInputFields),

              /// Confirm New Password Field
              Obx(() => TextFormField(
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '새 비밀번호를 다시 입력해주세요.';
                  }
                  if (value != _newPasswordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
                obscureText: _hideConfirmPassword.value,
                decoration: InputDecoration(
                  labelText: '새 비밀번호 확인',
                  prefixIcon: const Icon(Iconsax.password_check),
                  suffixIcon: IconButton(
                    onPressed: () => _hideConfirmPassword.value = !_hideConfirmPassword.value,
                    icon: Icon(_hideConfirmPassword.value ? Iconsax.eye_slash : Iconsax.eye),
                  ),
                ),
              )),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Password Requirements
              Container(
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '비밀번호 요구사항:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: TSizes.sm),
                    const Text('• 최소 6자 이상'),
                    const Text('• 영문자 포함'),
                    const Text('• 숫자 포함'),
                    const Text('• 특수문자 포함'),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Change Password Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading.value
                      ? null
                      : () => _changePassword(controller),
                  child: _isLoading.value
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text('비밀번호 변경'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  /// 비밀번호 변경 처리
  Future<void> _changePassword(UserController controller) async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    try {
      await controller.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      // 성공 시 이전 화면으로 돌아가기
      Get.back();
    } catch (e) {
      // 에러 처리는 controller에서 수행
    } finally {
      _isLoading.value = false;
    }
  }
}