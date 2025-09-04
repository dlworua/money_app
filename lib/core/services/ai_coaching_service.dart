import '../../data/models/user_model.dart';
import '../../data/models/ai_coaching_insight.dart';
import '../../data/models/transaction.dart';
import '../../data/models/budget.dart';
import '../enums/coaching_style.dart';
import 'ai_coach_generator.dart';
import 'financial_analysis_service.dart';

class AiCoachingService {
  final AiCoachGenerator _generator = AiCoachGenerator();
  final FinancialAnalysisService _analysisService = FinancialAnalysisService();
  
  /// 가계부 데이터 기반 맞춤 코칭 제공
  Future<AiCoachingInsight> getFinancialCoaching(
    UserModel user, 
    List<Transaction> transactions,
    List<Budget> budgets
  ) async {
    // 재무 데이터 분석
    final spendingAnalysis = _analysisService.analyzeSpendingPattern(transactions);
    final budgetAnalysis = _analysisService.analyzeBudgetPerformance(transactions, budgets);
    final opportunities = _analysisService.findSavingOpportunities(transactions, budgets);
    
    // 분석 결과를 바탕으로 코칭 생성
    return await _generateDataDrivenCoaching(
      user, 
      spendingAnalysis, 
      budgetAnalysis, 
      opportunities
    );
  }
  
