// lib/core/constants/app_constants.dart

class AppConstants {
  // 앱 정보
  static const String appName = '개미탕';
  static const String appVersion = '1.0.0';

  // 로딩 메시지
  static const List<String> loadingMessages = [
    '개미탕을 끓이는 중...',
    '신선한 종목을 준비하는 중...',
    '개미들이 모이는 중...',
    '뜨거운 정보를 가져오는 중...',
    '맛있는 개미탕 레시피를 찾는 중...',
    '개미 대군이 집결하는 중...',
    '따끈한 개미탕을 준비하는 중...',
    '개미 요리사가 준비하는 중...',
    '특급 개미탕 재료를 모으는 중...',
    '개미 셰프의 비법을 찾는 중...',
  ];

  // 새로고침 메시지
  static const List<String> refreshMessages = [
    '따끈한 최신 정보를 가져왔습니다!',
    '신선한 개미탕이 준비되었습니다!',
    '뜨거운 실시간 데이터를 업데이트했습니다!',
    '개미들의 최신 소식을 전해드립니다!',
    '갓 끓인 개미탕을 서빙합니다!',
    '개미 대군의 최신 동향을 업데이트했습니다!',
    '따끈따끈한 정보가 도착했습니다!',
  ];

  // 에러 메시지
  static const String defaultErrorMessage = '데이터를 불러오는데 실패했습니다.';
  static const String networkErrorMessage = '네트워크 연결을 확인해주세요.';
  static const String serverErrorMessage = '서버에 일시적인 문제가 발생했습니다.';

  // 성공 메시지
  static const String watchlistAddedMessage = '관심종목에 추가되었습니다.';
  static const String watchlistRemovedMessage = '관심종목에서 제거되었습니다.';

  // 기본값
  static const int defaultPageSize = 20;
  static const int maxRetryCount = 3;
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration cacheValidDuration = Duration(minutes: 5);

  // 유틸리티 메서드들
  static String getRandomLoadingMessage() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final index = random % loadingMessages.length;
    return loadingMessages[index];
  }

  static String getRandomRefreshMessage() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final index = random % refreshMessages.length;
    return refreshMessages[index];
  }
}