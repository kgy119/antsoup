import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

@JsonSerializable()
class StockModel {
  final String code;
  final String name;
  final int currentPrice;
  final int changeAmount;
  final double changePercent;
  final int currentAsi;
  final int asiChangeAmount;
  final double asiChangePercent;

  StockModel({
    required this.code,
    required this.name,
    required this.currentPrice,
    required this.changeAmount,
    required this.changePercent,
    required this.currentAsi,
    required this.asiChangeAmount,
    required this.asiChangePercent,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      currentPrice: _parseToInt(json['close_price'] ?? 0),
      changeAmount: _parseToInt(json['price_change'] ?? 0),
      changePercent: _parseToDouble(json['price_change_percent'] ?? 0.0),
      currentAsi: _parseToInt(json['current_asi'] ?? 0),
      asiChangeAmount: _parseToInt(json['asi_change'] ?? 0),
      asiChangePercent: _parseToDouble(json['asi_change_percent'] ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'current_price': currentPrice,
      'change_amount': changeAmount,
      'change_percent': changePercent,
      'current_asi': currentAsi,
      'asi_change_amount': asiChangeAmount,
      'asi_change_percent': asiChangePercent,
    };
  }

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

  // 헬퍼 메서드들
  bool get isUp => changeAmount > 0;
  bool get isDown => changeAmount < 0;
  bool get isFlat => changeAmount == 0;

  bool get isAsiUp => asiChangeAmount > 0;
  bool get isAsiDown => asiChangeAmount < 0;
  bool get isAsiFlat => asiChangeAmount == 0;

  // 포맷된 문자열 getter들
  String get formattedPrice {
    final formatter = NumberFormat('#,###');
    return formatter.format(currentPrice);
  }

  String get formattedChangeAmount {
    final formatter = NumberFormat('#,###');
    return formatter.format(changeAmount.abs());
  }

  String get formattedChangePercent {
    final symbol = isUp ? '+' : (isFlat ? '' : '');
    return '$symbol${changePercent.toStringAsFixed(2)}%';
  }

// ASI 현재값 포맷 (추가됨)
  String get formattedCurrentAsi {
    return currentAsi.toString();
  }

// 기존 ASI 변화율 포맷 (참고용으로 남겨둠)
  String get formattedAsiChangePercent {
    final symbol = isAsiUp ? '+' : (isAsiFlat ? '' : '');
    return 'ASI $symbol${asiChangePercent.toStringAsFixed(2)}%';
  }

  // ASI 값과 변화율을 함께 표시하는 포맷
  String get formattedAsiWithChange {
    final symbol = isAsiUp ? '+' : (isAsiFlat ? '' : '');
    return '$currentAsi $symbol${asiChangePercent.toStringAsFixed(2)}%';
  }

  String get changeSymbol {
    if (isUp) return '+';
    if (isDown) return '-';
    return '';
  }

}