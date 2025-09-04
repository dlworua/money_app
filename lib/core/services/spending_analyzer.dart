import '../../data/models/user_model.dart';
import '../../data/models/saving_record.dart';

class SpendingAnalyzer {
  static const int _analysisWindowDays = 30;
  static const double _significantChangeThreshold = 0.2; // 20% 변화

  /// 사용자의 소비 패턴을 종합 분석
  SpendingAnalysis analyzeSpendingPattern(UserModel user) {
    final records = user.savingRecords;
    final now = DateTime.now();
    
    // 최근 30일 데이터만 분석
    final recentRecords = records.where((record) {
      return now.difference(record.date).inDays <= _analysisWindowDays;
    }).toList();

    return SpendingAnalysis(
      userId: user.id,
      analyzedAt: now,
      totalRecords: recentRecords.length,
      categoryInsights: _analyzeCategoryPatterns(recentRecords),
      timePatterns: _analyzeTimePatterns(recentRecords),
      goalProgress: _analyzeGoalProgress(user),
      streakAnalysis: _analyzeStreakPattern(user),
      recommendations: _generateRecommendations(user, recentRecords),
    );
  }

  /// 카테고리별 소비 패턴 분석
  Map<String, CategoryInsight> _analyzeCategoryPatterns(List<SavingRecord> records) {
    final categoryMap = <String, List<SavingRecord>>{};
    
    for (final record in records) {
      categoryMap.putIfAbsent(record.category, () => []).add(record);
    }

    final insights = <String, CategoryInsight>{};
    
    for (final entry in categoryMap.entries) {
      final category = entry.key;
      final categoryRecords = entry.value;
      
      final totalAmount = categoryRecords.fold<double>(0, (sum, record) => sum + record.amount);
      final averageAmount = totalAmount / categoryRecords.length;
      final frequency = categoryRecords.length;
      
      // 최근 2주 vs 이전 2주 비교
      final midPoint = DateTime.now().subtract(const Duration(days: 15));
      final recentRecords = categoryRecords.where((r) => r.date.isAfter(midPoint)).toList();
      final olderRecords = categoryRecords.where((r) => r.date.isBefore(midPoint)).toList();
      
      final recentAvg = recentRecords.isEmpty ? 0.0 : 
        recentRecords.fold<double>(0, (sum, r) => sum + r.amount) / recentRecords.length;
      final olderAvg = olderRecords.isEmpty ? 0.0 : 
        olderRecords.fold<double>(0, (sum, r) => sum + r.amount) / olderRecords.length;
      
      final changeRate = olderAvg == 0 ? 0.0 : (recentAvg - olderAvg) / olderAvg;
      
      insights[category] = CategoryInsight(
        category: category,
        totalAmount: totalAmount,
        averageAmount: averageAmount,
        frequency: frequency,
        changeRate: changeRate,
        trend: _determineTrend(changeRate),
      );
    }
    
    return insights;
  }

