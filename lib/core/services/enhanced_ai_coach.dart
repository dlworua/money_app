import 'dart:math' as math;
import '../../data/models/user_model.dart';
import '../../data/models/transaction.dart';
import '../../data/models/budget.dart';
import 'financial_analysis_service.dart';
import '../services/logger_service.dart';

/// 강화된 AI 코칭 서비스 - 가계부 데이터 완전 활용
class EnhancedAiCoach {
  final FinancialAnalysisService _analysisService = FinancialAnalysisService();

  /// 🧠 종합 AI 분석 - 모든 데이터 완전 활용
  Future<ComprehensiveInsight> generateComprehensiveInsight(
    UserModel user,
    List<Transaction> transactions,
    List<Budget> budgets,
  ) async {
    LoggerService.info('🚀 Enhanced AI 분석 시작 - 사용자: ${user.id}');

    if (transactions.isEmpty) {
      return ComprehensiveInsight.empty(user);
    }

    try {
      // 1. 기본 재무 분석
      final spendingAnalysis = _analysisService.analyzeSpendingPattern(
        transactions,
      );
      final budgetAnalysis = _analysisService.analyzeBudgetPerformance(
        transactions,
        budgets,
      );
      final opportunities = _analysisService.findSavingOpportunities(
        transactions,
        budgets,
      );
      final goalSuggestions = _analysisService.generateSavingGoals(
        transactions,
        budgets,
        0.1,
      );

      // 2. 고급 패턴 분석
      final behaviorPatterns = _analyzeBehaviorPatterns(transactions);
      final temporalPatterns = _analyzeTemporalPatterns(transactions);
      final categoryInsights = _analyzeCategoryInsights(transactions);

      // 3. 심리적 프로파일링
      final psychProfile = _generatePsychologicalProfile(transactions, user);

      // 4. 예측 모델링
      final predictions = _generatePredictions(
        user,
        transactions,
        budgets,
        spendingAnalysis,
      );

      // 5. 개인화 전략
      final strategies = _generatePersonalizedStrategies(
        user,
        transactions,
        budgets,
        spendingAnalysis,
        behaviorPatterns,
        psychProfile,
      );

      // 6. 맞춤 메시지 생성
      final message = _generateDetailedMessage(
        user,
        spendingAnalysis,
        budgetAnalysis,
        behaviorPatterns,
        psychProfile,
        predictions,
        strategies,
      );

      return ComprehensiveInsight(
        userId: user.id,
        generatedAt: DateTime.now(),
        confidenceScore: _calculateConfidenceScore(transactions, budgets),
        spendingAnalysis: spendingAnalysis,
        budgetAnalysis: budgetAnalysis,
        opportunities: opportunities,
        goalSuggestions: goalSuggestions,
        behaviorPatterns: behaviorPatterns,
        temporalPatterns: temporalPatterns,
        categoryInsights: categoryInsights,
        psychProfile: psychProfile,
        predictions: predictions,
        strategies: strategies,
        personalizedMessage: message,
        actionableAdvice: _generateActionableAdvice(strategies, opportunities),
      );
    } catch (e) {
      LoggerService.error('❌ Enhanced AI 분석 실패', e);
      return ComprehensiveInsight.error(user, e.toString());
    }
  }

  /// 📊 행동 패턴 분석
  Map<String, dynamic> _analyzeBehaviorPatterns(
    List<Transaction> transactions,
  ) {
    final patterns = <String, dynamic>{};

    // 지출 빈도 패턴
    final expenseTransactions = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();
    if (expenseTransactions.isNotEmpty) {
      final dailyFrequency = _calculateDailyFrequency(expenseTransactions);
      patterns['spendingFrequency'] = dailyFrequency;

      // 충동구매 패턴 (소액 다빈도)
      final impulseScore = _calculateImpulseScore(expenseTransactions);
      patterns['impulseScore'] = impulseScore;

      // 지출 일관성 (변동성)
      final consistency = _calculateSpendingConsistency(expenseTransactions);
      patterns['consistency'] = consistency;

      // 계획성 점수
      final planningScore = _calculatePlanningScore(expenseTransactions);
      patterns['planningScore'] = planningScore;
    }

    return patterns;
  }

