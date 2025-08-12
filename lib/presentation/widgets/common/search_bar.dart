import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool enabled;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    this.onChanged,
    this.onTap,
    this.enabled = true,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        controller: controller,
        enabled: enabled,
        readOnly: readOnly,
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon ?? const Icon(Icons.search),
          suffixIcon: suffixIcon ??
              (controller?.text.isNotEmpty == true
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller?.clear();
                  onChanged?.call('');
                },
              )
                  : null),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }
}