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
  final VoidCallback? onSubmitted;

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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onChanged: (value) {
          widget.onChanged?.call(value);
          // 텍스트 상태 즉시 업데이트
          _updateTextState();
        },
        onTap: widget.onTap,
        onSubmitted: (value) {
          widget.focusNode?.unfocus();
          widget.onSubmitted?.call();
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon ?? const Icon(Icons.search),
          suffixIcon: _buildSuffixIcon(),
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

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) return widget.suffixIcon;

    // 텍스트가 있을 때만 X 버튼 표시
    if (_hasText) {
      return IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          // 텍스트만 지우고 포커스와 키보드는 유지
          widget.controller?.clear();
          widget.onChanged?.call('');
          // 텍스트 상태 업데이트
          _updateTextState();
        },
      );
    }

    return null;
  }
}