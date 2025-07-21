import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'utils/helpers/app_lifecycle_handler.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // GetStorage 초기화
  await GetStorage.init();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 앱 생명주기 관리자 초기화
  AppLifecycleHandler.instance.initialize();

  runApp(const App());
}