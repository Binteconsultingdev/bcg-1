import 'dart:ui';

import 'package:bcg/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSnackBar(String message, Color color) {
  ScaffoldMessenger.of(Get.context!).clearSnackBars();
  
  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: ThemeColor.textLightColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: ThemeColor.textLightColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.all(16),
    ),
  );
}
void showSuccessSnackbar(String message) {
  showSnackBar(message, ThemeColor.successColor);
}

void showErrorSnackbar(String message) {
  showSnackBar(message, ThemeColor.errorColor);
}

void showInfoSnackbar(String message) {
  showSnackBar(message, ThemeColor.primaryColor);
}

void showWarningSnackbar(String message) {
  showSnackBar(message, Colors.orange);
}