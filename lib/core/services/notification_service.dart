import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      print('로컬 알림 서비스만 초기화 시작');
      await _requestPermissions();
      await _initializeLocalNotifications();
      print('로컬 알림 서비스 초기화 완료');
    } catch (e) {
      print('로컬 알림 서비스 초기화 실패: $e');
    }
  }

  static Future<void> _requestPermissions() async {
    try {
      final status = await Permission.notification.request();
      print('알림 권한 상태: $status');
    } catch (e) {
      print('알림 권한 요청 실패: $e');
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );
  }

  static void _handleNotificationTap(String? route) {
    if (route != null && route.isNotEmpty) {
      Get.toNamed(route);
    }
  }

  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'antsoup_channel',
      '개미탕 알림',
      channelDescription: '개미탕 앱의 로컬 알림입니다.',
      importance: Importance.max,
      priority: Priority.high,
    );

    // iOS 알림 설정 수정
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics, // 올바른 타입으로 수정
    );

    await _localNotifications.show(
      0,
      '개미탕 테스트',
      'Firebase 없이 로컬 알림 테스트!',
      platformChannelSpecifics,
    );
  }
}