  /// ⏰ 시간적 패턴 분석
  Map<String, dynamic> _analyzeTemporalPatterns(
    List<Transaction> transactions,
  ) {
    final patterns = <String, dynamic>{};

    // 요일별 지출 패턴
    final dayOfWeekSpending = <int, double>{};
    final dayOfWeekCounts = <int, int>{};

    // 시간대별 지출 패턴
    final hourlySpending = <int, double>{};

    // 월중 지출 패턴 (급여일 기준)
    final monthlyPhases = <String, double>{'early': 0, 'mid': 0, 'late': 0};

    for (final transaction in transactions.where(
      (t) => t.type == TransactionType.expense,
    )) {
      // 요일별
      final dayOfWeek = transaction.date.weekday;
      dayOfWeekSpending[dayOfWeek] =
          (dayOfWeekSpending[dayOfWeek] ?? 0) + transaction.amount;
      dayOfWeekCounts[dayOfWeek] = (dayOfWeekCounts[dayOfWeek] ?? 0) + 1;

      // 시간대별
      final hour = transaction.date.hour;
      hourlySpending[hour] = (hourlySpending[hour] ?? 0) + transaction.amount;

      // 월중 단계별
      final day = transaction.date.day;
      if (day <= 10) {
        monthlyPhases['early'] = monthlyPhases['early']! + transaction.amount;
      } else if (day <= 20) {
        monthlyPhases['mid'] = monthlyPhases['mid']! + transaction.amount;
      } else {
        monthlyPhases['late'] = monthlyPhases['late']! + transaction.amount;
      }
    }

    patterns['dayOfWeek'] = {
      'spending': dayOfWeekSpending,
      'counts': dayOfWeekCounts,
      'peakDay': dayOfWeekSpending.entries.isNotEmpty
          ? dayOfWeekSpending.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key
          : null,
    };

    patterns['hourly'] = hourlySpending;
    patterns['monthlyPhases'] = monthlyPhases;

    return patterns;
  }

  /// 📈 카테고리 인사이트 분석
  Map<TransactionCategory, Map<String, dynamic>> _analyzeCategoryInsights(
    List<Transaction> transactions,
  ) {
    final insights = <TransactionCategory, Map<String, dynamic>>{};

    for (final category in TransactionCategory.values) {
      final categoryTransactions = transactions
          .where((t) => t.category == category)
          .toList();

      if (categoryTransactions.isNotEmpty) {
        final totalAmount = categoryTransactions.fold<double>(
          0,
          (sum, t) => sum + t.amount,
        );
        final avgAmount = totalAmount / categoryTransactions.length;
        final maxAmount = categoryTransactions
            .map((t) => t.amount)
            .reduce(math.max);
        final minAmount = categoryTransactions
            .map((t) => t.amount)
            .reduce(math.min);

        // 트렌드 분석 (최근 30일 vs 이전 30일)
        final now = DateTime.now();
        final recent = categoryTransactions
            .where(
              (t) => t.date.isAfter(now.subtract(const Duration(days: 30))),
            )
            .fold<double>(0, (sum, t) => sum + t.amount);

        final previous = categoryTransactions
            .where(
              (t) =>
                  t.date.isAfter(now.subtract(const Duration(days: 60))) &&
                  t.date.isBefore(now.subtract(const Duration(days: 30))),
            )
            .fold<double>(0, (sum, t) => sum + t.amount);

        final trend = previous > 0 ? (recent - previous) / previous : 0.0;

        insights[category] = {
          'total': totalAmount,
          'average': avgAmount,
          'max': maxAmount,
          'min': minAmount,
          'count': categoryTransactions.length,
          'trend': trend,
          'recentTotal': recent,
          'previousTotal': previous,
        };
      }
    }

    return insights;
  }

