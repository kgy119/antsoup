import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../app/theme/text_styles.dart';
import '../../data/models/wordcloud_model.dart';

class WordCloudWidget extends StatelessWidget {
  final WordCloudModel? wordCloud;
  final double height;
  final bool showStats;

  const WordCloudWidget({
    Key? key,
    this.wordCloud,
    this.height = 200,
    this.showStats = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildHeader(context),
          // 단어 클라우드 내용
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_outlined,
            size: 20.sp,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 8.w),
          Text(
            '개미들의 관심 키워드',
            style: AppTextStyles.headline6.copyWith(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (wordCloud != null && showStats)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${wordCloud!.keywords.length}개',
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (wordCloud == null || wordCloud!.keywords.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      child: CustomWordCloud(
        keywords: wordCloud!.keywords,
        width: Get.width - 64.w,
        height: (height - 60).h,
        onWordTap: (word) => _onWordTap(context, word),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 48.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 12.h),
          Text(
            '키워드 데이터가 없습니다',
            style: AppTextStyles.bodyText2.copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '개미들의 관심이 집중되면 표시됩니다',
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onWordTap(BuildContext context, String word) {
    Get.snackbar(
      '키워드 선택',
      '"$word" 키워드를 선택했습니다',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      colorText: Theme.of(context).primaryColor,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      borderRadius: 8.r,
      icon: Icon(
        Icons.touch_app,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

// 커스텀 단어 클라우드 위젯
class CustomWordCloud extends StatelessWidget {
  final List<WordCloudItem> keywords;
  final double width;
  final double height;
  final Function(String)? onWordTap;

  const CustomWordCloud({
    Key? key,
    required this.keywords,
    required this.width,
    required this.height,
    this.onWordTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedKeywords = List<WordCloudItem>.from(keywords)
      ..sort((a, b) => b.weight.compareTo(a.weight));

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: _buildWordWidgets(context, sortedKeywords),
      ),
    );
  }

  List<Widget> _buildWordWidgets(BuildContext context, List<WordCloudItem> sortedKeywords) {
    final List<Widget> widgets = [];
    final List<Rect> usedPositions = [];
    final random = math.Random();
    final colors = _getWordCloudColors(context);

    for (int i = 0; i < math.min(sortedKeywords.length, 20); i++) {
      final keyword = sortedKeywords[i];
      final fontSize = _calculateFontSize(keyword.weight, sortedKeywords);
      final color = colors[i % colors.length];

      // 텍스트 크기 측정
      final textPainter = TextPainter(
        text: TextSpan(
          text: keyword.word,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final textWidth = textPainter.width;
      final textHeight = textPainter.height;

      // 위치 계산 (겹치지 않도록)
      Offset position = _findNonOverlappingPosition(
        textWidth,
        textHeight,
        usedPositions,
        random,
      );

      // 사용된 위치에 추가
      usedPositions.add(Rect.fromLTWH(
        position.dx,
        position.dy,
        textWidth,
        textHeight,
      ));

      widgets.add(
        Positioned(
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            onTap: () => onWordTap?.call(keyword.word),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Text(
                keyword.word,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: color,
                  shadows: [
                    Shadow(
                      offset: const Offset(0.5, 0.5),
                      blurRadius: 1,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  double _calculateFontSize(int weight, List<WordCloudItem> sortedKeywords) {
    if (sortedKeywords.isEmpty) return 14.sp;

    final maxWeight = sortedKeywords.first.weight;
    final minWeight = sortedKeywords.last.weight;

    if (maxWeight == minWeight) return 16.sp;

    final ratio = (weight - minWeight) / (maxWeight - minWeight);
    return (12.sp + (ratio * 20.sp)).clamp(10.sp, 32.sp);
  }

  Offset _findNonOverlappingPosition(
      double textWidth,
      double textHeight,
      List<Rect> usedPositions,
      math.Random random,
      ) {
    const maxAttempts = 100;
    final centerX = width / 2;
    final centerY = height / 2;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      // 중앙에서 시작하여 점점 멀어지는 위치 생성
      final angle = random.nextDouble() * 2 * math.pi;
      final radius = (attempt / maxAttempts) * math.min(width, height) / 3;

      final x = (centerX + math.cos(angle) * radius - textWidth / 2)
          .clamp(0.0, width - textWidth);
      final y = (centerY + math.sin(angle) * radius - textHeight / 2)
          .clamp(0.0, height - textHeight);

      final newRect = Rect.fromLTWH(x, y, textWidth, textHeight);

      // 겹치는지 확인
      bool overlaps = false;
      for (final usedRect in usedPositions) {
        if (newRect.overlaps(usedRect.inflate(4))) { // 4픽셀 여백
          overlaps = true;
          break;
        }
      }

      if (!overlaps) {
        return Offset(x, y);
      }
    }

    // 적절한 위치를 찾지 못했다면 랜덤 위치 반환
    return Offset(
      random.nextDouble() * (width - textWidth).clamp(0, width),
      random.nextDouble() * (height - textHeight).clamp(0, height),
    );
  }

  List<Color> _getWordCloudColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return [
        Colors.white,
        Colors.blue[300]!,
        Colors.green[300]!,
        Colors.orange[300]!,
        Colors.purple[300]!,
        Colors.teal[300]!,
        Colors.pink[300]!,
        Colors.amber[300]!,
        Colors.cyan[300]!,
        Colors.lime[300]!,
      ];
    } else {
      return [
        Colors.grey[800]!,
        Colors.blue[600]!,
        Colors.green[600]!,
        Colors.orange[600]!,
        Colors.purple[600]!,
        Colors.teal[600]!,
        Colors.pink[600]!,
        Colors.amber[700]!,
        Colors.cyan[700]!,
        Colors.lime[700]!,
      ];
    }
  }
}

// 컴팩트 버전
class CompactWordCloudWidget extends WordCloudWidget {
  const CompactWordCloudWidget({
    Key? key,
    WordCloudModel? wordCloud,
  }) : super(
    key: key,
    wordCloud: wordCloud,
    height: 150,
    showStats: false,
  );

  @override
  Widget build(BuildContext context) {
    if (wordCloud == null || wordCloud!.keywords.isEmpty) {
      return Container(
        height: height.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            '키워드 없음',
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    return Container(
      height: height.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: CustomWordCloud(
        keywords: wordCloud!.keywords.take(10).toList(), // 컴팩트 버전은 10개만
        width: Get.width - 56.w,
        height: height.h - 24.h,
        onWordTap: (word) {
          Get.snackbar(
            '키워드',
            word,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 1),
          );
        },
      ),
    );
  }
}