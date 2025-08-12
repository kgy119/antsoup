import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/providers/local_storage_provider.dart';

class DeviceUtils {
  static const _chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static final Random _random = Random();

  // 디바이스 고유 ID 생성 또는 가져오기
  static Future<String> getOrCreateDeviceId() async {
    final localStorage = Get.find<LocalStorageProvider>();

    // 기존에 저장된 디바이스 ID가 있는지 확인
    String? existingId = localStorage.getDeviceId();
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    // 새로운 디바이스 ID 생성
    String newDeviceId = await _generateDeviceId();
    await localStorage.saveDeviceId(newDeviceId);

    return newDeviceId;
  }

  // 디바이스 ID 생성 (플랫폼별 정보 + 랜덤 문자열)
  static Future<String> _generateDeviceId() async {
    try {
      String platformInfo = '';

      if (Platform.isAndroid) {
        platformInfo = 'AND_';
      } else if (Platform.isIOS) {
        platformInfo = 'IOS_';
      } else {
        platformInfo = 'UNK_';
      }

      // 현재 타임스탬프 + 랜덤 문자열
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String randomString = _generateRandomString(8);

      return '${platformInfo}${timestamp}_$randomString';
    } catch (e) {
      // 플랫폼 정보를 가져올 수 없는 경우 완전 랜덤 생성
      return 'DEV_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(12)}';
    }
  }

  // 랜덤 문자열 생성
  static String _generateRandomString(int length) {
    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => _chars.codeUnitAt(_random.nextInt(_chars.length)),
      ),
    );
  }

  // 플랫폼 정보 가져오기
  static Map<String, String> getPlatformInfo() {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'isAndroid': Platform.isAndroid.toString(),
      'isIOS': Platform.isIOS.toString(),
    };
  }

  // 앱 버전 정보 (패키지에서 가져오기)
  static Future<Map<String, String>> getAppInfo() async {
    try {
      // TODO: package_info_plus 패키지 사용 시 실제 앱 정보 가져오기
      return {
        'app_name': '개미탕',
        'package_name': 'co.kr.antsoup',
        'version': '1.0.0',
        'build_number': '1',
      };
    } catch (e) {
      return {
        'app_name': '개미탕',
        'package_name': 'co.kr.antsoup',
        'version': 'unknown',
        'build_number': 'unknown',
      };
    }
  }
}