import 'dart:math';
import '../../core/services/logger_service.dart';
import '../../data/models/user_model.dart';

class AiCoachingService {
  static const List<String> _generalTips = [
    '💡 매일 작은 금액이라도 절약하는 습관을 만들어보세요!',
    '🎯 절약 목표를 세분화해서 달성 가능한 단위로 나누어보세요.',
    '📊 가계부를 작성해서 지출 패턴을 파악해보세요.',
    '🛒 장보기 전 미리 목록을 작성해서 불필요한 구매를 줄이세요.',
    '☕ 카페 대신 집에서 커피를 만들어 드셔보세요.',
    '🚗 대중교통이나 도보를 활용해보세요.',
    '💳 할인 쿠폰과 적립금을 적극 활용해보세요.',
  ];

  static const List<String> _streakTips = [
    '🔥 연속 절약 스트릭을 유지하고 있어요! 대단해요!',
    '⚡ 절약 습관이 몸에 배고 있네요! 계속 유지해보세요!',
    '🌟 꾸준함이 가장 중요해요. 지금처럼만 하면 목표 달성!',
    '💪 절약 마스터의 길을 걷고 있어요!',
  ];

  static const List<String> _motivationalTips = [
    '🎉 오늘도 절약에 성공했네요! 작은 실천이 큰 변화를 만들어요!',
    '🌱 절약은 미래를 위한 투자입니다. 지금의 노력이 빛을 발할 거예요!',
    '🏆 목표까지 한 걸음씩 다가가고 있어요. 포기하지 마세요!',
    '💎 절약왕이 되는 그날까지 함께 해요!',
  ];

  /// 사용자 데이터를 분석해서 맞춤형 코칭 팁을 제공
  static List<String> getPersonalizedTips(UserModel user) {
    List<String> tips = [];

    try {
      // 1. 레벨 기반 팁
      if (user.level < 3) {
        tips.add('🔰 절약 초보자를 위한 팁: 작은 것부터 시작해보세요! 하루 1000원만 아껴도 한달에 3만원이에요.');
      } else if (user.level < 10) {
        tips.add('📈 중급자 팁: 카테고리별 절약 목표를 설정해보세요. 식비 20%, 교통비 10% 줄이기!');
      } else {
        tips.add('🎖️ 절약 고수 팁: 투자 수익률을 고려한 절약 전략을 세워보세요!');
      }

      // 2. 연속일 기반 팁
      if (user.consecutiveDays > 7) {
        tips.add(_streakTips[Random().nextInt(_streakTips.length)]);
      }

      // 3. 월 목표 달성률 기반 팁
      final achievementRate = user.monthlyGoal > 0
          ? user.currentMonthSaved / user.monthlyGoal
          : 0.0;

      if (achievementRate < 0.3) {
        tips.add(
          '⏰ 이번 달 목표까지 ${((user.monthlyGoal - user.currentMonthSaved) / 1000).ceil()}천원 남았어요! 하루 ${((user.monthlyGoal - user.currentMonthSaved) / DateTime.now().day / 1000).ceil()}천원씩 절약하면 달성!',
        );
      } else if (achievementRate > 0.8) {
        tips.add('🎊 이번 달 목표를 거의 달성했네요! 남은 기간 동안 더 도전해볼까요?');
      }

      // 4. 절약 패턴 분석
      final recentRecords = user.savingRecords.length > 5
          ? user.savingRecords.take(5).toList()
          : user.savingRecords;

      if (recentRecords.isNotEmpty) {
        final avgAmount =
            recentRecords.fold<double>(
              0,
              (sum, record) => sum + record.amount,
            ) /
            recentRecords.length;

        if (avgAmount < 5000) {
          tips.add(
            '💰 소액 절약도 소중해요! 큰 금액 절약에도 도전해보세요. 외식 대신 집밥 한 번으로 2-3만원 절약!',
          );
        } else if (avgAmount > 20000) {
          tips.add('🌟 대단한 절약 실력이네요! 이 패턴을 유지하면 목표를 훨씬 초과 달성할 수 있어요!');
        }

        // 카테고리별 분석
        final categoryStats = <String, int>{};
        for (final record in recentRecords) {
          categoryStats[record.category] =
              (categoryStats[record.category] ?? 0) + 1;
        }

        final mostFrequentCategory = categoryStats.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        switch (mostFrequentCategory) {
          case '식비':
            tips.add('🍽️ 식비 절약에 특화되어 있네요! 식재료 벌크 구매나 쿠킹클래스 도전은 어때요?');
            break;
          case '교통비':
            tips.add('🚌 교통비 절약의 달인! 자전거나 킥보드 이용도 건강과 절약 일석이조!');
            break;
          case '쇼핑':
            tips.add('🛍️ 쇼핑 절약 고수! 필요 vs 욕구를 구분하는 24시간 룰을 적용해보세요!');
            break;
        }
      }

      // 5. 동기부여 메시지
      if (tips.length < 3) {
        tips.add(_motivationalTips[Random().nextInt(_motivationalTips.length)]);
      }

      // 6. 일반적인 팁 추가
      if (tips.length < 4) {
        tips.add(_generalTips[Random().nextInt(_generalTips.length)]);
      }

      LoggerService.info(
        'Generated ${tips.length} personalized tips for user ${user.id}',
      );
    } catch (e) {
      LoggerService.error('Error generating personalized tips', e);
      tips.add(_generalTips[Random().nextInt(_generalTips.length)]);
    }

    return tips;
  }