  /// 🧠 심리적 프로파일 생성
  Map<String, dynamic> _generatePsychologicalProfile(
    List<Transaction> transactions,
    UserModel user,
  ) {
    final profile = <String, dynamic>{};

    // 지출 성향 분석
    final expenseTransactions = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    if (expenseTransactions.isNotEmpty) {
      // 리스크 성향 (큰 금액 거래 비율)
      final largeTransactions = expenseTransactions
          .where((t) => t.amount > 50000)
          .length;
      final riskTolerance = largeTransactions / expenseTransactions.length;

      // 자제력 수준 (소액 빈번한 거래)
      final smallFrequent = expenseTransactions
          .where((t) => t.amount < 5000)
          .length;
      final selfControlLevel =
          1.0 - (smallFrequent / expenseTransactions.length).clamp(0.0, 1.0);

      // 계획성 수준 (예산 준수도)
      final planfulness = user.monthlyGoal > 0
          ? (1.0 - (user.currentMonthSaved / user.monthlyGoal)).clamp(0.0, 1.0)
          : 0.5;

      profile['riskTolerance'] = riskTolerance;
      profile['selfControlLevel'] = selfControlLevel;
      profile['planfulness'] = planfulness;
      profile['spendingPersonality'] = _determineSpendingPersonality(
        riskTolerance,
        selfControlLevel,
        planfulness,
      );
    }

    return profile;
  }

  /// 🔮 예측 모델 생성
  Map<String, dynamic> _generatePredictions(
    UserModel user,
    List<Transaction> transactions,
    List<Budget> budgets,
    Map<String, dynamic> spendingAnalysis,
  ) {
    final predictions = <String, dynamic>{};

    if (spendingAnalysis['isEmpty'] == true) {
      return {'available': false, 'reason': '데이터 부족'};
    }

    // 월말 지출 예측
    final dailyAvg = spendingAnalysis['dailyAverage'] as double;
    final remainingDays = DateTime(
      DateTime.now().year,
      DateTime.now().month + 1,
      1,
    ).difference(DateTime.now()).inDays;

    predictions['monthEndSpending'] =
        spendingAnalysis['totalSpending'] + (dailyAvg * remainingDays);

    // 목표 달성 확률 (다중 요인 고려)
    final goalProbability = _calculateAdvancedGoalProbability(
      user,
      spendingAnalysis,
      transactions,
    );
    predictions['goalAchievementProbability'] = goalProbability;

    // 위험 요소
    final riskFactors = <String>[];
    if (spendingAnalysis['spendingTrend'] > 0.2) riskFactors.add('지출 급증 경향');
    if (goalProbability < 0.3) riskFactors.add('목표 달성 어려움');
    if (user.consecutiveDays < 3) riskFactors.add('절약 습관 부족');

    predictions['riskFactors'] = riskFactors;
    predictions['available'] = true;

    return predictions;
  }

  /// 🎯 개인화 전략 생성
  List<PersonalizedStrategy> _generatePersonalizedStrategies(
    UserModel user,
    List<Transaction> transactions,
    List<Budget> budgets,
    Map<String, dynamic> spendingAnalysis,
    Map<String, dynamic> behaviorPatterns,
    Map<String, dynamic> psychProfile,
  ) {
    final strategies = <PersonalizedStrategy>[];

    // 개인 성향 기반 전략
    final personality =
        psychProfile['spendingPersonality'] as String? ?? 'balanced';

    switch (personality) {
      case 'impulsive':
        strategies.add(
          PersonalizedStrategy(
            title: '충동구매 제어 시스템',
            description: '24시간 대기 규칙과 구매 체크리스트를 활용해 보세요',
            priority: 'HIGH',
            expectedSaving: 30000,
            difficulty: '중간',
            timeframe: '2주',
          ),
        );
        break;
      case 'cautious':
        strategies.add(
          PersonalizedStrategy(
            title: '적극적 절약 도전',
            description: '안전한 범위에서 더 큰 절약 목표에 도전해보세요',
            priority: 'MEDIUM',
            expectedSaving: 50000,
            difficulty: '쉬움',
            timeframe: '1달',
          ),
        );
        break;
      default:
        strategies.add(
          PersonalizedStrategy(
            title: '균형잡힌 절약 계획',
            description: '카테고리별 목표를 세워 체계적으로 절약해보세요',
            priority: 'MEDIUM',
            expectedSaving: 40000,
            difficulty: '보통',
            timeframe: '3주',
          ),
        );
    }

    // 지출 패턴 기반 전략
    if (spendingAnalysis['topCategory'] != null) {
      final topCategory =
          spendingAnalysis['topCategory'] as TransactionCategory;
      strategies.add(
        PersonalizedStrategy(
          title: '${topCategory.displayName} 집중 절약',
          description: '가장 많이 지출하는 ${topCategory.displayName} 영역을 최우선으로 관리해보세요',
          priority: 'HIGH',
          expectedSaving:
              ((spendingAnalysis['topCategoryAmount'] as double) * 0.2).round(),
          difficulty: '보통',
          timeframe: '2주',
        ),
      );
    }

    return strategies;
  }

