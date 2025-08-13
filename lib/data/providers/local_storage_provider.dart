import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

class LocalStorageProvider extends GetxService {
  SharedPreferences? _prefs;
  Box? _settingsBox;
  Box? _cacheBox;

  LocalStorageProvider() {
    _initializeStorage();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _settingsBox = await Hive.openBox('settings');
      _cacheBox = await Hive.openBox('cache');
      print('로컬 저장소 초기화 완료');
    } catch (e) {
      print('로컬 저장소 초기화 실패: $e');
    }
  }

  // 테마 모드 저장/불러오기
  Future<void> saveThemeMode(bool isDarkMode) async {
    await _prefs?.setBool('is_dark_mode', isDarkMode);
  }

  bool getThemeMode() {
    final result = _prefs?.getBool('is_dark_mode') ?? false;
    print('LocalStorageProvider - getThemeMode(): $result');
    return result;
  }
  // 디바이스 고유 ID 저장/불러오기 (익명 사용자 구분용)
  Future<void> saveDeviceId(String deviceId) async {
    await _prefs?.setString('device_id', deviceId);
  }

  String? getDeviceId() {
    return _prefs?.getString('device_id');
  }

  // FCM 토큰 저장/불러오기
  Future<void> saveFcmToken(String token) async {
    await _prefs?.setString('fcm_token', token);
  }

  String? getFcmToken() {
    return _prefs?.getString('fcm_token');
  }

  // 알림 설정 저장/불러오기
  Future<void> saveNotificationSettings({
    required bool enabled,
    required bool stockAlert,
    required bool communityAlert,
    required bool marketAlert,
  }) async {
    await _settingsBox?.putAll({
      'notification_enabled': enabled,
      'stock_alert_enabled': stockAlert,
      'community_alert_enabled': communityAlert,
      'market_alert_enabled': marketAlert,
    });
  }

  Map<String, bool> getNotificationSettings() {
    if (_settingsBox == null) {
      return {
        'notification_enabled': true,
        'stock_alert_enabled': true,
        'community_alert_enabled': true,
        'market_alert_enabled': true,
      };
    }

    return {
      'notification_enabled': _settingsBox!.get('notification_enabled', defaultValue: true),
      'stock_alert_enabled': _settingsBox!.get('stock_alert_enabled', defaultValue: true),
      'community_alert_enabled': _settingsBox!.get('community_alert_enabled', defaultValue: true),
      'market_alert_enabled': _settingsBox!.get('market_alert_enabled', defaultValue: true),
    };
  }

  // 관심 종목 로컬 저장 (캐시)
  Future<void> saveWatchlistCache(List<String> stockCodes) async {
    await _settingsBox?.put('watchlist', stockCodes);
  }

  List<String> getWatchlistCache() {
    final List<dynamic>? cached = _cacheBox?.get('watchlist');
    return cached?.cast<String>() ?? [];
  }

  // 최근 검색어 저장/불러오기
  Future<void> addRecentSearch(String keyword) async {
    List<String> recentSearches = getRecentSearches();

    // 중복 제거
    recentSearches.remove(keyword);

    // 맨 앞에 추가
    recentSearches.insert(0, keyword);

    // 최대 10개까지만 저장
    if (recentSearches.length > 10) {
      recentSearches = recentSearches.take(10).toList();
    }

    await _cacheBox?.put('recent_searches', recentSearches);
  }

  List<String> getRecentSearches() {
    final List<dynamic>? cached = _cacheBox?.get('recent_searches');
    return cached?.cast<String>() ?? [];
  }

  Future<void> clearRecentSearches() async {
    await _cacheBox?.delete('recent_searches');
  }

  // 앱 설정 저장/불러오기
  Future<void> saveAppSettings({
    String? language,
    bool? autoRefresh,
    int? refreshInterval,
  }) async {
    final Map<String, dynamic> settings = {};

    if (language != null) settings['language'] = language;
    if (autoRefresh != null) settings['auto_refresh'] = autoRefresh;
    if (refreshInterval != null) settings['refresh_interval'] = refreshInterval;

    await _settingsBox?.putAll(settings);
  }

  Map<String, dynamic> getAppSettings() {
    if (_settingsBox == null) {
      return {
        'language': 'ko',
        'auto_refresh': true,
        'refresh_interval': 30,
      };
    }

    return {
      'language': _settingsBox!.get('language', defaultValue: 'ko'),
      'auto_refresh': _settingsBox!.get('auto_refresh', defaultValue: true),
      'refresh_interval': _settingsBox!.get('refresh_interval', defaultValue: 30), // 초 단위
    };
  }

  // 캐시 데이터 저장/불러오기 (일반적인 용도)
  Future<void> saveCache(String key, dynamic value) async {
    await _cacheBox?.put(key, value);
  }

  T? getCache<T>(String key, {T? defaultValue}) {
    return _cacheBox?.get(key, defaultValue: defaultValue);
  }

  Future<void> removeCache(String key) async {
    await _cacheBox?.delete(key);
  }

  Future<void> clearAllCache() async {
    await _cacheBox?.clear();
  }

  // 앱 데이터 정리 (회원가입 없으므로 로그아웃 개념 없음)
  Future<void> resetAppData() async {
    await _settingsBox?.clear();
    // 사용자 설정만 초기화, 캐시는 유지
  }
}