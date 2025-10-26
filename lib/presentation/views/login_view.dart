import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/supabase_user_repository.dart';
import '../../core/services/logger_service.dart';
import 'dart:io' show Platform;

/// 로그인 화면 - Google/Apple 소셜 로그인
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _authRepo = AuthRepository();
  final _supabaseUserRepo = SupabaseUserRepository();
  bool _isLoading = false;

  /// Google 로그인 처리
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final response = await _authRepo.signInWithGoogle();
      if (response.user != null) {
        final user = response.user!;
        LoggerService.info('✅ Google 로그인 성공: ${user.email}');

        // Supabase에 사용자 프로필이 있는지 확인
        final existingProfile = await _supabaseUserRepo.getUserFromSupabase(user.id);

        if (existingProfile == null) {
          // 최초 로그인 → Supabase에 프로필 생성
          await _supabaseUserRepo.createUserProfile(
            userId: user.id,
            name: user.userMetadata?['full_name'] ?? user.email ?? 'User',
            email: user.email!,
            photoUrl: user.userMetadata?['avatar_url'],
          );
        }

        if (mounted) {
          // 로그인 성공 → 메인 화면으로 이동
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      LoggerService.error('❌ Google 로그인 실패', e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google 로그인 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Apple 로그인 처리
  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final response = await _authRepo.signInWithApple();
      if (response.user != null) {
        final user = response.user!;
        LoggerService.info('✅ Apple 로그인 성공: ${user.email}');

        // Supabase에 사용자 프로필이 있는지 확인
        final existingProfile = await _supabaseUserRepo.getUserFromSupabase(user.id);

        if (existingProfile == null) {
          // 최초 로그인 → Supabase에 프로필 생성
          await _supabaseUserRepo.createUserProfile(
            userId: user.id,
            name: user.userMetadata?['full_name'] ?? user.email ?? 'User',
            email: user.email ?? 'apple@privaterelay.appleid.com',
            photoUrl: user.userMetadata?['avatar_url'],
          );
        }

        if (mounted) {
          // 로그인 성공 → 메인 화면으로 이동
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      LoggerService.error('❌ Apple 로그인 실패', e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple 로그인 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildLoginContent(context, isDark),
      ),
    );
  }

  Widget _buildLoginContent(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 앱 로고 및 타이틀
          Icon(
            Icons.account_balance_wallet,
            size: 100,
            color: Colors.green.shade400,
          ),
          const SizedBox(height: 24),

          Text(
            '머니 앱',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'AI와 함께하는 스마트한 가계부',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 64),

          // Google 로그인 버튼
          _buildGoogleSignInButton(),

          const SizedBox(height: 16),

          // Apple 로그인 버튼 (iOS만)
          if (Platform.isIOS) ...[
            _buildAppleSignInButton(),
            const SizedBox(height: 16),
          ],

          // 게스트로 계속하기 버튼
          _buildGuestButton(isDark),

          const SizedBox(height: 32),

          // 안내 문구
          Text(
            '로그인하시면 모든 기기에서\n데이터를 동기화할 수 있습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Google 로그인 버튼
  Widget _buildGoogleSignInButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleGoogleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google 로고 (텍스트로 대체)
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'G',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Google 계정으로 계속하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Apple 로그인 버튼
  Widget _buildAppleSignInButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleAppleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.apple, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Apple 계정으로 계속하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 게스트 버튼
  Widget _buildGuestButton(bool isDark) {
    return TextButton(
      onPressed: _isLoading
          ? null
          : () {
              // 게스트로 계속 → 메인 화면
              Navigator.of(context).pushReplacementNamed('/home');
            },
      child: Text(
        '게스트로 계속하기',
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
