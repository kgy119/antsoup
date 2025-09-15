import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

@JsonSerializable()
class StockModel {
  // ===== 기존 필드들 (그대로 유지) =====
  final String code;
  final String name;
  final int currentPrice;
  final int changeAmount;
  final double changePercent;
  final int currentAsi;

  // 기간별 ASI 지수값 (각 시점의 실제 지수)
  final int prevAsi1;              // 직전 시점의 ASI 지수
  final int prevAsi3;              // 3번째전 시점의 ASI 지수
  final int prevAsi7;              // 7번째전 시점의 ASI 지수

  // 개미탕 지수 비교 데이터 (변화량과 변화율)
  final int asiChangeAmount1;      // 직전 대비 변화량
  final double asiChangePercent1;  // 직전 대비 변화율
  final int asiChangeAmount3;      // 3번째전 대비 변화량
  final double asiChangePercent3;  // 3번째전 대비 변화율
  final int asiChangeAmount7;      // 7번째전 대비 변화량
  final double asiChangePercent7;  // 7번째전 대비 변화율

  // 기존 추가 필드들
  final int? asi5Avg;        // 개미탕 평균값
  final int? asi5Diff;       // 개미탕 편차
  final int? asiPlusDays;    // 개미탕 100이상 연속일
  final int? asiMinusDays;   // 개미탕 100이하 연속일

  // ===== 네이버 실시간 데이터 필드들 (새로 추가, 모두 nullable) =====
  final int? naverCurrentPrice;    // 네이버 실시간 현재가
  final int? naverChangeAmount;    // 네이버 실시간 변동금액
  final double? naverChangePercent; // 네이버 실시간 변동률
  final String? naverStatus;       // 네이버 상승/하락/보합 상태
  final DateTime? naverLastUpdate; // 마지막 업데이트 시간

  StockModel({
    required this.code,
    required this.name,
    required this.currentPrice,
    required this.changeAmount,
    required this.changePercent,
    required this.currentAsi,
    required this.prevAsi1,
    required this.prevAsi3,
    required this.prevAsi7,
    required this.asiChangeAmount1,
    required this.asiChangePercent1,
    required this.asiChangeAmount3,
    required this.asiChangePercent3,
    required this.asiChangeAmount7,
    required this.asiChangePercent7,
    // 기존 추가 필드들
    this.asi5Avg,
    this.asi5Diff,
    this.asiPlusDays,
    this.asiMinusDays,
    // 네이버 실시간 데이터 (모두 선택적)
    this.naverCurrentPrice,
    this.naverChangeAmount,
    this.naverChangePercent,
    this.naverStatus,
    this.naverLastUpdate,
  });

