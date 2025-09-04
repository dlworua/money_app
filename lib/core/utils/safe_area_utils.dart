import 'package:flutter/material.dart';
import 'responsive_utils.dart';

class SafeAreaUtils {
  // 안전한 화면 영역을 고려한 패딩
  static EdgeInsets getSafeResponsivePadding(BuildContext context, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final safeTop = mediaQuery.padding.top;
    final safeBottom = mediaQuery.padding.bottom;
    final safeLeft = mediaQuery.padding.left;
    final safeRight = mediaQuery.padding.right;
    
    final scale = ResponsiveUtils.getIPhone16PlusSpacing(context, 1.0);
    
    if (all != null) {
      return EdgeInsets.only(
        top: (all * scale) + safeTop,
        bottom: (all * scale) + safeBottom,
        left: (all * scale) + safeLeft,
        right: (all * scale) + safeRight,
      );
    }
    
    return EdgeInsets.only(
      top: ((top ?? vertical ?? 0) * scale) + safeTop,
      bottom: ((bottom ?? vertical ?? 0) * scale) + safeBottom,
      left: ((left ?? horizontal ?? 0) * scale) + safeLeft,
      right: ((right ?? horizontal ?? 0) * scale) + safeRight,
    );
  }
  
  // 오버플로우 방지를 위한 최대 크기 계산
  static BoxConstraints getMaxConstraints(BuildContext context, {
    double? maxWidthRatio,
    double? maxHeightRatio,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    
    final availableWidth = screenSize.width - safeArea.left - safeArea.right;
    final availableHeight = screenSize.height - safeArea.top - safeArea.bottom;
    
    return BoxConstraints(
      maxWidth: maxWidthRatio != null 
          ? availableWidth * maxWidthRatio 
          : availableWidth * 0.95, // 기본 95%
      maxHeight: maxHeightRatio != null 
          ? availableHeight * maxHeightRatio 
          : availableHeight * 0.9, // 기본 90%
    );
  }
  
  // 안전한 반응형 위젯 래퍼
  static Widget safeResponsiveWidget(
    BuildContext context,
    Widget child, {
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? maxWidthRatio,
    double? maxHeightRatio,
  }) {
    return Container(
      constraints: getMaxConstraints(context, 
        maxWidthRatio: maxWidthRatio, 
        maxHeightRatio: maxHeightRatio
      ),
      padding: padding ?? ResponsiveUtils.getIPhone16PlusPadding(context),
      margin: margin,
      child: child,
    );
  }
}