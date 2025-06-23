class TValidator {
  /// 이메일 유효성 검사
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    }

    // 한국어 도메인 지원을 위한 확장된 이메일 정규식
    final emailRegExp = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );

    if (!emailRegExp.hasMatch(value)) {
      return '올바른 이메일 형식을 입력해주세요.';
    }

    // 일반적이지 않은 이메일 형식 추가 검증
    if (value.contains('..') || value.startsWith('.') || value.endsWith('.')) {
      return '올바른 이메일 형식을 입력해주세요.';
    }

    return null;
  }

  /// 비밀번호 유효성 검사 (한국 서비스에 맞게 조정 - 대문자 요구사항 제거)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }

    // 최소 길이 확인
    if (value.length < 6) {
      return '비밀번호는 최소 6자 이상이어야 합니다.';
    }

    // 최대 길이 확인 (보안상 너무 긴 비밀번호 제한)
    if (value.length > 128) {
      return '비밀번호는 최대 128자까지 가능합니다.';
    }

    // 영문자 확인 (대소문자 구분 없음)
    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return '비밀번호에 영문자가 하나 이상 포함되어야 합니다.';
    }

    // 숫자 확인
    if (!value.contains(RegExp(r'[0-9]'))) {
      return '비밀번호에 숫자가 하나 이상 포함되어야 합니다.';
    }

    // 특수문자 확인
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return '비밀번호에 특수문자가 하나 이상 포함되어야 합니다.';
    }

    // 연속된 문자 확인 (선택사항)
    if (_hasConsecutiveChars(value)) {
      return '연속된 문자나 숫자는 사용할 수 없습니다.';
    }

    return null;
  }

  /// 한국 전화번호 유효성 검사
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 선택사항이므로 null 반환
    }

    // 숫자만 추출
    String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    // 길이 확인 (11자리: 01012345678)
    if (digitsOnly.length != 11) {
      return '전화번호는 11자리여야 합니다.';
    }

    // 한국 휴대폰 번호 패턴 확인
    if (!digitsOnly.startsWith('010')) {
      return '010으로 시작하는 전화번호를 입력해주세요.';
    }

    // 유효한 번호 패턴 확인
    final phoneRegExp = RegExp(r'^010[0-9]{8}$');
    if (!phoneRegExp.hasMatch(digitsOnly)) {
      return '올바른 전화번호 형식을 입력해주세요.';
    }

    return null;
  }

  /// 사용자명 유효성 검사 (한글 허용)
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '사용자명을 입력해주세요.';
    }

    // 길이 확인
    if (value.length < 3) {
      return '사용자명은 최소 3자 이상이어야 합니다.';
    }

    if (value.length > 20) {
      return '사용자명은 최대 20자까지 가능합니다.';
    }

    // 한글, 영문, 숫자, 언더스코어 허용
    if (!RegExp(r'^[가-힣a-zA-Z0-9_]+$').hasMatch(value)) {
      return '사용자명은 한글, 영문, 숫자, 언더스코어(_)만 사용 가능합니다.';
    }

    // 언더스코어로 시작하거나 끝나는 경우 제한
    if (value.startsWith('_') || value.endsWith('_')) {
      return '사용자명은 언더스코어(_)로 시작하거나 끝날 수 없습니다.';
    }

    // 연속된 언더스코어 제한
    if (value.contains('__')) {
      return '연속된 언더스코어(_)는 사용할 수 없습니다.';
    }

    // 예약어 확인 (한글 예약어도 추가)
    final reservedWords = [
      'admin', 'administrator', 'root', 'user', 'guest', 'anonymous',
      'null', 'undefined', 'system', 'api', 'www', 'mail', 'ftp',
      'test', 'demo', 'support', 'help', 'info', 'contact',
      '관리자', '운영자', '테스트', '시스템', '고객센터'
    ];

    if (reservedWords.contains(value.toLowerCase()) || reservedWords.contains(value)) {
      return '사용할 수 없는 사용자명입니다.';
    }

    return null;
  }

  /// 비밀번호 확인 유효성 검사
  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요.';
    }

    if (value != originalPassword) {
      return '비밀번호가 일치하지 않습니다.';
    }

    return null;
  }

  /// 이름 유효성 검사 (한국 이름 고려)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요.';
    }

    // 길이 확인
    if (value.length < 2) {
      return '이름은 최소 2자 이상이어야 합니다.';
    }

    if (value.length > 50) {
      return '이름은 최대 50자까지 가능합니다.';
    }

    // 한글, 영문만 허용 (공백 포함)
    if (!RegExp(r'^[가-힣a-zA-Z\s]+$').hasMatch(value)) {
      return '이름은 한글 또는 영문만 입력 가능합니다.';
    }

    // 연속된 공백 제한
    if (value.contains('  ')) {
      return '연속된 공백은 사용할 수 없습니다.';
    }

    return null;
  }

  /// 나이 유효성 검사
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 선택사항
    }

    final age = int.tryParse(value);
    if (age == null) {
      return '올바른 나이를 입력해주세요.';
    }

    if (age < 14) {
      return '만 14세 이상만 가입할 수 있습니다.';
    }

    if (age > 120) {
      return '올바른 나이를 입력해주세요.';
    }

    return null;
  }

  /// 생년월일 유효성 검사
  static String? validateBirthDate(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 선택사항
    }

    try {
      final birthDate = DateTime.parse(value);
      final now = DateTime.now();
      final age = now.year - birthDate.year;

      if (birthDate.isAfter(now)) {
        return '미래 날짜는 입력할 수 없습니다.';
      }

      if (age < 14) {
        return '만 14세 이상만 가입할 수 있습니다.';
      }

      if (age > 120) {
        return '올바른 생년월일을 입력해주세요.';
      }

      return null;
    } catch (e) {
      return '올바른 날짜 형식을 입력해주세요. (YYYY-MM-DD)';
    }
  }

  /// 연속된 문자 확인 헬퍼 함수
  static bool _hasConsecutiveChars(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      // 연속된 3자리 확인
      int char1 = password.codeUnitAt(i);
      int char2 = password.codeUnitAt(i + 1);
      int char3 = password.codeUnitAt(i + 2);

      // 연속된 숫자나 문자 확인 (123, abc, 321, cba 등)
      if ((char2 == char1 + 1 && char3 == char2 + 1) ||
          (char2 == char1 - 1 && char3 == char2 - 1)) {
        return true;
      }

      // 반복된 문자 확인 (111, aaa 등)
      if (char1 == char2 && char2 == char3) {
        return true;
      }
    }
    return false;
  }

  /// URL 유효성 검사
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 선택사항
    }

    final urlRegExp = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );

    if (!urlRegExp.hasMatch(value)) {
      return '올바른 URL 형식을 입력해주세요.';
    }

    return null;
  }

  /// 금액 유효성 검사
  static String? validateAmount(String? value, {double? minAmount, double? maxAmount}) {
    if (value == null || value.isEmpty) {
      return '금액을 입력해주세요.';
    }

    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return '올바른 금액을 입력해주세요.';
    }

    if (amount < 0) {
      return '음수는 입력할 수 없습니다.';
    }

    if (minAmount != null && amount < minAmount) {
      return '최소 금액은 ${minAmount.toStringAsFixed(0)}원입니다.';
    }

    if (maxAmount != null && amount > maxAmount) {
      return '최대 금액은 ${maxAmount.toStringAsFixed(0)}원입니다.';
    }

    return null;
  }

  /// 필수 입력 필드 검사
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName을(를) 입력해주세요.';
    }
    return null;
  }

  /// 최소/최대 길이 검사
  static String? validateLength(String? value, String fieldName,
      {int? minLength, int? maxLength}) {
    if (value == null) return null;

    if (minLength != null && value.length < minLength) {
      return '$fieldName은(는) 최소 $minLength자 이상이어야 합니다.';
    }

    if (maxLength != null && value.length > maxLength) {
      return '$fieldName은(는) 최대 $maxLength자까지 가능합니다.';
    }

    return null;
  }
}