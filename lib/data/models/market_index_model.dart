import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

// part 'market_index_model.g.dart'; // 코드 생성 후 주석 해제

@JsonSerializable()
class MarketIndexModel {
  final String name;
  final double value;
  final double changeAmount;
  final double changePercent;

  MarketIndexModel({
    required this.name,
    required this.value,
    required this.changeAmount,
    required this.changePercent,
  });

  // 임시로 수동 구현 (코드 생성 후 주석 처리)
  factory MarketIndexModel.fromJson(Map<String, dynamic> json) {
    return MarketIndexModel(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'changeAmount': changeAmount,
      'changePercent': changePercent,
    };
  }

  // 코드 생성 후 아래 주석 해제
  // factory MarketIndexModel.fromJson(Map<String, dynamic> json) => _$MarketIndexModelFromJson(json);
  // Map<String, dynamic> toJson() => _$MarketIndexModelToJson(this);

  // 헬퍼 메서드들
  bool get isUp => changeAmount > 0;
  bool get isDown => changeAmount < 0;
  bool get isFlat => changeAmount == 0;

  String get formattedValue {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(value);
  }

  String get formattedChangeAmount {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(changeAmount.abs());
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