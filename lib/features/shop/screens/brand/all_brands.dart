import 'package:antsoup/common/widgets/brands/brand_card.dart';
import 'package:antsoup/common/widgets/layouts/grid_layout.dart';
import 'package:antsoup/common/widgets/text/section_heading.dart';
import 'package:antsoup/features/shop/screens/all_products/all_products.dart';
import 'package:antsoup/features/shop/screens/brand/brand_products.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';

class AllBrandsScreen extends StatelessWidget {
  const AllBrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(showBackArrow: true, title: Text('Brands')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Heading
              TSectionHeading(title: 'Brands', showActionButton: false),
              SizedBox(height: TSizes.spaceBtwItems),

              /// Brands
              TGridLayout(itemCount: 10, mainAxisExtent: 88, itemBuilder: (context, index) => TBrandCard(showBorder: true, onTab: () => Get.to(() => BrandProducts()),)),
            ],
          ),
        ),
      ),
    );
  }
}
