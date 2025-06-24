import 'package:antsoup/common/widgets/appbar/appbar.dart';
import 'package:antsoup/features/personalization/screens/address/add_new_address.dart';
import 'package:antsoup/features/personalization/controllers/address_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../repositories/user_repository.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColors.primary,
        onPressed: () => Get.to(() => const AddNewAddressScreen()),
        child: const Icon(Iconsax.add, color: TColors.white),
      ),
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('주소 관리', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasAddresses) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.location,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  '등록된 주소가 없습니다',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: TSizes.sm),
                Text(
                  '새 주소를 추가해보세요',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const AddNewAddressScreen()),
                  icon: const Icon(Iconsax.add),
                  label: const Text('주소 추가'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshAddresses(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  /// Address Count Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(TSizes.md),
                    decoration: BoxDecoration(
                      color: TColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.location, color: TColors.primary),
                        const SizedBox(width: TSizes.sm),
                        Text(
                          '총 ${controller.addressCount}개의 주소',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Address List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
                    itemBuilder: (context, index) {
                      final address = controller.addresses[index];
                      return TSingleAddress(
                        address: address,
                        onTap: () => controller.selectAddress(address),
                        onEdit: () {
                          controller.populateForm(address);
                          Get.to(() => AddNewAddressScreen(addressToEdit: address));
                        },
                        onDelete: () => controller.deleteAddress(address),
                        onSetDefault: () => controller.setDefaultAddress(address),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// 개별 주소 위젯
class TSingleAddress extends StatelessWidget {
  const TSingleAddress({
    super.key,
    required this.address,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  final AddressModel address;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: address.isDefault ? TColors.primary : Colors.grey[300]!,
            width: address.isDefault ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          color: address.isDefault ? TColors.primary.withOpacity(0.05) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header with name and default badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TSizes.sm,
                      vertical: TSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.primary,
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                    ),
                    child: Text(
                      '기본',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: TSizes.sm),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                      case 'default':
                        onSetDefault?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Iconsax.edit),
                          SizedBox(width: TSizes.sm),
                          Text('편집'),
                        ],
                      ),
                    ),
                    if (!address.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Iconsax.tick_circle),
                            SizedBox(width: TSizes.sm),
                            Text('기본 주소로 설정'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Iconsax.trash, color: Colors.red),
                          SizedBox(width: TSizes.sm),
                          Text('삭제', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(Iconsax.more),
                ),
              ],
            ),
            const SizedBox(height: TSizes.sm),

            /// Phone Number
            Row(
              children: [
                const Icon(Iconsax.call, size: 16, color: Colors.grey),
                const SizedBox(width: TSizes.xs),
                Text(
                  address.phoneNumber,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: TSizes.xs),

            /// Full Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.location, size: 16, color: Colors.grey),
                const SizedBox(width: TSizes.xs),
                Expanded(
                  child: Text(
                    address.fullAddress,
                    style: Theme.of(context).textTheme.bodyMedium,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}