import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';
import 'presentation/widgets/common/main_navigation.dart';
import 'presentation/controllers/main_navigation_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  // Hive 초기화
  await Hive.initFlutter();

  // 알림 서비스 초기화
  await NotificationService.initialize();

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 세로 모드로 고정
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AntSoupApp());
}

class AntSoupApp extends StatelessWidget {
  const AntSoupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 12 기준
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: '개미탕',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialBinding: InitialBinding(),
          home: const MainNavigationWrapper(),
          getPages: AppPages.routes,
          locale: const Locale('ko', 'KR'),
          fallbackLocale: const Locale('ko', 'KR'),
        );
      },
    );
  }
}

class MainNavigationWrapper extends StatelessWidget {
  const MainNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MainNavigationController());
    return const MainNavigation();
  }
}