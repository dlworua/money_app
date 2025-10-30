import 'subscription_tier.dart';

/// 사용자 요금제 구독 정보
class UserSubscriptionModel {
  final String userId;
  final SubscriptionTier tier;
  final DateTime? subscribedAt; // 구독 시작일
  final DateTime? expiresAt; // 구독 만료일 (null = 평생)

  // 사용량 추적
  final int monthlyTransactionsUsed; // 이번 달 거래 추가 사용 횟수
  final int budgetsUsed; // 예산 설정 사용 횟수 (누적)
  final int savingsGoalsUsed; // 절약목표 설정 사용 횟수 (누적)
  final DateTime lastResetDate; // 마지막 월별 리셋 날짜

  UserSubscriptionModel({
    required this.userId,
    required this.tier,
    this.subscribedAt,
    this.expiresAt,
    this.monthlyTransactionsUsed = 0,
    this.budgetsUsed = 0,
    this.savingsGoalsUsed = 0,
    DateTime? lastResetDate,
  }) : lastResetDate = lastResetDate ?? DateTime.now();

  /// 요금제가 활성 상태인지 확인
  bool get isActive {
    if (tier == SubscriptionTier.free) return true;
    if (expiresAt == null) return true; // 평생 구독
    return DateTime.now().isBefore(expiresAt!);
  }

  /// 거래 추가 가능 여부
  bool get canAddTransaction {
    final limit = tier.monthlyTransactionLimit;
    if (limit == null) return true; // 무제한
    return monthlyTransactionsUsed < limit;
  }

  /// 남은 거래 추가 가능 횟수
  int? get remainingTransactions {
    final limit = tier.monthlyTransactionLimit;
    if (limit == null) return null; // 무제한
    final remaining = limit - monthlyTransactionsUsed;
    return remaining > 0 ? remaining : 0;
  }

  /// 예산 설정 가능 여부
  bool get canAddBudget {
    final limit = tier.budgetLimit;
    if (limit == null) return true; // 무제한
    return budgetsUsed < limit;
  }

  /// 남은 예산 설정 가능 횟수
  int? get remainingBudgets {
    final limit = tier.budgetLimit;
    if (limit == null) return null; // 무제한
    final remaining = limit - budgetsUsed;
    return remaining > 0 ? remaining : 0;
  }

  /// 절약목표 설정 가능 여부
  bool get canAddSavingsGoal {
    final limit = tier.savingsGoalLimit;
    if (limit == null) return true; // 무제한
    return savingsGoalsUsed < limit;
  }

  /// 남은 절약목표 설정 가능 횟수
  int? get remainingSavingsGoals {
    final limit = tier.savingsGoalLimit;
    if (limit == null) return null; // 무제한
    final remaining = limit - savingsGoalsUsed;
    return remaining > 0 ? remaining : 0;
  }

  /// 월별 리셋이 필요한지 확인
  bool get needsMonthlyReset {
    final now = DateTime.now();
    return now.year != lastResetDate.year || now.month != lastResetDate.month;
  }

  /// 월별 사용량 리셋 (거래 추가만 리셋, 예산/목표는 누적)
  UserSubscriptionModel resetMonthlyUsage() {
    return copyWith(
      monthlyTransactionsUsed: 0,
      lastResetDate: DateTime.now(),
    );
  }

  /// 거래 추가 사용량 증가
  UserSubscriptionModel incrementTransactionUsage() {
    return copyWith(
      monthlyTransactionsUsed: monthlyTransactionsUsed + 1,
    );
  }

  /// 예산 사용량 증가
  UserSubscriptionModel incrementBudgetUsage() {
    return copyWith(
      budgetsUsed: budgetsUsed + 1,
    );
  }

  /// 절약목표 사용량 증가
  UserSubscriptionModel incrementSavingsGoalUsage() {
    return copyWith(
      savingsGoalsUsed: savingsGoalsUsed + 1,
    );
  }

  /// 요금제 업그레이드 (예산/목표 사용 횟수 유지)
  UserSubscriptionModel upgradeTier(SubscriptionTier newTier) {
    return copyWith(
      tier: newTier,
      subscribedAt: DateTime.now(),
      expiresAt: null, // 평생 구독으로 설정 (인앱 결제 시 갱신 가능)
      // budgetsUsed와 savingsGoalsUsed는 그대로 유지됨
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'tier': tier.name,
      'subscribed_at': subscribedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'monthly_transactions_used': monthlyTransactionsUsed,
      'budgets_used': budgetsUsed,
      'savings_goals_used': savingsGoalsUsed,
      'last_reset_date': lastResetDate.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      userId: json['user_id'] as String,
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      subscribedAt: json['subscribed_at'] != null
          ? DateTime.parse(json['subscribed_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      monthlyTransactionsUsed: json['monthly_transactions_used'] as int? ?? 0,
      budgetsUsed: json['budgets_used'] as int? ?? 0,
      savingsGoalsUsed: json['savings_goals_used'] as int? ?? 0,
      lastResetDate: json['last_reset_date'] != null
          ? DateTime.parse(json['last_reset_date'] as String)
          : DateTime.now(),
    );
  }

  /// 복사본 생성
  UserSubscriptionModel copyWith({
    String? userId,
    SubscriptionTier? tier,
    DateTime? subscribedAt,
    DateTime? expiresAt,
    int? monthlyTransactionsUsed,
    int? budgetsUsed,
    int? savingsGoalsUsed,
    DateTime? lastResetDate,
  }) {
    return UserSubscriptionModel(
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      monthlyTransactionsUsed: monthlyTransactionsUsed ?? this.monthlyTransactionsUsed,
      budgetsUsed: budgetsUsed ?? this.budgetsUsed,
      savingsGoalsUsed: savingsGoalsUsed ?? this.savingsGoalsUsed,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }
}
