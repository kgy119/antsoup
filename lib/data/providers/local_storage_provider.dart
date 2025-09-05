import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

class LocalStorageProvider extends GetxService {
  SharedPreferences? _prefs;
  Box? _settingsBox;
  Box? _cacheBox;

  // 초기화 완료 여부를 추적
  bool _isInitialized = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      // SharedPreferences 초기화
      _prefs = await SharedPreferences.getInstance();
      print('SharedPreferences 초기화 완료');

      // Hive 박스 초기화 (안전하게)
      try {
        _settingsBox = await Hive.openBox('settings');
        print('Settings Box 초기화 완료');
      } catch (e) {
        print('Settings Box 초기화 실패: $e');
        // 박스 삭제 후 재생성 시도
        await Hive.deleteBoxFromDisk('settings');
        _settingsBox = await Hive.openBox('settings');
      }

      try {
        _cacheBox = await Hive.openBox('cache');
        print('Cache Box 초기화 완료');
      } catch (e) {
        print('Cache Box 초기화 실패: $e');
        // 박스 삭제 후 재생성 시도
        await Hive.deleteBoxFromDisk('cache');
        _cacheBox = await Hive.openBox('cache');
      }

      _isInitialized = true;
      print('로컬 저장소 초기화 완료');
    } catch (e) {
      print('로컬 저장소 초기화 실패: $e');
      _isInitialized = false;
    }
  }

  // 초기화 대기 메서드
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeStorage();
    }
  }

  // 테마 모드 저장/불러오기 (안전성 추가)
  Future<void> saveThemeMode(bool isDarkMode) async {
    try {
      await _ensureInitialized();
      await _prefs?.setBool('is_dark_mode', isDarkMode);
    } catch (e) {
      print('테마 모드 저장 실패: $e');
    }
  }

  bool getThemeMode() {
    try {
      if (!_isInitialized || _prefs == null) {
        return false; // 기본값 반환
      }
      final result = _prefs!.getBool('is_dark_mode') ?? false;
      print('LocalStorageProvider - getThemeMode(): $result');
      return result;
    } catch (e) {
      print('테마 모드 로드 실패: $e');
      return false;
    }
  }

  // 디바이스 고유 ID 저장/불러오기 (안전성 추가)
  Future<void> saveDeviceId(String deviceId) async {
    try {
      await _ensureInitialized();
      await _prefs?.setString('device_id', deviceId);
    } catch (e) {
      print('디바이스 ID 저장 실패: $e');
    }
  }

  String? getDeviceId() {
    try {
      if (!_isInitialized || _prefs == null) {
        return null;
      }
      return _prefs!.getString('device_id');
    } catch (e) {
      print('디바이스 ID 로드 실패: $e');
      return null;
    }
  }

  // FCM 토큰 저장/불러오기 (안전성 추가)
  Future<void> saveFcmToken(String token) async {
    try {
      await _ensureInitialized();
      await _prefs?.setString('fcm_token', token);
    } catch (e) {
      print('FCM 토큰 저장 실패: $e');
    }
  }

  String? getFcmToken() {
    try {
      if (!_isInitialized || _prefs == null) {
        return null;
      }
      return _prefs!.getString('fcm_token');
    } catch (e) {
      print('FCM 토큰 로드 실패: $e');
      return null;
    }
  }

  // 알림 설정 저장/불러오기 (안전성 추가)
  Future<void> saveNotificationSettings({
    required bool enabled,
    required bool stockAlert,
    required bool communityAlert,
    required bool marketAlert,
  }) async {
    try {
      await _ensureInitialized();
      await _settingsBox?.putAll({
        'notification_enabled': enabled,
        'stock_alert_enabled': stockAlert,
        'community_alert_enabled': communityAlert,
        'market_alert_enabled': marketAlert,
      });
    } catch (e) {
      print('알림 설정 저장 실패: $e');
    }
  }

  Map<String, bool> getNotificationSettings() {
    try {
      if (!_isInitialized || _settingsBox == null) {
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
    } catch (e) {
      print('알림 설정 로드 실패: $e');
      return {
        'notification_enabled': true,
        'stock_alert_enabled': true,
        'community_alert_enabled': true,
        'market_alert_enabled': true,
      };
    }
  }

  // 관심종목 추가
  Future<void> addToWatchlist(String stockCode) async {
    print('LocalStorage - addToWatchlist: $stockCode');

    List<String> currentList = getWatchlist();
    print('LocalStorage - 현재 관심종목: $currentList');

    if (!currentList.contains(stockCode)) {
      currentList.add(stockCode);
      await saveWatchlist(currentList);
      print('LocalStorage - 추가 후 관심종목: ${getWatchlist()}');
    } else {
      print('LocalStorage - 이미 존재하는 종목: $stockCode');
    }
  }

// 관심종목 제거
  Future<void> removeFromWatchlist(String stockCode) async {
    print('LocalStorage - removeFromWatchlist: $stockCode');

    List<String> currentList = getWatchlist();
    print('LocalStorage - 제거 전 관심종목: $currentList');

    currentList.remove(stockCode);
    await saveWatchlist(currentList);
    print('LocalStorage - 제거 후 관심종목: ${getWatchlist()}');
  }

// 관심종목 저장
  Future<void> saveWatchlist(List<String> stockCodes) async {
    print('LocalStorage - saveWatchlist: $stockCodes');
    await _settingsBox?.put('watchlist', stockCodes);

    // 저장 확인
    final saved = getWatchlist();
    print('LocalStorage - 저장 확인: $saved');
  }

// 관심종목 불러오기
  List<String> getWatchlist() {
    final List<dynamic>? cached = _settingsBox?.get('watchlist');
    final result = cached?.cast<String>() ?? [];
    print('LocalStorage - getWatchlist: $result');
    return result;
  }

  Future<void> clearWatchlist() async {
    try {
      await _ensureInitialized();
      await _settingsBox?.delete('watchlist');
    } catch (e) {
      print('관심종목 전체 삭제 실패: $e');
    }
  }

  bool isInWatchlist(String stockCode) {
    try {
      return getWatchlist().contains(stockCode);
    } catch (e) {
      print('관심종목 확인 실패: $e');
      return false;
    }
  }

  // 최근 검색어 관련 메서드들 (안전성 추가)
  Future<void> addRecentSearch(String keyword) async {
    try {
      await _ensureInitialized();
      List<String> recentSearches = getRecentSearches();

      recentSearches.remove(keyword);
      recentSearches.insert(0, keyword);

      if (recentSearches.length > 10) {
        recentSearches = recentSearches.take(10).toList();
      }

      await _cacheBox?.put('recent_searches', recentSearches);
    } catch (e) {
      print('최근 검색어 추가 실패: $e');
    }
  }

  List<String> getRecentSearches() {
    try {
      if (!_isInitialized || _cacheBox == null) {
        return [];
      }
      final List<dynamic>? cached = _cacheBox!.get('recent_searches');
      return cached?.cast<String>() ?? [];
    } catch (e) {
      print('최근 검색어 로드 실패: $e');
      return [];
    }
  }

  Future<void> clearRecentSearches() async {
    try {
      await _ensureInitialized();
      await _cacheBox?.delete('recent_searches');
    } catch (e) {
      print('최근 검색어 삭제 실패: $e');
    }
  }

  // 앱 설정 저장/불러오기 (안전성 추가)
  Future<void> saveAppSettings({
    String? language,
    bool? autoRefresh,
    int? refreshInterval,
  }) async {
    try {
      await _ensureInitialized();
      final Map<String, dynamic> settings = {};

      if (language != null) settings['language'] = language;
      if (autoRefresh != null) settings['auto_refresh'] = autoRefresh;
      if (refreshInterval != null) settings['refresh_interval'] = refreshInterval;

      await _settingsBox?.putAll(settings);
    } catch (e) {
      print('앱 설정 저장 실패: $e');
    }
  }

  Map<String, dynamic> getAppSettings() {
    try {
      if (!_isInitialized || _settingsBox == null) {
        return {
          'language': 'ko',
          'auto_refresh': true,
          'refresh_interval': 30,
        };
      }

      return {
        'language': _settingsBox!.get('language', defaultValue: 'ko'),
        'auto_refresh': _settingsBox!.get('auto_refresh', defaultValue: true),
        'refresh_interval': _settingsBox!.get('refresh_interval', defaultValue: 30),
      };
    } catch (e) {
      print('앱 설정 로드 실패: $e');
      return {
        'language': 'ko',
        'auto_refresh': true,
        'refresh_interval': 30,
      };
    }
  }

  // 캐시 데이터 관련 메서드들 (안전성 추가)
  Future<void> saveCache(String key, dynamic value) async {
    try {
      await _ensureInitialized();
      await _cacheBox?.put(key, value);
    } catch (e) {
      print('캐시 저장 실패: $e');
    }
  }

  T? getCache<T>(String key, {T? defaultValue}) {
    try {
      if (!_isInitialized || _cacheBox == null) {
        return defaultValue;
      }
      return _cacheBox!.get(key, defaultValue: defaultValue);
    } catch (e) {
      print('캐시 로드 실패: $e');
      return defaultValue;
    }
  }

  Future<void> removeCache(String key) async {
    try {
      await _ensureInitialized();
      await _cacheBox?.delete(key);
    } catch (e) {
      print('캐시 삭제 실패: $e');
    }
  }

  Future<void> clearAllCache() async {
    try {
      await _ensureInitialized();
      await _cacheBox?.clear();
    } catch (e) {
      print('캐시 전체 삭제 실패: $e');
    }
  }

  Future<void> resetAppData() async {
    try {
      await _ensureInitialized();
      await _settingsBox?.clear();
    } catch (e) {
      print('앱 데이터 리셋 실패: $e');
    }
  }


}