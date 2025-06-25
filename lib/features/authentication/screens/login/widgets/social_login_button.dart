import 'package:flutter/material.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    this.icon,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  final String? icon;
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? TColors.white,
          foregroundColor: textColor ?? TColors.dark,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: BorderSide(
            color: borderColor ?? Colors.transparent,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TSizes.buttonRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘 표시 (Google, Facebook만)
            if (icon != null) ...[
              Image(
                width: 20,
                height: 20,
                image: AssetImage(icon!),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
            ],

            // 텍스트
            Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor ?? TColors.dark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}