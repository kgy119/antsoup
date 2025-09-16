// lib/presentation/widgets/common/search_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool enabled;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted; // 이 부분 변경

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
    this.focusNode,
    this.onSubmitted,
  });


  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    // 초기 텍스트 상태 확인
    _hasText = widget.controller?.text.isNotEmpty ?? false;

    // 텍스트 변경 감지
    widget.controller?.addListener(_updateTextState);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_updateTextState);
    super.dispose();
  }

  void _updateTextState() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 40.h, // 높이 고정으로 컴팩트하게
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onChanged: (value) {
          widget.onChanged?.call(value);
          _updateTextState();
        },
        onTap: widget.onTap,
        onSubmitted: (value) {
          widget.focusNode?.unfocus();
          widget.onSubmitted?.call(value);
        },
        textInputAction: TextInputAction.search,
        style: TextStyle(
          fontSize: 14.sp, // 폰트 크기 조정
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white54 : Colors.grey.shade600,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20.sp, // 아이콘 크기 축소
            color: isDark ? Colors.white54 : Colors.grey.shade600,
          ),
          suffixIcon: _buildSuffixIcon(),
          filled: true,
          fillColor: isDark
              ? Colors.grey.shade800
              : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r), // 모서리 둥글기 축소
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.5, // 테두리 두께 축소
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w, // 패딩 축소
            vertical: 8.h,    // 패딩 축소
          ),
          isDense: true, // 밀도 높게 설정
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) return widget.suffixIcon;

    if (_hasText) {
      return IconButton(
        icon: Icon(
          Icons.clear,
          size: 18.sp, // 클리어 아이콘 크기 축소
        ),
        onPressed: () {
          widget.controller?.clear();
          widget.onChanged?.call('');
          _updateTextState();
        },
        padding: EdgeInsets.all(8.w), // 패딩 축소
        constraints: BoxConstraints(
          minWidth: 32.w, // 최소 크기 축소
          minHeight: 32.h,
        ),
      );
    }

    return null;
  }
}