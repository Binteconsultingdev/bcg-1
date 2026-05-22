import 'dart:io';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';

class ProductThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? localPath; // 👈 nuevo

  const ProductThumbnail({
    super.key,
    this.imageUrl,
    required this.size,
    this.localPath,
  });

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
      child: ClipRRect(
        borderRadius: ThemeColor.smallBorderRadius,
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    // Primero local, luego red, luego placeholder
    if (localPath != null && localPath!.isNotEmpty) {
      return Image.file(
        File(localPath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildNoImage(),
      );
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildNoImage(),
      );
    }
    return _buildNoImage();
  }

  Widget _buildNoImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.hide_image_outlined,
          color: ThemeColor.textTertiaryColor,
          size: size * 0.38,
        ),
        const SizedBox(height: 4),
        Text(
          'Sin imagen',
          style: TextStyle(
            color: ThemeColor.textTertiaryColor,
            fontSize: size * 0.13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}