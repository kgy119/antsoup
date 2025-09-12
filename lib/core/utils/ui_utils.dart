import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UIUtils {
  // 안전한 하단 패딩 계산
  static double getSafeBottomPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    // 최소 16.h, 최대 시스템 패딩 + 16.h
    return (bottomPadding > 0 ? bottomPadding : 16.h) + 8.h;
  }

  // 안전한 상단 패딩 계산
  static double getSafeTopPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.padding.top;
  }

  // 네비게이션 바 높이 고려한 패딩
  static EdgeInsets getSafeContentPadding(BuildContext context) {
    return EdgeInsets.only(
      top: 0,
      left: 16.w,
      right: 16.w,
      bottom: getSafeBottomPadding(context),
    );
  }

  // 전체 화면 안전 영역 패딩
  static EdgeInsets getFullSafePadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
      bottom: mediaQuery.padding.bottom,
    );
  }
}

// 사용 예시:
// Padding(
//   padding: UIUtils.getSafeContentPadding(context),
//   child: YourWidget(),
// )