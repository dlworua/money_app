import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show Platform;
import '../../data/repositories/supabase_user_repository.dart';
import '../../core/services/logger_service.dart';
import '../providers/auth_provider.dart';

/// 통합 로그인 화면 (이메일 메인 + 소셜 하단)
class UnifiedLoginView extends ConsumerStatefulWidget {
  const UnifiedLoginView({super.key});

  @override
  ConsumerState<UnifiedLoginView> createState() => _UnifiedLoginViewState();
}

class _UnifiedLoginViewState extends ConsumerState<UnifiedLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  bool _isLoading = false;
  bool _isSignUpMode = false; // false = 로그인, true = 회원가입
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  /// 이메일 로그인
  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);

      final response = await authRepo.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      LoggerService.error('❌ 로그인 실패', e);

      if (mounted) {
        String errorMessage = '로그인 실패';

        if (e.toString().contains('Invalid login credentials')) {
          errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다';
        } else if (e.toString().contains('Email not confirmed')) {
          errorMessage = '이메일 인증이 필요합니다\n이메일을 확인해주세요';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 이메일 회원가입
  Future<void> _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final supabaseUserRepo = SupabaseUserRepository();

      final response = await authRepo.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nicknameController.text.trim(),
      );

      if (response.user != null) {
        final user = response.user!;

        // Supabase 프로필 생성
        await supabaseUserRepo.createUserProfile(
          userId: user.id,
          name: _nicknameController.text.trim(),
          email: user.email!,
        );

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('📧 이메일 인증'),
              content: Text(
                '${user.email}로 인증 이메일을 전송했습니다.\n\n'
                '이메일 확인 후 로그인해주세요.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _isSignUpMode = false;
                      _passwordController.clear();
                      _nicknameController.clear();
                    });
                  },
                  child: const Text('확인'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.error('❌ 회원가입 실패', e);

      if (mounted) {
        String errorMessage = '회원가입 실패';

        if (e.toString().contains('already registered')) {
          errorMessage = '이미 등록된 이메일입니다';
        } else if (e.toString().contains('Password should be')) {
          errorMessage = '비밀번호는 6자 이상이어야 합니다';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 소셜 로그인 (연동된 경우에만 성공)
  Future<void> _handleSocialSignIn(String provider) async {
    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final supabaseUserRepo = SupabaseUserRepository();

      AuthResponse response;

      if (provider == 'Google') {
        response = await authRepo.signInWithGoogle();
      } else {
        response = await authRepo.signInWithApple();
      }

      if (response.user != null) {
        final user = response.user!;

        // Supabase 프로필 확인
        final existingProfile = await supabaseUserRepo.getUserFromSupabase(user.id);

        if (existingProfile == null) {
          // 프로필 없음 = 이메일 계정 없이 소셜 로그인 시도
          await authRepo.signOut();

          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('$provider 계정 연동 필요'),
                content: const Text(
                  '소셜 로그인을 사용하려면\n먼저 이메일로 회원가입하고\n프로필에서 계정을 연동해주세요.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('확인'),
                  ),
                ],
              ),
            );
          }
        } else {
          // 프로필 있음 = 연동된 계정 → 로그인 성공
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      }
    } catch (e) {
      LoggerService.error('❌ 소셜 로그인 실패', e);

      if (mounted) {
        String errorMessage = '$provider 로그인 실패';
        if (e.toString().contains('취소') || e.toString().contains('CANCEL')) {
          errorMessage = '로그인이 취소되었습니다';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.orange),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 비밀번호 재설정
  Future<void> _handleResetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일을 입력해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.resetPassword(_emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_emailController.text.trim()}로\n비밀번호 재설정 이메일을 전송했습니다',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호 재설정 이메일 전송 실패'),
            backgroundColor: Colors.red,
          ),
        );
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
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      // 로고
                      Icon(
                        Icons.account_balance_wallet,
                        size: 80,
                        color: Colors.green.shade400,
                      ),

                      const SizedBox(height: 24),

                      // 타이틀
                      Text(
                        _isSignUpMode ? '회원가입' : '로그인',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _isSignUpMode
                            ? 'AI와 함께하는 스마트한 가계부'
                            : '다시 오신 것을 환영합니다',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 닉네임 (회원가입 시에만)
                      if (_isSignUpMode) ...[
                        TextFormField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            labelText: '닉네임',
                            hintText: '사용할 닉네임을 입력하세요',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '닉네임을 입력해주세요';
                            }
                            if (value.trim().length < 2) {
                              return '닉네임은 2자 이상이어야 합니다';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 이메일
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: '이메일',
                          hintText: 'example@email.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '이메일을 입력해주세요';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return '올바른 이메일 형식이 아닙니다';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // 비밀번호
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          hintText: _isSignUpMode ? '6자 이상 입력하세요' : '비밀번호를 입력하세요',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요';
                          }
                          if (_isSignUpMode && value.length < 6) {
                            return '비밀번호는 6자 이상이어야 합니다';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 8),

                      // 비밀번호 찾기 (로그인 모드)
                      if (!_isSignUpMode)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _handleResetPassword,
                            child: Text(
                              '비밀번호를 잊으셨나요?',
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // 로그인/회원가입 버튼
                      ElevatedButton(
                        onPressed: _isSignUpMode ? _handleEmailSignUp : _handleEmailSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _isSignUpMode ? '회원가입' : '로그인',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 전환 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSignUpMode ? '이미 계정이 있으신가요?' : '계정이 없으신가요?',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isSignUpMode = !_isSignUpMode;
                                _passwordController.clear();
                                _nicknameController.clear();
                              });
                            },
                            child: Text(
                              _isSignUpMode ? '로그인' : '회원가입',
                              style: TextStyle(
                                color: Colors.green.shade400,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // 구분선
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '간편 로그인',
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 소셜 로그인 버튼들 (로우)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google
                          _buildSocialButton(
                            icon: Icons.g_mobiledata,
                            label: 'Google',
                            color: Colors.white,
                            iconColor: Colors.blue,
                            onTap: () => _handleSocialSignIn('Google'),
                          ),

                          const SizedBox(width: 16),

                          // Apple (iOS만)
                          if (Platform.isIOS)
                            _buildSocialButton(
                              icon: Icons.apple,
                              label: 'Apple',
                              color: Colors.black,
                              iconColor: Colors.white,
                              onTap: () => _handleSocialSignIn('Apple'),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 게스트 안내
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/home');
                          },
                          child: Text(
                            '게스트로 둘러보기',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 안내 문구
                      Text(
                        '이메일 계정 생성 후\n프로필에서 소셜 계정을 연동할 수 있습니다',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// 소셜 로그인 버튼
  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
