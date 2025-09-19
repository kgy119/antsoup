// 기존 enum에 추가
enum StockSortType {
  asiHighToLow,
  asiLowToHigh,
  priceChangeHighToLow,
  priceChangeLowToHigh,
  // 새로 추가
  coldAntSoup,
  mixedAntSoup,
  hotAntSoup,
}

// extension도 업데이트
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
      case StockSortType.coldAntSoup:
        return '식어가는 개미탕';
      case StockSortType.mixedAntSoup:
        return '냉탕온탕 개미탕';
      case StockSortType.hotAntSoup:
        return '펄펄끓는 개미탕';
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
      case StockSortType.coldAntSoup:
        return 'cold_antsoup';
      case StockSortType.mixedAntSoup:
        return 'mixed_antsoup';
      case StockSortType.hotAntSoup:
        return 'hot_antsoup';
    }
  }
}