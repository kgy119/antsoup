import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:logger/logger.dart';

class ApiService extends getx.GetxService {
  late Dio _dio;
  final Logger _logger = Logger();

  static const String baseUrl = 'http://antsoup.co.kr/api';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  @override
  Future<void> onInit() async {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: connectTimeout),
        receiveTimeout: const Duration(milliseconds: receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 인터셉터 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('요청: ${options.method} ${options.path}');
          _logger.d('헤더: ${options.headers}');
          _logger.d('데이터: ${options.data}');

          // TODO: 토큰이 있으면 헤더에 추가
          // final token = SharedPreferences의 토큰;
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }

          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('응답: ${response.statusCode} ${response.requestOptions.path}');
          _logger.d('응답 데이터: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('에러: ${error.requestOptions.path}');
          _logger.e('에러 메시지: ${error.message}');
          _logger.e('에러 응답: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }

  // GET 요청
  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST 요청
  Future<Response<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT 요청
  Future<Response<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE 요청
  Future<Response<T>> delete<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 에러 처리
  Exception _handleError(DioException error) {
    String message = '';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = '연결 시간이 초과되었습니다.';
        break;
      case DioExceptionType.sendTimeout:
        message = '요청 시간이 초과되었습니다.';
        break;
      case DioExceptionType.receiveTimeout:
        message = '응답 시간이 초과되었습니다.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            message = '잘못된 요청입니다.';
            break;
          case 401:
            message = '인증이 필요합니다.';
            // TODO: 로그인 페이지로 이동
            break;
          case 403:
            message = '접근 권한이 없습니다.';
            break;
          case 404:
            message = '요청한 리소스를 찾을 수 없습니다.';
            break;
          case 500:
            message = '서버 오류가 발생했습니다.';
            break;
          default:
            message = '알 수 없는 오류가 발생했습니다. (코드: $statusCode)';
        }
        break;
      case DioExceptionType.cancel:
        message = '요청이 취소되었습니다.';
        break;
      case DioExceptionType.unknown:
        message = '네트워크 연결을 확인해주세요.';
        break;
      default:
        message = '알 수 없는 오류가 발생했습니다.';
    }

    return Exception(message);
  }
}