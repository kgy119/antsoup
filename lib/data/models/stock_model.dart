import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

@JsonSerializable()
// lib/data/models/stock_model.dart의 수정된 부분

class StockModel {
  final String code;
  final String name;
  final int currentPrice;
  final int changeAmount;
  final double changePercent;
  final int currentAsi;

  // 개미탕 지수 비교 데이터 (직전, 3번째전, 7번째전)
  final int asiChangeAmount1;      // 직전 대비 변화량
  final double asiChangePercent1;  // 직전 대비 변화율
  final int asiChangeAmount3;      // 3번째전 대비 변화량
  final double asiChangePercent3;  // 3번째전 대비 변화율
  final int asiChangeAmount7;      // 7번째전 대비 변화량
  final double asiChangePercent7;  // 7번째전 대비 변화율

  StockModel({
    required this.code,
    required this.name,
    required this.currentPrice,
    required this.changeAmount,
    required this.changePercent,
    required this.currentAsi,
    required this.asiChangeAmount1,
    required this.asiChangePercent1,
    required this.asiChangeAmount3,
    required this.asiChangePercent3,
    required this.asiChangeAmount7,
    required this.asiChangePercent7,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      currentPrice: _parseToInt(json['close_price'] ?? 0),
      changeAmount: _parseToInt(json['price_change'] ?? 0),
      changePercent: _parseToDouble(json['price_change_percent'] ?? 0.0),
      currentAsi: _parseToInt(json['current_asi'] ?? 0),
      asiChangeAmount1: _parseToInt(json['asi_change_1'] ?? 0),
      asiChangePercent1: _parseToDouble(json['asi_change_percent_1'] ?? 0.0),
      asiChangeAmount3: _parseToInt(json['asi_change_3'] ?? 0),
      asiChangePercent3: _parseToDouble(json['asi_change_percent_3'] ?? 0.0),
      asiChangeAmount7: _parseToInt(json['asi_change_7'] ?? 0),
      asiChangePercent7: _parseToDouble(json['asi_change_percent_7'] ?? 0.0),
    );
  }

  // 기존 헬퍼 메서드들...
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

  bool get isUp => changeAmount > 0;
  bool get isDown => changeAmount < 0;
  bool get isFlat => changeAmount == 0;

  // ASI 증감 상태 (각 기간별)
  bool get isAsiUp1 => asiChangeAmount1 > 0;
  bool get isAsiDown1 => asiChangeAmount1 < 0;
  bool get isAsiFlat1 => asiChangeAmount1 == 0;

  bool get isAsiUp3 => asiChangeAmount3 > 0;
  bool get isAsiDown3 => asiChangeAmount3 < 0;
  bool get isAsiFlat3 => asiChangeAmount3 == 0;

  bool get isAsiUp7 => asiChangeAmount7 > 0;
  bool get isAsiDown7 => asiChangeAmount7 < 0;
  bool get isAsiFlat7 => asiChangeAmount7 == 0;

  // 포맷된 문자열 getter들
  String get formattedPrice {
    final formatter = NumberFormat('#,###');
    return formatter.format(currentPrice);
  }

  String get formattedChangePercent {
    final symbol = isUp ? '+' : (isFlat ? '' : '');
    return '$symbol${changePercent.toStringAsFixed(2)}%';
  }

  String get formattedCurrentAsi {
    return currentAsi.toString();
  }

  // 각 기간별 ASI 변화율 포맷
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

  // 각 기간별 ASI와 변화율을 함께 표시하는 포맷
  String get formattedAsiWithChange1 {
    return '$currentAsi ${formattedAsiChangePercent1}';
  }

  String get formattedAsiWithChange3 {
    return '$currentAsi ${formattedAsiChangePercent3}';
  }

  String get formattedAsiWithChange7 {
    return '$currentAsi ${formattedAsiChangePercent7}';
  }

  String get changeSymbol {
    if (isUp) return '+';
    if (isDown) return '-';
    return '';
  }
}