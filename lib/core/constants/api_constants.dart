class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://antsoup.co.kr/api';

  // 주식 관련 엔드포인트
  static const String popularStocks = '/stocks/popular';
  static const String antInterestStocks = '/stocks/ant-interest';
  static const String stockDetail = '/stocks/{code}';
  static const String searchStocks = '/stocks/search';

  // 시장 지수 엔드포인트
  static const String marketIndexes = '/market/indexes';

  // 커뮤니티 관련 엔드포인트
  static const String communityPosts = '/community/posts';
  static const String createPost = '/community/posts';
  static const String postComments = '/community/posts/{id}/comments';

  // 차트 데이터 엔드포인트
  static const String stockChart = '/stocks/{code}/chart';
  static const String marketChart = '/market/chart';

  // 알림 관련 엔드포인트
  static const String registerFcm = '/notification/register-token';
  static const String watchlistAdd = '/watchlist/add';
  static const String watchlistRemove = '/watchlist/{code}';
  static const String getWatchlist = '/watchlist';

  // 통계 관련 엔드포인트
  static const String stockStatistics = '/statistics/stocks';
  static const String marketStatistics = '/statistics/market';
  static const String antStatistics = '/statistics/ants';

  // 뉴스 관련 엔드포인트
  static const String stockNews = '/news/stocks';
  static const String marketNews = '/news/market';
}