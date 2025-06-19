import 'package:antsoup/features/shop/screens/all_products/all_products.dart';
import 'package:antsoup/features/shop/screens/home/widgets/home_appbar.dart';
import 'package:antsoup/features/shop/screens/home/widgets/home_categories.dart';
import 'package:antsoup/features/shop/screens/home/widgets/promo_slider.dart';
import 'package:antsoup/utils/constants/image_strings.dart';
import 'package:antsoup/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/custom_shapes/contaioners/primary_header_contaner.dart';
import '../../../../common/widgets/custom_shapes/contaioners/search_container.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/products/product_cards/product_cards_vertical.dart';
import '../../../../common/widgets/text/section_heading.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const TPrimaryHeaderContainer(
              child: Column(
                children: [

                  /// appbar
                  THomeAppBar(),
                  SizedBox(height: TSizes.spaceBtwSections),

                  /// searchbar
                  TSearchContaioner(text: 'Search in Store'),
                  SizedBox(height: TSizes.spaceBtwSections),

                  /// Caregories
                  Padding(
                    padding: EdgeInsets.only(left: TSizes.defaultSpace),
                    child: Column(
                      children: [

                        /// Heading
                        TSectionHeading(title: 'Popular Caregories',
                            showActionButton: false,
                            textColor: Colors.white),
                        SizedBox(height: TSizes.spaceBtwItems),

                        /// Categories
                        THomeCategories(),
                      ],
                    ),
                  ),

                  SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),),

            /// Body -- banners
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [

                  /// Promo Slider
                  const TPromoSlider(banners: [
                    TImages.promoBanner1,
                    TImages.promoBanner2,
                    TImages.promoBanner3
                  ]),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Heading
                  TSectionHeading(title: 'Popular Products', onPressed: () => Get.to(() => const AllProductsScreen())),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Popular Products
                  TGridLayout(itemCount: 4, itemBuilder: (_ , index) => const TProductCardVertical(),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
















