import 'package:carousel_slider/carousel_slider.dart';
import 'package:antsoup/features/shop/controllers/home_controller.dart';
import 'package:antsoup/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/custom_shapes/contaioners/circular_container.dart';
import '../../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../../utils/constants/sizes.dart';

class TPromoSlider extends StatelessWidget {
  const TPromoSlider({
    super.key, required this.banners,
  });

  final List<String> banners;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 1,
              onPageChanged: (index, _) => controller.updatePageIndicator(index)
            ),
            items: banners.map((url) => TRoundedImage(imageUrl: url)).toList(),
          ),

          const SizedBox(height: TSizes.spaceBtwItems),
          Center(
            child: Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for(int i=0; i<banners.length; i++)
                    TCircularContaioner(
                      width: 20,
                      height: 4,
                      margin: const EdgeInsets.only(right: 10),
                      backgroundColor: controller.carousalCurrentIndex == i ? TColors.primary : TColors.grey,
                    ),
                  ],
                ),
            ),
          )
        ],
      ),
    );
  }
}

