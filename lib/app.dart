import 'package:antsoup/features/authentication/screens/onboarding/onboarding.dart';
import 'package:antsoup/features/authentication/screens/login/login.dart';
import 'package:antsoup/features/authentication/controllers.onboarding/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:antsoup/utils/constants/text_strings.dart';
import 'package:antsoup/utils/theme/theme.dart';

import 'bindings/general_bindings.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: TTexts.appName,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialBinding: GeneralBindings(),
      // 온보딩 완료 여부에 따라 시작 화면 결정
      home: OnBoardingController.isOnBoardingComplete()
          ? const LoginScreen()
          : const OnBoardingScreen(),
    );
  }
}