// lib/app.dart
import 'package:antsoup/features/authentication/screens/onboarding/onboarding.dart';
import 'package:antsoup/features/authentication/screens/login/login.dart';
import 'package:antsoup/features/authentication/controllers.onboarding/onboarding_controller.dart';
import 'package:antsoup/features/authentication/controllers/auth_controller.dart';
import 'package:antsoup/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get.dart';
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
      home: const AuthStateHandler(),
    );
  }
}

/// 인증 상태에 따라 적절한 화면을 표시하는 핸들러
class AuthStateHandler extends StatefulWidget {
  const AuthStateHandler({super.key});

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    // 약간의 지연 (스플래시 효과)
    await Future.delayed(const Duration(seconds: 2));

    // AuthController 초기화 및 상태 확인
    final authController = Get.put(AuthController());

    // AuthController가 완전히 초기화될 때까지 대기
    while (!authController.isInitialized.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // 온보딩 완료 여부 확인
    final isOnBoardingComplete = OnBoardingController.isOnBoardingComplete();

    if (!isOnBoardingComplete) {
      // 온보딩 미완료 시 온보딩 화면으로
      print('온보딩 화면으로 이동');
      Get.offAll(() => const OnBoardingScreen());
    } else if (authController.isLoggedIn) {
      // 저장된 로그인 상태가 있으면 메인 화면으로
      print('저장된 로그인 상태 확인됨 - 메인 화면으로 이동');
      Get.offAll(() => const NavigationMenu());
    } else {
      // 로그인이 필요하면 로그인 화면으로
      print('로그인 화면으로 이동');
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.restaurant,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // 앱 이름
            Text(
              TTexts.appName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 로딩 인디케이터
            const CircularProgressIndicator(),
            const SizedBox(height: 16),

            // 상태 메시지
            Text(
              '로그인 상태 확인 중...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}