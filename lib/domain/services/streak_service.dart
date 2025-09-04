import 'dart:math';
import '../../core/services/logger_service.dart';
import '../../data/models/user_model.dart';

class StreakService {
  /// 스트릭 콤보에 따른 보너스 계수 계산
  static double getStreakMultiplier(int consecutiveDays) {
    if (consecutiveDays < 3) return 1.0;
    if (consecutiveDays < 7) return 1.2;
    if (consecutiveDays < 14) return 1.5;
    if (consecutiveDays < 30) return 2.0;
    if (consecutiveDays < 60) return 2.5;
    if (consecutiveDays < 100) return 3.0;
    return 4.0; // 100일 이상은 최대 4배
  }

  /// 스트릭 단계별 이름
  static String getStreakTitle(int consecutiveDays) {
    if (consecutiveDays < 3) return '🌱 새싹 절약러';
    if (consecutiveDays < 7) return '🔥 열정 절약러';
    if (consecutiveDays < 14) return '⭐ 스타 절약러';
    if (consecutiveDays < 30) return '💎 다이아 절약러';
    if (consecutiveDays < 60) return '👑 마스터 절약러';
    if (consecutiveDays < 100) return '🏆 레전드 절약러';
    return '🌟 절약 신';
  }

  /// 다음 스트릭 단계까지 남은 일수
  static int getDaysToNextStreakLevel(int consecutiveDays) {
    final milestones = [3, 7, 14, 30, 60, 100];
    for (int milestone in milestones) {
      if (consecutiveDays < milestone) {
        return milestone - consecutiveDays;
      }
    }
    return 0; // 최고 단계 달성
  }

  /// 스트릭 보너스 포인트 계산
  static int calculateStreakBonus(double savingAmount, int consecutiveDays) {
    final multiplier = getStreakMultiplier(consecutiveDays);
    final basePoints = (savingAmount * 0.01).round(); // 절약 금액의 1%를 기본 포인트로
    final bonusPoints = (basePoints * (multiplier - 1.0)).round();
    
    LoggerService.info('Streak bonus: $consecutiveDays일 연속, ${multiplier}x 배수, ${bonusPoints}P 보너스');
    return bonusPoints;
  }

  /// 일일 콤보 시스템 - 하루에 여러 번 절약하면 추가 보너스
  static int calculateDailyComboBonus(int todaySavingCount) {
    if (todaySavingCount <= 1) return 0;
    if (todaySavingCount == 2) return 50;  // 2번째 절약
    if (todaySavingCount == 3) return 100; // 3번째 절약
    if (todaySavingCount == 4) return 200; // 4번째 절약
    return 300 + ((todaySavingCount - 4) * 100); // 5번째부터는 각각 100P씩 추가
  }

  /// 주간 완벽 달성 보너스 (일주일 내내 절약)
  static int calculateWeeklyPerfectBonus(List<DateTime> savingDates) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    // 이번 주 절약한 날들 카운트
    final thisWeekDays = savingDates.where((date) => 
      date.isAfter(weekStart.subtract(const Duration(days: 1))) && 
      date.isBefore(weekEnd.add(const Duration(days: 1)))
    ).map((date) => DateTime(date.year, date.month, date.day)).toSet();

