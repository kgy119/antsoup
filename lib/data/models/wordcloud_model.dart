class WordCloudItem {
  final String word;
  final int weight; // 1-10 (키워드1이 10, 키워드10이 1)
  final double fontSize;

  const WordCloudItem({
    required this.word,
    required this.weight,
    required this.fontSize,
  });
}

class WordCloudModel {
  final String code;
  final String name;
  final String rawWords; // 원본 문자열
  final List<WordCloudItem> keywords;
  final DateTime date;

  const WordCloudModel({
    required this.code,
    required this.name,
    required this.rawWords,
    required this.keywords,
    required this.date,
  });

  factory WordCloudModel.fromJson(Map<String, dynamic> json) {
    final rawWords = json['words'] as String? ?? '';
    final keywords = _parseKeywords(rawWords);

    return WordCloudModel(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      rawWords: rawWords,
      keywords: keywords,
      date: DateTime.parse(json['date'] as String? ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'words': rawWords,
      'date': date.toIso8601String(),
    };
  }

  static List<WordCloudItem> _parseKeywords(String rawWords) {
    if (rawWords.isEmpty) return [];

    final words = rawWords.split('|');
    final keywords = <WordCloudItem>[];

    for (int i = 0; i < words.length && i < 10; i++) {
      final word = words[i].trim();
      if (word.isNotEmpty) {
        final weight = 10 - i; // 첫 번째 키워드가 가장 높은 가중치
        final fontSize = 12.0 + (weight * 2.0); // 12~30 범위의 폰트 크기

        keywords.add(WordCloudItem(
          word: word,
          weight: weight,
          fontSize: fontSize,
        ));
      }
    }

    return keywords;
  }

  bool get hasKeywords => keywords.isNotEmpty;
}