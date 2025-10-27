import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/config/supabase_config.dart';
import 'presentation/views/main_navigation_view.dart';
import 'presentation/views/unified_login_view.dart';
import 'presentation/viewmodels/theme_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // PKCE 플로우 사용
    ),
  );

  // AdMob 초기화
  await MobileAds.instance.initialize();

  // 🎨 안드로이드 네비게이션 바 완전 숨김 처리
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky, // 완전 몰입 모드
    overlays: [], // 모든 시스템 UI 숨김
  );

  // 시스템 UI 색상 설정 (재표시될 때를 위해)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeViewModelProvider);

    return MaterialApp(
      title: AppConstants.appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: _buildInitialScreen(),
      routes: {
        '/login': (context) => const UnifiedLoginView(),
        '/home': (context) => const MainNavigationView(),
      },
    );
  }

  /// 초기 화면 결정 (로그인 상태 확인)
  Widget _buildInitialScreen() {
    final user = Supabase.instance.client.auth.currentUser;

    // 로그인 상태면 메인 화면, 아니면 로그인 화면
    if (user != null) {
      return const MainNavigationView();
    } else {
      return const UnifiedLoginView();
    }
  }
}
