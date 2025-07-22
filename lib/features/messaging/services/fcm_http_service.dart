import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/constants/api_constants.dart';

/// FCM 관련 HTTP 통신 서비스 (announcements 토픽 전용)
class FCMHttpService {
  static const String _baseUrl = 'http://antsoup.co.kr'; // 실제 서버 URL

  /// FCM 토큰을 서버에 업데이트
  static Future<bool> updateFCMToken({
    required String uid,
    required String fcmToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/fcm/update-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tSecretAPIKey', // API 키 사용
        },
        body: json.encode({
          'uid': uid,
          'fcm_token': fcmToken,
          'platform': 'flutter',
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('서버 FCM 토큰 업데이트 성공');
        return true;
      } else {
        print('서버 FCM 토큰 업데이트 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('서버 FCM 토큰 업데이트 에러: $e');
      return false;
    }
  }

  /// 테스트 알림 요청
  static Future<bool> sendTestNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/fcm/send-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tSecretAPIKey',
        },
        body: json.encode({
          'fcm_token': fcmToken,
          'title': title,
          'body': body,
          'data': data ?? {},
          'type': 'test',
        }),
      );

      if (response.statusCode == 200) {
        print('테스트 알림 전송 성공');
        return true;
      } else {
        print('테스트 알림 전송 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('테스트 알림 전송 에러: $e');
      return false;
    }
  }

  /// 공지사항 알림 전송 (announcements 토픽)
  static Future<bool> sendAnnouncementNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/fcm/send-announcement'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tSecretAPIKey',
        },
        body: json.encode({
          'topic': 'announcements',
          'title': title,
          'body': body,
          'data': {
            'type': 'announcement',
            'timestamp': DateTime.now().toIso8601String(),
            ...?data,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('공지사항 알림 전송 성공');
        return true;
      } else {
        print('공지사항 알림 전송 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('공지사항 알림 전송 에러: $e');
      return false;
    }
  }

  /// FCM 토큰 유효성 검증
  static Future<bool> validateFCMToken(String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/fcm/validate-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tSecretAPIKey',
        },
        body: json.encode({
          'fcm_token': fcmToken,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('FCM 토큰 검증 에러: $e');
      return false;
    }
  }

  /// 서버에서 전체 공지사항 전송 (관리자용)
  static Future<bool> sendGlobalAnnouncement({
    required String title,
    required String message,
    String? actionUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/fcm/send-global-announcement'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tSecretAPIKey',
        },
        body: json.encode({
          'title': title,
          'body': message,
          'topic': 'announcements',
          'data': {
            'type': 'announcement',
            'action_url': actionUrl,
            'timestamp': DateTime.now().toIso8601String(),
            ...?additionalData,
          },
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('전체 공지사항 전송 에러: $e');
      return false;
    }
  }
}