    if (thisWeekDays.length >= 7) {
      return 1000; // 주간 완벽 달성 보너스 1000P
    }
    return 0;
  }

  /// 월간 달성률 보너스
  static int calculateMonthlyAchievementBonus(UserModel user) {
    if (user.monthlyGoal <= 0) return 0;
    
    final achievementRate = user.currentMonthSaved / user.monthlyGoal;
    
    if (achievementRate >= 1.5) return 3000;  // 150% 달성
    if (achievementRate >= 1.2) return 2000;  // 120% 달성
    if (achievementRate >= 1.0) return 1000;  // 100% 달성
    if (achievementRate >= 0.8) return 500;   // 80% 달성
    
    return 0;
  }

  /// 특별 이벤트 보너스 (휴일, 기념일 등)
  static int calculateSpecialEventBonus() {
    final now = DateTime.now();
    
    // 월요일에 절약하면 "월요병 극복 보너스"
    if (now.weekday == 1) return 100;
    
    // 금요일에 절약하면 "금요일 자제력 보너스"
    if (now.weekday == 5) return 150;
    
    // 매월 1일에 절약하면 "새달 시작 보너스"
    if (now.day == 1) return 200;
    
    // 랜덤 럭키데이 (5% 확률로 대박 보너스)
    if (Random().nextInt(100) < 5) {
      return 500; // 럭키 보너스!
    }
    
    return 0;
  }

  /// 연속 절약 실패 시 격려 메시지
  static String getMotivationalMessage(int daysSinceLastSaving) {
    if (daysSinceLastSaving == 1) {
      return '💪 어제 못했어도 괜찮아요! 오늘부터 다시 시작해요!';
    } else if (daysSinceLastSaving < 7) {
      return '🌈 작은 시작이 큰 변화를 만들어요. 천천히 다시 도전해보세요!';
    } else {
      return '🎯 새로운 시작이 가장 중요해요. 오늘이 바로 그 날!';
    }
  }

  /// 스트릭 유지를 위한 다음 절약 추천 시간
  static DateTime getNextSavingRecommendation() {
    final now = DateTime.now();
    
    // 오후 6-8시 사이를 추천 (저녁 시간대)
    var recommendedTime = DateTime(now.year, now.month, now.day, 18 + Random().nextInt(3));
    
    // 이미 지나간 시간이면 다음날로
    if (recommendedTime.isBefore(now)) {
      recommendedTime = recommendedTime.add(const Duration(days: 1));
    }
    
    return recommendedTime;
  }

  /// 스트릭 레벨별 특별 권한
  static List<String> getStreakBenefits(int consecutiveDays) {
    List<String> benefits = [];
    
    if (consecutiveDays >= 3) benefits.add('🎨 특별 테마 잠금 해제');
    if (consecutiveDays >= 7) benefits.add('🎮 보너스 게임 추가 횟수');
    if (consecutiveDays >= 14) benefits.add('💰 절약 팁 AI 개인 맞춤');
    if (consecutiveDays >= 30) benefits.add('🏆 월간 리더보드 가산점');
    if (consecutiveDays >= 60) benefits.add('💎 프리미엄 기능 미리보기');
    if (consecutiveDays >= 100) benefits.add('👑 절약 마스터 전용 커뮤니티');
    
    return benefits;
  }

  /// 전체 스트릭 보너스 계산 (모든 보너스 종합)
  static Map<String, int> calculateAllBonuses(
    UserModel user, 
    double todaySavingAmount,
    int todaySavingCount,
    List<DateTime> recentSavingDates,
  ) {
    final bonuses = <String, int>{};
    
    // 연속일 보너스
    final streakBonus = calculateStreakBonus(todaySavingAmount, user.consecutiveDays);
    if (streakBonus > 0) bonuses['streak'] = streakBonus;
    
    // 일일 콤보 보너스
    final comboBonus = calculateDailyComboBonus(todaySavingCount);
    if (comboBonus > 0) bonuses['combo'] = comboBonus;
    
    // 주간 완벽 보너스
    final weeklyBonus = calculateWeeklyPerfectBonus(recentSavingDates);
    if (weeklyBonus > 0) bonuses['weekly'] = weeklyBonus;
    
    // 월간 달성률 보너스
    final monthlyBonus = calculateMonthlyAchievementBonus(user);
    if (monthlyBonus > 0) bonuses['monthly'] = monthlyBonus;
    
    // 특별 이벤트 보너스
    final eventBonus = calculateSpecialEventBonus();
    if (eventBonus > 0) bonuses['event'] = eventBonus;
    
    LoggerService.info('All bonuses calculated: $bonuses');
    return bonuses;
  }
}