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
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StockSortType>(
          value: selectedSort,
          onChanged: (StockSortType? value) {
            if (value != null) {
              onSortChanged(value);
            }
          },
          isDense: true, // 밀도 높게
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18.sp,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 13.sp,
          ),
          items: StockSortType.values.map((sortType) {
            return DropdownMenuItem<StockSortType>(
              value: sortType,
              child: Text(
                sortType.displayName,
                style: TextStyle(fontSize: 13.sp),
              ),
            );
          }).toList(),

        ),
      ),
    );
  }
}