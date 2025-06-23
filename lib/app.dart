import 'package:antsoup/bindings/general_bindings.dart';
import 'package:antsoup/features/authentication/screens/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:antsoup/utils/constants/text_strings.dart';
import 'package:antsoup/utils/theme/theme.dart';

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
      initialBinding: GeneralBindings(), // 여기서 바인딩 설정
      home: const OnBoardingScreen(),
    );
  }
}