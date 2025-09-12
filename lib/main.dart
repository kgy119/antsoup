import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';
import 'core/services/notification_service.dart';
import 'presentation/widgets/common/main_navigation.dart';
import 'presentation/controllers/main_navigation_controller.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print('앱이 포그라운드로 전환됨');
        break;
      case AppLifecycleState.inactive:
        print('앱이 비활성화됨');
        break;
      case AppLifecycleState.paused:
        print('앱이 백그라운드로 전환됨');
        break;
      case AppLifecycleState.detached:
        print('앱이 종료됨');
        break;
      case AppLifecycleState.hidden:
        print('앱이 숨겨짐');
        break;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== Firebase 없이 앱 시작 ===');

  // 앱 생명주기 관찰자 추가
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());

  // Hive 초기화만
  try {
    await Hive.initFlutter();
    print('Hive 초기화 성공');
  } catch (e) {
    print('Hive 초기화 실패: $e');
  }

  // 로컬 알림만 초기화
  try {
    await NotificationService.initialize();
    print('로컬 알림 서비스 초기화 성공');
  } catch (e) {
    print('로컬 알림 서비스 초기화 실패: $e');
  }

  // 갤럭시 S24 등 최신 안드로이드 기기 대응
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent, // 투명하게 변경
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent, // 추가
    ),
  );

  // Edge-to-edge 디스플레이 설정
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge, // 전체 화면 사용
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AntSoupApp());
  print('=== Firebase 없이 앱 실행 완료 ===');
}

class AntSoupApp extends StatelessWidget {
  const AntSoupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return FutureBuilder<ThemeMode>(
          future: _getInitialThemeMode(),
          builder: (context, snapshot) {
            final themeMode = snapshot.data ?? ThemeMode.system;

            return GetMaterialApp(
              title: '개미탕',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              initialBinding: InitialBinding(),
              home: const MainNavigationWrapper(),
              getPages: AppPages.routes,
              locale: const Locale('ko', 'KR'),
              fallbackLocale: const Locale('ko', 'KR'),
            );
          },
        );
      },
    );
  }

  Future<ThemeMode> _getInitialThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      return isDarkMode ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      print('테마 설정 로드 실패: $e');
      return ThemeMode.system;
    }
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