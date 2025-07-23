import 'package:antsoup/features/personalization/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../features/authentication/controllers/auth_controller.dart';
import '../images/t_circular_image.dart';

class TUserProfileTitle extends StatelessWidget {
  const TUserProfileTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser.value;
      final networkImage = user?.profilePicture ?? '';
      final image = networkImage.isNotEmpty ? networkImage : TImages.user;
      final userName = user?.name ?? '게스트';
      final userEmail = user?.email ?? '로그인이 필요합니다';

      return ListTile(
        leading: TCircularImage(
          image: image,
          isNetworkImage: networkImage.isNotEmpty,
          width: 50,
          height: 50,
          padding: 0,
          fit: BoxFit.cover,
        ),
        title: Text(
            userName,
            style: Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.white)
        ),
        subtitle: Text(
            userEmail,
            style: Theme.of(context).textTheme.bodyMedium!.apply(color: TColors.white)
        ),
        trailing: IconButton(
            onPressed: () => Get.to(() => const ProfileScreen()),
            icon: const Icon(Iconsax.edit, color: TColors.white)
        ),
      );
    });
  }
}