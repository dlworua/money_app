import '../../data/models/user_model.dart';
import '../../data/models/ai_coaching_insight.dart';
import '../../data/models/transaction.dart';
import '../../data/models/budget.dart';
import '../enums/coaching_style.dart';
import 'ai_coach_generator.dart';
import 'financial_analysis_service.dart';

/// 인사이트 타입 (내부용)
enum _InsightType {
  categoryAnalysis, // 카테고리별 분석
  budgetComparison, // 예산 비교
  trendAnalysis, // 트렌드 분석
  savingOpportunity, // 절약 기회
}

class AiCoachingService {
  final AiCoachGenerator _generator = AiCoachGenerator();
  final FinancialAnalysisService _analysisService = FinancialAnalysisService();

  /// 실제 계부 데이터와 완전히 연동된 맞춤 코칭 제공
  ///
  /// 다양한 인사이트를 순환하면서 제공:
  /// 1. 카테고리별 지출 분석
  /// 2. 예산 대비 지출 비교
  /// 3. 최근 지출 트렌드 분석
  /// 4. 절약 기회 발견
  Future<AiCoachingInsight> getFinancialCoaching(
    UserModel user,
    List<Transaction> transactions,
    List<Budget> budgets,
  ) async {
    try {
      // 데이터가 없으면 기본 메시지
      if (transactions.isEmpty) {
        return _createWelcomeCoaching(user);
      }

      // 인사이트 타입을 순환하면서 제공
      final insightTypes = [
        _InsightType.categoryAnalysis,
        _InsightType.budgetComparison,
        _InsightType.trendAnalysis,
        _InsightType.savingOpportunity,
      ];

      // 마지막으로 제공한 인사이트 타입 추적 (향후 UserModel에 저장)
      final lastInsightIndex =
          DateTime.now().millisecondsSinceEpoch % insightTypes.length;
      final currentInsightType = insightTypes[lastInsightIndex];

      // 인사이트 타입에 따라 다른 분석 제공
      switch (currentInsightType) {
        case _InsightType.categoryAnalysis:
          return _generateCategoryInsight(user, transactions, budgets);
        case _InsightType.budgetComparison:
          // 예산 초과 경고가 있으면 제공
          final budgetAlert = await getBudgetOverspendAlert(
            user,
            transactions,
            budgets,
          );
          if (budgetAlert != null) {
            return budgetAlert;
          }
          return _generateCategoryInsight(user, transactions, budgets);
        case _InsightType.trendAnalysis:
          return getMonthlyFinancialReport(user, transactions, budgets);
        case _InsightType.savingOpportunity:
          // 절약 기회가 있으면 제공
          final savingOpps = await getSavingOpportunityAlerts(
            user,
            transactions,
            budgets,
          );
          if (savingOpps.isNotEmpty) {
            return savingOpps.first;
          }
          return _generateCategoryInsight(user, transactions, budgets);
      }
    } catch (error) {
      // 에러 발생시 기존 분석 제공
      return _generateCategoryInsight(user, transactions, budgets);
    }
  }

  /// 카테고리별 지출 분석 인사이트
  Future<AiCoachingInsight> _generateCategoryInsight(
    UserModel user,
    List<Transaction> transactions,
    List<Budget> budgets,
  ) async {
    try {
      // 데이터가 없으면 기본 메시지
      if (transactions.isEmpty) {
        return _createWelcomeCoaching(user);
      }

      // 간단한 분석부터 시작 (복잡한 AnalysisService 사용 안함)
      final totalSpending = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final categorySpending = <TransactionCategory, double>{};
      for (final t in transactions.where(
        (t) => t.type == TransactionType.expense,
      )) {
        categorySpending[t.category] =
            (categorySpending[t.category] ?? 0) + t.amount;
      }

      TransactionCategory? topCategory;
      double maxAmount = 0;
      categorySpending.forEach((category, amount) {
        if (amount > maxAmount) {
          maxAmount = amount;
          topCategory = category;
        }
      });

      final dailyAverage = totalSpending / 30;

      String title;
      String message;
      List<String> actionItems = [];

      if (transactions.length == 1) {
        title = _getTitleByStyle('first_transaction', user.preferredCoachingStyle);
        message = _generateFirstTransactionMessage(
          user.preferredCoachingStyle,
          totalSpending,
          topCategory?.displayName ?? '기타',
        );
        actionItems = _getFirstTransactionActions(
          user.preferredCoachingStyle,
          topCategory?.displayName ?? '해당 카테고리',
        );
      } else if (transactions.length < 5) {
        title = _getTitleByStyle('early_stage', user.preferredCoachingStyle);
        message = _generateEarlyStageMessage(
          user.preferredCoachingStyle,
          transactions.length,
          totalSpending,
          topCategory?.displayName ?? '기타',
        );
        actionItems = _getEarlyStageActions(
          user.preferredCoachingStyle,
          topCategory?.displayName ?? '해당 카테고리',
        );
      } else {
        title = _getTitleByStyle('detailed_analysis', user.preferredCoachingStyle);
        message = _generateDetailedAnalysisMessage(
          user.preferredCoachingStyle,
          transactions.length,
          totalSpending,
          dailyAverage,
          topCategory?.displayName ?? '기타',
        );
        actionItems = _getDetailedAnalysisActions(
          user.preferredCoachingStyle,
          topCategory?.displayName ?? '최고 지출 카테고리',
          dailyAverage,
        );
      }

      // 카테고리별 추가 조언은 기본 조언만 추가 (말투는 이미 적용됨)
      if (topCategory != null && actionItems.length < 4) {
        actionItems.addAll(_getBasicAdviceForCategory(topCategory));
      }

      return AiCoachingInsight(
        id: 'financial_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        style: user.preferredCoachingStyle,
        title: title,
        message: message,
        type: InsightType.spendingPattern,
        analysisData: {
          'transactionCount': transactions.length,
          'totalSpending': totalSpending,
          'topCategory': topCategory?.name,
          'dailyAverage': dailyAverage,
        },
        confidenceScore: transactions.length >= 5 ? 0.8 : 0.6,
        actionItems: actionItems.take(4).toList(),
      );
    } catch (error) {
      // 에러 발생시 기본 코칭 제공
      return AiCoachingInsight(
        id: 'error_fallback_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        style: user.preferredCoachingStyle,
        title: '📊 가계부 현황',
        message:
            '${transactions.length}건의 거래를 기록하셨네요! 더 자세한 분석은 조금 더 데이터를 쌓은 후 제공해드릴게요.',
        type: InsightType.general,
        analysisData: {
          'transactionCount': transactions.length,
          'error': error.toString(),
        },
        confidenceScore: 0.5,
        actionItems: ['꾸준히 가계부 작성하기', '카테고리별로 정확히 분류하기', '매주 지출 패턴 확인하기'],
      );
    }
  }

