import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/constants/enums.dart';

class SortDropdown extends StatelessWidget {
  final StockSortType selectedSort;
  final Function(StockSortType) onSortChanged;

  const SortDropdown({
    Key? key,
    required this.selectedSort,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isDark ? AppColors.grey600 : AppColors.grey300,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StockSortType>(
          value: selectedSort,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDark ? Colors.white70 : AppColors.grey600,
            size: 18.sp,
          ),
          style: AppTextStyles.bodyText2.copyWith(
            color: isDark ? Colors.white : AppColors.grey800,
            fontSize: 13.sp,
          ),
          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
          onChanged: (StockSortType? value) {
            if (value != null) {
              onSortChanged(value);
            }
          },
          items: StockSortType.values.map<DropdownMenuItem<StockSortType>>(
                (StockSortType value) {
              return DropdownMenuItem<StockSortType>(
                value: value,
                child: Container(
                  width: 140.w,
                  child: Text(
                    value.displayName,
                    style: AppTextStyles.bodyText2.copyWith(
                      color: isDark ? Colors.white : AppColors.grey800,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}