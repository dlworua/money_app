import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/responsive_utils.dart';

class AppTheme {
  // 브랜드 컬러 팔레트 (프리미엄 핀테크 앱 스타일)
  static const primaryColor = Color(0xFF1E3A8A); // 딥 네이비 블루
  static const secondaryColor = Color(0xFF3B82F6); // 브라이트 블루
  static const accentColor = Color(0xFF10B981); // 에메랄드 그린
  static const successColor = Color(0xFF059669);
  static const warningColor = Color(0xFFF59E0B);
  static const errorColor = Color(0xFFDC2626);
  
  // 뉴트럴 컬러
  static const backgroundColor = Color(0xFFFAFAFA);
  static const surfaceColor = Color(0xFFFFFFFF);
  static const onSurfaceColor = Color(0xFF1F2937);
  static const onBackgroundColor = Color(0xFF374151);
  
  // 그라데이션
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF9FAFB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 텍스트 스타일 (iPhone 16 Plus 기준 - 반응형)
  static TextStyle getHeadingLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 32),
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static TextStyle getHeadingMedium(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static TextStyle getHeadingSmall(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );
  
  static TextStyle getBodyLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static TextStyle getBodyMedium(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static TextStyle getBodySmall(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.3,
  );
  
  static TextStyle getLabelLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // 호환성을 위한 정적 텍스트 스타일 (기본값)
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.3,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // 박스 쉐도우
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
  
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 3,
      offset: Offset(0, 2),
    ),
  ];

  // 보더 라디우스
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXLarge = BorderRadius.all(Radius.circular(24));

  // 스페이싱
  static const double spaceXS = 4;
  static const double spaceS = 8;
  static const double spaceM = 16;
  static const double spaceL = 24;
  static const double spaceXL = 32;
  static const double spaceXXL = 48;

  // 🌙 다크 모드 컬러 팔레트
  static const darkPrimaryColor = Color(0xFF60A5FA); // 밝은 블루
  static const darkSecondaryColor = Color(0xFF3B82F6);
  static const darkAccentColor = Color(0xFF34D399); // 밝은 그린
  static const darkBackgroundColor = Color(0xFF111827); // 다크 배경
  static const darkSurfaceColor = Color(0xFF1F2937); // 다크 서피스
  static const darkOnSurfaceColor = Color(0xFFF9FAFB); // 밝은 텍스트
  static const darkOnBackgroundColor = Color(0xFFE5E7EB);

  /// 라이트 테마
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      canvasColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurfaceColor,
      ),
      // Dialog 테마 설정
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: headingSmall.copyWith(color: onSurfaceColor),
        contentTextStyle: bodyMedium.copyWith(color: onBackgroundColor),
      ),
      fontFamily: 'SF Pro Display', // iOS 스타일 폰트
      textTheme: const TextTheme(
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        headlineSmall: headingSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurfaceColor,
        iconTheme: IconThemeData(color: onSurfaceColor),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: onSurfaceColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      iconTheme: const IconThemeData(color: onSurfaceColor),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radiusMedium),
        color: surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: radiusMedium),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: radiusMedium),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: radiusMedium),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  /// 다크 테마
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackgroundColor,
      canvasColor: darkBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimaryColor,
        brightness: Brightness.dark,
        primary: darkPrimaryColor,
        secondary: darkSecondaryColor,
        tertiary: darkAccentColor,
        surface: darkSurfaceColor,
        error: errorColor,
        onPrimary: darkBackgroundColor,
        onSecondary: darkBackgroundColor,
        onSurface: darkOnSurfaceColor,
      ),
      // Dialog 테마 설정
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurfaceColor,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: headingSmall.copyWith(color: darkOnSurfaceColor),
        contentTextStyle: bodyMedium.copyWith(color: darkOnBackgroundColor),
      ),
      fontFamily: 'SF Pro Display',
      textTheme: TextTheme(
        headlineLarge: headingLarge.copyWith(color: darkOnSurfaceColor),
        headlineMedium: headingMedium.copyWith(color: darkOnSurfaceColor),
        headlineSmall: headingSmall.copyWith(color: darkOnSurfaceColor),
        bodyLarge: bodyLarge.copyWith(color: darkOnBackgroundColor),
        bodyMedium: bodyMedium.copyWith(color: darkOnBackgroundColor),
        bodySmall: bodySmall.copyWith(color: darkOnBackgroundColor),
        labelLarge: labelLarge.copyWith(color: darkOnBackgroundColor),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: darkOnSurfaceColor,
        iconTheme: IconThemeData(color: darkOnSurfaceColor),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: darkOnSurfaceColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      iconTheme: const IconThemeData(color: darkOnSurfaceColor),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radiusMedium),
        color: darkSurfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: darkPrimaryColor,
          foregroundColor: darkBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: radiusMedium),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: darkPrimaryColor,
          foregroundColor: darkBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: radiusMedium),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: radiusMedium),
          side: const BorderSide(color: Color(0xFF374151)),
          foregroundColor: darkOnSurfaceColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  /// ========================================
  /// 테마 인식 헬퍼 메서드들
  /// ========================================

  /// 현재 테마가 다크 모드인지 확인
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// 테마에 따른 배경색 반환
  static Color getBackgroundColor(BuildContext context) {
    return isDark(context) ? darkBackgroundColor : backgroundColor;
  }

  /// 테마에 따른 서피스 색상 반환 (카드, 패널 등)
  static Color getSurfaceColor(BuildContext context) {
    return isDark(context) ? darkSurfaceColor : surfaceColor;
  }

  /// 테마에 따른 텍스트 색상 반환
  static Color getTextColor(BuildContext context) {
    return isDark(context) ? darkOnSurfaceColor : onSurfaceColor;
  }

  /// 테마에 따른 보조 텍스트 색상 반환
  static Color getSecondaryTextColor(BuildContext context) {
    return isDark(context) ? darkOnBackgroundColor : onBackgroundColor;
  }

  /// 테마에 따른 카드 색상 반환
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).cardTheme.color ?? getSurfaceColor(context);
  }

  /// 테마에 따른 회색 톤 반환
  static Color getGreyColor(BuildContext context, [int shade = 600]) {
    if (isDark(context)) {
      // 다크 모드에서는 밝은 회색
      return shade >= 500 ? Colors.grey[400]! : Colors.grey[600]!;
    }
    return Colors.grey[shade]!;
  }

  /// ========================================
  /// 하드코딩 색상 대체 헬퍼 메서드들
  /// ========================================

  /// Colors.white 대체 - 가장 밝은 색상
  static Color white(BuildContext context) {
    return isDark(context) ? darkSurfaceColor : Colors.white;
  }

  /// Colors.black 대체 - 가장 어두운 색상
  static Color black(BuildContext context) {
    return isDark(context) ? Colors.white : Colors.black;
  }

  /// 테마에 따른 Pink 색상
  static Color pink(BuildContext context, [int shade = 600]) {
    if (isDark(context)) {
      // 다크모드에서는 약간 밝게
      return shade >= 500 ? Colors.pink[300]! : Colors.pink[200]!;
    }
    return Colors.pink[shade]!;
  }

  /// 테마에 따른 Purple 색상
  static Color purple(BuildContext context, [int shade = 600]) {
    if (isDark(context)) {
      return shade >= 500 ? Colors.purple[300]! : Colors.purple[200]!;
    }
    return Colors.purple[shade]!;
  }

  /// 테마에 따른 Blue 색상
  static Color blue(BuildContext context, [int shade = 600]) {
    if (isDark(context)) {
      return shade >= 500 ? Colors.blue[300]! : Colors.blue[200]!;
    }
    return Colors.blue[shade]!;
  }

  /// 테마에 따른 Green 색상
  static Color green(BuildContext context, [int shade = 600]) {
    if (isDark(context)) {
      return shade >= 500 ? Colors.green[300]! : Colors.green[200]!;
    }
    return Colors.green[shade]!;
  }

  /// 테마에 따른 Orange 색상
  static Color orange(BuildContext context, [int shade = 600]) {
    if (isDark(context)) {
      return shade >= 500 ? Colors.orange[300]! : Colors.orange[200]!;
    }
    return Colors.orange[shade]!;
  }

  /// 테마에 따른 Red 색상
  static Color red(BuildContext context, [int shade = 600]) {
    if (isDark(context)) {
      return shade >= 500 ? Colors.red[300]! : Colors.red[200]!;
    }
    return Colors.red[shade]!;
  }

  /// 테마에 따른 Amber 색상
  static Color amber(BuildContext context, [int shade = 600]) {
    if (isDark(context)) {
      return shade >= 500 ? Colors.amber[300]! : Colors.amber[200]!;
    }
    return Colors.amber[shade]!;
  }

  /// 테마에 따른 Teal 색상
  static Color teal(BuildContext context, [int shade = 600]) {
    if (isDark(context)) {
      return shade >= 500 ? Colors.teal[300]! : Colors.teal[200]!;
    }
    return Colors.teal[shade]!;
  }

  /// 테마에 따른 Indigo 색상
  static Color indigo(BuildContext context, [int shade = 600]) {
    if (isDark(context)) {
      return shade >= 500 ? Colors.indigo[300]! : Colors.indigo[200]!;
    }
    return Colors.indigo[shade]!;
  }
}