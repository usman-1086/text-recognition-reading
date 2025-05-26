import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Responsive {
  static double width = Get.width;
  static double height = Get.height;

  // Breakpoints
  static bool isMobile() => width < 768;
  static bool isTablet() => width >= 768 && width < 1024;
  static bool isDesktop() => width >= 1024;

  // Responsive values
  static double wp(double percentage) => width * percentage / 100;
  static double hp(double percentage) => height * percentage / 100;

  // Font sizes
  static double fontSize(double size) {
    if (isMobile()) return size;
    if (isTablet()) return size * 1.1;
    return size * 1.2;
  }

  // Padding/Margin
  static double padding(double value) {
    if (isMobile()) return value;
    if (isTablet()) return value * 1.2;
    return value * 1.5;
  }

  // Icon sizes
  static double iconSize(double size) {
    if (isMobile()) return size;
    if (isTablet()) return size * 1.1;
    return size * 1.3;
  }

  // Card heights
  static double cardHeight(double baseHeight) {
    if (isMobile()) return baseHeight;
    if (isTablet()) return baseHeight * 1.1;
    return baseHeight * 1.2;
  }

  // Grid columns
  static int gridColumns() {
    if (isMobile()) return 1;
    if (isTablet()) return 2;
    return 3;
  }

  // Max width for content
  static double maxContentWidth() {
    if (isMobile()) return width;
    if (isTablet()) return width * 0.9;
    return 1200;
  }
}