import 'package:antsoup/common/widgets/appbar/appbar.dart';
import 'package:antsoup/features/personalization/controllers/address_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/sizes.dart';
import '../../repositories/user_repository.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key, this.addressToEdit});

  final AddressModel? addressToEdit;

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.instance;
    final isEditing = addressToEdit != null;

    // 편집 모드일 때 폼에 기존 데이터 설정
    if (isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.populateForm(addressToEdit!);
      });
    } else {
      // 새 주소 추가일 때 폼 초기화
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.clearForm();
      });
    }

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(isEditing ? '주소 편집' : '새 주소 추가'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: controller.addressFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Instructions
                if (!isEditing) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(TSizes.md),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.info_circle, color: Colors.blue[600]),
                            const SizedBox(width: TSizes.sm),
                            Text(
                              '주소 추가 안내',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TSizes.xs),
                        Text(
                          '정확한 배송을 위해 상세한 주소를 입력해주세요.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],

                /// Name Field
                TextFormField(
                  controller: controller.nameController,
                  validator: controller.validateName,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: '수령인 이름',
                    hintText: '홍길동',
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Phone Number Field
                TextFormField(
                  controller: controller.phoneController,
                  validator: controller.validatePhoneNumber,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.mobile),
                    labelText: '전화번호',
                    hintText: '010-1234-5678',
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Street and Postal Code Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: controller.streetController,
                        validator: controller.validateStreet,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.building_31),
                          labelText: '도로명/지번',
                          hintText: '예: 강남대로 123',
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: controller.postalCodeController,
                        validator: controller.validatePostalCode,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.code),
                          labelText: '우편번호',
                          hintText: '12345',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// City and State Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.cityController,
                        validator: controller.validateCity,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.building),
                          labelText: '시/군/구',
                          hintText: '강남구',
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: controller.stateController,
                        validator: controller.validateState,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.activity),
                          labelText: '시/도',
                          hintText: '서울특별시',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Country Field
                TextFormField(
                  controller: controller.countryController,
                  validator: controller.validateCountry,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.global),
                    labelText: '국가',
                    hintText: '대한민국',
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Address Preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(TSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Iconsax.location, color: Colors.grey[600]),
                          const SizedBox(width: TSizes.sm),
                          Text(
                            '주소 미리보기',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.sm),
                      Obx(() {
                        final street = controller.streetController.text;
                        final city = controller.cityController.text;
                        final state = controller.stateController.text;
                        final postalCode = controller.postalCodeController.text;
                        final country = controller.countryController.text;

                        if (street.isEmpty && city.isEmpty && state.isEmpty) {
                          return Text(
                            '주소를 입력하면 여기에 미리보기가 표시됩니다.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          );
                        }

                        return Text(
                          '$street, $city, $state $postalCode, $country'.replaceAll(RegExp(r',\s*,|,\s*$'), ''),
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Save Button
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : () {
                      if (isEditing) {
                        controller.updateAddress(addressToEdit!);
                      } else {
                        controller.addNewAddress();
                      }
                    },
                    child: controller.isSaving.value
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(isEditing ? '주소 수정' : '주소 저장'),
                  ),
                )),

                /// Delete Button (편집 모드에서만 표시)
                if (isEditing) ...[
                  const SizedBox(height: TSizes.spaceBtwItems),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => controller.deleteAddress(addressToEdit!),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('주소 삭제'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}