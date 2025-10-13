import '../../data/models/user_model.dart';
import '../../data/models/ai_coaching_insight.dart';
import '../../data/models/transaction.dart';
import '../../data/models/budget.dart';
import '../enums/coaching_style.dart';
import 'ai_coach_generator.dart';
import 'financial_analysis_service.dart';

/// 고급 AI 코칭 서비스 - 소비 기록 연동 및 실질적 조언 제공
class AdvancedAiCoachingService {
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
      },
      confidenceScore: 0.9,
      actionItems: _getSpecificAdviceForCategory(categoryEnum, categoryData['actualSpending'], 0),
    );
  }

  /// 데이터 기반 코칭 생성 (실질적 조언 포함)
  Future<AiCoachingInsight> _generateDataDrivenCoaching(
    UserModel user,
    Map<String, dynamic> spendingAnalysis,
    Map<String, dynamic> budgetAnalysis,
    List<Map<String, dynamic>> opportunities,
  ) async {
    // 가장 중요한 인사이트 선택 + 구체적 조언 추가
    String title;
    String message;
    List<String> actionItems = [];
    InsightType type = InsightType.general;
    
    // 실질적 조언을 위한 데이터 분석
    final totalSpending = spendingAnalysis['totalSpending'] ?? 0.0;
    final dailyAverage = spendingAnalysis['dailyAverage'] ?? 0.0;
    final topCategory = spendingAnalysis['topCategory'];
    final spendingTrend = spendingAnalysis['spendingTrend'] ?? 0.0;
    
    if (opportunities.isNotEmpty) {
      final topOpportunity = opportunities.first;
      title = '💡 절약 기회 발견!';
      message = topOpportunity['message'];
      actionItems.add(topOpportunity['suggestion']);
      
      // 기존 메시지에 구체적 조언 추가
      if (topCategory != null) {
        actionItems.addAll(_getSpecificAdviceForCategory(topCategory, totalSpending, dailyAverage));
      }
      type = InsightType.spendingPattern;
    } else if (spendingTrend > 0.2) {
      title = '📈 지출 증가 알림';
      message = '최근 지출이 ${(spendingTrend * 100).toInt()}% 증가했어요. ';
      message += '이번 달 총 ${_formatCurrency(totalSpending)} 지출하셨고, 하루 평균 ${_formatCurrency(dailyAverage)}입니다.';
      
      // 지출 증가시 구체적 대응 방안
      actionItems.addAll([
        '가장 큰 지출 카테고리부터 30% 줄여보기',
        '일주일간 매일 가계부 작성해서 새는 돈 찾기',
        '구독 서비스나 정기 결제 재점검하기'
      ]);
      type = InsightType.warning;
    } else if (spendingAnalysis['isEmpty'] != true) {
      title = '📊 가계부 현황';
      message = '이번 달 총 ${_formatCurrency(totalSpending)} 지출하셨고, 하루 평균 ${_formatCurrency(dailyAverage)} 정도 사용하고 계세요. ';
      
      if (topCategory != null) {
        final categoryName = _getCategoryDisplayName(topCategory);
        message += '$categoryName에 가장 많이 지출하고 계시네요.';
        
        // 최고 지출 카테고리별 맞춤 조언
        actionItems.addAll(_getSpecificAdviceForCategory(topCategory, totalSpending, dailyAverage));
      } else {
        message += '현재 재정 관리를 잘하고 계시네요!';
        actionItems.addAll([
          '꾸준한 가계부 작성으로 더 정확한 분석 받기',
          '월별 예산 설정해서 목표 관리하기',
          '저축 자동이체 설정해보기'
        ]);
      }
      type = InsightType.general;
    } else {
      // 데이터가 없는 경우 기본 조언
      title = '📝 가계부 시작하기';
      message = '아직 거래 기록이 부족해요. 지출을 기록해주시면 맞춤형 조언을 드릴 수 있어요!';
      actionItems.addAll([
        '오늘부터 모든 지출 기록해보기',
        '카테고리별로 분류해서 입력하기',
        '일주일만 꾸준히 해보세요!'
      ]);
      type = InsightType.general;
    }
    
    return AiCoachingInsight(
      id: 'advanced_coaching_${DateTime.now().millisecondsSinceEpoch}',
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

  /// 통화 포맷 헬퍼 메서드
  String _formatCurrency(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toInt()}만원';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toInt()}천원';
    } else {
      return '${amount.toInt()}원';
    }
  }

  /// 카테고리 표시명 가져오기
  String _getCategoryDisplayName(TransactionCategory category) {
    return category.displayName;
  }

  /// 카테고리별 구체적인 조언 제공
  List<String> _getSpecificAdviceForCategory(TransactionCategory category, double totalAmount, double dailyAverage) {
    switch (category) {
      case TransactionCategory.food:
        return [
          '주 2회 집에서 도시락 만들어 가기',
          '대용량 할인마트에서 식재료 구매하기',
          '배달음식 대신 간단한 요리 3개 레시피 배우기'
        ];
        
      case TransactionCategory.transport:
        return [
          '대중교통 정기권 vs 건별 결제 비용 비교해보기',
          '1km 이내 거리는 걷거나 자전거 이용하기',
          '카풀 앱이나 동료와 함께 출퇴근하기'
        ];
        
      case TransactionCategory.shopping:
        return [
          '쇼핑 전 리스트 작성하고 예산 정하기',
          '온라인 장바구니 24시간 후 재검토하기',
          '중고거래 앱에서 먼저 찾아보기'
        ];
        
      case TransactionCategory.entertainment:
        return [
          '구독 서비스 2개 이상이면 가족 공유로 전환',
          '도서관, 공원 등 무료 문화시설 이용하기',
          'OTT 서비스 돌아가며 1개월씩만 구독하기'
        ];
        
      case TransactionCategory.utilities:
        return [
          '전기, 가스 요금 절약 습관 점검하기',
          '에너지 효율 등급 높은 가전제품 사용하기',
          '사용하지 않는 전자기기 플러그 뽑기'
        ];
        
      default:
        return [
          '해당 카테고리 세부 항목별 필요도 평가하기',
          '비슷한 기능의 더 저렴한 대안 찾아보기',
          '구매 전 3일 고민 시간 갖기'
        ];
    }
  }

  /// 신뢰도 점수 계산
  double _getConfidenceScore(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 0.9;
      case 'medium':
        return 0.7;
      case 'low':
        return 0.5;
      default:
        return 0.6;
    }
  }

  /// HomeViewModel에서 사용하는 추가 메서드들
  List<AiCoachingInsight> getRecentInsights(UserModel user, {int limit = 5}) {
    return user.coachingInsights.take(limit).toList();
  }

  UserModel updateCoachingStyle(UserModel user, CoachingStyle style) {
    return user.copyWith(preferredCoachingStyle: style);
  }

  UserModel addCoachingInsight(UserModel user, AiCoachingInsight insight) {
    final insights = [insight, ...user.coachingInsights];
    return user.copyWith(coachingInsights: insights);
  }

  Future<AiCoachingInsight> generateAchievementCelebration(UserModel user, String achievement) async {
    return AiCoachingInsight(
      id: 'achievement_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      style: user.preferredCoachingStyle,
      title: '🎉 축하합니다!',
      message: '$achievement을 달성하셨네요! 정말 훌륭합니다!',
      type: InsightType.achievement,
      actionItems: ['이 성취를 바탕으로 더 큰 목표에 도전해보세요!'],
      confidenceScore: 1.0,
      analysisData: {'achievement': achievement},
    );
  }

  Future<AiCoachingInsight> generateUrgentWarning(UserModel user, String warning) async {
    return AiCoachingInsight(
      id: 'warning_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      style: user.preferredCoachingStyle,
      title: '⚠️ 주의 필요',
      message: warning,
      type: InsightType.warning,
      actionItems: ['즉시 지출 패턴을 점검해보세요'],
      confidenceScore: 0.9,
      analysisData: {'warning': warning},
    );
  }

  Future<AiCoachingInsight?> generateWeeklyReview(UserModel user) async {
    return AiCoachingInsight(
      id: 'weekly_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      style: user.preferredCoachingStyle,
      title: '📊 주간 리뷰',
      message: '이번 주 절약 현황을 정리해드렸습니다.',
      type: InsightType.general,
      actionItems: ['다음 주 계획을 세워보세요'],
      confidenceScore: 0.8,
      analysisData: {'type': 'weekly_review'},
    );
  }

  UserModel markInsightAsRead(UserModel user, String insightId) {
    final insights = user.coachingInsights.map((insight) {
      if (insight.id == insightId) {
        return insight.copyWith(isRead: true);
      }
      return insight;
    }).toList();
    return user.copyWith(coachingInsights: insights);
  }

  UserModel updateCoachingSettings(UserModel user, {bool? enableDailyCoaching, bool? enableWeeklyReview}) {
    return user.copyWith(
      enableDailyCoaching: enableDailyCoaching ?? user.enableDailyCoaching,
    );
  }

  Map<String, dynamic> getCoachingStats(UserModel user) {
    final totalInsights = user.coachingInsights.length;
    final unreadCount = user.coachingInsights.where((i) => !i.isRead).length;
    return {
      'totalInsights': totalInsights,
      'unreadCount': unreadCount,
      'readRate': totalInsights > 0 ? (totalInsights - unreadCount) / totalInsights : 0.0,
    };
  }

  int getUnreadInsightCount(UserModel user) {
    return user.coachingInsights.where((i) => !i.isRead).length;
  }
}