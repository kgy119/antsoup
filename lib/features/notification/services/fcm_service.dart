import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../utils/loader/loaders.dart';
import '../../authentication/controllers/auth_controller.dart';

/// FCM(Firebase Cloud Messaging) 관리 서비스
class FCMService extends GetxService {
  static FCMService get instance => Get.find();

  late final FirebaseMessaging _firebaseMessaging;
  late final FlutterLocalNotificationsPlugin _localNotifications;

  // FCM 토큰
  final RxString fcmToken = ''.obs;

  // 알림 권한 상태
  final RxBool isNotificationEnabled = false.obs;

  // FCM 사용 가능 여부
  final RxBool isFCMAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFCM();
  }

  /// FCM 초기화
  Future<void> _initializeFCM() async {
    try {
      print('FCM 초기화 시작...');

      // FCM 플러그인 사용 가능 여부 확인
      if (!await _checkFCMAvailability()) {
        print('FCM을 사용할 수 없습니다. 스킵합니다.');
        return;
      }

      _firebaseMessaging = FirebaseMessaging.instance;
      _localNotifications = FlutterLocalNotificationsPlugin();
      isFCMAvailable.value = true;

      // 알림 권한 요청
      await _requestNotificationPermissions();

      // 로컬 알림 초기화
      await _initializeLocalNotifications();

      // FCM 토큰 가져오기
      await _getFCMToken();

      // 메시지 리스너 설정
      _setupMessageListeners();

      print('FCM 초기화 완료');
    } catch (e) {
      print('FCM 초기화 실패: $e');
      isFCMAvailable.value = false;
    }
  }

  /// FCM 사용 가능 여부 확인
  Future<bool> _checkFCMAvailability() async {
    try {
      // 간단한 FCM 메서드 호출로 플러그인 가용성 확인
      await FirebaseMessaging.instance.isSupported();
      return true;
    } on MissingPluginException catch (e) {
      print('FCM 플러그인이 등록되지 않음: $e');
      return false;
    } catch (e) {
      print('FCM 가용성 확인 실패: $e');
      return false;
    }
  }

  /// 알림 권한 요청
  Future<void> _requestNotificationPermissions() async {
    try {
      if (!isFCMAvailable.value) return;

      // iOS/Android 알림 권한 요청
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      isNotificationEnabled.value = settings.authorizationStatus == AuthorizationStatus.authorized;

      print('알림 권한 상태: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('알림 권한 허용됨');
      } else {
        print('알림 권한 거부됨');
      }
    } on MissingPluginException catch (e) {
      print('알림 권한 요청 플러그인 없음: $e');
    } catch (e) {
      print('알림 권한 요청 실패: $e');
    }
  }

  /// 로컬 알림 초기화
  Future<void> _initializeLocalNotifications() async {
    try {
      if (!isFCMAvailable.value) return;

      // Android 알림 채널 생성
      const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
        'default_channel',
        '기본 알림',
        description: '개미탕 기본 알림 채널',
        importance: Importance.high,
      );

      const AndroidNotificationChannel testChannel = AndroidNotificationChannel(
        'test_channel',
        '테스트 알림',
        description: '개미탕 테스트 알림 채널',
        importance: Importance.high,
      );

      // 채널 등록
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(defaultChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(testChannel);

      // 초기화 설정
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      print('로컬 알림 초기화 완료');
    } on MissingPluginException catch (e) {
      print('로컬 알림 플러그인 없음: $e');
    } catch (e) {
      print('로컬 알림 초기화 실패: $e');
    }
  }

  /// FCM 토큰 가져오기
  Future<void> _getFCMToken() async {
    try {
      if (!isFCMAvailable.value) return;

      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        fcmToken.value = token;
        print('FCM 토큰 획득: ${token.substring(0, 20)}...');

        // 토큰이 새로 생성되면 서버에 업데이트
        await _updateTokenToServer(token);
      }

      // 토큰 갱신 리스너 설정
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        fcmToken.value = newToken;
        print('FCM 토큰 갱신됨');
        _updateTokenToServer(newToken);
      });

    } on MissingPluginException catch (e) {
      print('FCM 토큰 플러그인 없음: $e');
    } catch (e) {
      print('FCM 토큰 획득 실패: $e');
    }
  }

  /// 서버에 FCM 토큰 업데이트
  Future<void> _updateTokenToServer(String token) async {
    try {
      // AuthController를 통해 사용자 FCM 토큰 업데이트
      if (Get.isRegistered<dynamic>() && Get.find<dynamic>().runtimeType.toString().contains('AuthController')) {
        final authController = Get.find<dynamic>();
        if (authController.isLoggedIn) {
          await authController.updateFCMToken(token);
          print('서버에 FCM 토큰 업데이트 완료');
        }
      }
    } catch (e) {
      print('서버 FCM 토큰 업데이트 실패: $e');
    }
  }

  /// 메시지 리스너 설정
  void _setupMessageListeners() {
    try {
      if (!isFCMAvailable.value) return;

      // 앱이 포그라운드에 있을 때 메시지 수신
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 앱이 백그라운드에서 알림을 탭했을 때
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // 앱이 종료된 상태에서 알림을 탭해서 앱을 열었을 때
      _handleAppLaunchedFromNotification();
    } catch (e) {
      print('메시지 리스너 설정 실패: $e');
    }
  }

  /// 포그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    print('포그라운드 메시지 수신: ${message.messageId}');
    print('제목: ${message.notification?.title}');
    print('내용: ${message.notification?.body}');

    // 포그라운드에서는 로컬 알림으로 표시
    _showLocalNotification(message);

    // 데이터 처리
    _processMessageData(message);
  }

  /// 백그라운드 메시지 처리
  void _handleBackgroundMessage(RemoteMessage message) {
    print('백그라운드 메시지 탭: ${message.messageId}');

    // 데이터 처리 및 화면 이동
    _processMessageData(message);
  }

  /// 앱 시작 시 알림에서 앱을 열었는지 확인
  Future<void> _handleAppLaunchedFromNotification() async {
    try {
      if (!isFCMAvailable.value) return;

      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();

      if (initialMessage != null) {
        print('앱이 알림으로 시작됨: ${initialMessage.messageId}');
        _processMessageData(initialMessage);
      }
    } on MissingPluginException catch (e) {
      print('초기 메시지 확인 플러그인 없음: $e');
    } catch (e) {
      print('초기 메시지 확인 실패: $e');
    }
  }

  /// 로컬 알림 표시 (포그라운드용)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      if (!isFCMAvailable.value) return;

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'default_channel',
        '기본 알림',
        channelDescription: '개미탕 기본 알림 채널',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? '개미탕',
        message.notification?.body ?? '새로운 알림이 있습니다.',
        notificationDetails,
        payload: message.data.toString(),
      );
    } on MissingPluginException catch (e) {
      print('로컬 알림 플러그인 없음: $e');
    } catch (e) {
      print('로컬 알림 표시 실패: $e');
    }
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    print('알림 탭됨: ${response.payload}');

    // 테스트 알림 처리
    if (response.payload == 'test_notification') {
      TLoaders.infoSnacBar(
        title: '테스트 알림 탭됨',
        message: '로컬 테스트 알림이 정상적으로 작동합니다!',
      );
      return;
    }

    // 기타 알림 데이터 처리
    if (response.payload != null) {
      _navigateToScreen(response.payload!);
    }
  }

  /// 메시지 데이터 처리
  void _processMessageData(RemoteMessage message) {
    Map<String, dynamic> data = message.data;

    print('메시지 데이터: $data');

    // 메시지 타입에 따른 처리
    String? messageType = data['type'];

    switch (messageType) {
      case 'announcement':
        _handleAnnouncementMessage(data);
        break;
      case 'system':
        _handleSystemMessage(data);
        break;
      default:
        _handleDefaultMessage(data);
    }
  }

  /// 공지사항 메시지 처리
  void _handleAnnouncementMessage(Map<String, dynamic> data) {
    print('공지사항 메시지 처리');

    // 공지사항 상세 화면으로 이동하거나 홈화면에 표시
    TLoaders.infoSnacBar(
      title: '📢 공지사항',
      message: data['message'] ?? '새로운 공지사항이 있습니다.',
    );

    // 공지사항 화면으로 이동하는 로직 추가 가능
    // Get.toNamed('/announcements');
  }

  /// 시스템 메시지 처리
  void _handleSystemMessage(Map<String, dynamic> data) {
    print('시스템 메시지 처리');

    TLoaders.infoSnacBar(
      title: '🔔 시스템 알림',
      message: data['message'] ?? '시스템 알림이 있습니다.',
    );
  }

  /// 기본 메시지 처리
  void _handleDefaultMessage(Map<String, dynamic> data) {
    print('기본 메시지 처리');

    // 홈 화면으로 이동
    // Get.offAllNamed('/home');
  }


  /// 채팅 메시지 처리
  void _handleChatMessage(Map<String, dynamic> data) {
    print('채팅 메시지 처리');

    // 채팅방으로 이동
    String? chatRoomId = data['chat_room_id'];
    if (chatRoomId != null) {
      // 채팅방 화면으로 이동하는 로직
      // Get.toNamed('/chat_room', arguments: chatRoomId);
    }
  }

  /// 주식 알림 처리
  void _handleStockAlert(Map<String, dynamic> data) {
    print('주식 알림 처리');

    // 주식 상세 화면으로 이동
    String? stockCode = data['stock_code'];
    if (stockCode != null) {
      // 주식 상세 화면으로 이동하는 로직
      // Get.toNamed('/stock_detail', arguments: stockCode);
    }
  }

  /// 화면 이동 처리
  void _navigateToScreen(String payload) {
    try {
      // payload 파싱하여 화면 이동
      print('화면 이동: $payload');

      // 실제 구현에서는 payload를 JSON으로 파싱하여 적절한 화면으로 이동
    } catch (e) {
      print('화면 이동 실패: $e');
    }
  }

  /// 알림 권한 다시 요청
  Future<void> requestPermissionAgain() async {
    if (!isFCMAvailable.value) {
      TLoaders.warningSnacBar(
        title: 'FCM 사용 불가',
        message: 'FCM 서비스를 사용할 수 없습니다.',
      );
      return;
    }

    await _requestNotificationPermissions();

    if (isNotificationEnabled.value) {
      TLoaders.successSnacBar(
        title: '알림 권한',
        message: '알림 권한이 허용되었습니다.',
      );
    } else {
      TLoaders.warningSnacBar(
        title: '알림 권한',
        message: '알림 권한이 거부되었습니다.',
      );
    }
  }


  /// 토픽 구독
  Future<void> subscribeToTopic(String topic) async {
    if (!isFCMAvailable.value) {
      TLoaders.warningSnacBar(
        title: 'FCM 사용 불가',
        message: 'FCM 서비스를 사용할 수 없습니다.',
      );
      return;
    }

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('토픽 구독 완료: $topic');

      TLoaders.successSnacBar(
        title: '구독 완료',
        message: '$topic 알림을 구독했습니다.',
      );
    } on MissingPluginException catch (e) {
      print('토픽 구독 플러그인 없음: $e');
      TLoaders.errorSnacBar(
        title: '구독 실패',
        message: 'FCM 플러그인이 등록되지 않았습니다.',
      );
    } catch (e) {
      print('토픽 구독 실패: $e');
      TLoaders.errorSnacBar(
        title: '구독 실패',
        message: '토픽 구독에 실패했습니다.',
      );
    }
  }

  /// 토픽 구독 해제
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!isFCMAvailable.value) {
      TLoaders.warningSnacBar(
        title: 'FCM 사용 불가',
        message: 'FCM 서비스를 사용할 수 없습니다.',
      );
      return;
    }

    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('토픽 구독 해제 완료: $topic');

      TLoaders.successSnacBar(
        title: '구독 해제',
        message: '$topic 알림 구독을 해제했습니다.',
      );
    } on MissingPluginException catch (e) {
      print('토픽 구독 해제 플러그인 없음: $e');
      TLoaders.errorSnacBar(
        title: '구독 해제 실패',
        message: 'FCM 플러그인이 등록되지 않았습니다.',
      );
    } catch (e) {
      print('토픽 구독 해제 실패: $e');
      TLoaders.errorSnacBar(
        title: '구독 해제 실패',
        message: '토픽 구독 해제에 실패했습니다.',
      );
    }
  }

  /// 토픽 구독 (스낵바 없이)
  Future<void> subscribeToTopicSilently(String topic) async {
    if (!isFCMAvailable.value) {
      return;
    }

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('토픽 구독 완료 (무음): $topic');
    } on MissingPluginException catch (e) {
      print('토픽 구독 플러그인 없음: $e');
    } catch (e) {
      print('토픽 구독 실패: $e');
    }
  }

  /// 토픽 구독 해제 (스낵바 없이)
  Future<void> unsubscribeFromTopicSilently(String topic) async {
    if (!isFCMAvailable.value) {
      return;
    }

    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('토픽 구독 해제 완료 (무음): $topic');
    } on MissingPluginException catch (e) {
      print('토픽 구독 해제 플러그인 없음: $e');
    } catch (e) {
      print('토픽 구독 해제 실패: $e');
    }
  }
}