  /// 절약 기회 알림
  Future<List<AiCoachingInsight>> getSavingOpportunityAlerts(
    UserModel user,
    List<Transaction> transactions, 
    List<Budget> budgets
  ) async {
    final opportunities = _analysisService.findSavingOpportunities(transactions, budgets);
    final alerts = <AiCoachingInsight>[];
    
    for (final opportunity in opportunities.take(3)) { // 상위 3개만
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
  
  /// 예산 초과 경고
  Future<AiCoachingInsight?> getBudgetOverspendAlert(
    UserModel user,
    List<Transaction> transactions,
    List<Budget> budgets
  ) async {
    final budgetAnalysis = _analysisService.analyzeBudgetPerformance(transactions, budgets);
    
    // 가장 심각한 예산 초과 찾기
    String? worstCategory;
    double worstOverspend = 0;
    
    budgetAnalysis.forEach((category, data) {
      if (data['isOverBudget'] && data['actualSpending'] - data['budgetAmount'] > worstOverspend) {
        worstCategory = category;
        worstOverspend = data['actualSpending'] - data['budgetAmount'];
      }
    });
    
    if (worstCategory == null) return null;
    
    final categoryData = budgetAnalysis[worstCategory];
    final categoryEnum = TransactionCategory.values.byName(worstCategory!);
    
    return AiCoachingInsight(
      id: 'budget_alert_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      style: user.preferredCoachingStyle,
      title: '⚠️ ${categoryEnum.displayName} 예산 초과 알림',
      message: '이달 ${categoryEnum.displayName} 예산 ${categoryData['budgetAmount'].toInt()}원을 '
               '${categoryData['spendingPercentage'].toInt()}% 사용했어요. '
               '${worstOverspend.toInt()}원 초과했습니다.',
      type: InsightType.warning,
      analysisData: {
        'category': worstCategory!,
        'budgetAmount': categoryData['budgetAmount'],
        'actualSpending': categoryData['actualSpending'],
        'overspendAmount': worstOverspend,
        'spendingPercentage': categoryData['spendingPercentage'],
      },
      confidenceScore: 0.95, // 예산 초과는 확실한 데이터
      actionItems: [
        '남은 기간 동안 일일 ${categoryData['recommendedDailySpend'].toInt()}원 이하로 지출을 제한해보세요.',
        '${categoryEnum.displayName} 카테고리에서 불필요한 지출을 줄여보세요.',
      ],
    );
  }
  
  /// 월말 재무 리포트
  Future<AiCoachingInsight> getMonthlyFinancialReport(
    UserModel user,
    List<Transaction> transactions,
    List<Budget> budgets
  ) async {
    final spendingAnalysis = _analysisService.analyzeSpendingPattern(transactions, days: 30);
    final budgetAnalysis = _analysisService.analyzeBudgetPerformance(transactions, budgets);
    final savingGoals = _analysisService.generateSavingGoals(transactions, budgets, 0.1); // 기본 10% 저축률
    
    if (spendingAnalysis['isEmpty'] == true) {
      return AiCoachingInsight(
        id: 'monthly_report_empty_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        style: user.preferredCoachingStyle,
        title: '📊 이달의 가계부 현황',
        message: '아직 충분한 거래 데이터가 없어요. 가계부를 더 작성해주시면 맞춤 분석을 제공할게요!',
        type: InsightType.general,
        analysisData: {},
        confidenceScore: 1.0,
        actionItems: ['수입과 지출을 꾸준히 기록해보세요.'],
      );
    }
    
    final monthlySpending = spendingAnalysis['totalSpending'];
    final dailyAverage = spendingAnalysis['dailyAverage'];
    final topCategory = spendingAnalysis['topCategory'] as TransactionCategory;
    final spendingTrend = spendingAnalysis['spendingTrend'];
    
    String trendMessage;
    if (spendingTrend > 0.1) {
      trendMessage = '지난 주 대비 ${(spendingTrend * 100).toInt()}% 증가했어요. 지출을 점검해보세요.';
    } else if (spendingTrend < -0.1) {
      trendMessage = '지난 주 대비 ${(-spendingTrend * 100).toInt()}% 절약했어요! 👏';
    } else {
      trendMessage = '지출이 안정적으로 유지되고 있어요.';
    }
    
    final message = '이달 총 ${monthlySpending.toInt()}원 지출했어요. '
                   '일평균 ${dailyAverage.toInt()}원이며, '
                   '${topCategory.displayName}에 가장 많이 썼어요. $trendMessage';
    
    return AiCoachingInsight(
      id: 'monthly_report_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      style: user.preferredCoachingStyle,
      title: '📊 이달의 가계부 현황',
      message: message,
      type: InsightType.monthlyReview,
      analysisData: {
        'monthlySpending': monthlySpending,
        'dailyAverage': dailyAverage,
        'topCategory': topCategory.name,
        'spendingTrend': spendingTrend,
        'budgetAnalysis': budgetAnalysis,
        'savingGoals': savingGoals,
      },
      confidenceScore: 0.9,
      actionItems: _getReportActionSuggestions(savingGoals, topCategory),
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
    
    return insight.copyWith(
      title: '⚠️ 목표 달성 위험',
      type: InsightType.warning,
    );
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
    final hoursSinceLastCoaching = now.difference(user.lastCoachingDate!).inHours;
    
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
    
    final avgConfidence = insights.fold<double>(
      0,
      (sum, insight) => sum + insight.confidenceScore,
    ) / insights.length;
    
    final typeCounts = <InsightType, int>{};
    for (final insight in insights) {
      typeCounts[insight.type] = (typeCounts[insight.type] ?? 0) + 1;
    }
    
    final mostCommonType = typeCounts.entries.isEmpty 
        ? InsightType.general
        : typeCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
    
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
    TransactionCategory topCategory
  ) {
    final suggestions = <String>[];
    
    // 절약 목표가 있는 경우
    if (savingGoals['cannotAnalyze'] != true) {
      final goals = savingGoals['goals'] as Map<String, dynamic>;
      final conservativeGoal = goals['conservative'] as Map<String, dynamic>;
      
      suggestions.add(
        '이달 ${conservativeGoal['amount'].toInt()}원(${conservativeGoal['percentage']}%) 절약을 목표로 해보세요.'
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
  
  /// 데이터 기반 코칭 생성
  Future<AiCoachingInsight> _generateDataDrivenCoaching(
    UserModel user,
    Map<String, dynamic> spendingAnalysis,
    Map<String, dynamic> budgetAnalysis,
    List<Map<String, dynamic>> opportunities,
  ) async {
    // 가장 중요한 인사이트 선택
    String title;
    String message;
    List<String> actionItems = [];
    InsightType type = InsightType.general;
    
    if (opportunities.isNotEmpty) {
      final topOpportunity = opportunities.first;
      title = '💡 절약 기회 발견!';
      message = topOpportunity['message'];
      actionItems.add(topOpportunity['suggestion']);
      type = InsightType.spendingPattern;
    } else if (spendingAnalysis['spendingTrend'] > 0.2) {
      title = '📈 지출 증가 알림';
      message = '최근 지출이 ${(spendingAnalysis['spendingTrend'] * 100).toInt()}% 증가했어요.';
      actionItems.add('지출 내역을 점검하고 불필요한 항목을 찾아보세요.');
      type = InsightType.warning;
    } else {
      title = '📊 가계부 현황';
      message = '현재 재정 관리를 잘하고 계시네요! 이 상태를 유지해보세요.';
      actionItems.add('꾸준한 가계부 작성으로 더 정확한 분석을 받아보세요.');
      type = InsightType.general;
    }
    
    return AiCoachingInsight(
      id: 'data_driven_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      style: user.preferredCoachingStyle,
      title: title,
      message: message,
      type: type,
      analysisData: {
        'spendingAnalysis': spendingAnalysis,
        'budgetAnalysis': budgetAnalysis,
        'opportunities': opportunities,
      },
      confidenceScore: 0.85,
      actionItems: actionItems,
    );
  }
}