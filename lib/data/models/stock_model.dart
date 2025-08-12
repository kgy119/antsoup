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

  // factory StockModel.fromJson(Map<String, dynamic> json) => _$StockModelFromJson(json);
  // Map<String, dynamic> toJson() => _$StockModelToJson(this);

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