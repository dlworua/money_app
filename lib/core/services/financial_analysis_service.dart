import '../../data/models/transaction.dart';
import '../../data/models/budget.dart';

class FinancialAnalysisService {
  // 지출 패턴 분석
  Map<String, dynamic> analyzeSpendingPattern(List<Transaction> transactions, {int days = 30}) {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: days));
    
    final recentTransactions = transactions.where(
      (t) => t.date.isAfter(cutoffDate) && t.type == TransactionType.expense,
    ).toList();
    
    if (recentTransactions.isEmpty) {
      return {'isEmpty': true};
    }
    
    // 카테고리별 지출 분석
    final categorySpending = <TransactionCategory, double>{};
    double totalSpending = 0;
    
    for (final transaction in recentTransactions) {
      categorySpending[transaction.category] = 
          (categorySpending[transaction.category] ?? 0) + transaction.amount;
      totalSpending += transaction.amount;
    }
    
    // 일일 평균 지출
    final dailyAverage = totalSpending / days;
    
    // 가장 많이 지출한 카테고리
    final topCategory = categorySpending.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    // 지출 변동성 계산 (최근 7일 vs 이전 7일)
    final recentWeek = recentTransactions
        .where((t) => t.date.isAfter(now.subtract(const Duration(days: 7))))
        .fold<double>(0, (sum, t) => sum + t.amount) / 7;
    
    final previousWeek = recentTransactions
        .where((t) => t.date.isBefore(now.subtract(const Duration(days: 7))) &&
                     t.date.isAfter(now.subtract(const Duration(days: 14))))
        .fold<double>(0, (sum, t) => sum + t.amount) / 7;
    
    final spendingTrend = previousWeek > 0 
        ? (recentWeek - previousWeek) / previousWeek 
        : 0.0;
    
    return {
      'totalSpending': totalSpending,
      'dailyAverage': dailyAverage,
      'topCategory': topCategory.key,
      'topCategoryAmount': topCategory.value,
      'topCategoryPercentage': (topCategory.value / totalSpending) * 100,
      'spendingTrend': spendingTrend,
      'categoryBreakdown': categorySpending,
      'transactionCount': recentTransactions.length,
    };
  }
  
  // 예산 대비 지출 분석
  Map<String, dynamic> analyzeBudgetPerformance(
    List<Transaction> transactions, 
    List<Budget> budgets
  ) {
    final analysis = <String, dynamic>{};
    final now = DateTime.now();
    
    for (final budget in budgets.where((b) => b.isActive)) {
      // 해당 예산 기간의 지출 계산
      final periodExpenses = transactions
          .where((t) => 
            t.type == TransactionType.expense &&
            t.category == budget.category &&
            t.date.isAfter(budget.startDate) &&
            t.date.isBefore(budget.endDate.add(const Duration(days: 1))))
          .fold<double>(0, (sum, t) => sum + t.amount);
      
      // 예산 진행률 계산
      final timeProgress = _calculateTimeProgress(budget.startDate, budget.endDate, now);
      final spendingRate = budget.amount > 0 ? (periodExpenses / budget.amount) : 0;
      
      // 예상 월말 지출
      final projectedSpending = timeProgress > 0 ? (periodExpenses / timeProgress) : 0;
      
      analysis[budget.category.name] = {
        'budgetAmount': budget.amount,
        'actualSpending': periodExpenses,
        'remainingBudget': budget.amount - periodExpenses,
        'spendingPercentage': (spendingRate * 100).clamp(0, 200),
        'timeProgress': timeProgress * 100,
        'isOverBudget': periodExpenses > budget.amount,
        'projectedSpending': projectedSpending,
        'willExceedBudget': projectedSpending > budget.amount,
        'recommendedDailySpend': _calculateRecommendedDailySpend(budget, periodExpenses, now),
      };
    }
    
    return analysis;
  }
  
  // 절약 기회 탐지
  List<Map<String, dynamic>> findSavingOpportunities(
    List<Transaction> transactions,
    List<Budget> budgets
  ) {
    final opportunities = <Map<String, dynamic>>[];
    final spendingAnalysis = analyzeSpendingPattern(transactions);
    
    if (spendingAnalysis['isEmpty'] == true) return opportunities;
    
    // 1. 예산 초과 카테고리
    final budgetAnalysis = analyzeBudgetPerformance(transactions, budgets);
    budgetAnalysis.forEach((category, data) {
      if (data['isOverBudget']) {
        opportunities.add({
          'type': 'budget_exceeded',
          'category': category,
          'priority': 'high',
          'title': '${TransactionCategory.values.byName(category).displayName} 예산 초과',
          'message': '이달 ${data['budgetAmount'].toInt()}원 예산을 ${(data['spendingPercentage']).toInt()}% 사용했어요.',
          'suggestion': '남은 기간 동안 일일 ${data['recommendedDailySpend'].toInt()}원 이하로 지출해보세요.',
          'potentialSaving': (data['actualSpending'] - data['budgetAmount']).abs(),
        });
      }
    });
    
    // 2. 급증한 카테고리
    final spendingTrend = spendingAnalysis['spendingTrend'] as double;
    
    if (spendingTrend > 0.2) { // 20% 이상 증가
      opportunities.add({
        'type': 'spending_spike',
        'priority': 'medium',
        'title': '지출이 급증했어요',
        'message': '지난 주 대비 ${(spendingTrend * 100).toInt()}% 지출이 늘었어요.',
        'suggestion': '가장 많이 늘어난 항목을 확인하고 필요없는 지출을 줄여보세요.',
        'potentialSaving': spendingAnalysis['dailyAverage'] * 7 * spendingTrend,
      });
    }
    
    // 3. 소액 다빈도 지출 패턴
    final smallFrequentExpenses = _findSmallFrequentExpenses(transactions);
    if (smallFrequentExpenses.isNotEmpty) {
      final totalSmallExpenses = smallFrequentExpenses.fold<double>(
        0, (sum, expense) => sum + expense['totalAmount']
      );
      
      opportunities.add({
        'type': 'small_frequent',
        'priority': 'low',
        'title': '소액 결제가 많아요',
        'message': '월 ${totalSmallExpenses.toInt()}원을 소액으로 자주 지출하고 있어요.',
        'suggestion': '카페, 편의점 등의 소액 지출을 줄이거나 계획적으로 구매해보세요.',
        'potentialSaving': totalSmallExpenses * 0.3, // 30% 절약 가능 추정
      });
    }
    
    // 우선순위 순으로 정렬
    opportunities.sort((a, b) {
      final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      return priorityOrder[a['priority']]!.compareTo(priorityOrder[b['priority']]!);
    });
    
    return opportunities;
  }
  
  // 개인화된 절약 목표 제안
  Map<String, dynamic> generateSavingGoals(
    List<Transaction> transactions,
    List<Budget> budgets,
    double currentSavingsRate
  ) {
    final spendingAnalysis = analyzeSpendingPattern(transactions);
    
    if (spendingAnalysis['isEmpty'] == true) {
      return {
        'cannotAnalyze': true,
        'message': '충분한 거래 데이터가 없어요. 가계부를 더 작성해주세요!'
      };
    }
    
    final monthlySpending = spendingAnalysis['dailyAverage'] * 30;
    final topCategory = spendingAnalysis['topCategory'] as TransactionCategory;
    final topCategoryAmount = spendingAnalysis['topCategoryAmount'] as double;
    
    // 달성 가능한 절약 목표 계산
    final conservativeGoal = monthlySpending * 0.05; // 5% 절약
    final moderateGoal = monthlySpending * 0.1;      // 10% 절약
    final ambitiousGoal = monthlySpending * 0.15;    // 15% 절약
    
    // 카테고리별 절약 전략
    final strategies = _generateCategoryStrategies(topCategory, topCategoryAmount);
    
    return {
      'monthlySpending': monthlySpending,
      'currentSavingsRate': currentSavingsRate,
      'goals': {
        'conservative': {
          'amount': conservativeGoal,
          'percentage': 5,
          'difficulty': '쉬움',
          'timeframe': '1개월',
        },
        'moderate': {
          'amount': moderateGoal,
          'percentage': 10,
          'difficulty': '보통',
          'timeframe': '2개월',
        },
        'ambitious': {
          'amount': ambitiousGoal,
          'percentage': 15,
          'difficulty': '도전적',
          'timeframe': '3개월',
        },
      },
      'topSpendingCategory': topCategory.displayName,
      'strategies': strategies,
    };
  }
  
  // 시간 진행률 계산
  double _calculateTimeProgress(DateTime start, DateTime end, DateTime now) {
    if (now.isBefore(start)) return 0.0;
    if (now.isAfter(end)) return 1.0;
    
    final totalDuration = end.difference(start).inDays;
    final passedDuration = now.difference(start).inDays;
    
    return totalDuration > 0 ? passedDuration / totalDuration : 1.0;
  }
  
  // 권장 일일 지출 계산
  double _calculateRecommendedDailySpend(Budget budget, double currentSpend, DateTime now) {
    final remainingDays = budget.endDate.difference(now).inDays.clamp(1, 365);
    final remainingBudget = (budget.amount - currentSpend).clamp(0, double.infinity);
    
    return remainingBudget / remainingDays;
  }
  
  // 소액 다빈도 지출 탐지
  List<Map<String, dynamic>> _findSmallFrequentExpenses(List<Transaction> transactions) {
    final smallExpenses = transactions
        .where((t) => t.type == TransactionType.expense && t.amount <= 10000) // 1만원 이하
        .toList();
    
    final categoryCount = <TransactionCategory, int>{};
    final categoryTotal = <TransactionCategory, double>{};
    
    for (final expense in smallExpenses) {
      categoryCount[expense.category] = (categoryCount[expense.category] ?? 0) + 1;
      categoryTotal[expense.category] = (categoryTotal[expense.category] ?? 0) + expense.amount;
    }
    
    return categoryCount.entries
        .where((entry) => entry.value >= 5) // 5회 이상
        .map((entry) => {
          'category': entry.key,
          'count': entry.value,
          'totalAmount': categoryTotal[entry.key]!,
          'averageAmount': categoryTotal[entry.key]! / entry.value,
        })
        .toList();
  }
  
  // 카테고리별 절약 전략 생성
  List<String> _generateCategoryStrategies(TransactionCategory category, double amount) {
    switch (category) {
      case TransactionCategory.food:
        return [
          '외식 횟수를 주 1-2회 줄여보세요',
          '집에서 도시락을 싸서 다니세요',
          '할인 마트나 새벽 배송을 활용해보세요',
          '요리 레시피를 배워서 직접 만들어보세요',
        ];
      case TransactionCategory.transport:
        return [
          '대중교통 정기권 구매를 고려해보세요',
          '가까운 거리는 걸어서 이동해보세요',
          '카풀이나 공유 모빌리티를 활용해보세요',
          '택시 대신 지하철/버스를 이용해보세요',
        ];
      case TransactionCategory.shopping:
        return [
          '쇼핑 목록을 미리 작성하고 계획적으로 구매하세요',
          '할인 쿠폰이나 적립금을 적극 활용하세요',
          '충동구매를 피하고 하루 정도 고민해보세요',
          '중고거래나 공유경제를 활용해보세요',
        ];
      case TransactionCategory.entertainment:
        return [
          '집에서 즐길 수 있는 취미를 찾아보세요',
          '무료 문화 행사나 전시를 이용해보세요',
          'OTT 서비스를 가족과 공유해보세요',
          '도서관이나 커뮤니티 센터를 활용해보세요',
        ];
      default:
        return [
          '해당 카테고리의 지출을 한 번 더 검토해보세요',
          '정말 필요한 지출인지 구분해보세요',
          '더 저렴한 대안이 있는지 찾아보세요',
          '구매 전 하루 정도 고민하는 습관을 만들어보세요',
        ];
    }
  }
}