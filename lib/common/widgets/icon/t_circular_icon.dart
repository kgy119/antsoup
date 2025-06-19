import 'package:antsoup/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';

class TCircularIcon extends StatelessWidget {
  const TCircularIcon({
    super.key, this.width, this.height, this.size, required this.icon, this.color, this.backgroundColor, this.onPress,
  });

  final double? width, height, size;
  final IconData icon;
  final Color? color, backgroundColor;
  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: backgroundColor != null
            ? backgroundColor!
            : THelperFunctions.isDarkMode(context)
              ? TColors.black.withOpacity(0.9)
              : TColors.white.withOpacity(0.9),
      ),
      child: IconButton(onPressed: onPress, icon: Icon(icon, color: color, size: size)),
    );
  }
}