  // ===== 기존 fromJson (완전히 동일하게 유지) =====
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      currentPrice: _parseToInt(json['close_price'] ?? 0),
      changeAmount: _parseToInt(json['price_change'] ?? 0),
      changePercent: _parseToDouble(json['price_change_percent'] ?? 0.0),
      currentAsi: _parseToInt(json['current_asi'] ?? 0),
      // 기간별 ASI 지수값 추가
      prevAsi1: _parseToInt(json['prev_asi_1'] ?? json['current_asi'] ?? 0),
      prevAsi3: _parseToInt(json['prev_asi_3'] ?? json['current_asi'] ?? 0),
      prevAsi7: _parseToInt(json['prev_asi_7'] ?? json['current_asi'] ?? 0),
      // 변화량과 변화율
      asiChangeAmount1: _parseToInt(json['asi_change_1'] ?? 0),
      asiChangePercent1: _parseToDouble(json['asi_change_percent_1'] ?? 0.0),
      asiChangeAmount3: _parseToInt(json['asi_change_3'] ?? 0),
      asiChangePercent3: _parseToDouble(json['asi_change_percent_3'] ?? 0.0),
      asiChangeAmount7: _parseToInt(json['asi_change_7'] ?? 0),
      asiChangePercent7: _parseToDouble(json['asi_change_percent_7'] ?? 0.0),
      // 기존 추가 필드들
      asi5Avg: json['asi_5_avg'],
      asi5Diff: json['asi_5_diff'],
      asiPlusDays: json['asi_plus_days'],
      asiMinusDays: json['asi_minus_days'],
      // 네이버 데이터는 fromJson에서 설정하지 않음 (runtime에서 추가)
    );
  }

  // ===== 네이버 실시간 데이터 업데이트 메서드 (새로 추가) =====
  StockModel updateWithNaverData({
    int? naverCurrentPrice,
    int? naverChangeAmount,
    double? naverChangePercent,
    String? naverStatus,
  }) {
    return StockModel(
      // 기존 모든 필드 그대로 복사
      code: code,
      name: name,
      currentPrice: currentPrice,
      changeAmount: changeAmount,
      changePercent: changePercent,
      currentAsi: currentAsi,
      prevAsi1: prevAsi1,
      prevAsi3: prevAsi3,
      prevAsi7: prevAsi7,
      asiChangeAmount1: asiChangeAmount1,
      asiChangePercent1: asiChangePercent1,
      asiChangeAmount3: asiChangeAmount3,
      asiChangePercent3: asiChangePercent3,
      asiChangeAmount7: asiChangeAmount7,
      asiChangePercent7: asiChangePercent7,
      asi5Avg: asi5Avg,
      asi5Diff: asi5Diff,
      asiPlusDays: asiPlusDays,
      asiMinusDays: asiMinusDays,
      // 네이버 데이터만 업데이트
      naverCurrentPrice: naverCurrentPrice,
      naverChangeAmount: naverChangeAmount,
      naverChangePercent: naverChangePercent,
      naverStatus: naverStatus,
      naverLastUpdate: DateTime.now(),
    );
  }


  // 더 정확한 상승/하락 판단
  bool get isDisplayUp {
    if (hasNaverData) {
      // 네이버 상태 문자열도 함께 확인
      return naverStatus == '상승' || naverChangeAmount! > 0 || naverChangePercent! > 0;
    }
    return changeAmount > 0;
  }

  bool get isDisplayDown {
    if (hasNaverData) {
      // 네이버 상태 문자열도 함께 확인
      return naverStatus == '하락' || naverChangeAmount! < 0 || naverChangePercent! < 0;
    }
    return changeAmount < 0;
  }

  bool get isDisplayFlat {
    if (hasNaverData) {
      // 네이버 상태 문자열도 함께 확인
      return naverStatus == '보합' || (naverChangeAmount! == 0 && naverChangePercent! == 0);
    }
    return changeAmount == 0;
  }

  // 색상 결정 로직 개선
  Color get displayColor {
    if (hasNaverData) {
      // 네이버 상태 문자열 우선 확인
      switch (naverStatus) {
        case '상승':
          return Colors.red;      // 빨간색
        case '하락':
          return Colors.blue;     // 파란색
        case '보합':
          return Colors.black;    // 검은색 (회색 대신)
        default:
        // 상태가 명확하지 않으면 숫자로 판단
          if (naverChangePercent! > 0) return Colors.red;
          if (naverChangePercent! < 0) return Colors.blue;
          return Colors.black;
      }
    }

    // 기존 서버 데이터 기준
    if (changeAmount > 0) return Colors.red;
    if (changeAmount < 0) return Colors.blue;
    return Colors.black;  // 검은색 (회색 대신)
  }

  // 표시용 변동률 포맷팅 (기호 포함)
  String get formattedDisplayChangePercent {
    final percent = displayChangePercent;

    if (percent == 0) return '0.00%';

    // 기호 명시적 추가
    if (percent > 0) {
      return '+${percent.toStringAsFixed(2)}%';  // 상승: +2.12%
    } else {
      return '${percent.toStringAsFixed(2)}%';   // 하락: -1.23% (음수 기호 자동)
    }
  }

  // 표시용 변동금액 포맷팅 (기호 포함)
  String get formattedDisplayChangeAmount {
    final amount = displayChangeAmount;

    if (amount == 0) return '0';

    final formattedAmount = amount.abs().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );

    // 기호 명시적 추가
    if (amount > 0) {
      return '+$formattedAmount';  // 상승: +1,000
    } else {
      return '-$formattedAmount';  // 하락: -1,000
    }
  }

  // 디버깅용 정보
  String get debugInfo {
    if (hasNaverData) {
      return 'Status: $naverStatus, Amount: $naverChangeAmount, Percent: $naverChangePercent';
    }
    return 'Server data only';
  }

  // 실제 표시할 가격 (네이버 데이터 우선, 없으면 기존 데이터)
  int get displayPrice => naverCurrentPrice ?? currentPrice;

  // 실제 표시할 변동금액
  int get displayChangeAmount => naverChangeAmount ?? changeAmount;

  // 실제 표시할 변동률
  double get displayChangePercent => naverChangePercent ?? changePercent;

  // 상승/하락 상태
  String get displayStatus {
    if (naverStatus != null) return naverStatus!;
    return displayChangeAmount > 0 ? '상승' : displayChangeAmount < 0 ? '하락' : '보합';
  }

  // 네이버 데이터 존재 여부
  bool get hasNaverData => naverCurrentPrice != null;

  // 실시간 데이터 신선도 체크 (5분 이내)
  bool get isNaverDataFresh {
    if (naverLastUpdate == null) return false;
    return DateTime.now().difference(naverLastUpdate!).inMinutes <= 5;
  }

  // ===== 기존 getter들 (그대로 유지) =====
  String get formattedCurrentAsi {
    return currentAsi.toString();
  }

  String get formattedAsiWithChange1 {
    return '$prevAsi1 ${formattedAsiChangePercent1}';
  }

  String get formattedAsiWithChange3 {
    return '$prevAsi3 ${formattedAsiChangePercent3}';
  }

  String get formattedAsiWithChange7 {
    return '$prevAsi7 ${formattedAsiChangePercent7}';
  }

  String? get heatStatus {
    if (asiPlusDays != null) {
      if (asiPlusDays! >= 5) return '사골육수';
      if (asiPlusDays! >= 3) return '가열중';
    }
    return null;
  }

  String? get coldStatus {
    if (asiMinusDays != null) {
      if (asiMinusDays! >= 5) return '냉동보관';
      if (asiMinusDays! >= 3) return '냉각중';
    }
    return null;
  }

  String get formattedAsi5Avg => asi5Avg?.toString() ?? '-';
  String get formattedAsi5Diff => asi5Diff?.toString() ?? '-';

  // ===== 기존 헬퍼 메서드들 (그대로 유지) =====
  static int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // 기존 상태 확인 getter들 (기존 데이터 기준)
  bool get isUp => changeAmount > 0;
  bool get isDown => changeAmount < 0;
  bool get isFlat => changeAmount == 0;

  // ASI 증감 상태 (기존 그대로)
  bool get isAsiUp1 => asiChangeAmount1 > 0;
  bool get isAsiDown1 => asiChangeAmount1 < 0;
  bool get isAsiFlat1 => asiChangeAmount1 == 0;

  bool get isAsiUp3 => asiChangeAmount3 > 0;
  bool get isAsiDown3 => asiChangeAmount3 < 0;
  bool get isAsiFlat3 => asiChangeAmount3 == 0;

  bool get isAsiUp7 => asiChangeAmount7 > 0;
  bool get isAsiDown7 => asiChangeAmount7 < 0;
  bool get isAsiFlat7 => asiChangeAmount7 == 0;

  // ===== 포맷팅 메서드들 (업데이트) =====
  String get formattedPrice {
    final formatter = NumberFormat('#,###');
    return formatter.format(currentPrice);
  }

  // 표시용 포맷팅 (네이버 데이터 우선)
  String get formattedDisplayPrice {
    final formatter = NumberFormat('#,###');
    return formatter.format(displayPrice);
  }

  String get formattedChangePercent {
    final symbol = isUp ? '+' : (isFlat ? '' : '');
    return '$symbol${changePercent.toStringAsFixed(2)}%';
  }

  // 기존 ASI 변화율 포맷 (그대로 유지)
  String get formattedAsiChangePercent1 {
    final symbol = isAsiUp1 ? '+' : (isAsiFlat1 ? '' : '');
    return '$symbol${asiChangePercent1.toStringAsFixed(1)}%';
  }

  String get formattedAsiChangePercent3 {
    final symbol = isAsiUp3 ? '+' : (isAsiFlat3 ? '' : '');
    return '$symbol${asiChangePercent3.toStringAsFixed(1)}%';
  }

  String get formattedAsiChangePercent7 {
    final symbol = isAsiUp7 ? '+' : (isAsiFlat7 ? '' : '');
    return '$symbol${asiChangePercent7.toStringAsFixed(1)}%';
  }

  String get changeSymbol {
    if (isUp) return '+';
    if (isDown) return '-';
    return '';
  }

  String get displayChangeSymbol {
    if (isDisplayUp) return '+';
    if (isDisplayDown) return '-';
    return '';
  }
}