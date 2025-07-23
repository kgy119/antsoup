import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';

class TProfileMenu extends StatelessWidget {
  const TProfileMenu({
    super.key,
    this.icon = Iconsax.arrow_right_34,
    required this.onPress,
    required this.title,
    required this.value,
    this.showIcon = true,
  });

  final IconData icon;
  final VoidCallback? onPress; // null 허용으로 변경
  final String title, value;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems / 1.5),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: onPress == null
                        ? Colors.grey
                        : null, // 비활성화 시 회색
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showIcon)
                Expanded(
                  child: Icon(
                    icon,
                    size: 18,
                    color: onPress == null
                        ? Colors.grey
                        : null, // 비활성화 시 회색
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}