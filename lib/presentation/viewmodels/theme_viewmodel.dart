import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 테마 모드 관리 ViewModel
class ThemeViewModel extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeViewModel() : super(ThemeMode.light) {
    _loadTheme();
  }

  /// SharedPreferences에서 테마 설정 로드
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey);

      if (themeModeString != null) {
        state = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.light,
        );
      }
    } catch (e) {
      // 로드 실패 시 기본값(light) 유지
      state = ThemeMode.light;
    }
  }

  /// 테마 모드 변경 및 저장
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.toString());
    } catch (e) {
      // 저장 실패해도 state는 변경된 상태 유지
    }
  }

  /// 라이트/다크 토글
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// 현재 다크 모드 여부
  bool get isDarkMode => state == ThemeMode.dark;
}

/// ThemeViewModel Provider
final themeViewModelProvider = StateNotifierProvider<ThemeViewModel, ThemeMode>((ref) {
  return ThemeViewModel();
});
