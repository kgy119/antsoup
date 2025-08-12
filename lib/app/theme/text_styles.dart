import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  // 제목 스타일
  static TextStyle get headline1 => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w800, // Bold
    fontFamily: 'Poppins',
    height: 1.2,
  );

  static TextStyle get headline2 => TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.w800, // Bold
    fontFamily: 'Poppins',
    height: 1.2,
  );

  static TextStyle get headline3 => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600, // SemiBold
    fontFamily: 'Poppins',
    height: 1.3,
  );

  static TextStyle get headline4 => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600, // SemiBold
    fontFamily: 'Poppins',
    height: 1.3,
  );

  static TextStyle get headline5 => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600, // SemiBold
    fontFamily: 'Poppins',
    height: 1.3,
  );

  static TextStyle get headline6 => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600, // SemiBold
    fontFamily: 'Poppins',
    height: 1.3,
  );

  // 본문 스타일
  static TextStyle get bodyText1 => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400, // Regular
    fontFamily: 'Poppins',
    height: 1.5,
  );

  static TextStyle get bodyText2 => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400, // Regular
    fontFamily: 'Poppins',
    height: 1.5,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w300, // Light
    fontFamily: 'Poppins',
    height: 1.4,
  );

  static TextStyle get button => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500, // Medium
    fontFamily: 'Poppins',
    height: 1.2,
  );

  // 주식 관련 스타일
  static TextStyle get stockPrice => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w800, // Bold
    fontFamily: 'Poppins',
    height: 1.2,
  );

  static TextStyle get stockChange => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500, // Medium
    fontFamily: 'Poppins',
    height: 1.2,
  );

  static TextStyle get stockCode => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w300, // Light
    fontFamily: 'Poppins',
    height: 1.2,
    color: Colors.grey,
  );
}