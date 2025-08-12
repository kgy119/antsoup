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

// 주식 카드 위젯
class StockCard extends StatelessWidget {
  final String stockName;
  final String stockCode;
  final String currentPrice;
  final String changeAmount;
  final String changePercent;
  final bool isUp;
  final VoidCallback? onTap;

  const StockCard({
    super.key,
    required this.stockName,
    required this.stockCode,
    required this.currentPrice,
    required this.changeAmount,
    required this.changePercent,
    required this.isUp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = isUp ? AppColors.stockUp : AppColors.stockDown;

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
                  Text(
                    currentPrice,
                    style: AppTextStyles.stockPrice,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        isUp ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: changeColor,
                        size: 16.sp,
                      ),
                      Text(
                        '$changeAmount ($changePercent%)',
                        style: AppTextStyles.stockChange.copyWith(
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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