  /// 💬 상세 메시지 생성
  String _generateDetailedMessage(
    UserModel user,
    Map<String, dynamic> spendingAnalysis,
    Map<String, dynamic> budgetAnalysis,
    Map<String, dynamic> behaviorPatterns,
    Map<String, dynamic> psychProfile,
    Map<String, dynamic> predictions,
    List<PersonalizedStrategy> strategies,
  ) {
    final messages = <String>[];

    // 개인화된 인사
    messages.add(_generatePersonalGreeting(user));

    // 현재 상황 요약
    if (spendingAnalysis['isEmpty'] != true) {
      final totalSpending = spendingAnalysis['totalSpending'] as double;
      final dailyAvg = spendingAnalysis['dailyAverage'] as double;

      messages.add('📊 **이번 달 분석 결과**');
      messages.add('총 지출: ${_formatCurrency(totalSpending)}');
      messages.add('일평균 지출: ${_formatCurrency(dailyAvg)}');

      if (spendingAnalysis['topCategory'] != null) {
        final topCategory =
            spendingAnalysis['topCategory'] as TransactionCategory;
        final topAmount = spendingAnalysis['topCategoryAmount'] as double;
        messages.add(
          '최대 지출 카테고리: ${topCategory.displayName} (${_formatCurrency(topAmount)})',
        );
      }
    }

    // 긍정적 피드백
    messages.add('\\n✨ **잘하고 있는 점**');
    if (user.consecutiveDays > 0) {
      messages.add('${user.consecutiveDays}일 연속 절약 기록을 유지하고 있어요! 🔥');
    }
    if (user.level > 1) {
      messages.add('레벨 ${user.level}까지 성장한 절약 실력이 대단해요! 💪');
    }

    // 개인화된 조언
    messages.add('\\n🎯 **맞춤형 조언**');
    final personality =
        psychProfile['spendingPersonality'] as String? ?? 'balanced';
    switch (personality) {
      case 'impulsive':
        messages.add('충동적인 소비 성향이 있으신 것 같아요. 구매 전 잠깐 멈춰서 생각해보는 습관을 길러보세요!');
        break;
      case 'cautious':
        messages.add('신중한 소비자이시네요! 이런 장점을 살려 더 적극적인 절약에 도전해보세요!');
        break;
      default:
        messages.add('균형잡힌 소비 패턴을 보여주고 계세요. 카테고리별 목표 설정으로 한 단계 업그레이드해보세요!');
    }

    // 예측 및 목표
    if (predictions['available'] == true) {
      final goalProb =
          ((predictions['goalAchievementProbability'] as double) * 100).round();
      messages.add('\\n🔮 **목표 달성 예측**');
      messages.add('현재 패턴으로는 $goalProb% 확률로 목표를 달성할 수 있어요!');

      if (goalProb < 70) {
        messages.add('목표 달성을 위해 일일 절약 금액을 조금 더 늘려보시는 것을 추천드려요.');
      }
    }

    // 실행 계획
    if (strategies.isNotEmpty) {
      messages.add('\\n🚀 **이번 주 실행 계획**');
      for (int i = 0; i < math.min(3, strategies.length); i++) {
        final strategy = strategies[i];
        messages.add('${i + 1}. ${strategy.title}');
        messages.add('   ${strategy.description}');
        messages.add(
          '   예상 절약: ${_formatCurrency(strategy.expectedSaving.toDouble())}, 난이도: ${strategy.difficulty}',
        );
      }
    }

    return messages.join('\\n');
  }

