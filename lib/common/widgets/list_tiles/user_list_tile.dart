import 'package:antsoup/utils/helpers/time_helper.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../features/authentication/models/user_model.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../images/t_circular_image.dart';

class TUserListTile extends StatelessWidget {
  const TUserListTile({
    super.key,
    required this.user,
    this.onTap,
    this.showLastSeen = true,
  });

  final UserModel user;
  final VoidCallback? onTap;
  final bool showLastSeen;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: TSizes.defaultSpace,
        vertical: TSizes.xs,
      ),
      leading: TCircularImage(
        image: user.profilePicture ?? 'assets/images/content/user.png',
        isNetworkImage: user.hasProfilePicture,
        width: 50,
        height: 50,
        padding: 0,
      ),
      title: Text(
        user.name,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: showLastSeen && user.lastLoginAt != null
          ? Text(
        TTimeHelper.getLastSeenText(user.lastLoginAt!),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: dark ? TColors.darkGrey : TColors.textSecondary,
        ),
      ) : null,
      trailing: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 50,
          height: 56, // ListTile 기본 높이에 맞게 조정
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 메시지 아이콘
              Icon(
                Iconsax.message,
                size: 22, // 아이콘 크기 증가
                color: dark ? TColors.darkGrey : TColors.textSecondary,
              ),
              const SizedBox(height: 6),
              // 온라인 상태 표시
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: TTimeHelper.isRecentlyActive(user.lastLoginAt)
                      ? TColors.success
                      : TColors.darkGrey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dark ? TColors.black : TColors.white,
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}