import 'package:antsoup/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';

class TCartCounterIcon extends StatelessWidget {
  const TCartCounterIcon({
    super.key,
    required this.onPressed,
    this.iconColor = TColors.dark,
  });

  final Color? iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Stack(
      children: [
        IconButton(
            onPressed: onPressed,
            icon: Icon(Iconsax.shopping_bag, color: dark ? TColors.light : TColors.dark)),
        Positioned(
            right: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: TColors.black,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Text('2',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .apply(color: TColors.white, fontSizeFactor: 0.8)),
              ),
            ))
      ],
    );
  }
}
