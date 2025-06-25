import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../utils/local_storage/storage_utility.dart';
import '../screens/login/login.dart';

class OnBoardingController extends GetxController{
  static OnBoardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  void updatePageIndicator(index) => currentPageIndex.value = index;

  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  void nextPage() {
    if(currentPageIndex.value == 2){
      // 온보딩 완료 상태를 저장
      _setOnBoardingComplete();
      Get.offAll(() => const LoginScreen());
    }else{
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  void skipPage() {
    // 온보딩 완료 상태를 저장
    _setOnBoardingComplete();
    Get.offAll(() => const LoginScreen());
  }

  // 온보딩 완료 상태를 로컬 저장소에 저장
  void _setOnBoardingComplete() {
    final storage = TLocalStorage();
    storage.saveData('isOnBoardingComplete', true);
  }

  // 온보딩 완료 상태 확인
  static bool isOnBoardingComplete() {
    final storage = TLocalStorage();
    return storage.readData<bool>('isOnBoardingComplete') ?? false;
  }
}