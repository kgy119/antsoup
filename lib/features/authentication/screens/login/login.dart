import 'package:antsoup/common/styles/spacing_styles.dart';
import 'package:antsoup/utils/constants/sizes.dart';
import 'package:antsoup/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/login_signup/form_divider.dart';
import '../../../../common/widgets/login_signup/login_form.dart';
import '../../../../common/widgets/login_signup/login_header.dart';
import '../../../../common/widgets/login_signup/social_buttons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHight,
          child: Column(
            children: [
              const TLoginHeader(),

              ///Form
              const TLoginForm(),

              ///Divider
              TFormDivider(dividerText: TTexts.orSignInWith.capitalize!),
              const SizedBox(height: TSizes.spaceBtwItems),

              ///Footer
              const TSocialButtons()
            ],
          ),
        ),
      ),
    );
  }
}





