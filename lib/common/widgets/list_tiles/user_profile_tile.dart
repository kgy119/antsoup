import 'package:antsoup/common/widgets/images/t_circular_image.dart';
import 'package:antsoup/features/personalization/controllers/user_controller.dart';
import 'package:antsoup/features/personalization/screens/profile/profile.dart';
import 'package:antsoup/utils/constants/colors.dart';
import 'package:antsoup/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TUserProfileTitle extends StatelessWidget {
  const TUserProfileTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());

    return ListTile(
      leading: Obx(() => TCircularImage(
        image: controller.userProfile.profilePicture ?? TImages.user,
        width: 50,
        height: 50,
        padding: 0,
        isNetworkImage: controller.userProfile.profilePicture != null,
      )),
      title: Obx(() => Text(
        controller.userProfile.fullName.isEmpty
            ? controller.userProfile.username
            : controller.userProfile.fullName,
        style: Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.white),
      )),
      subtitle: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.userProfile.email,
            style: Theme.of(context).textTheme.bodyMedium!.apply(color: TColors.white),
          ),
          if (controller.userProfile.phoneNumber != null) ...[
            const SizedBox(height: 2),
            Text(
              controller.userProfile.phoneNumber!,
              style: Theme.of(context).textTheme.bodySmall!.apply(color: TColors.white),
            ),
          ],
          const SizedBox(height: 4),

          /// Email and Phone Verification Status
          Row(
            children: [
              if (!controller.userProfile.emailVerified) ...[
                Icon(
                  Iconsax.warning_2,
                  size: 12,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  '이메일 미인증',
                  style: Theme.of(context).textTheme.bodySmall!.apply(color: Colors.orange),
                ),
                const SizedBox(width: 8),
              ],
              if (controller.userProfile.emailVerified) ...[
                Icon(
                  Iconsax.verify,
                  size: 12,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  '인증됨',
                  style: Theme.of(context).textTheme.bodySmall!.apply(color: Colors.green),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),

          const SizedBox(height: 4),

          /// Profile Completeness Indicator
          Row(
            children: [
              Text(
                '프로필 ${(controller.profileCompleteness * 100).toInt()}% 완성',
                style: Theme.of(context).textTheme.bodySmall!.apply(color: TColors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: controller.profileCompleteness,
                  backgroundColor: TColors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    controller.profileCompleteness < 0.5
                        ? Colors.red
                        : controller.profileCompleteness < 0.8
                        ? Colors.orange
                        : Colors.green,
                  ),
                  minHeight: 2,
                ),
              ),
            ],
          ),
        ],
      )),
      trailing: IconButton(
        onPressed: () => Get.to(() => const ProfileScreen()),
        icon: const Icon(Iconsax.edit, color: TColors.white),
      ),
      onTap: () => Get.to(() => const ProfileScreen()),
    );
  }
}