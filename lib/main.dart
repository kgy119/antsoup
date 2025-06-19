import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/config/bindings/auth_binding.dart';
import 'core/config/bindings/initial_binding.dart';
import 'core/config/bindings/splash_binding.dart';
import 'core/config/theme.dart';
import 'features/auth/views/login_screen.dart';
import 'features/auth/views/register_screen.dart';
import 'features/splash/views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AntSoup',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Use InitialBinding for app-wide dependencies
      initialBinding: InitialBinding(),

      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(),
          binding: SplashBinding(),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
          binding: AuthBinding(),
        ),
        // Add more routes here as you expand your app
        // GetPage(
        //   name: '/home',
        //   page: () => const HomeScreen(),
        //   binding: HomeBinding(),
        // ),
      ],
    );
  }
}