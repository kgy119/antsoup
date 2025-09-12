import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../data/models/wordcloud_model.dart';

class WordCloudWidget extends StatelessWidget {
  final WordCloudModel? wordCloud;
  final double height;

  const WordCloudWidget({
    Key? key,
    required this.wordCloud,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (wordCloud == null || !wordCloud!.hasKeywords) {
      return Container(
        height: height.h,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.grey200,
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                size: 32.sp,
                color: AppColors.grey400,
              ),
              SizedBox(height: 8.h),
              Text(
                '단어 클라우드 데이터가 없습니다',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: height.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.grey200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud,
                size: 20.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                '키워드 클라우드',
                style: AppTextStyles.bodyText1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: _buildWordCloud(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCloud(BuildContext context) {
    final keywords = wordCloud!.keywords;

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      alignment: WrapAlignment.center,
      children: keywords.map((keyword) {
        return _buildKeywordChip(context, keyword);
      }).toList(),
    );
  }

  Widget _buildKeywordChip(BuildContext context, WordCloudItem keyword) {
    // 가중치에 따른 색상 계산
    final color = _getColorByWeight(keyword.weight);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.3 : 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        keyword.word,
        style: TextStyle(
          fontSize: keyword.fontSize.sp,
          fontWeight: _getFontWeightByWeight(keyword.weight),
          color: isDark ? color.withOpacity(0.9) : color,
        ),
      ),
    );
  }

  Color _getColorByWeight(int weight) {
    // 가중치별 색상 그라데이션
    final colors = [
      AppColors.grey400,     // 가중치 1-2
      AppColors.grey500,     // 가중치 3
      AppColors.lightPrimary, // 가중치 4-5
      AppColors.primary,     // 가중치 6-7
      AppColors.stockUp,     // 가중치 8-9
      AppColors.error,       // 가중치 10
    ];

    final index = ((weight - 1) / 2).floor().clamp(0, colors.length - 1);
    return colors[index];
  }

  FontWeight _getFontWeightByWeight(int weight) {
    if (weight >= 8) return FontWeight.w700;
    if (weight >= 6) return FontWeight.w600;
    if (weight >= 4) return FontWeight.w500;
    return FontWeight.w400;
  }
}