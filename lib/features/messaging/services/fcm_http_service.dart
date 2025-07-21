import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/constants/api_constants.dart';

/// FCM 관련 HTTP 통신 서비스
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

  /// 채팅 메시지 알림 전송
  static Future<bool> sendChatNotification({
    required String targetFCMToken,
    required String senderName,
    required String message,
    required String chatRoomId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/fcm/send-chat-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tSecretAPIKey',
        },
        body: json.encode({
          'fcm_token': targetFCMToken,
          'title': senderName,
          'body': message,
          'data': {
            'type': 'chat',
            'chat_room_id': chatRoomId,
            'sender_name': senderName,
          },
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('채팅 알림 전송 에러: $e');
      return false;
    }
  }

  /// 주식 알림 전송
  static Future<bool> sendStockAlert({
    required List<String> fcmTokens,
    required String stockName,
    required String alertMessage,
    required String stockCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/fcm/send-stock-alert'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tSecretAPIKey',
        },
        body: json.encode({
          'fcm_tokens': fcmTokens,
          'title': '주식 알림: $stockName',
          'body': alertMessage,
          'data': {
            'type': 'stock_alert',
            'stock_code': stockCode,
            'stock_name': stockName,
          },
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('주식 알림 전송 에러: $e');
      return false;
    }
  }

  /// 토픽별 알림 전송
  static Future<bool> sendTopicNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/fcm/send-topic-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tSecretAPIKey',
        },
        body: json.encode({
          'topic': topic,
          'title': title,
          'body': body,
          'data': data ?? {},
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('토픽 알림 전송 에러: $e');
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
}