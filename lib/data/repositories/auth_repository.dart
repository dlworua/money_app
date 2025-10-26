import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import '../../core/services/logger_service.dart';

/// 인증 저장소 - Supabase Auth를 사용한 소셜 로그인
///
/// 지원하는 로그인 방식:
/// - Google 로그인
/// - Apple 로그인
/// - 이메일/비밀번호 (선택사항)
class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 현재 로그인된 사용자
  User? get currentUser => _supabase.auth.currentUser;

  /// 로그인 상태 Stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Google 로그인
  Future<AuthResponse> signInWithGoogle() async {
    try {
      LoggerService.info('🔐 Google 로그인 시작');

      // 1. Google Sign In 초기화
      final googleSignIn = GoogleSignIn(
        serverClientId: _getGoogleClientId(),
      );

      // 2. Google 계정 선택
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google 로그인 취소됨');
      }

      // 3. Google 인증 정보 가져오기
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Google ID Token을 가져올 수 없습니다');
      }

      // 4. Supabase에 Google 인증 정보 전달
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      LoggerService.info('✅ Google 로그인 성공: ${response.user?.email}');
      return response;
    } catch (e) {
      LoggerService.error('❌ Google 로그인 실패', e);
      rethrow;
    }
  }

  /// Apple 로그인
  Future<AuthResponse> signInWithApple() async {
    try {
      LoggerService.info('🍎 Apple 로그인 시작');

      // 1. Nonce 생성 (보안)
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      // 2. Apple Sign In 요청
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      // 3. ID Token 확인
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Apple ID Token을 가져올 수 없습니다');
      }

      // 4. Supabase에 Apple 인증 정보 전달
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      LoggerService.info('✅ Apple 로그인 성공: ${response.user?.email}');
      return response;
    } catch (e) {
      LoggerService.error('❌ Apple 로그인 실패', e);
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      LoggerService.info('🚪 로그아웃 시작');

      // Google Sign Out
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      // Supabase Sign Out
      await _supabase.auth.signOut();

      LoggerService.info('✅ 로그아웃 완료');
    } catch (e) {
      LoggerService.error('❌ 로그아웃 실패', e);
      rethrow;
    }
  }

  /// 계정 삭제 (회원 탈퇴)
  Future<void> deleteAccount() async {
    try {
      LoggerService.info('🗑️ 계정 삭제 시작');

      final userId = currentUser?.id;
      if (userId == null) {
        throw Exception('로그인되지 않은 상태입니다');
      }

      // 1. Supabase에서 사용자 데이터 삭제 (RLS 정책에 따라 자동 삭제)
      // users, transactions, budgets 테이블의 데이터가 모두 삭제됨

      // 2. Auth 계정 삭제
      await _supabase.rpc('delete_user'); // Supabase Function 필요

      LoggerService.info('✅ 계정 삭제 완료');
    } catch (e) {
      LoggerService.error('❌ 계정 삭제 실패', e);
      rethrow;
    }
  }

  /// Google Client ID 가져오기 (플랫폼별)
  String? _getGoogleClientId() {
    // TODO: Google Cloud Console에서 발급받은 Client ID 입력
    // Android: xxx.apps.googleusercontent.com
    // iOS: xxx.apps.googleusercontent.com
    // Web: xxx.apps.googleusercontent.com
    return null; // Supabase가 자동으로 처리
  }

  /// Nonce 생성 (Apple 로그인용 보안 토큰)
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