  /// 시간대별 패턴 분석
  TimePatternInsight _analyzeTimePatterns(List<SavingRecord> records) {
    final weekdayRecords = records.where((r) => r.date.weekday <= 5).length;
    final weekendRecords = records.where((r) => r.date.weekday > 5).length;
    
    final hourCounts = <int, int>{};
    for (final record in records) {
      final hour = record.date.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    final peakHour = hourCounts.entries.isEmpty ? 12 : 
      hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    return TimePatternInsight(
      weekdayFrequency: weekdayRecords,
      weekendFrequency: weekendRecords,
      peakHour: peakHour,
      mostActiveDay: _findMostActiveDay(records),
    );
  }

  /// 목표 달성도 분석
  GoalProgressInsight _analyzeGoalProgress(UserModel user) {
    final progressRate = user.monthlyGoal == 0 ? 0.0 : user.currentMonthSaved / user.monthlyGoal;
    final daysInMonth = DateTime.now().day;
    final expectedProgress = daysInMonth / DateTime.now().day; // 현재까지 예상 진행률
    
    return GoalProgressInsight(
      currentProgress: progressRate,
      expectedProgress: expectedProgress,
      isOnTrack: progressRate >= expectedProgress * 0.8, // 80% 이상이면 잘 하고 있음
      daysRemaining: DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day - DateTime.now().day,
      amountNeeded: user.monthlyGoal - user.currentMonthSaved,
    );
  }

  /// 연속 기록 패턴 분석
  StreakInsight _analyzeStreakPattern(UserModel user) {
    final currentStreak = user.consecutiveDays;
    final personalBest = user.achievements2['longest_streak'] ?? 0;
    
    return StreakInsight(
      currentStreak: currentStreak,
      personalBest: personalBest,
      isNewRecord: currentStreak > personalBest,
      motivation: _getStreakMotivation(currentStreak),
    );
  }

  /// 개선 권장사항 생성
  List<String> _generateRecommendations(UserModel user, List<SavingRecord> records) {
    final recommendations = <String>[];
    
    // 목표 진행도 기반 권장사항
    final progress = user.currentMonthSaved / user.monthlyGoal;
    if (progress < 0.5 && DateTime.now().day > 15) {
      recommendations.add('월 목표 달성을 위해 절약 노력을 더 기울여보세요');
    }
    
    // 카테고리 기반 권장사항
    final categoryInsights = _analyzeCategoryPatterns(records);
    if (categoryInsights.entries.isNotEmpty) {
      final highestSpendingCategory = categoryInsights.entries
          .reduce((a, b) => a.value.totalAmount > b.value.totalAmount ? a : b);
      
      if (highestSpendingCategory.value.changeRate > _significantChangeThreshold) {
        recommendations.add('${highestSpendingCategory.key} 지출이 최근 증가했어요. 관리해보세요');
      }
    }
    
    // 연속 기록 기반 권장사항
    if (user.consecutiveDays == 0) {
      recommendations.add('오늘부터 다시 시작해보세요! 작은 절약부터');
    } else if (user.consecutiveDays >= 7) {
      recommendations.add('훌륭한 연속 기록이에요! 계속 유지해보세요');
    }
    
    return recommendations;
  }

  SpendingTrend _determineTrend(double changeRate) {
    if (changeRate > _significantChangeThreshold) {
      return SpendingTrend.increasing;
    } else if (changeRate < -_significantChangeThreshold) {
      return SpendingTrend.decreasing;
    } else {
      return SpendingTrend.stable;
    }
  }

  int _findMostActiveDay(List<SavingRecord> records) {
    final dayCounts = <int, int>{};
    for (final record in records) {
      final day = record.date.weekday;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    
    return dayCounts.entries.isEmpty ? 1 : 
      dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _getStreakMotivation(int streak) {
    if (streak == 0) return '새로운 시작을 응원합니다!';
    if (streak < 7) return '좋은 시작이에요!';
    if (streak < 30) return '훌륭한 습관이 만들어지고 있어요!';
    return '정말 대단한 성취입니다!';
  }
}

// 분석 결과 데이터 클래스들
class SpendingAnalysis {
  final String userId;
  final DateTime analyzedAt;
  final int totalRecords;
  final Map<String, CategoryInsight> categoryInsights;
  final TimePatternInsight timePatterns;
  final GoalProgressInsight goalProgress;
  final StreakInsight streakAnalysis;
  final List<String> recommendations;

  const SpendingAnalysis({
    required this.userId,
    required this.analyzedAt,
    required this.totalRecords,
    required this.categoryInsights,
    required this.timePatterns,
    required this.goalProgress,
    required this.streakAnalysis,
    required this.recommendations,
  });
}

class CategoryInsight {
  final String category;
  final double totalAmount;
  final double averageAmount;
  final int frequency;
  final double changeRate;
  final SpendingTrend trend;

  const CategoryInsight({
    required this.category,
    required this.totalAmount,
    required this.averageAmount,
    required this.frequency,
    required this.changeRate,
    required this.trend,
  });
}

class TimePatternInsight {
  final int weekdayFrequency;
  final int weekendFrequency;
  final int peakHour;
  final int mostActiveDay;

  const TimePatternInsight({
    required this.weekdayFrequency,
    required this.weekendFrequency,
    required this.peakHour,
    required this.mostActiveDay,
  });
}

class GoalProgressInsight {
  final double currentProgress;
  final double expectedProgress;
  final bool isOnTrack;
  final int daysRemaining;
  final double amountNeeded;

  const GoalProgressInsight({
    required this.currentProgress,
    required this.expectedProgress,
    required this.isOnTrack,
    required this.daysRemaining,
    required this.amountNeeded,
  });
}

class StreakInsight {
  final int currentStreak;
  final int personalBest;
  final bool isNewRecord;
  final String motivation;

  const StreakInsight({
    required this.currentStreak,
    required this.personalBest,
    required this.isNewRecord,
    required this.motivation,
  });
}

enum SpendingTrend {
  increasing,
  decreasing,
  stable,
}