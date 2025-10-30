import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_subscription_model.dart';
import '../models/subscription_tier.dart';

/// 구독 정보 저장소
class SubscriptionRepository {
  final SupabaseClient _supabase;

  SubscriptionRepository(this._supabase);

  /// 사용자 구독 정보 조회
  Future<UserSubscriptionModel?> getUserSubscription(String userId) async {
    try {
      final response = await _supabase
          .from('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserSubscriptionModel.fromJson(response);
    } catch (e) {
      print('Error fetching user subscription: $e');
      return null;
    }
  }

  /// 현재 로그인한 사용자의 구독 정보 조회
  Future<UserSubscriptionModel?> getCurrentUserSubscription() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    return getUserSubscription(userId);
  }

  /// 구독 정보 생성 (회원가입 시 자동 호출되지만 수동 생성도 가능)
  Future<UserSubscriptionModel?> createSubscription(
    String userId, {
    SubscriptionTier tier = SubscriptionTier.free,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'tier': tier.name,
        'monthly_transactions_used': 0,
        'budgets_used': 0,
        'savings_goals_used': 0,
        'last_reset_date': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('user_subscriptions')
          .insert(data)
          .select()
          .single();

      return UserSubscriptionModel.fromJson(response);
    } catch (e) {
      print('Error creating subscription: $e');
      return null;
    }
  }

  /// 구독 정보 업데이트
  Future<UserSubscriptionModel?> updateSubscription(
    UserSubscriptionModel subscription,
  ) async {
    try {
      final response = await _supabase
          .from('user_subscriptions')
          .update(subscription.toJson())
          .eq('user_id', subscription.userId)
          .select()
          .single();

      return UserSubscriptionModel.fromJson(response);
    } catch (e) {
      print('Error updating subscription: $e');
      return null;
    }
  }

  /// 거래 추가 사용량 증가
  Future<UserSubscriptionModel?> incrementTransactionUsage(
    String userId,
  ) async {
    try {
      final subscription = await getUserSubscription(userId);
      if (subscription == null) return null;

      // 월별 리셋이 필요한지 확인
      final updatedSubscription = subscription.needsMonthlyReset
          ? subscription.resetMonthlyUsage()
          : subscription;

      // 사용량 증가
      final newSubscription = updatedSubscription.incrementTransactionUsage();

      return await updateSubscription(newSubscription);
    } catch (e) {
      print('Error incrementing transaction usage: $e');
      return null;
    }
  }

  /// 예산 사용량 증가
  Future<UserSubscriptionModel?> incrementBudgetUsage(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);
      if (subscription == null) return null;

      final newSubscription = subscription.incrementBudgetUsage();
      return await updateSubscription(newSubscription);
    } catch (e) {
      print('Error incrementing budget usage: $e');
      return null;
    }
  }

  /// 절약목표 사용량 증가
  Future<UserSubscriptionModel?> incrementSavingsGoalUsage(
    String userId,
  ) async {
    try {
      final subscription = await getUserSubscription(userId);
      if (subscription == null) return null;

      final newSubscription = subscription.incrementSavingsGoalUsage();
      return await updateSubscription(newSubscription);
    } catch (e) {
      print('Error incrementing savings goal usage: $e');
      return null;
    }
  }

  /// 요금제 업그레이드
  Future<UserSubscriptionModel?> upgradeTier(
    String userId,
    SubscriptionTier newTier, {
    DateTime? expiresAt,
  }) async {
    try {
      final subscription = await getUserSubscription(userId);
      if (subscription == null) return null;

      var newSubscription = subscription.upgradeTier(newTier);

      // 만료일 설정 (인앱 결제 시 1개월 후로 설정 가능)
      if (expiresAt != null) {
        newSubscription = newSubscription.copyWith(expiresAt: expiresAt);
      }

      return await updateSubscription(newSubscription);
    } catch (e) {
      print('Error upgrading tier: $e');
      return null;
    }
  }

  /// 월별 사용량 리셋 (서버 함수 호출)
  Future<void> resetMonthlyUsageForAllUsers() async {
    try {
      await _supabase.rpc('reset_monthly_subscription_usage');
    } catch (e) {
      print('Error resetting monthly usage: $e');
    }
  }

  /// 구독 만료 확인 (서버 함수 호출)
  Future<void> checkExpiredSubscriptions() async {
    try {
      await _supabase.rpc('check_expired_subscriptions');
    } catch (e) {
      print('Error checking expired subscriptions: $e');
    }
  }

  /// 결제 내역 생성 (인앱 결제 완료 시)
  Future<void> createPaymentTransaction({
    required String userId,
    required SubscriptionTier tier,
    required int amount,
    required String paymentMethod, // 'app_store', 'google_play', 'points'
    String? transactionId,
    String? receiptData,
  }) async {
    try {
      await _supabase.from('payment_transactions').insert({
        'user_id': userId,
        'subscription_tier': tier.name,
        'amount': amount,
        'currency': 'KRW',
        'payment_method': paymentMethod,
        'transaction_id': transactionId,
        'receipt_data': receiptData,
        'status': 'pending',
      });
    } catch (e) {
      print('Error creating payment transaction: $e');
    }
  }

  /// 결제 완료 처리
  Future<void> completePayment(String transactionId) async {
    try {
      await _supabase
          .from('payment_transactions')
          .update({
            'status': 'completed',
            'paid_at': DateTime.now().toIso8601String(),
          })
          .eq('transaction_id', transactionId);
    } catch (e) {
      print('Error completing payment: $e');
    }
  }

  /// 포인트 결제 내역 생성
  Future<void> createPointPaymentTransaction({
    required String userId,
    required SubscriptionTier tier,
    required int pointsUsed,
    required int pointsRemaining,
    required int finalAmount,
    double? discountRate,
  }) async {
    try {
      await _supabase.from('point_payment_transactions').insert({
        'user_id': userId,
        'subscription_tier': tier.name,
        'points_used': pointsUsed,
        'points_remaining': pointsRemaining,
        'final_amount': finalAmount,
        'discount_rate': discountRate,
        'status': 'completed',
      });
    } catch (e) {
      print('Error creating point payment transaction: $e');
    }
  }

  /// 사용자의 결제 내역 조회
  Future<List<Map<String, dynamic>>> getPaymentHistory(String userId) async {
    try {
      final response = await _supabase
          .from('payment_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching payment history: $e');
      return [];
    }
  }

  /// 사용자의 포인트 결제 내역 조회
  Future<List<Map<String, dynamic>>> getPointPaymentHistory(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('point_payment_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching point payment history: $e');
      return [];
    }
  }
}
