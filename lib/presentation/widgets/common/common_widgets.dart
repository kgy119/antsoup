import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';

// 공통 앱바
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.headline6,
      ),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}

class StockCard extends StatelessWidget {
  final String stockName;
  final String stockCode;
  final String currentPrice;
  final String priceChangePercent;
  final String asiWithChange;
  final bool isUp;
  final bool isAsiUp;
  final VoidCallback? onTap;

  const StockCard({
    super.key,
    required this.stockName,
    required this.stockCode,
    required this.currentPrice,
    required this.priceChangePercent,
    required this.asiWithChange,
    required this.isUp,
    required this.isAsiUp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 가격 변화에 따른 색상 결정 (종가와 변화율 모두 동일한 색상 사용)
    final priceColor = _getPriceChangeColor(priceChangePercent, isUp);

    // ASI 변화에 따른 색상 결정
    final asiColor = _getAsiChangeColor(asiWithChange, isAsiUp);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stockName,
                      style: AppTextStyles.headline6,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      stockCode,
                      style: AppTextStyles.stockCode,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 현재가 (변화율과 동일한 색상)
                  Text(
                    currentPrice,
                    style: AppTextStyles.stockPrice.copyWith(
                      color: priceColor, // 변화율과 동일한 색상
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // 가격 변화율 (현재가와 동일한 색상)
                  Text(
                    priceChangePercent,
                    style: AppTextStyles.stockChange.copyWith(
                      color: priceColor, // 현재가와 동일한 색상
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // ASI 값과 변화율
                  Text(
                    asiWithChange,
                    style: AppTextStyles.caption.copyWith(
                      color: asiColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriceChangeColor(String changePercent, bool isUp) {
    // 0.00%인지 확인
    if (changePercent == '0.00%' || changePercent == '+0.00%' || changePercent == '-0.00%') {
      return Colors.black;
    }

    // +나 -가 포함되어 있는지 확인
    if (changePercent.startsWith('+')) {
      return AppColors.stockUp; // 빨간색
    } else if (changePercent.startsWith('-')) {
      return AppColors.stockDown; // 파란색
    }

    // 백업: isUp 플래그 사용
    return isUp ? AppColors.stockUp : AppColors.stockDown;
  }

  // ASI 변화율 색상 결정
  Color _getAsiChangeColor(String asiString, bool isAsiUp) {
    // 0.00%가 포함되어 있는지 확인
    if (asiString.contains('0.00%') || asiString.contains('+0.00%') || asiString.contains('-0.00%')) {
      return Colors.black;
    }

    // +나 -가 포함되어 있는지 확인
    if (asiString.contains('+')) {
      return AppColors.stockUp; // 빨간색
    } else if (asiString.contains('-')) {
      return AppColors.stockDown; // 파란색
    }

    // 백업: isAsiUp 플래그 사용
    return isAsiUp ? AppColors.stockUp : AppColors.stockDown;
  }
}

// 로딩 위젯
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: AppTextStyles.bodyText2,
            ),
          ],
        ],
      ),
    );
  }
}

// 에러 위젯
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: AppTextStyles.bodyText1,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('다시 시도'),
            ),
          ],
        ],
      ),
    );
  }
}

// 빈 상태 위젯
class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Widget? action;

  const EmptyWidget({
    super.key,
    required this.message,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 64.sp,
            color: AppColors.grey400,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: AppTextStyles.bodyText1.copyWith(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            SizedBox(height: 16.h),
            action!,
          ],
        ],
      ),
    );
  }
}

// 검색바 위젯은 별도 파일로 분리됨 (search_bar.dart)