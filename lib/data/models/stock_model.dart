import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

// part 'stock_model.g.dart';

@JsonSerializable()
class StockModel {
  final String code;
  final String name;
  final int currentPrice;
  final int changeAmount;
  final double changePercent;

  StockModel({
    required this.code,
    required this.name,
    required this.currentPrice,
    required this.changeAmount,
    required this.changePercent,
  });

  // 실제 fromJson 구현 (서버 응답 구조에 맞게 조정)
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      code: json['code'] ?? json['stock_code'] ?? '',
      name: json['name'] ?? json['stock_name'] ?? '',
      currentPrice: _parseToInt(json['current_price'] ?? json['price'] ?? 0),
      changeAmount: _parseToInt(json['change_amount'] ?? json['change'] ?? 0),
      changePercent: _parseToDouble(json['change_percent'] ?? json['change_rate'] ?? 0.0),
    );
  }

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'current_price': currentPrice,
      'change_amount': changeAmount,
      'change_percent': changePercent,
    };
  }

  // 숫자 파싱 헬퍼 메서드
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

  String get formattedPrice {
    final formatter = NumberFormat('#,###');
    return formatter.format(currentPrice);
  }

  String get formattedChangeAmount {
    final formatter = NumberFormat('#,###');
    final absAmount = changeAmount.abs();
    return formatter.format(absAmount);
  }

  String get formattedChangePercent {
    return changePercent.abs().toStringAsFixed(2);
  }

  String get changeSymbol {
    if (isUp) return '+';
    if (isDown) return '-';
    return '';
  }
}