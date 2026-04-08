
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';

class ProductThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double size;
  const ProductThumbnail({this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColor,
        borderRadius: ThemeColor.smallBorderRadius,
        border: Border.all(color: ThemeColor.dividerColor),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: ThemeColor.smallBorderRadius,
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_outlined,
                  color: ThemeColor.textTertiaryColor,
                  size: size * 0.48,
                ),
              ),
            )
          : Icon(Icons.image_outlined,
              color: ThemeColor.textTertiaryColor, size: size * 0.48),
    );
  }
}