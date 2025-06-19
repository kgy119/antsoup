import 'package:antsoup/common/widgets/appbar/appbar.dart';
import 'package:antsoup/common/widgets/images/t_circular_image.dart';
import 'package:antsoup/common/widgets/text/section_heading.dart';
import 'package:antsoup/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:antsoup/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/image_strings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text('Profile'),
      ),
      /// body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const TCircularImage(image: TImages.user, width: 80, height: 80),
                    TextButton(onPressed: (){}, child: const Text('Change Pfofile Picture')),
                  ],
                ),
              ),

              /// Details
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading Profile Info
              const TSectionHeading(title: 'Profile Infomation', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(onPress: () {}, title: 'Name', value: 'Kim Gun Young'),
              TProfileMenu(onPress: () {}, title: 'Username', value: 'Kim Gun Young'),

              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading Personal Info
              const TSectionHeading(title: 'Personal Infomation', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(onPress: () {}, title: 'User ID', value: 'Kim Gun Young', icon: Iconsax.copy),
              TProfileMenu(onPress: () {}, title: 'E-mail', value: 'hoyaf798@gmail.com'),
              TProfileMenu(onPress: () {}, title: 'Phone Number', value: '010-1234-5678'),
              TProfileMenu(onPress: () {}, title: 'Gender', value: 'Male'),
              TProfileMenu(onPress: () {}, title: 'Date of Birth', value: '1979.09.09'),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),
              
              Center(
                child: TextButton(
                  onPressed: (){},
                  child: const Text('Close Account', style: TextStyle(color: Colors.red)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

