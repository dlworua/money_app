import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/supabase_user_repository.dart';
import '../../core/services/logger_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/terms_agreement_widget.dart';
import '../../data/models/terms_agreement_model.dart';

/// 이메일 로그인/회원가입 화면
class EmailLoginView extends ConsumerStatefulWidget {
  const EmailLoginView({super.key});

  @override
  ConsumerState<EmailLoginView> createState() => _EmailLoginViewState();
}

class _EmailLoginViewState extends ConsumerState<EmailLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isSignUpMode = false; // false = 로그인, true = 회원가입
  bool _obscurePassword = true;

  // 약관 동의 상태
  bool _serviceTermsAgreed = false;
  bool _privacyPolicyAgreed = false;
  bool _marketingConsentAgreed = false;
  bool _ageConfirmationAgreed = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// 이메일 로그인 처리
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
        // 로그인 성공 → 메인 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      LoggerService.error('❌ 로그인 실패', e);

      if (mounted) {
        String errorMessage = '로그인 실패';

        if (e.toString().contains('Invalid login credentials')) {
          errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다';
        } else if (e.toString().contains('Email not confirmed')) {
          errorMessage = '이메일 인증이 필요합니다. 이메일을 확인해주세요';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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

  /// 이메일 회원가입 처리
  Future<void> _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    // 필수 약관 동의 확인
    if (!_serviceTermsAgreed || !_privacyPolicyAgreed || !_ageConfirmationAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('필수 약관에 모두 동의해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final supabaseUserRepo = SupabaseUserRepository();

      final response = await authRepo.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
      );

      if (response.user != null) {
        final user = response.user!;

        // Supabase에 사용자 프로필 생성
        await supabaseUserRepo.createUserProfile(
          userId: user.id,
          name: _nameController.text.trim().isEmpty
              ? user.email!.split('@')[0]
              : _nameController.text.trim(),
          email: user.email!,
        );

        // 약관 동의 데이터 저장
        final termsAgreement = TermsAgreementModel(
          userId: user.id,
          serviceTerms: _serviceTermsAgreed,
          privacyPolicy: _privacyPolicyAgreed,
          marketingConsent: _marketingConsentAgreed,
          ageConfirmation: _ageConfirmationAgreed,
          agreedAt: DateTime.now(),
        );

        // Supabase에 약관 동의 데이터 저장 (향후 구현)
        // await supabaseUserRepo.saveTermsAgreement(termsAgreement);

        if (mounted) {
          // 이메일 인증 안내
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('📧 이메일 인증'),
              content: Text(
                '${user.email}로 인증 이메일을 전송했습니다.\n\n'
                '이메일 확인 후 로그인해주세요.'
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _isSignUpMode = false;
                      _passwordController.clear();
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
          SnackBar(
            content: Text(errorMessage),
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
              '${_emailController.text.trim()}로\n비밀번호 재설정 이메일을 전송했습니다'
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                      // 타이틀
                      Text(
                        _isSignUpMode ? '회원가입' : '로그인',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _isSignUpMode
                            ? '이메일로 가입하고 모든 기기에서 동기화하세요'
                            : '이메일로 로그인하세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 이름 입력 (회원가입 시에만)
                      if (_isSignUpMode) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: '이름 (선택사항)',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 이메일 입력
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: '이메일',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '이메일을 입력해주세요';
                          }
                          if (!value.contains('@')) {
                            return '올바른 이메일 형식이 아닙니다';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // 비밀번호 입력
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
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

                      // 비밀번호 찾기 (로그인 모드만)
                      if (!_isSignUpMode)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _handleResetPassword,
                            child: const Text('비밀번호를 잊으셨나요?'),
                          ),
                        ),

                      // 약관 동의 (회원가입 모드만)
                      if (_isSignUpMode) ...[
                        const SizedBox(height: 32),
                        TermsAgreementWidget(
                          onAgreementChanged: (serviceTerms, privacyPolicy, marketingConsent, ageConfirmation) {
                            setState(() {
                              _serviceTermsAgreed = serviceTerms;
                              _privacyPolicyAgreed = privacyPolicy;
                              _marketingConsentAgreed = marketingConsent;
                              _ageConfirmationAgreed = ageConfirmation;
                            });
                          },
                        ),
                      ],

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
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isSignUpMode = !_isSignUpMode;
                                _passwordController.clear();
                              });
                            },
                            child: Text(
                              _isSignUpMode ? '로그인' : '회원가입',
                              style: TextStyle(
                                color: Colors.green.shade400,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
