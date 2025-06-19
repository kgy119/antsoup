import 'package:antsoup/common/widgets/images/t_rounded_image.dart';
import 'package:antsoup/common/widgets/products/product_cards/product_card_horizontal.dart';
import 'package:antsoup/common/widgets/text/section_heading.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(showBackArrow: true, title: Text('Sports')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Banner
              const TRoundedImage(imageUrl: TImages.promoBanner3, applyImageRadius: true, width: double.infinity),
              const SizedBox(height: TSizes.spaceBtwSections),
              
              /// Sub-Categories
              Column(
                children: [
                  /// Heading
                  TSectionHeading(title: 'Sports shirts', onPressed: (){}),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),

                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      itemCount: 4,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (_,__) => const SizedBox(width: TSizes.spaceBtwItems),
                        itemBuilder: (context, index) => const TProductCardHorizontal(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}
