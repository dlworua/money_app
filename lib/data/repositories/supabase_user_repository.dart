import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/services/logger_service.dart';

/// Supabase 사용자 데이터 저장소 (하이브리드 방식)
///
/// 핵심 데이터만 Supabase에 저장:
/// - name, email, coins, level, total_savings 등
///
/// 복잡한 데이터는 SharedPreferences 유지:
/// - achievements, savingRecords, pointHistory 등
class SupabaseUserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Supabase에서 사용자 데이터 가져오기
  Future<Map<String, dynamic>?> getUserFromSupabase(String userId) async {
    try {
      LoggerService.info('Supabase에서 사용자 데이터 조회: $userId');

      final response = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        LoggerService.info('Supabase 사용자 데이터 로드 성공');
        return response;
      }

      LoggerService.info('Supabase에 사용자 데이터 없음');
      return null;
    } catch (e) {
      LoggerService.error('Supabase 사용자 데이터 조회 실패', e);
      return null;
    }
  }

  /// Supabase에 사용자 프로필 생성 (최초 로그인 시)
  /// RLS를 우회하는 Database Function 사용
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    try {
      LoggerService.info('Supabase에 새 사용자 프로필 생성: $email');

      // Database Function 호출 (RLS 우회)
      await _supabase.rpc('create_user_profile', params: {
        'p_user_id': userId,
        'p_name': name,
        'p_email': email,
        'p_photo_url': photoUrl,
      });

      LoggerService.info('✅ Supabase 사용자 프로필 생성 완료');
    } catch (e) {
      LoggerService.error('❌ Supabase 사용자 프로필 생성 실패', e);
      rethrow;
    }
  }

  /// Supabase에 기본 사용자 데이터 업데이트
  Future<void> updateUserBasicData({
    required String userId,
    String? name,
    int? coins,
    int? level,
    double? totalSavings,
    double? monthlyGoal,
    double? currentMonthSaved,
    int? consecutiveDays,
    String? preferredCoachingStyle,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (coins != null) updateData['coins'] = coins;
      if (level != null) updateData['level'] = level;
      if (totalSavings != null) updateData['total_savings'] = totalSavings;
      if (monthlyGoal != null) updateData['monthly_goal'] = monthlyGoal;
      if (currentMonthSaved != null) {
        updateData['current_month_saved'] = currentMonthSaved;
      }
      if (consecutiveDays != null) {
        updateData['consecutive_days'] = consecutiveDays;
      }
      if (preferredCoachingStyle != null) {
        updateData['preferred_coaching_style'] = preferredCoachingStyle;
      }

      if (updateData.isEmpty) return;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('users')
          .update(updateData)
          .eq('user_id', userId);

      LoggerService.info('✅ Supabase 사용자 데이터 업데이트 완료');
    } catch (e) {
      LoggerService.error('❌ Supabase 사용자 데이터 업데이트 실패', e);
      rethrow;
    }
  }

  /// Supabase에서 포인트 추가 (보안 함수 사용)
  Future<void> addCoins(int amount) async {
    try {
      await _supabase.rpc('add_coins', params: {'amount': amount});
      LoggerService.info('✅ 포인트 추가 완료: +$amount');
    } catch (e) {
      LoggerService.error('❌ 포인트 추가 실패', e);
      rethrow;
    }
  }

  /// Supabase에서 포인트 차감 (보안 함수 사용)
  Future<void> spendCoins(int amount) async {
    try {
      await _supabase.rpc('spend_coins', params: {'amount': amount});
      LoggerService.info('✅ 포인트 차감 완료: -$amount');
    } catch (e) {
      LoggerService.error('❌ 포인트 차감 실패', e);
      rethrow;
    }
  }

  /// UserModel을 Supabase 데이터로 변환
  Map<String, dynamic> userModelToSupabase(UserModel user) {
    return {
      'user_id': user.id,
      'name': user.name,
      'email': user.email,
      'coins': user.coins,
      'level': user.level,
      'total_savings': user.totalSaved,
      'monthly_goal': user.monthlyGoal,
      'current_month_saved': user.currentMonthSaved,
      'consecutive_days': user.consecutiveDays,
      'preferred_coaching_style': user.preferredCoachingStyle.name,
    };
  }

  /// Supabase 데이터를 UserModel로 병합
  UserModel mergeSupabaseData(
    UserModel localUser,
    Map<String, dynamic> supabaseData,
  ) {
    return localUser.copyWith(
      id: supabaseData['user_id'] as String,
      name: supabaseData['name'] as String? ?? localUser.name,
      email: supabaseData['email'] as String? ?? localUser.email,
      coins: supabaseData['coins'] as int? ?? localUser.coins,
      level: supabaseData['level'] as int? ?? localUser.level,
      totalSaved: (supabaseData['total_savings'] as num?)?.toDouble() ??
          localUser.totalSaved,
      monthlyGoal: (supabaseData['monthly_goal'] as num?)?.toDouble() ??
          localUser.monthlyGoal,
      currentMonthSaved:
          (supabaseData['current_month_saved'] as num?)?.toDouble() ??
              localUser.currentMonthSaved,
      consecutiveDays: supabaseData['consecutive_days'] as int? ??
          localUser.consecutiveDays,
    );
  }
}