  /// 절약 목표 달성 확률 예측 (간단한 머신러닝 알고리즘)
  static double predictGoalAchievementProbability(UserModel user) {
    try {
      final daysInMonth = DateTime.now().day;
      final daysRemaining =
          DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day -
          daysInMonth;

      if (daysRemaining <= 0) {
        return user.currentMonthSaved >= user.monthlyGoal ? 1.0 : 0.0;
      }

      // 현재 달성률 (미래 확장용으로 유지)

      // 일일 평균 절약 금액
      final dailyAverage = daysInMonth > 0
          ? user.currentMonthSaved / daysInMonth
          : 0.0;

      // 예상 월말 달성 금액
      final projectedTotal =
          user.currentMonthSaved + (dailyAverage * daysRemaining);

      // 달성 확률 계산 (여러 요소 고려)
      double probability = (projectedTotal / user.monthlyGoal).clamp(0.0, 1.0);

      // 보정 요소들
      if (user.consecutiveDays > 7) probability += 0.1; // 꾸준함 보너스
      if (user.level > 5) probability += 0.05; // 경험 보너스
      if (user.savingRecords.length > 10) probability += 0.05; // 기록 횟수 보너스

      return probability.clamp(0.0, 1.0);
    } catch (e) {
      LoggerService.error('Error predicting goal achievement', e);
      return 0.5; // 기본값
    }
  }

  /// 다음 레벨까지 필요한 경험치 계산
  static int getExpToNextLevel(UserModel user) {
    final nextLevelExp = user.level * 1000;
    return nextLevelExp - user.experience;
  }

  /// 맞춤형 절약 목표 제안
  static double suggestOptimalMonthlyGoal(UserModel user) {
    try {
      // 최근 3개월 평균 절약 금액 기반 (현재는 이번 달만 사용)
      final baseAmount = user.currentMonthSaved > 0
          ? user.currentMonthSaved * 1.2
          : 50000.0;

      // 사용자 레벨에 따른 조정
      final levelMultiplier = 1.0 + (user.level * 0.05);

      // 연속일에 따른 조정
      final streakMultiplier = user.consecutiveDays > 0
          ? 1.0 + (user.consecutiveDays * 0.01)
          : 1.0;

      final suggestedGoal = (baseAmount * levelMultiplier * streakMultiplier)
          .roundToDouble();

      // 최소/최대 제한
      return suggestedGoal.clamp(30000.0, 500000.0);
    } catch (e) {
      LoggerService.error('Error suggesting optimal goal', e);
      return 100000.0; // 기본 목표
    }
  }
}
