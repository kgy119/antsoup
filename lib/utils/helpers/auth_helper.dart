import '../../features/authentication/models/user_model.dart';

class TAuthHelper {
  /// 인증 제공자 텍스트 변환
  static String getAuthProviderText(SocialAuthProvider provider) {
    switch (provider) {
      case SocialAuthProvider.google:
        return 'Google';
      case SocialAuthProvider.kakao:
        return 'Kakao';
      case SocialAuthProvider.naver:
        return 'Naver';
      case SocialAuthProvider.facebook:
        return 'Facebook';
      case SocialAuthProvider.apple:
        return 'Apple';
      default:
        return 'Unknown';
    }
  }

  /// 인증 제공자 아이콘 반환 (선택사항)
  static String getAuthProviderIcon(SocialAuthProvider provider) {
    switch (provider) {
      case SocialAuthProvider.google:
        return '🔴'; // 또는 실제 아이콘 경로
      case SocialAuthProvider.kakao:
        return '🟡';
      case SocialAuthProvider.naver:
        return '🟢';
      case SocialAuthProvider.facebook:
        return '🔵';
      case SocialAuthProvider.apple:
        return '⚫';
      default:
        return '❓';
    }
  }
}