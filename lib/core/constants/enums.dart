enum StockSortType {
  asiHighToLow,
  asiLowToHigh,
  priceChangeHighToLow,
  priceChangeLowToHigh,
}

extension StockSortTypeExtension on StockSortType {
  String get displayName {
    switch (this) {
      case StockSortType.asiHighToLow:
        return 'ASI 높은 순서';
      case StockSortType.asiLowToHigh:
        return 'ASI 낮은 순서';
      case StockSortType.priceChangeHighToLow:
        return '종가 상승률 높은 순서';
      case StockSortType.priceChangeLowToHigh:
        return '종가 상승률 낮은 순서';
    }
  }

  String get sortKey {
    switch (this) {
      case StockSortType.asiHighToLow:
        return 'asi_desc';
      case StockSortType.asiLowToHigh:
        return 'asi_asc';
      case StockSortType.priceChangeHighToLow:
        return 'price_change_desc';
      case StockSortType.priceChangeLowToHigh:
        return 'price_change_asc';
    }
  }
}