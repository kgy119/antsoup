import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class TCircularImage extends StatelessWidget {
  const TCircularImage({
    super.key,
    this.fit,
    required this.image,
    this.isNetworkImage = false,
    this.overLayColor,
    this.backgroundColor,
    this.width = 56,
    this.height = 56,
    this.padding = TSizes.sm,
    this.enableCache = true, // 캐시 제어 옵션 추가
  });

  final BoxFit? fit;
  final String image;
  final bool isNetworkImage;
  final Color? overLayColor;
  final Color? backgroundColor;
  final double width, height, padding;
  final bool enableCache; // 추가

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ?? (THelperFunctions.isDarkMode(context)
            ? TColors.black
            : TColors.white),
        borderRadius: BorderRadius.circular(100),
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (isNetworkImage) {
      // 네트워크 이미지의 경우 캐시 버스팅 적용
      final imageUrl = enableCache ? image : '$image?t=${DateTime.now().millisecondsSinceEpoch}';

      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit ?? BoxFit.cover,
        width: width - (padding * 2),
        height: height - (padding * 2),
        placeholder: (context, url) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorWidget: (context, url, error) {
          return Container(
            color: Colors.grey.shade200,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red),
                Text(
                  '이미지 로드 실패',
                  style: TextStyle(fontSize: 8, color: Colors.red),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // 로컬 이미지
      return Image(
        fit: fit ?? BoxFit.cover,
        image: AssetImage(image),
        color: overLayColor,
        width: width - (padding * 2),
        height: height - (padding * 2),
      );
    }
  }
}