  /// 절약 기회 알림
  Future<List<AiCoachingInsight>> getSavingOpportunityAlerts(
    UserModel user,
    List<Transaction> transactions,
    List<Budget> budgets,
  ) async {
    final opportunities = _analysisService.findSavingOpportunities(
      transactions,
      budgets,
    );
    final alerts = <AiCoachingInsight>[];

    for (final opportunity in opportunities.take(3)) {
      // 상위 3개만
      final insight = AiCoachingInsight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        style: user.preferredCoachingStyle,
        title: opportunity['title'],
        message: opportunity['message'],
        type: InsightType.spendingPattern,
        analysisData: {
          'opportunity': opportunity,
          'potentialSaving': opportunity['potentialSaving'],
          'priority': opportunity['priority'],
        },
        confidenceScore: _getConfidenceScore(opportunity['priority']),
        actionItems: [opportunity['suggestion']],
      );
      alerts.add(insight);
    }

    return alerts;
  }

  /// 실제 거래 기반 예산 초과 경고
  Future<AiCoachingInsight?> getBudgetOverspendAlert(
    UserModel user,
    List<Transaction> transactions,
    List<Budget> budgets,
  ) async {
    final budgetAnalysis = _analysisService.analyzeBudgetPerformance(
      transactions,
      budgets,
    );

    // 가장 심각한 예산 초과 찾기
    String? worstCategory;
    double worstOverspend = 0;

    budgetAnalysis.forEach((category, data) {
      if (data['isOverBudget'] &&
          data['actualSpending'] - data['budgetAmount'] > worstOverspend) {
        worstCategory = category;
        worstOverspend = data['actualSpending'] - data['budgetAmount'];
      }
    });

    if (worstCategory == null) return null;

    final categoryData = budgetAnalysis[worstCategory];
    final categoryEnum = TransactionCategory.values.byName(worstCategory!);

    // 해당 카테고리의 실제 거래 분석
    final categoryTransactions = transactions
        .where(
          (t) =>
              t.category == categoryEnum && t.type == TransactionType.expense,
        )
        .toList();

    final recentTransactions = categoryTransactions
        .where((t) => DateTime.now().difference(t.date).inDays <= 7)
        .toList();

    final recentSpending = recentTransactions.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );
    final avgTransactionAmount = categoryTransactions.isEmpty
        ? 0.0
        : categoryTransactions.fold<double>(0, (sum, t) => sum + t.amount) /
              categoryTransactions.length;

    String detailMessage =
        '이달 ${categoryEnum.displayName} 예산 ${_formatCurrency(categoryData['budgetAmount'])}을 '
        '${categoryData['spendingPercentage'].toInt()}% 사용해서 '
        '${_formatCurrency(worstOverspend)} 초과했어요. ';

    if (recentTransactions.isNotEmpty) {
      detailMessage +=
          '최근 7일간 ${recentTransactions.length}건으로 ${_formatCurrency(recentSpending)} 지출했네요.';
    }

    List<String> specificActions = [];

    // 거래 패턴 기반 맞춤 조언
    if (avgTransactionAmount > 50000) {
      specificActions.add(
        '한 번에 ${_formatCurrency(avgTransactionAmount)} 정도 쓰시는데, 소액 지출로 나눠보세요.',
      );
    }

    if (categoryTransactions.length > 20) {
      specificActions.add(
        '${categoryTransactions.length}건의 잦은 지출이 있어요. 주 2-3회로 줄여보세요.',
      );
    } else if (categoryTransactions.length < 5) {
      specificActions.add('지출 건수는 적지만 금액이 커요. 대용량 구매보다 필요한 만큼만 구매해보세요.');
    }

    // 카테고리별 구체적 조언 추가
    specificActions.addAll(
      _getDetailedAdviceForTopCategory(
        categoryEnum,
        categoryData['actualSpending'],
        categoryData['actualSpending'] / 30,
        categoryTransactions.length,
      ),
    );

    return AiCoachingInsight(
      id: 'budget_alert_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      style: user.preferredCoachingStyle,
      title:
          '🚨 ${categoryEnum.displayName} 예산 ${worstOverspend > categoryData['budgetAmount'] * 0.5 ? "대폭 " : ""}초과!',
      message: detailMessage,
      type: InsightType.warning,
      analysisData: {
        'category': worstCategory!,
        'budgetAmount': categoryData['budgetAmount'],
        'actualSpending': categoryData['actualSpending'],
        'overspendAmount': worstOverspend,
        'spendingPercentage': categoryData['spendingPercentage'],
        'transactionCount': categoryTransactions.length,
        'recentSpending': recentSpending,
        'avgTransactionAmount': avgTransactionAmount,
      },
      confidenceScore: 0.95,
      actionItems: specificActions.take(4).toList(),
    );
  }

  /// 실제 거래 분석 기반 월말 재무 리포트
  Future<AiCoachingInsight> getMonthlyFinancialReport(
    UserModel user,
    List<Transaction> transactions,
    List<Budget> budgets,
  ) async {
    final now = DateTime.now();
    final thisMonth = transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();

    final spendingAnalysis = _analysisService.analyzeSpendingPattern(
      transactions,
      days: 30,
    );
    final budgetAnalysis = _analysisService.analyzeBudgetPerformance(
      transactions,
      budgets,
    );
    final savingGoals = _analysisService.generateSavingGoals(
      transactions,
      budgets,
      0.1,
    );

    final transactionCount = thisMonth.length;
    final expenseCount = thisMonth
        .where((t) => t.type == TransactionType.expense)
        .length;
    final incomeCount = thisMonth
        .where((t) => t.type == TransactionType.income)
        .length;
    final savingCount = thisMonth
        .where((t) => t.type == TransactionType.saving)
        .length;

    if (transactionCount < 5) {
      return AiCoachingInsight(
        id: 'monthly_report_empty_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        style: user.preferredCoachingStyle,
        title: '📊 이달의 가계부 현황',
        message:
            '이달 $transactionCount건의 거래만 기록되어 있어요. 더 정확한 분석을 위해 매일 가계부를 작성해보세요!',
        type: InsightType.general,
        analysisData: {'transactionCount': transactionCount},
        confidenceScore: 0.5,
        actionItems: [
          '매일 최소 3-5건의 거래 기록하기',
          '작은 지출도 놓치지 말고 기록하기',
          '영수증 사진과 함께 메모 남기기',
        ],
      );
    }

    final monthlySpending = spendingAnalysis['totalSpending'];
    final monthlyIncome = thisMonth
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final monthlySaving = thisMonth
        .where((t) => t.type == TransactionType.saving)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final dailyAverage = spendingAnalysis['dailyAverage'];
    final topCategory = spendingAnalysis['topCategory'] as TransactionCategory?;
    final spendingTrend = spendingAnalysis['spendingTrend'];

    // 거래 패턴 분석
    final avgExpenseAmount = expenseCount > 0
        ? thisMonth
                  .where((t) => t.type == TransactionType.expense)
                  .fold<double>(0, (sum, t) => sum + t.amount) /
              expenseCount
        : 0.0;

    final bigSpendingCount = thisMonth
        .where((t) => t.type == TransactionType.expense && t.amount > 50000)
        .length;

    String detailMessage = '이달 총 $transactionCount건 거래: ';
    detailMessage += '수입 $incomeCount건(${_formatCurrency(monthlyIncome)}), ';
    detailMessage += '지출 $expenseCount건(${_formatCurrency(monthlySpending)})';
    if (savingCount > 0) {
      detailMessage += ', 절약 $savingCount건(${_formatCurrency(monthlySaving)})';
    }
    detailMessage += '.\n';

    detailMessage += '일평균 ${_formatCurrency(dailyAverage)} 지출하시고, ';
    if (topCategory != null) {
      detailMessage += '${topCategory.displayName}에 가장 많이 쓰셨어요. ';
    }

    // 지출 트렌드 분석
    String trendMessage;
    if (spendingTrend > 0.15) {
      trendMessage =
          '지난 대비 지출이 ${(spendingTrend * 100).toInt()}% 늘었어요. 지출 관리가 필요해요!';
    } else if (spendingTrend < -0.1) {
      trendMessage = '지난 대비 ${(-spendingTrend * 100).toInt()}% 절약에 성공했어요! 🎉';
    } else {
      trendMessage = '지출이 안정적으로 유지되고 있어요.';
    }
    detailMessage += trendMessage;

    // 맞춤 액션 아이템 생성
    List<String> actionItems = [];

    // 거래 패턴 기반 조언
    if (avgExpenseAmount > 30000) {
      actionItems.add(
        '평균 지출 금액이 ${_formatCurrency(avgExpenseAmount)}로 높아요. 소액 지출 늘리기',
      );
    }

    if (bigSpendingCount > 5) {
      actionItems.add('5만원 이상 큰 지출이 $bigSpendingCount회 있었어요. 고액 지출 전 하루 고민하기');
    }

    if (incomeCount == 0) {
      actionItems.add('수입 기록이 없어요. 급여나 수입도 함께 기록해보세요');
    } else if (monthlyIncome > 0 && monthlySpending > monthlyIncome * 0.8) {
      actionItems.add('지출이 수입의 80% 이상이에요. 절약 목표 세우기');
    }

    if (savingCount == 0) {
      actionItems.add('절약 기록을 시작해보세요. 작은 절약도 의미 있어요!');
    }

    // 카테고리별 맞춤 조언 추가
    if (topCategory != null && actionItems.length < 3) {
      actionItems.addAll(
        _getOptimizationAdviceForCategory(
          topCategory,
          monthlySpending * 0.3,
          dailyAverage,
        ),
      );
    }

    // 기본 조언 추가
    if (topCategory != null) {
      actionItems.addAll(_getReportActionSuggestions(savingGoals, topCategory));
    }

    return AiCoachingInsight(
      id: 'monthly_report_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      style: user.preferredCoachingStyle,
      title: '📊 ${now.month}월 가계부 분석 리포트',
      message: detailMessage,
      type: InsightType.monthlyReview,
      analysisData: {
        'transactionCount': transactionCount,
        'expenseCount': expenseCount,
        'incomeCount': incomeCount,
        'savingCount': savingCount,
        'monthlySpending': monthlySpending,
        'monthlyIncome': monthlyIncome,
        'monthlySaving': monthlySaving,
        'dailyAverage': dailyAverage,
        'topCategory': topCategory?.name,
        'spendingTrend': spendingTrend,
        'avgExpenseAmount': avgExpenseAmount,
        'bigSpendingCount': bigSpendingCount,
        'budgetAnalysis': budgetAnalysis,
        'savingGoals': savingGoals,
      },
      confidenceScore: transactionCount > 20 ? 0.95 : 0.8,
      actionItems: actionItems.take(5).toList(),
    );
  }

  /// 사용자 맞춤 AI 코칭 제공
  Future<AiCoachingInsight> getPersonalizedCoaching(UserModel user) async {
    // 마지막 코칭으로부터 충분한 시간이 지났는지 확인
    if (!_shouldGenerateNewCoaching(user)) {
      // 최근 코칭이 있다면 그것을 반환
      if (user.coachingInsights.isNotEmpty) {
        return user.coachingInsights.last;
      }
    }

    // 새로운 코칭 인사이트 생성
    final insight = await _generator.generateCoachingInsight(
      user,
      user.preferredCoachingStyle,
    );

    return insight;
  }

  /// 일일 코칭 체크 (앱 시작 시 호출)
  Future<AiCoachingInsight?> checkDailyCoaching(UserModel user) async {
    if (!user.enableDailyCoaching) return null;

    // 오늘 이미 코칭을 받았는지 확인
    final now = DateTime.now();
    final lastCoaching = user.lastCoachingDate;

    if (lastCoaching != null) {
      final daysDiff = now.difference(lastCoaching).inDays;
      if (daysDiff < 1) {
        return null; // 오늘 이미 코칭을 받음
      }
    }

    return await getPersonalizedCoaching(user);
  }

  /// 주간 리뷰 생성
  Future<AiCoachingInsight?> generateWeeklyReview(UserModel user) async {
    if (!user.enableWeeklyReview) return null;

    // 주간 리뷰용 특별 분석
    final weeklyInsight = await _generator.generateCoachingInsight(
      user,
      user.preferredCoachingStyle,
    );

    // 주간 리뷰임을 표시
    return weeklyInsight.copyWith(
      title: '📊 주간 절약 리뷰',
      type: InsightType.monthlyReview,
    );
  }

  /// 목표 달성 축하 메시지
  Future<AiCoachingInsight> generateAchievementCelebration(
    UserModel user,
    String achievement,
  ) async {
    final insight = await _generator.generateCoachingInsight(
      user,
      user.preferredCoachingStyle,
    );

    return insight.copyWith(
      title: '🎉 축하합니다!',
      type: InsightType.achievement,
      message: _getAchievementMessage(achievement, user.preferredCoachingStyle),
    );
  }

  /// 긴급 경고 메시지 (목표 달성이 어려운 경우)
  Future<AiCoachingInsight> generateUrgentWarning(UserModel user) async {
    final insight = await _generator.generateCoachingInsight(
      user,
      user.preferredCoachingStyle,
    );

    return insight.copyWith(title: '⚠️ 목표 달성 위험', type: InsightType.warning);
  }

  /// 코칭 스타일 변경
  UserModel updateCoachingStyle(UserModel user, CoachingStyle newStyle) {
    return user.copyWith(preferredCoachingStyle: newStyle);
  }

  /// 코칭 설정 업데이트
  UserModel updateCoachingSettings(
    UserModel user, {
    bool? enableDailyCoaching,
    bool? enableWeeklyReview,
    Map<String, dynamic>? preferences,
  }) {
    return user.copyWith(
      enableDailyCoaching: enableDailyCoaching,
      enableWeeklyReview: enableWeeklyReview,
      coachingPreferences: preferences,
    );
  }

  /// 코칭 인사이트 추가 (히스토리 관리)
  UserModel addCoachingInsight(UserModel user, AiCoachingInsight insight) {
    final updatedInsights = [...user.coachingInsights, insight];

    // 최대 50개까지만 보관 (메모리 관리)
    final limitedInsights = updatedInsights.length > 50
        ? updatedInsights.sublist(updatedInsights.length - 50)
        : updatedInsights;

    return user.copyWith(
      coachingInsights: limitedInsights,
      lastCoachingDate: insight.createdAt,
    );
  }

  /// 인사이트 읽음 표시
  UserModel markInsightAsRead(UserModel user, String insightId) {
    final updatedInsights = user.coachingInsights.map((insight) {
      if (insight.id == insightId) {
        return insight.copyWith(isRead: true);
      }
      return insight;
    }).toList();

    return user.copyWith(coachingInsights: updatedInsights);
  }

  /// 읽지 않은 인사이트 개수
  int getUnreadInsightCount(UserModel user) {
    return user.coachingInsights.where((insight) => !insight.isRead).length;
  }

  /// 최근 인사이트 가져오기
  List<AiCoachingInsight> getRecentInsights(UserModel user, {int limit = 10}) {
    final sortedInsights = [...user.coachingInsights]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sortedInsights.take(limit).toList();
  }

  /// 코칭 타입별 인사이트 가져오기
  List<AiCoachingInsight> getInsightsByType(UserModel user, InsightType type) {
    return user.coachingInsights
        .where((insight) => insight.type == type)
        .toList();
  }

  /// 새로운 코칭을 생성해야 하는지 확인
  bool _shouldGenerateNewCoaching(UserModel user) {
    if (user.lastCoachingDate == null) return true;

    final now = DateTime.now();
    final hoursSinceLastCoaching = now
        .difference(user.lastCoachingDate!)
        .inHours;

    // 6시간마다 새로운 코칭 생성 가능
    return hoursSinceLastCoaching >= 6;
  }

  /// 성취별 축하 메시지
  String _getAchievementMessage(String achievement, CoachingStyle style) {
    switch (style) {
      case CoachingStyle.strict:
        return '$achievement 달성. 당연한 결과입니다. 다음 목표로 나아가세요.';
      case CoachingStyle.kind:
        return '$achievement을 달성하셨네요! 정말 자랑스러워요! 🎉';
      case CoachingStyle.friendly:
        return '$achievement 달성이라니! 완전 대박! 축하해! 🎊';
      case CoachingStyle.motivational:
        return '🔥 $achievement 달성! 당신은 진정한 절약 챔피언입니다!';
      case CoachingStyle.analytical:
        return '데이터 분석 결과: $achievement 달성률 100%. 목표 수립 및 실행 능력 우수.';
    }
  }

  /// 코칭 통계 생성
  Map<String, dynamic> getCoachingStats(UserModel user) {
    final insights = user.coachingInsights;
    if (insights.isEmpty) {
      return {
        'totalInsights': 0,
        'averageConfidence': 0.0,
        'mostCommonType': 'none',
        'lastCoachingDaysAgo': null,
      };
    }

    final avgConfidence =
        insights.fold<double>(
          0,
          (sum, insight) => sum + insight.confidenceScore,
        ) /
        insights.length;

    final typeCounts = <InsightType, int>{};
    for (final insight in insights) {
      typeCounts[insight.type] = (typeCounts[insight.type] ?? 0) + 1;
    }

    final mostCommonType = typeCounts.entries.isEmpty
        ? InsightType.general
        : typeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final daysSinceLastCoaching = user.lastCoachingDate != null
        ? DateTime.now().difference(user.lastCoachingDate!).inDays
        : null;

    return {
      'totalInsights': insights.length,
      'averageConfidence': avgConfidence,
      'mostCommonType': mostCommonType.displayName,
      'lastCoachingDaysAgo': daysSinceLastCoaching,
      'unreadCount': getUnreadInsightCount(user),
    };
  }

  /// 우선순위에 따른 신뢰도 점수
  double _getConfidenceScore(String priority) {
    switch (priority) {
      case 'high':
        return 0.95;
      case 'medium':
        return 0.8;
      case 'low':
        return 0.65;
      default:
        return 0.7;
    }
  }

  /// 월간 리포트 액션 제안 생성
  List<String> _getReportActionSuggestions(
    Map<String, dynamic> savingGoals,
    TransactionCategory topCategory,
  ) {
    final suggestions = <String>[];

    // 절약 목표가 있는 경우
    if (savingGoals['cannotAnalyze'] != true) {
      final goals = savingGoals['goals'] as Map<String, dynamic>;
      final conservativeGoal = goals['conservative'] as Map<String, dynamic>;

      suggestions.add(
        '이달 ${conservativeGoal['amount'].toInt()}원(${conservativeGoal['percentage']}%) 절약을 목표로 해보세요.',
      );
    }

    // 카테고리별 맞춤 제안
    final strategies = savingGoals['strategies'] as List<String>? ?? [];
    if (strategies.isNotEmpty) {
      suggestions.add(strategies.first);
    }

    // 기본 제안
    if (suggestions.isEmpty) {
      suggestions.addAll([
        '가장 많이 지출한 ${topCategory.displayName} 카테고리를 점검해보세요.',
        '다음 달 예산을 미리 계획해보는 것이 어떨까요?',
      ]);
    }

    return suggestions;
  }

  /// 환영 코칭 생성
  AiCoachingInsight _createWelcomeCoaching(UserModel user) {
    return AiCoachingInsight(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      style: user.preferredCoachingStyle,
      title: '🎉 가계부 시작하기!',
      message: '안녕하세요! 거래를 기록하시면 AI가 맞춤형 절약 조언을 제공해드려요.',
      type: InsightType.general,
      analysisData: {'isEmpty': true},
      confidenceScore: 1.0,
      actionItems: ['첫 번째 거래를 기록해보세요', '카테고리별로 정확히 분류하기', '꾸준히 기록하면 더 정확한 분석'],
    );
  }

  /// 카테고리별 기본 조언
  List<String> _getBasicAdviceForCategory(TransactionCategory? category) {
    if (category == null) return ['절약 방법 찾아보기', '지출 패턴 분석하기'];
    switch (category) {
      case TransactionCategory.food:
        return ['집밥 도전해보기', '할인 상품 활용하기'];
      case TransactionCategory.transport:
        return ['대중교통 이용하기', '걸을 수 있는 거리는 도보로'];
      case TransactionCategory.shopping:
        return ['필요한 것만 구매하기', '할인 쿠폰 활용하기'];
      default:
        return ['절약 방법 찾아보기', '대안 상품 비교하기'];
    }
  }

  /// 통화 포맷 헬퍼 메서드 (단위 포함)
  String _formatCurrency(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toInt()}만';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toInt()}천';
    } else {
      return '${amount.toInt()}';
    }
  }

  /// 카테고리 표시명 가져오기
  List<String> _getDetailedAdviceForTopCategory(
    TransactionCategory category,
    double totalAmount,
    double dailyAverage,
    int transactionCount,
  ) {
    final monthlyAverage = dailyAverage * 30;

    switch (category) {
      case TransactionCategory.food:
        if (monthlyAverage > 300000) {
          return [
            '식비가 월 ${_formatCurrency(monthlyAverage)}로 높은 편이에요. 주 3회 집밥으로 20% 절약해보세요.',
            '배달음식을 마트 도시락으로 바꿔보기',
            '점심 도시락 준비로 일일 1만원씩 아끼기',
          ];
        } else {
          return [
            '합리적인 식비 관리하고 계시네요!',
            '할인마트 이용으로 10% 더 절약하기',
            '간단한 요리 레시피 3개 도전해보기',
          ];
        }

      case TransactionCategory.transport:
        if (monthlyAverage > 150000) {
          return [
            '교통비가 월 ${_formatCurrency(monthlyAverage)}네요. 정기권 구매로 15% 절약 가능해요.',
            '가까운 거리는 도보나 자전거 이용하기',
            '카풀 앱 활용으로 택시비 반으로 줄이기',
          ];
        } else {
          return [
            '교통비를 잘 관리하고 계시네요!',
            '도보 시간을 늘려 건강까지 챙기기',
            '대중교통 앱으로 최적 경로 찾기',
          ];
        }

      case TransactionCategory.shopping:
        return [
          '쇼핑 전 꼭 필요한 것만 리스트 작성하기',
          '온라인 구매 시 24시간 후 재검토하기',
          '중고 거래로 30% 저렴하게 구매하기',
          '할인 쿠폰과 적립금 활용하기',
        ];

      case TransactionCategory.entertainment:
        if (monthlyAverage > 200000) {
          return [
            '엔터테인먼트 비용이 높아요. 무료 문화 행사 활용해보세요.',
            '구독 서비스 2개 이상 시 가족 공유 계획으로 변경',
            '영화관 대신 홈시어터나 도서관 이용하기',
          ];
        } else {
          return [
            '적절한 여가 비용이에요!',
            '무료 전시회나 공원 산책으로 더 알차게',
            'OTT 서비스는 번갈아 구독하기',
          ];
        }

      default:
        return [
          '${category.displayName} 지출을 세부 항목별로 점검해보세요',
          '불필요한 구독이나 정기 결제 확인하기',
          '구매 전 3일 고민 시간 갖기',
        ];
    }
  }

  /// 카테고리별 최적화 조언
  List<String> _getOptimizationAdviceForCategory(
    TransactionCategory category,
    double categorySpending,
    double dailyAverage,
  ) {
    final monthlySpending = dailyAverage * 30;

    switch (category) {
      case TransactionCategory.food:
        if (categorySpending > monthlySpending * 0.3) {
          return ['식비가 전체 지출의 30% 이상이에요. 주 2회 집밥 도전!', '점심 도시락으로 월 10만원 절약하기'];
        }
        return ['현재 식비 관리 잘하고 계시네요!', '가끔 특가 상품 활용해보기'];

      case TransactionCategory.transport:
        return ['정기권 할인 혜택 확인해보기', '가까운 거리는 걸어서 건강도 챙기기'];

      case TransactionCategory.shopping:
        return ['충동구매 방지를 위한 1일 고민 시간 갖기', '필요한 것과 원하는 것 구분해서 구매하기'];

      default:
        return ['${category.displayName} 지출 패턴 분석해보기', '더 저렴한 대안 옵션 찾아보기'];
    }
  }

  // ========================================
  // 말투별 메시지 템플릿 생성 (완전히 다른 메시지를 처음부터 생성)
  // ========================================

  /// 시나리오별 타이틀 생성
  String _getTitleByStyle(String scenario, CoachingStyle style) {
    final titles = {
      'first_transaction': {
        CoachingStyle.strict: '첫 거래 기록 완료',
        CoachingStyle.kind: '🎯 첫 거래 분석해보았어요!',
        CoachingStyle.friendly: '🎉 와! 첫 거래다!',
        CoachingStyle.motivational: '🔥 환상적인 첫 걸음!',
        CoachingStyle.analytical: '[데이터] 초기 거래 분석',
      },
      'early_stage': {
        CoachingStyle.strict: '가계부 초기 단계 분석',
        CoachingStyle.kind: '📈 가계부 잘 시작하셨어요!',
        CoachingStyle.friendly: '📱 오 괜찮은데? 계속 가보자!',
        CoachingStyle.motivational: '💪 멋진 시작! 계속 전진!',
        CoachingStyle.analytical: '[분석] 초기 패턴 감지',
      },
      'detailed_analysis': {
        CoachingStyle.strict: '재무 분석 리포트',
        CoachingStyle.kind: '💰 상세 가계부 분석 결과예요!',
        CoachingStyle.friendly: '💸 자, 분석 결과 나왔어!',
        CoachingStyle.motivational: '🎯 당신의 재무 현황 분석!',
        CoachingStyle.analytical: '[종합] 소비 패턴 분석 결과',
      },
    };

    return titles[scenario]?[style] ?? '가계부 분석';
  }

  /// 첫 거래 메시지 생성
  String _generateFirstTransactionMessage(
    CoachingStyle style,
    double amount,
    String category,
  ) {
    final formattedAmount = _formatCurrency(amount);

    switch (style) {
      case CoachingStyle.strict:
        return '첫 거래 ${formattedAmount}원이 ${category}로 기록되었습니다. 매일 꾸준히 기록하십시오.';

      case CoachingStyle.kind:
        return '첫 거래를 기록하셨네요! ${formattedAmount}원을 ${category}에 사용하셨어요. 정말 좋은 시작이에요! 😊';

      case CoachingStyle.friendly:
        return '오! 첫 거래 완료! ${category}에 ${formattedAmount}원 썼구나! 이제 계속 기록하면서 어디에 돈 쓰는지 파악해보자! 💪';

      case CoachingStyle.motivational:
        return '🔥 축하합니다! 첫 거래 기록으로 재무 관리의 첫 발을 내디뎠습니다! ${category}에 ${formattedAmount}원을 지출했네요. 이제 매일 기록하면서 절약 챔피언이 되어봅시다!';

      case CoachingStyle.analytical:
        return '[데이터] 초기 거래 등록 완료. 카테고리: ${category}, 금액: ${formattedAmount}원. 통계 분석을 위해 최소 7일간 데이터 축적이 필요합니다.';
    }
  }

  /// 첫 거래 액션 아이템 생성
  List<String> _getFirstTransactionActions(
    CoachingStyle style,
    String category,
  ) {
    switch (style) {
      case CoachingStyle.strict:
        return [
          '오늘 남은 거래를 모두 기록할 것',
          '${category} 카테고리의 불필요한 지출 점검',
          '주간 기록 목표 설정',
        ];

      case CoachingStyle.kind:
        return [
          '오늘 남은 지출들도 기록해보세요 📝',
          '${category}에서 조금씩 절약해볼까요?',
          '일주일 동안 꾸준히 기록하면 패턴을 볼 수 있어요!',
        ];

      case CoachingStyle.friendly:
        return [
          '오늘 더 쓴 거 있으면 바로바로 적어!',
          '${category} 비용 줄일 방법 생각해봐',
          '일주일만 꾸준히 해보자, 할 수 있어!',
        ];

      case CoachingStyle.motivational:
        return [
          '🎯 오늘의 모든 거래를 기록하여 완벽한 하루를 만드세요!',
          '💡 ${category} 지출을 20% 줄이는 것을 목표로!',
          '🔥 7일 연속 기록 달성에 도전하세요!',
        ];

      case CoachingStyle.analytical:
        return [
          '[액션1] 일일 거래 완전 기록 (정확도 향상)',
          '[액션2] ${category} 지출 패턴 모니터링',
          '[액션3] 7일 데이터 수집 완료 목표',
        ];
    }
  }

  /// 초기 단계 (거래 2-4건) 메시지 생성
  String _generateEarlyStageMessage(
    CoachingStyle style,
    int transactionCount,
    double totalSpending,
    String topCategory,
  ) {
    final formattedAmount = _formatCurrency(totalSpending);

    switch (style) {
      case CoachingStyle.strict:
        return '총 ${transactionCount}건의 거래가 기록되었습니다. ${formattedAmount}원을 지출했으며, ${topCategory}에 가장 많이 사용했습니다. 꾸준한 기록을 유지하십시오.';

      case CoachingStyle.kind:
        return '벌써 ${transactionCount}건이나 기록하셨네요! 정말 잘하고 계세요! 😊 총 ${formattedAmount}원을 지출하셨고, ${topCategory}에 가장 많이 쓰셨어요. 조금만 더 기록하면 더 자세한 분석을 받을 수 있어요!';

      case CoachingStyle.friendly:
        return '오 꽤 괜찮은데? ${transactionCount}건 기록했네! ${topCategory}에 ${formattedAmount}원 썼구나. 이 페이스 유지하면서 일주일만 더 꾸준히 해보자!';

      case CoachingStyle.motivational:
        return '🔥 훌륭합니다! 이미 ${transactionCount}건의 거래를 기록했어요! 총 ${formattedAmount}원의 지출 패턴이 보이기 시작했습니다. ${topCategory} 카테고리가 선두네요! 이 열정으로 계속 달려봅시다! 💪';

      case CoachingStyle.analytical:
        return '[초기 분석] 거래 수: ${transactionCount}건, 총 지출: ${formattedAmount}원. 주요 카테고리: ${topCategory}. 통계적 유의성 확보를 위해 최소 5건 이상의 데이터 필요. 현재 데이터 수집률: ${(transactionCount / 5 * 100).toInt()}%.';
    }
  }

  /// 초기 단계 액션 아이템 생성
  List<String> _getEarlyStageActions(
    CoachingStyle style,
    String category,
  ) {
    switch (style) {
      case CoachingStyle.strict:
        return [
          '하루 최소 3-5건의 거래 기록 의무화',
          '${category} 지출 즉시 삭감 검토',
          '1주일 데이터 축적 완료',
        ];

      case CoachingStyle.kind:
        return [
          '하루에 3-5건 정도 편하게 기록해보세요 😊',
          '${category} 지출을 조금씩 줄여볼까요?',
          '1주일만 더 기록하면 상세 분석이 가능해져요!',
        ];

      case CoachingStyle.friendly:
        return [
          '하루 3-5건씩만 적어봐, 어렵지 않아!',
          '${category} 좀 줄여볼까? 작은 것부터!',
          '일주일만 더 하면 진짜 제대로 된 분석 나와!',
        ];

      case CoachingStyle.motivational:
        return [
          '🎯 하루 3-5건 기록으로 재무 관리 달인 되기!',
          '💡 ${category} 지출 20% 절감 도전!',
          '🔥 7일 연속 완벽 기록으로 절약 챔피언 등극!',
        ];

      case CoachingStyle.analytical:
        return [
          '[목표] 일일 3-5건 기록으로 표본 크기 확보',
          '[분석] ${category} 지출 패턴 모니터링 시작',
          '[마일스톤] 7일 데이터 수집 → 통계 분석 가능',
        ];
    }
  }

  /// 상세 분석 (거래 5건 이상) 메시지 생성
  String _generateDetailedAnalysisMessage(
    CoachingStyle style,
    int transactionCount,
    double totalSpending,
    double dailyAverage,
    String topCategory,
  ) {
    final formattedTotal = _formatCurrency(totalSpending);
    final formattedDaily = _formatCurrency(dailyAverage);

    switch (style) {
      case CoachingStyle.strict:
        return '${transactionCount}건의 거래가 분석되었습니다. 총 지출액 ${formattedTotal}원, 일평균 ${formattedDaily}원입니다. ${topCategory}에 가장 많이 지출했습니다. 지출 관리를 강화하십시오.';

      case CoachingStyle.kind:
        return '와! ${transactionCount}건이나 꾸준히 기록하셨네요! 정말 대단해요! 🎉 총 ${formattedTotal}원을 지출하셨고, 하루 평균 ${formattedDaily}원이에요. ${topCategory}에 가장 많이 쓰셨는데, 조금씩 줄여나가면 좋을 것 같아요!';

      case CoachingStyle.friendly:
        return '오 진짜 잘하고 있어! ${transactionCount}건 기록 완료! ${topCategory}에 제일 많이 썼는데 총 ${formattedTotal}원이야. 하루 평균 ${formattedDaily}원 정도 쓰는구나. 이제 본격적으로 절약 시작해볼까?';

      case CoachingStyle.motivational:
        return '🔥 환상적입니다! ${transactionCount}건의 완벽한 기록! 당신의 재무 현황이 명확하게 보입니다! 총 ${formattedTotal}원 지출, 일평균 ${formattedDaily}원! ${topCategory}가 주요 지출처네요. 이제 최적화 단계로 돌입합시다! 💪';

      case CoachingStyle.analytical:
        return '[상세 분석 결과] 표본 크기: ${transactionCount}건 (통계적 유의성 확보). 총 지출: ${formattedTotal}원, 일평균: ${formattedDaily}원. 주요 지출 카테고리: ${topCategory}. 패턴 분석 완료, 최적화 권장사항 생성 가능.';
    }
  }

  /// 상세 분석 액션 아이템 생성
  List<String> _getDetailedAnalysisActions(
    CoachingStyle style,
    String topCategory,
    double dailyAverage,
  ) {
    final targetAmount = _formatCurrency(dailyAverage * 0.8);

    switch (style) {
      case CoachingStyle.strict:
        return [
          '${topCategory}에서 즉시 20% 지출 삭감',
          '일일 예산 ${targetAmount}로 강제 제한',
          '주간 가계부 점검 의무화',
        ];

      case CoachingStyle.kind:
        return [
          '${topCategory}에서 조금씩 절약해볼까요? 20% 목표로요! 😊',
          '하루 예산을 ${targetAmount} 정도로 맞춰보시는 건 어떨까요?',
          '매주 가계부를 가볍게 리뷰해보세요!',
        ];

      case CoachingStyle.friendly:
        return [
          '${topCategory} 좀 줄여보자! 20%만 줄이면 돼!',
          '하루 ${targetAmount} 안으로 써보는 거 도전해볼래?',
          '주말마다 가계부 확인하는 습관 만들자!',
        ];

      case CoachingStyle.motivational:
        return [
          '🎯 ${topCategory} 지출 20% 절감 미션 시작!',
          '💡 일일 예산 ${targetAmount} 달성으로 절약 왕 등극!',
          '🔥 주간 가계부 리뷰로 완벽한 재무 관리 체계 구축!',
        ];

      case CoachingStyle.analytical:
        return [
          '[최적화1] ${topCategory} 지출 20% 감축 (효율성 개선)',
          '[목표2] 일일 예산 ${targetAmount} 설정 (지출 통제)',
          '[습관3] 주간 단위 데이터 리뷰 (지속 가능성 확보)',
        ];
    }
  }
}
