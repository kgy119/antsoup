class TTimeHelper {
  /// 마지막 접속 시간을 텍스트로 변환
  static String getLastSeenText(DateTime lastLoginAt) {
    final now = DateTime.now();
    final difference = now.difference(lastLoginAt);

    if (difference.inMinutes < 5) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${lastLoginAt.month}/${lastLoginAt.day}';
    }
  }

  /// 최근 활동 여부 확인 (5분 이내)
  static bool isRecentlyActive(DateTime? lastLoginAt) {
    if (lastLoginAt == null) return false;
    final difference = DateTime.now().difference(lastLoginAt);
    return difference.inMinutes < 5;
  }

  /// 정확한 시간 표시 (시:분 형태)
  static String getExactTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 날짜 표시 (월/일 형태)
  static String getDateText(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}';
  }

  /// 전체 날짜시간 표시
  static String getFullDateTime(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 ${getExactTime(dateTime)}';
  }

  /// 날짜 포맷팅 (한국어)
  static String formatDateKorean(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 날짜 포맷팅 (국제 형식)
  static String formatDateInternational(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 날짜와 시간 포맷팅 (한국어)
  static String formatDateTimeKorean(DateTime date) {
    return '${formatDateKorean(date)} ${getExactTime(date)}';
  }

  /// 상대적 날짜 표시 (오늘, 어제, N일 전)
  static String getRelativeDateText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(targetDay).inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else if (difference < 7) {
      return '${difference}일 전';
    } else {
      return formatDateKorean(date);
    }
  }
}