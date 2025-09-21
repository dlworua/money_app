import 'saving_record.dart';
import 'ai_coaching_insight.dart';
import 'point_history.dart';
import '../../core/enums/coaching_style.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final int coins; // 기본 포인트 (필드명은 호환성 유지)
  final bool isPremium;
  final DateTime? lastAdWatchedAt;

  // 💎 프리미엄 구독 관련 필드들
  final DateTime? premiumStartDate; // 프리미엄 시작일
  final DateTime? premiumEndDate; // 프리미엄 종료일
  final String? subscriptionPlan; // 구독 플랜 (monthly/yearly)
  final int savingRecordsThisMonth; // 이번 달 기록 횟수 (무료 제한용)

  // 💡 절약 챌린지 관련 필드들
  final int level; // 절약 마스터 레벨
  final int experience; // 절약 경험치
  final double totalSaved; // 총 절약 금액 (원)
  final double monthlyGoal; // 월 절약 목표 (원)
  final double currentMonthSaved; // 이번 달 절약 금액
  final double dailyBudget; // 일일 지출 예산 (원)
  final int consecutiveDays; // 연속 절약 기록일
  final DateTime? lastCheckInDate; // 마지막 절약 기록 날짜
  final List<String> achievements; // 달성한 절약 업적
  final List<String> categories; // 주요 절약 카테고리
  final List<SavingRecord> savingRecords; // 절약 기록들
  final List<PointHistory> pointHistory; // 포인트 히스토리

  // 🎯 챌린지 관련 (기존 호환성)
  final int dailySpinCount; // 일일 보상 횟수
  final DateTime? lastSpinDate; // 마지막 보상 날짜
  final int totalGamesPlayed; // 총 활동 횟수
  
  // 🎫 티켓 시스템
  final int gameTickets; // 현재 보유 티켓
  final int maxTickets; // 최대 티켓 수 (기본 10개)
  final DateTime? lastTicketRefillTime; // 마지막 티켓 충전 시간


  // 🏆 고급 기능들
  final int streakMultiplier; // 연속 절약 배수
  final Map<String, dynamic> achievements2; // 확장된 업적 시스템
  final List<String> aiTips; // AI 개인 맞춤 팁들
  final DateTime? lastAiTipDate; // 마지막 AI 팁 받은 날짜

  // 🤖 AI 코칭 시스템
  final CoachingStyle preferredCoachingStyle; // 선호하는 코칭 스타일
  final List<AiCoachingInsight> coachingInsights; // AI 코칭 인사이트 히스토리
  final DateTime? lastCoachingDate; // 마지막 AI 코칭 받은 날짜
  final bool enableDailyCoaching; // 일일 AI 코칭 활성화
  final bool enableWeeklyReview; // 주간 리뷰 활성화
  final Map<String, dynamic> coachingPreferences; // 코칭 개인화 설정

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.coins = 0,
    this.isPremium = false,
    this.lastAdWatchedAt,
    // 💎 프리미엄 구독 필드들
    this.premiumStartDate,
    this.premiumEndDate,
    this.subscriptionPlan,
    this.savingRecordsThisMonth = 0,
    // 💡 절약 관련 필드들
    this.level = 1,
    this.experience = 0,
    this.totalSaved = 0.0,
    this.monthlyGoal = 100000.0, // 기본 목표: 10만원
    this.currentMonthSaved = 0.0,
    this.dailyBudget = 50000.0, // 기본 일일 예산: 5만원
    this.consecutiveDays = 0,
    this.lastCheckInDate,
    this.achievements = const [],
    this.categories = const ['식비', '교통비', '쇼핑', '기타'],
    this.savingRecords = const [],
    this.pointHistory = const [],
    // 기존 호환성 필드들
    this.dailySpinCount = 0,
    this.lastSpinDate,
    this.totalGamesPlayed = 0,
    // 🎫 티켓 시스템 필드들
    this.gameTickets = 10, // 시작 시 10개 티켓
    this.maxTickets = 10, // 기본 최대 10개
    this.lastTicketRefillTime,
    // 🏆 고급 기능들
    this.streakMultiplier = 1,
    this.achievements2 = const {},
    this.aiTips = const [],
    this.lastAiTipDate,
    // 🤖 AI 코칭 시스템 필드들
    this.preferredCoachingStyle = CoachingStyle.kind,
    this.coachingInsights = const [],
    this.lastCoachingDate,
    this.enableDailyCoaching = true,
    this.enableWeeklyReview = true,
    this.coachingPreferences = const {},
  });

  // 복사 메서드 - 프리미엄 및 절약 챌린지 필드들 포함
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? coins,
    bool? isPremium,
    DateTime? lastAdWatchedAt,
    DateTime? premiumStartDate,
    DateTime? premiumEndDate,
    String? subscriptionPlan,
    int? savingRecordsThisMonth,
    int? level,
    int? experience,
    double? totalSaved,
    double? monthlyGoal,
    double? currentMonthSaved,
    double? dailyBudget,
    int? consecutiveDays,
    DateTime? lastCheckInDate,
    List<String>? achievements,
    List<String>? categories,
    List<SavingRecord>? savingRecords,
    List<PointHistory>? pointHistory,
    int? dailySpinCount,
    DateTime? lastSpinDate,
    int? totalGamesPlayed,
    // 🎫 티켓 시스템 필드들
    int? gameTickets,
    int? maxTickets,
    DateTime? lastTicketRefillTime,
    int? streakMultiplier,
    Map<String, dynamic>? achievements2,
    List<String>? aiTips,
    DateTime? lastAiTipDate,
    // 🤖 AI 코칭 시스템 필드들
    CoachingStyle? preferredCoachingStyle,
    List<AiCoachingInsight>? coachingInsights,
    DateTime? lastCoachingDate,
    bool? enableDailyCoaching,
    bool? enableWeeklyReview,
    Map<String, dynamic>? coachingPreferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      coins: coins ?? this.coins,
      isPremium: isPremium ?? this.isPremium,
      lastAdWatchedAt: lastAdWatchedAt ?? this.lastAdWatchedAt,
      premiumStartDate: premiumStartDate ?? this.premiumStartDate,
      premiumEndDate: premiumEndDate ?? this.premiumEndDate,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      savingRecordsThisMonth:
          savingRecordsThisMonth ?? this.savingRecordsThisMonth,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      totalSaved: totalSaved ?? this.totalSaved,
      monthlyGoal: monthlyGoal ?? this.monthlyGoal,
      currentMonthSaved: currentMonthSaved ?? this.currentMonthSaved,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      achievements: achievements ?? this.achievements,
      categories: categories ?? this.categories,
      savingRecords: savingRecords ?? this.savingRecords,
      pointHistory: pointHistory ?? this.pointHistory,
      dailySpinCount: dailySpinCount ?? this.dailySpinCount,
      lastSpinDate: lastSpinDate ?? this.lastSpinDate,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      // 🎫 티켓 시스템 필드들
      gameTickets: gameTickets ?? this.gameTickets,
      maxTickets: maxTickets ?? this.maxTickets,
      lastTicketRefillTime: lastTicketRefillTime ?? this.lastTicketRefillTime,
      streakMultiplier: streakMultiplier ?? this.streakMultiplier,
      achievements2: achievements2 ?? this.achievements2,
      aiTips: aiTips ?? this.aiTips,
      lastAiTipDate: lastAiTipDate ?? this.lastAiTipDate,
      // 🤖 AI 코칭 시스템 필드들
      preferredCoachingStyle:
          preferredCoachingStyle ?? this.preferredCoachingStyle,
      coachingInsights: coachingInsights ?? this.coachingInsights,
      lastCoachingDate: lastCoachingDate ?? this.lastCoachingDate,
      enableDailyCoaching: enableDailyCoaching ?? this.enableDailyCoaching,
      enableWeeklyReview: enableWeeklyReview ?? this.enableWeeklyReview,
      coachingPreferences: coachingPreferences ?? this.coachingPreferences,
    );
  }

  // JSON 직렬화 - 프리미엄 및 절약 데이터 포함
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'coins': coins,
      'isPremium': isPremium,
      'lastAdWatchedAt': lastAdWatchedAt?.toIso8601String(),
      'premiumStartDate': premiumStartDate?.toIso8601String(),
      'premiumEndDate': premiumEndDate?.toIso8601String(),
      'subscriptionPlan': subscriptionPlan,
      'savingRecordsThisMonth': savingRecordsThisMonth,
      'level': level,
      'experience': experience,
      'totalSaved': totalSaved,
      'monthlyGoal': monthlyGoal,
      'currentMonthSaved': currentMonthSaved,
      'dailyBudget': dailyBudget,
      'consecutiveDays': consecutiveDays,
      'lastCheckInDate': lastCheckInDate?.toIso8601String(),
      'achievements': achievements,
      'categories': categories,
      'savingRecords': savingRecords.map((record) => record.toJson()).toList(),
      'pointHistory': pointHistory.map((history) => history.toJson()).toList(),
      'dailySpinCount': dailySpinCount,
      'lastSpinDate': lastSpinDate?.toIso8601String(),
      'totalGamesPlayed': totalGamesPlayed,
      // 🎫 티켓 시스템 필드들
      'gameTickets': gameTickets,
      'maxTickets': maxTickets,
      'lastTicketRefillTime': lastTicketRefillTime?.toIso8601String(),
      'streakMultiplier': streakMultiplier,
      'achievements2': achievements2,
      'aiTips': aiTips,
      'lastAiTipDate': lastAiTipDate?.toIso8601String(),
      // 🤖 AI 코칭 시스템 필드들
      'preferredCoachingStyle': preferredCoachingStyle.name,
      'coachingInsights': coachingInsights
          .map((insight) => insight.toJson())
          .toList(),
      'lastCoachingDate': lastCoachingDate?.toIso8601String(),
      'enableDailyCoaching': enableDailyCoaching,
      'enableWeeklyReview': enableWeeklyReview,
      'coachingPreferences': coachingPreferences,
    };
  }

  // JSON 역직렬화 - 프리미엄 및 절약 데이터 포함
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      coins: json['coins'] as int? ?? 0,
      isPremium: json['isPremium'] as bool? ?? false,
      lastAdWatchedAt: json['lastAdWatchedAt'] != null
          ? DateTime.parse(json['lastAdWatchedAt'] as String)
          : null,
      premiumStartDate: json['premiumStartDate'] != null
          ? DateTime.parse(json['premiumStartDate'] as String)
          : null,
      premiumEndDate: json['premiumEndDate'] != null
          ? DateTime.parse(json['premiumEndDate'] as String)
          : null,
      subscriptionPlan: json['subscriptionPlan'] as String?,
      savingRecordsThisMonth: json['savingRecordsThisMonth'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      experience: json['experience'] as int? ?? 0,
      totalSaved: (json['totalSaved'] as num?)?.toDouble() ?? 0.0,
      monthlyGoal: (json['monthlyGoal'] as num?)?.toDouble() ?? 100000.0,
      currentMonthSaved: (json['currentMonthSaved'] as num?)?.toDouble() ?? 0.0,
      dailyBudget: (json['dailyBudget'] as num?)?.toDouble() ?? 50000.0,
      consecutiveDays: json['consecutiveDays'] as int? ?? 0,
      lastCheckInDate: json['lastCheckInDate'] != null
          ? DateTime.parse(json['lastCheckInDate'] as String)
          : null,
      achievements: List<String>.from(json['achievements'] ?? []),
      categories: List<String>.from(
        json['categories'] ?? ['식비', '교통비', '쇼핑', '기타'],
      ),
      savingRecords:
          (json['savingRecords'] as List<dynamic>?)
              ?.map(
                (recordJson) =>
                    SavingRecord.fromJson(recordJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
      pointHistory:
          (json['pointHistory'] as List<dynamic>?)
              ?.map(
                (historyJson) =>
                    PointHistory.fromJson(historyJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
      dailySpinCount: json['dailySpinCount'] as int? ?? 0,
      lastSpinDate: json['lastSpinDate'] != null
          ? DateTime.parse(json['lastSpinDate'] as String)
          : null,
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      // 🎫 티켓 시스템 필드들
      gameTickets: json['gameTickets'] as int? ?? 10,
      maxTickets: json['maxTickets'] as int? ?? 10,
      lastTicketRefillTime: json['lastTicketRefillTime'] != null
          ? DateTime.parse(json['lastTicketRefillTime'] as String)
          : null,
      streakMultiplier: json['streakMultiplier'] as int? ?? 1,
      achievements2: Map<String, dynamic>.from(json['achievements2'] ?? {}),
      aiTips: List<String>.from(json['aiTips'] ?? []),
      lastAiTipDate: json['lastAiTipDate'] != null
          ? DateTime.parse(json['lastAiTipDate'] as String)
          : null,
      // 🤖 AI 코칭 시스템 필드들
      preferredCoachingStyle: CoachingStyle.values.firstWhere(
        (style) => style.name == json['preferredCoachingStyle'],
        orElse: () => CoachingStyle.kind,
      ),
      coachingInsights:
          (json['coachingInsights'] as List<dynamic>?)
              ?.map(
                (insightJson) => AiCoachingInsight.fromJson(
                  insightJson as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      lastCoachingDate: json['lastCoachingDate'] != null
          ? DateTime.parse(json['lastCoachingDate'] as String)
          : null,
      enableDailyCoaching: json['enableDailyCoaching'] as bool? ?? true,
      enableWeeklyReview: json['enableWeeklyReview'] as bool? ?? true,
      coachingPreferences: Map<String, dynamic>.from(
        json['coachingPreferences'] ?? {},
      ),
    );
  }
}