  /// 🎬 실행 가능한 조언 생성
  List<ActionableAdvice> _generateActionableAdvice(
    List<PersonalizedStrategy> strategies,
    List<Map<String, dynamic>> opportunities,
  ) {
    final advice = <ActionableAdvice>[];

    // 전략 기반 조언
    for (final strategy in strategies.take(3)) {
      advice.add(
        ActionableAdvice(
          title: strategy.title,
          description: strategy.description,
          actionType: 'strategy',
          priority: strategy.priority,
          expectedImpact: strategy.expectedSaving,
        ),
      );
    }

    // 기회 기반 조언
    for (final opportunity in opportunities.take(2)) {
      advice.add(
        ActionableAdvice(
          title: opportunity['title'] as String,
          description: opportunity['suggestion'] as String,
          actionType: 'opportunity',
          priority: opportunity['priority'] as String,
          expectedImpact: (opportunity['potentialSaving'] as double).round(),
        ),
      );
    }

    return advice;
  }

  // 🔧 헬퍼 메서드들

  double _calculateDailyFrequency(List<Transaction> transactions) {
    if (transactions.isEmpty) return 0;

    final days = DateTime.now().difference(transactions.last.date).inDays + 1;
    return transactions.length / days;
  }

  double _calculateImpulseScore(List<Transaction> transactions) {
    final smallTransactions = transactions.where((t) => t.amount < 5000).length;
    return smallTransactions / transactions.length;
  }

  double _calculateSpendingConsistency(List<Transaction> transactions) {
    if (transactions.length < 5) return 0.5;

    final amounts = transactions.map((t) => t.amount).toList();
    final mean =
        amounts.fold<double>(0, (sum, amount) => sum + amount) / amounts.length;
    final variance =
        amounts.fold<double>(
          0,
          (sum, amount) => sum + ((amount - mean) * (amount - mean)),
        ) /
        amounts.length;
    final stdDev = math.sqrt(variance);

    return 1.0 - (stdDev / mean).clamp(0.0, 1.0);
  }

  double _calculatePlanningScore(List<Transaction> transactions) {
    // 주말 vs 평일 지출 비율로 계획성 측정
    final weekdaySpending = transactions
        .where((t) => t.date.weekday <= 5)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final weekendSpending = transactions
        .where((t) => t.date.weekday > 5)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final totalSpending = weekdaySpending + weekendSpending;
    if (totalSpending == 0) return 0.5;

    // 평일 지출 비율이 높으면 계획적
    return (weekdaySpending / totalSpending).clamp(0.0, 1.0);
  }

  String _determineSpendingPersonality(
    double risk,
    double selfControl,
    double planfulness,
  ) {
    if (risk > 0.6 && selfControl < 0.4) return 'impulsive';
    if (risk < 0.3 && selfControl > 0.7) return 'cautious';
    return 'balanced';
  }

  double _calculateAdvancedGoalProbability(
    UserModel user,
    Map<String, dynamic> spendingAnalysis,
    List<Transaction> transactions,
  ) {
    if (user.monthlyGoal <= 0) return 0.5;

    double probability = user.currentMonthSaved / user.monthlyGoal;

    // 보정 요인들
    if (user.consecutiveDays > 7) probability += 0.1;
    if (user.level > 5) probability += 0.05;
    if (transactions.length > 30) probability += 0.05; // 데이터 충분성

    final trend = spendingAnalysis['spendingTrend'] as double? ?? 0;
    if (trend < 0) probability += 0.1; // 지출 감소 경향

    return probability.clamp(0.0, 1.0);
  }

  double _calculateConfidenceScore(
    List<Transaction> transactions,
    List<Budget> budgets,
  ) {
    double score = 0;

    if (transactions.length >= 50) {
      score += 40;
    } else if (transactions.length >= 20) {
      score += 25;
    } else if (transactions.length >= 10) {
      score += 15;
    }

    if (budgets.isNotEmpty) score += 20;

    // 데이터 다양성
    final categories = transactions.map((t) => t.category).toSet().length;
    score += (categories / TransactionCategory.values.length) * 40;

    return score.clamp(0, 100);
  }

