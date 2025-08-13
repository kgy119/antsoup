import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class StockDetailModel {
  final String code;
  final String name;
  final int currentPrice;
  final int changeAmount;
  final double changePercent;
  final int volume;
  final int marketCap;
  final double per;
  final double pbr;
  final List<ChartDataPoint> priceHistory;
  final List<ChartDataPoint> antSoupIndex;

  StockDetailModel({
    required this.code,
    required this.name,
    required this.currentPrice,
    required this.changeAmount,
    required this.changePercent,
    required this.volume,
    required this.marketCap,
    required this.per,
    required this.pbr,
    required this.priceHistory,
    required this.antSoupIndex,
  });

  factory StockDetailModel.fromJson(Map<String, dynamic> json) {
    return StockDetailModel(
      code: json['code'],
      name: json['name'],
      currentPrice: json['currentPrice'],
      changeAmount: json['changeAmount'],
      changePercent: (json['changePercent'] as num).toDouble(),
      volume: json['volume'],
      marketCap: json['marketCap'],
      per: (json['per'] as num).toDouble(),
      pbr: (json['pbr'] as num).toDouble(),
      priceHistory: (json['priceHistory'] as List)
          .map((item) => ChartDataPoint.fromJson(item))
          .toList(),
      antSoupIndex: (json['antSoupIndex'] as List)
          .map((item) => ChartDataPoint.fromJson(item))
          .toList(),
    );
  }

  // 헬퍼 메서드들
  bool get isUp => changeAmount > 0;
  bool get isDown => changeAmount < 0;
  bool get isFlat => changeAmount == 0;

  String get formattedPrice {
    return '${currentPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }

  String get formattedVolume {
    if (volume >= 100000000) {
      return '${(volume / 100000000).toStringAsFixed(1)}억주';
    } else if (volume >= 10000) {
      return '${(volume / 10000).toStringAsFixed(1)}만주';
    }
    return '${volume}주';
  }

  String get formattedMarketCap {
    if (marketCap >= 1000000000000) {
      return '${(marketCap / 1000000000000).toStringAsFixed(1)}조원';
    } else if (marketCap >= 100000000) {
      return '${(marketCap / 100000000).toStringAsFixed(1)}억원';
    }
    return '${marketCap}억원';
  }
}

@JsonSerializable()
class ChartDataPoint {
  final DateTime date;
  final double value;

  ChartDataPoint({
    required this.date,
    required this.value,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      date: DateTime.parse(json['date']),
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
    };
  }
}