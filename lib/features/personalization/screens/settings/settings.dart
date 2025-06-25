import 'package:antsoup/common/widgets/appbar/appbar.dart';
import 'package:antsoup/common/widgets/custom_shapes/contaioners/primary_header_contaner.dart';
import 'package:antsoup/common/widgets/list_tiles/setting_menu_tile.dart';
import 'package:antsoup/common/widgets/text/section_heading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/list_tiles/user_profile_tile.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Header
            TPrimaryHeaderContainer(
                child: Column(
                  children: [
                    /// AppBar
                    TAppBar(title: Text('My Profile', style: Theme.of(context).textTheme.headlineMedium!.apply(color: TColors.white))),

                    /// User Profile Card
                    const TUserProfileTitle(),
                    const SizedBox(height: TSizes.spaceBtwSections),
                  ],
                ),
            ),

            /// Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  /// Account Setting
                  const TSectionHeading(title: 'Account Settings', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TSettingsMenuTile(
                    icon: Iconsax.notification,
                    title: 'Notifications',
                    subTitle: 'Set any kind of notification message',
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ),

                  /// Logout Button
                  const SizedBox(height: TSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(onPressed: (){}, child: const Text('Logout')),
                  ),

                  const SizedBox(height: TSizes.spaceBtwSections),
                  Center(
                    child: TextButton(
                      onPressed: (){},
                      child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections * 2.5),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

