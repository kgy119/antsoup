import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      // 권한 요청
      await _requestPermissions();

      // 로컬 알림 초기화
      await _initializeLocalNotifications();

      // Firebase 알림 초기화
      await _initializeFirebaseNotifications();
    } catch (e) {
      print('알림 서비스 초기화 실패: $e');
      // 초기화 실패시에도 앱이 계속 실행되도록 함
    }
  }

  static Future<void> _requestPermissions() async {
    try {
      // 알림 권한 요청
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('알림 권한 상태: ${settings.authorizationStatus}');
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

  static Future<void> _initializeFirebaseNotifications() async {
    // 포그라운드 메시지 핸들링
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // 백그라운드 메시지 핸들링
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data['route']);
    });

    // 앱이 종료된 상태에서 알림을 통해 앱이 열렸을 때
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data['route']);
    }

    // FCM 토큰 가져오기
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    // TODO: 서버에 토큰 전송
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'antsoup_channel',
      '개미탕 알림',
      channelDescription: '개미탕 앱의 푸시 알림입니다.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data['route'],
    );
  }

  static void _handleNotificationTap(String? route) {
    if (route != null && route.isNotEmpty) {
      Get.toNamed(route);
    }
  }

  // 로컬 알림 보내기 (테스트용)
  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'antsoup_channel',
      '개미탕 알림',
      channelDescription: '개미탕 앱의 푸시 알림입니다.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      0,
      '개미탕 테스트',
      '푸시 알림이 정상적으로 작동합니다!',
      platformChannelSpecifics,
    );
  }
}