  String _generatePersonalGreeting(UserModel user) {
    if (user.level >= 10) {
      return '👑 ${user.name.isNotEmpty ? user.name : '절약왕'}님, 고급 절약러의 새로운 도전이 시작됩니다!';
    } else if (user.level >= 5) {
      return '⭐ ${user.name.isNotEmpty ? user.name : '절약러'}님, 중급자의 다음 단계로 도약할 시간이에요!';
    }
    return '🌱 ${user.name.isNotEmpty ? user.name : '새싹절약러'}님, 절약 여정을 함께 시작해요!';
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(1)}만원';
    }
    return '${amount.toStringAsFixed(0)}원';
  }
}

// 📦 데이터 클래스들

class ComprehensiveInsight {
  final String userId;
  final DateTime generatedAt;
  final double confidenceScore;
  final Map<String, dynamic> spendingAnalysis;
  final Map<String, dynamic> budgetAnalysis;
  final List<Map<String, dynamic>> opportunities;
  final Map<String, dynamic> goalSuggestions;
  final Map<String, dynamic> behaviorPatterns;
  final Map<String, dynamic> temporalPatterns;
  final Map<TransactionCategory, Map<String, dynamic>> categoryInsights;
  final Map<String, dynamic> psychProfile;
  final Map<String, dynamic> predictions;
  final List<PersonalizedStrategy> strategies;
  final String personalizedMessage;
  final List<ActionableAdvice> actionableAdvice;

  ComprehensiveInsight({
    required this.userId,
    required this.generatedAt,
    required this.confidenceScore,
    required this.spendingAnalysis,
    required this.budgetAnalysis,
    required this.opportunities,
    required this.goalSuggestions,
    required this.behaviorPatterns,
    required this.temporalPatterns,
    required this.categoryInsights,
    required this.psychProfile,
    required this.predictions,
    required this.strategies,
    required this.personalizedMessage,
    required this.actionableAdvice,
  });

  factory ComprehensiveInsight.empty(UserModel user) {
    return ComprehensiveInsight(
      userId: user.id,
      generatedAt: DateTime.now(),
      confidenceScore: 0,
      spendingAnalysis: {'isEmpty': true},
      budgetAnalysis: {},
      opportunities: [],
      goalSuggestions: {'cannotAnalyze': true},
      behaviorPatterns: {},
      temporalPatterns: {},
      categoryInsights: {},
      psychProfile: {},
      predictions: {'available': false, 'reason': '데이터 없음'},
      strategies: [],
      personalizedMessage:
          '아직 분석할 데이터가 부족해요. 가계부를 더 작성해주시면 맞춤형 AI 조언을 드릴 수 있어요! 📝',
      actionableAdvice: [],
    );
  }

  factory ComprehensiveInsight.error(UserModel user, String error) {
    return ComprehensiveInsight(
      userId: user.id,
      generatedAt: DateTime.now(),
      confidenceScore: 0,
      spendingAnalysis: {'error': true},
      budgetAnalysis: {},
      opportunities: [],
      goalSuggestions: {},
      behaviorPatterns: {},
      temporalPatterns: {},
      categoryInsights: {},
      psychProfile: {},
      predictions: {'available': false, 'reason': '분석 오류'},
      strategies: [],
      personalizedMessage: '분석 중 오류가 발생했어요. 잠시 후 다시 시도해주세요. 🔄',
      actionableAdvice: [],
    );
  }
}

class PersonalizedStrategy {
  final String title;
  final String description;
  final String priority;
  final int expectedSaving;
  final String difficulty;
  final String timeframe;

  PersonalizedStrategy({
    required this.title,
    required this.description,
    required this.priority,
    required this.expectedSaving,
    required this.difficulty,
    required this.timeframe,
  });
}

class ActionableAdvice {
  final String title;
  final String description;
  final String actionType;
  final String priority;
  final int expectedImpact;

  ActionableAdvice({
    required this.title,
    required this.description,
    required this.actionType,
    required this.priority,
    required this.expectedImpact,
  });
}
