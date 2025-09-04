import 'package:flutter/material.dart';

class ResponsiveUtils {
  // iPhone 16 Plus를 기준 디바이스로 설정 (6.7인치, 430pt 논리 해상도)
  static const double _referenceWidth = 430.0;     // iPhone 16 Plus 논리 너비
  static const double _referenceHeight = 932.0;    // iPhone 16 Plus 논리 높이
  static const double _referenceScreenSize = 6.7;  // iPhone 16 Plus 실제 크기 (인치)
  
  // 정확한 디바이스별 논리 해상도와 실제 화면 크기 매핑
  static const Map<String, Map<String, double>> _deviceSpecs = {
    // iPhone 시리즈
    'iPhone SE': {'width': 320.0, 'height': 568.0, 'inches': 4.0},
    'iPhone 12 Mini': {'width': 360.0, 'height': 780.0, 'inches': 5.4},
    'iPhone X/11 Pro': {'width': 375.0, 'height': 812.0, 'inches': 5.8},
    'iPhone 12/13/14/15': {'width': 390.0, 'height': 844.0, 'inches': 6.1},
    'iPhone 16': {'width': 393.0, 'height': 852.0, 'inches': 6.1},
    'iPhone 8 Plus': {'width': 414.0, 'height': 736.0, 'inches': 5.5},
    'iPhone 16 Plus': {'width': 430.0, 'height': 932.0, 'inches': 6.7}, // 기준 디바이스
    'iPhone 16 Pro': {'width': 402.0, 'height': 874.0, 'inches': 6.3},
    'iPhone 16 Pro Max': {'width': 440.0, 'height': 956.0, 'inches': 6.9},
    
    // Samsung Galaxy 시리즈
    'Galaxy S24': {'width': 360.0, 'height': 780.0, 'inches': 6.2},
    'Galaxy S24 Ultra': {'width': 412.0, 'height': 915.0, 'inches': 6.8},
    'Galaxy S25 Ultra': {'width': 420.0, 'height': 932.0, 'inches': 6.9},
    'Galaxy Z Fold5 Cover': {'width': 360.0, 'height': 772.0, 'inches': 6.2},
    'Galaxy Z Fold5 Main': {'width': 673.0, 'height': 841.0, 'inches': 7.6},
  };

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // 화면 크기에 따른 동적 패딩
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isLargeScreen(context)) {
      return const EdgeInsets.all(24);
    } else if (isMediumScreen(context)) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  // 화면 크기에 따른 동적 여백 (구 버전 - 호환성 유지)
  static EdgeInsets getResponsiveMarginOld(BuildContext context) {
    if (isLargeScreen(context)) {
      return const EdgeInsets.all(16);
    } else if (isMediumScreen(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.all(8);
    }
  }

  // iPhone 16 Plus 기준으로 완벽하게 통일된 폰트 크기 제공
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenSize = MediaQuery.of(context).size;
    final scale = _getScaleFactorForDevice(screenSize.width, screenSize.height);
    return baseSize * scale;
  }
  
  // iPhone 16 Plus를 기준(1.0)으로 한 모든 디바이스의 정확한 스케일 팩터 계산
  static double _getScaleFactorForDevice(double screenWidth, double screenHeight) {
    // 정확한 물리적 크기 기반 스케일링 - 작은 화면일수록 더 작게 스케일링
    final exactScale = screenWidth / _referenceWidth;
    
    // 화면 크기별 정밀 스케일링 - 실제 비율을 더 정확하게 반영
    if (screenWidth <= 320) return exactScale * 0.85;   // iPhone SE (4.0") - 훨씬 더 작게
    if (screenWidth <= 360) return exactScale * 0.90;   // iPhone Mini (5.4"), Galaxy S24 (6.2") - 더 작게
    if (screenWidth <= 375) return exactScale * 0.93;   // iPhone X/11 Pro (5.8") - 작게
    if (screenWidth <= 393) return exactScale * 0.96;   // iPhone 12-15 (6.1"), iPhone 16 (6.1") - 약간 작게
    if (screenWidth <= 414) return exactScale * 0.98;   // iPhone 8 Plus (5.5"), Galaxy S24 Ultra (6.8") - 거의 기준
    if (screenWidth <= 430) return 1.0;                 // iPhone 16 Plus (6.7") - 기준점
    if (screenWidth <= 440) return exactScale * 1.01;   // iPhone 16 Pro Max (6.9") - 약간 크게
    if (screenWidth <= 450) return exactScale * 1.03;   // Galaxy S25 Ultra (6.9") - 크게
    if (screenWidth <= 673) return exactScale * 0.75;   // Galaxy Z Fold5 Main (7.6") - 태블릿은 더 작게
    
    return exactScale.clamp(0.6, 1.4); // 안전장치 범위 확장
  }

  // iPhone 16 Plus 기준으로 완벽하게 통일된 아이콘 크기 제공
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final screenSize = MediaQuery.of(context).size;
    final scale = _getScaleFactorForDevice(screenSize.width, screenSize.height);
    return baseSize * scale;
  }

  // 화면 크기에 따른 컨테이너 최대 너비
  static double getMaxContainerWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isLargeScreen(context)) {
      return screenWidth * 0.8;
    } else if (isMediumScreen(context)) {
      return screenWidth * 0.9;
    } else {
      return screenWidth;
    }
  }

  // 화면 밀도에 따른 크기 조정
  static double getScaledSize(BuildContext context, double size) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);
    
    // 텍스트 스케일링과 픽셀 밀도를 고려한 크기 조정
    return size * (textScaleFactor.clamp(0.8, 1.3)) / (devicePixelRatio.clamp(1.0, 3.0));
  }

  // 안전 영역을 고려한 높이
  static double getSafeAreaHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height - 
           mediaQuery.padding.top - 
           mediaQuery.padding.bottom;
  }

  // 탭바 높이 계산
  static double getTabBarHeight(BuildContext context) {
    return kToolbarHeight + (isSmallScreen(context) ? 48 : 56);
  }

  // iPhone 16 Plus 기준으로 완벽하게 통일된 패딩 제공
  static EdgeInsets getIPhone16PlusPadding(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scale = _getScaleFactorForDevice(screenSize.width, screenSize.height);
    
    const basePadding = 16.0;
    final adjustedPadding = basePadding * scale;
    
    return EdgeInsets.all(adjustedPadding);
  }

  // iPhone 16 Plus 기준으로 완벽하게 통일된 스페이싱 제공
  static double getIPhone16PlusSpacing(BuildContext context, double baseSpacing) {
    final screenSize = MediaQuery.of(context).size;
    final scale = _getScaleFactorForDevice(screenSize.width, screenSize.height);
    
    return baseSpacing * scale;
  }

  // iPhone 16 Plus 기준 게임 카드 그리드를 위한 최적화된 크기
  static double getGameCardAspectRatio(BuildContext context) {
    // iPhone 16 Plus 기준 비율을 모든 디바이스에서 유지
    const baseAspectRatio = 0.85;
    return baseAspectRatio; // 모든 디바이스에서 동일한 비율 유지
  }

  // iPhone 16 Plus 기준으로 완벽하게 통일된 게임 카드 패딩 제공
  static EdgeInsets getGameCardPadding(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scale = _getScaleFactorForDevice(screenSize.width, screenSize.height);
    
    const basePadding = 16.0;
    final adjustedPadding = basePadding * scale;
    
    return EdgeInsets.all(adjustedPadding);
  }
  
  // iPhone 16 Plus 기준 위젯 크기 (너비/높이)
  static double getResponsiveSize(BuildContext context, double baseSize) {
    final screenSize = MediaQuery.of(context).size;
    final scale = _getScaleFactorForDevice(screenSize.width, screenSize.height);
    return baseSize * scale;
  }
  
  // iPhone 16 Plus 기준 margin 제공
  static EdgeInsets getResponsiveMargin(BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final scale = _getScaleFactorForDevice(screenSize.width, screenSize.height);
    
    if (all != null) {
      return EdgeInsets.all(all * scale);
    }
    
    return EdgeInsets.only(
      left: (left ?? horizontal ?? 0) * scale,
      top: (top ?? vertical ?? 0) * scale,
      right: (right ?? horizontal ?? 0) * scale,
      bottom: (bottom ?? vertical ?? 0) * scale,
    );
  }
  
  // iPhone 16 Plus 기준 padding 제공 (더 세밀한 제어) - 오버플로우 방지
  static EdgeInsets getResponsivePaddingCustom(BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final scale = _getScaleFactorForDevice(screenSize.width, screenSize.height);
    
    // 최소/최대 패딩 제한으로 오버플로우 방지
    double clampPadding(double value) => (value * scale).clamp(4.0, 32.0);
    
    if (all != null) {
      final paddingValue = clampPadding(all);
      return EdgeInsets.all(paddingValue);
    }
    
    return EdgeInsets.only(
      left: clampPadding(left ?? horizontal ?? 0),
      top: clampPadding(top ?? vertical ?? 0),
      right: clampPadding(right ?? horizontal ?? 0),
      bottom: clampPadding(bottom ?? vertical ?? 0),
    );
  }
  
  // 안전한 반응형 크기 (오버플로우 방지)
  static double getSafeResponsiveSize(BuildContext context, double baseSize, {
    double? maxRatio,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final scale = _getScaleFactorForDevice(screenSize.width, screenSize.height);
    final scaledSize = baseSize * scale;
    
    // 화면 크기 대비 최대 비율 제한
    final maxSize = screenSize.width * (maxRatio ?? 0.8);
    return scaledSize.clamp(baseSize * 0.5, maxSize);
  }
  
  // 텍스트 오버플로우 방지 폰트 크기
  static double getSafeResponsiveFontSize(BuildContext context, double baseSize) {
    final scaledSize = getResponsiveFontSize(context, baseSize);
    // 텍스트 크기 제한 (최소 10, 최대 48)
    return scaledSize.clamp(10.0, 48.0);
  }
}