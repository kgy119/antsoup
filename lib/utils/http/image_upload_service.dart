import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'dart:convert';

class TImageUploadService {
  static const String _baseUrl = 'http://antsoup.co.kr/api';

  /// 프로필 이미지 업로드
  static Future<Map<String, dynamic>> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {

      final uri = Uri.parse('$_baseUrl/upload_profile_image.php');
      final request = http.MultipartRequest('POST', uri);

      // 헤더 추가
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
      });

      // 파일 첨부 (MIME 타입 명시)
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      String mimeType;

      switch (fileExtension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg'; // 기본값
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'profile_image',
        await imageFile.readAsBytes(),
        filename: 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension',
        contentType: http_parser.MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);
      request.fields['user_id'] = userId;

      print('업로드 요청 전송 중... (MIME: $mimeType)');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return {
            'success': true,
            'file_url': responseData['data']['file_url'],
            'message': responseData['message'],
          };
        } else {
          throw Exception(responseData['message'] ?? '업로드 실패');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }

    } catch (e) {
      print('이미지 업로드 오류: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// 이미지 URL 검증
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return validExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  /// 서버 이미지 URL을 전체 URL로 변환
  static String getFullImageUrl(String relativePath) {
    if (relativePath.startsWith('http')) {
      return relativePath;
    }
    return 'http://antsoup.co.kr/$relativePath';
  }
}