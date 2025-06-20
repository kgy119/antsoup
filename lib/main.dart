import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';
import 'bindings/general_bindings.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // GetStorage 초기화
  await GetStorage.init();

  // 일반 바인딩 설정
  await Get.putAsync(() => GeneralBindings().dependencies());

  runApp(const App());
}