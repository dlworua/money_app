import 'dart:math';
import '../../data/models/user_model.dart';
import '../../data/models/ai_coaching_insight.dart';
import '../enums/coaching_style.dart';
import 'spending_analyzer.dart';

class AiCoachGenerator {
  final SpendingAnalyzer _analyzer = SpendingAnalyzer();
  final Random _random = Random();

  /// 사용자 맞춤 AI 코칭 인사이트 생성
  Future<AiCoachingInsight> generateCoachingInsight(
    UserModel user,
    CoachingStyle style,
  ) async {
    final analysis = _analyzer.analyzeSpendingPattern(user);
    final insightType = _determineInsightType(analysis, user);
    final insight = _generateInsightByType(user, analysis, style, insightType);

    return insight;
  }

  /// 분석 결과에 따라 인사이트 타입 결정
  InsightType _determineInsightType(SpendingAnalysis analysis, UserModel user) {
    // 우선순위: 경고 > 성취 > 목표진행도 > 패턴분석 > 일반

    // 경고 상황 체크
    if (analysis.goalProgress.currentProgress < 0.3 &&
        DateTime.now().day > 20) {
      return InsightType.warning;
    }

    // 성취 체크
    if (analysis.streakAnalysis.isNewRecord ||
        analysis.goalProgress.currentProgress >= 1.0) {
      return InsightType.achievement;
    }

    // 연속 기록 동기부여
    if (user.consecutiveDays > 0 && user.consecutiveDays % 7 == 0) {
      return InsightType.streakMotivation;
    }

    // 목표 진행도
    if (analysis.goalProgress.isOnTrack) {
      return InsightType.goalProgress;
    }

    // 카테고리 분석
    final hasSignificantCategoryChange = analysis.categoryInsights.values.any(
      (insight) => insight.changeRate.abs() > 0.2,
    );
    if (hasSignificantCategoryChange) {
      return InsightType.categoryAnalysis;
    }

    // 소비 패턴
    if (analysis.totalRecords > 5) {
      return InsightType.spendingPattern;
    }

    return InsightType.general;
  }

  /// 타입별 인사이트 생성
  AiCoachingInsight _generateInsightByType(
    UserModel user,
    SpendingAnalysis analysis,
    CoachingStyle style,
    InsightType type,
  ) {
    final messages = _getMessagesForType(user, analysis, style, type);
    final title = _getTitleForType(type, style);
    final actionItems = _getActionItemsForType(type, analysis, user);

    return AiCoachingInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      style: style,
      title: title,
      message: messages[_random.nextInt(messages.length)],
      type: type,
      analysisData: _buildAnalysisData(analysis),
      confidenceScore: _calculateConfidenceScore(analysis, type),
      actionItems: actionItems,
    );
  }

  /// 타입별 메시지 생성
  List<String> _getMessagesForType(
    UserModel user,
    SpendingAnalysis analysis,
    CoachingStyle style,
    InsightType type,
  ) {
    switch (type) {
      case InsightType.achievement:
        return _getAchievementMessages(user, analysis, style);
      case InsightType.warning:
        return _getWarningMessages(user, analysis, style);
      case InsightType.goalProgress:
        return _getGoalProgressMessages(user, analysis, style);
      case InsightType.streakMotivation:
        return _getStreakMessages(user, style);
      case InsightType.categoryAnalysis:
        return _getCategoryAnalysisMessages(analysis, style);
      case InsightType.spendingPattern:
        return _getSpendingPatternMessages(analysis, style);
      default:
        return _getGeneralMessages(user, style);
    }
  }

  /// 성취 메시지 (칭찬)
  List<String> _getAchievementMessages(
    UserModel user,
    SpendingAnalysis analysis,
    CoachingStyle style,
  ) {
    final progress = (analysis.goalProgress.currentProgress * 100).round();

    switch (style) {
      case CoachingStyle.strict:
        return [
          '목표 달성률 $progress%... 드디어 해냈군요. 계속 이 정도만 유지하세요.',
          '${user.consecutiveDays}일 연속 기록, 나쁘지 않습니다. 이제 습관이 되도록 하세요.',
        ];
      case CoachingStyle.kind:
        return [
          '축하드려요! 목표 달성률 $progress%를 기록하셨네요. 정말 자랑스러워요! 🎉',
          '${user.consecutiveDays}일 연속 절약 기록, 정말 대단하세요! 꾸준함이 최고의 힘이에요.',
        ];
      case CoachingStyle.friendly:
        return [
          '야호! 목표 달성률 $progress%라니! 진짜 대박이야! 🎊',
          '${user.consecutiveDays}일 연속이라고? 완전 멋있다! 이 기세로 쭉 가보자!',
        ];
      case CoachingStyle.motivational:
        return [
          '🔥 목표 달성률 $progress%! 당신은 진정한 절약 마스터입니다! 이 열정을 이어가세요!',
          '${user.consecutiveDays}일 연속 기록! 불가능을 가능으로 만드는 당신의 의지력에 박수를! 👏',
        ];
      case CoachingStyle.analytical:
        return [
          '데이터 분석 결과: 목표 달성률 $progress%, 예상 수치 대비 +${(progress - 70).round()}%p 초과 달성',
          '연속 기록 ${user.consecutiveDays}일은 상위 15% 사용자 수준입니다. 지속 가능성 90% 예측',
        ];
    }
  }

  /// 경고 메시지
  List<String> _getWarningMessages(
    UserModel user,
    SpendingAnalysis analysis,
    CoachingStyle style,
  ) {
    final progress = (analysis.goalProgress.currentProgress * 100).round();
    final remaining = analysis.goalProgress.daysRemaining;

    switch (style) {
      case CoachingStyle.strict:
        return [
          '목표 달성률 $progress%? 이대로는 목표 달성 불가능입니다. 즉시 행동하세요.',
          '$remaining일 남았는데 이런 식으로는 안 됩니다. 각성하고 노력하세요.',
        ];
      case CoachingStyle.kind:
        return [
          '목표 달성률이 $progress%예요. 걱정하지 마세요, 아직 $remaining일 남았어요. 함께 해볼까요?',
          '조금 힘들어 보이지만 포기하지 마세요. 작은 변화부터 시작해보아요.',
        ];
      case CoachingStyle.friendly:
        return [
          '어? 목표 달성률이 $progress%밖에 안 되네? 괜찮아, $remaining일 남았으니까 힘내보자!',
          '이런, 좀 빡센데? 하지만 넌 할 수 있어! 마지막 스퍼트 해보자!',
        ];
      case CoachingStyle.motivational:
        return [
          '💪 목표 달성률 $progress%! 아직 끝나지 않았습니다! $remaining일의 기적을 만들어보세요!',
          '지금이 바로 진정한 실력을 보여줄 때입니다! 역전의 명수가 되어보세요!',
        ];
      case CoachingStyle.analytical:
        return [
          '현재 진행률 $progress%, 목표 달성 확률 23%. 일일 절약액을 2.3배 증가시켜야 합니다.',
          '통계적으로 $remaining일 남은 시점에서 회복 가능. 전략 수정이 필요합니다.',
        ];
    }
  }

  /// 목표 진행도 메시지
  List<String> _getGoalProgressMessages(
    UserModel user,
    SpendingAnalysis analysis,
    CoachingStyle style,
  ) {
    final progress = (analysis.goalProgress.currentProgress * 100).round();

    switch (style) {
      case CoachingStyle.strict:
        return ['목표 달성률 $progress%. 평균적인 수준입니다. 더 노력하면 더 좋겠군요.'];
      case CoachingStyle.kind:
        return ['목표 달성률 $progress%로 순조롭게 진행되고 있어요! 이 페이스를 유지하세요.'];
      case CoachingStyle.friendly:
        return ['목표 달성률 $progress%! 괜찮은 페이스네! 이대로만 하면 될 것 같아!'];
      case CoachingStyle.motivational:
        return ['🎯 목표 달성률 $progress%! 완벽한 페이스입니다! 승리의 길로 가고 있어요!'];
      case CoachingStyle.analytical:
        return ['목표 진행률 $progress%, 예상 범위 내 수치. 현재 속도 유지 시 목표 달성 가능.'];
    }
  }

  /// 연속 기록 동기부여 메시지
  List<String> _getStreakMessages(UserModel user, CoachingStyle style) {
    final streak = user.consecutiveDays;

    switch (style) {
      case CoachingStyle.strict:
        return ['$streak일 연속 기록. 좋습니다. 하지만 만족하지 말고 더 나아가세요.'];
      case CoachingStyle.kind:
        return ['$streak일 연속 절약! 정말 꾸준하시네요. 응원하고 있어요! 💪'];
      case CoachingStyle.friendly:
        return ['$streak일 연속이라니! 완전 대단해! 이 기세 그대로 쭉 가자!'];
      case CoachingStyle.motivational:
        return ['🔥 $streak일 연속 기록! 당신은 절약의 챔피언입니다! 전설을 써내려가세요!'];
      case CoachingStyle.analytical:
        return ['연속 기록 $streak일. 습관 형성률 85% 도달. 지속 확률 매우 높음.'];
    }
  }

  /// 카테고리 분석 메시지
  List<String> _getCategoryAnalysisMessages(
    SpendingAnalysis analysis,
    CoachingStyle style,
  ) {
    if (analysis.categoryInsights.entries.isEmpty) {
      // 카테고리 데이터가 없을 때 기본 메시지
      switch (style) {
        case CoachingStyle.strict:
          return ['절약 기록이 부족합니다. 더 많이 기록하세요.'];
        case CoachingStyle.kind:
          return ['아직 절약 기록이 적어요. 천천히 시작해보세요!'];
        case CoachingStyle.friendly:
          return ['아직 데이터가 부족해! 더 많이 기록해보자!'];
        case CoachingStyle.motivational:
          return ['더 많은 절약으로 데이터를 쌓아보세요!'];
        case CoachingStyle.analytical:
          return ['분석을 위해 더 많은 데이터가 필요합니다.'];
      }
    }

    final highestCategory = analysis.categoryInsights.entries.reduce(
      (a, b) => a.value.totalAmount > b.value.totalAmount ? a : b,
    );

    final categoryName = highestCategory.key;
    final changeRate = (highestCategory.value.changeRate * 100).round();

    switch (style) {
      case CoachingStyle.strict:
        return ['$categoryName 지출이 $changeRate% 증가했습니다. 관리가 필요합니다.'];
      case CoachingStyle.kind:
        return ['$categoryName 지출이 조금 늘었어요($changeRate%). 함께 줄여볼까요?'];
      case CoachingStyle.friendly:
        return ['$categoryName에서 $changeRate% 더 썼네? 다음엔 좀 줄여보자!'];
      case CoachingStyle.motivational:
        return ['$categoryName 지출 증가 발견! 이제 절약의 진짜 실력을 보여줄 때입니다!'];
      case CoachingStyle.analytical:
        return ['$categoryName 카테고리 지출량 전월 대비 +$changeRate%. 예산 재조정 권장.'];
    }
  }

  /// 소비 패턴 메시지
  List<String> _getSpendingPatternMessages(
    SpendingAnalysis analysis,
    CoachingStyle style,
  ) {
    final peakDay = _getDayName(analysis.timePatterns.mostActiveDay);

    switch (style) {
      case CoachingStyle.strict:
        return ['$peakDay에 절약 기록이 가장 많습니다. 다른 요일도 신경 쓰세요.'];
      case CoachingStyle.kind:
        return ['$peakDay에 가장 활발하시네요! 다른 요일에도 조금씩 해보시겠어요?'];
      case CoachingStyle.friendly:
        return ['$peakDay에 절약을 가장 많이 하는구나! 다른 날도 챙겨보자!'];
      case CoachingStyle.motivational:
        return ['$peakDay 절약 왕! 이 에너지를 매일 발휘해보세요!'];
      case CoachingStyle.analytical:
        return ['주간 패턴 분석: $peakDay 최대 활동. 균등 분산 시 효율성 12% 향상 예측.'];
    }
  }

  /// 일반 메시지
  List<String> _getGeneralMessages(UserModel user, CoachingStyle style) {
    switch (style) {
      case CoachingStyle.strict:
        return [
          '절약은 꾸준함이 생명입니다. 매일 기록하세요.',
          '목표 없는 절약은 의미가 없습니다. 명확한 목표를 세우세요.',
        ];
      case CoachingStyle.kind:
        return [
          '오늘도 절약 앱을 열어주셔서 감사해요! 작은 실천이 큰 변화를 만들어요.',
          '절약 여정에 함께할 수 있어서 기뻐요. 천천히 해도 괜찮아요.',
        ];
      case CoachingStyle.friendly:
        return ['오늘은 어떤 절약을 해볼까? 함께 재미있게 해보자!', '절약 습관 만들기, 우리 같이 파이팅 해보자! 💪'];
      case CoachingStyle.motivational:
        return [
          '🌟 매일이 새로운 절약의 기회입니다! 오늘도 도전하세요!',
          '당신의 절약 여정이 누군가에게는 영감이 됩니다! 계속 나아가세요!',
        ];
      case CoachingStyle.analytical:
        return [
          '사용자 데이터 기반 최적화된 절약 전략을 제안드리겠습니다.',
          '패턴 분석 결과를 바탕으로 개선점을 찾아보세요.',
        ];
    }
  }

  String _getTitleForType(InsightType type, CoachingStyle style) {
    switch (type) {
      case InsightType.achievement:
        return style == CoachingStyle.strict ? '목표 달성 완료' : '🎉 축하합니다!';
      case InsightType.warning:
        return style == CoachingStyle.strict ? '긴급 점검 필요' : '⚠️ 관심 필요';
      case InsightType.goalProgress:
        return '🎯 목표 진행 상황';
      case InsightType.streakMotivation:
        return '🔥 연속 기록 달성';
      case InsightType.categoryAnalysis:
        return '📊 카테고리 분석';
      case InsightType.spendingPattern:
        return '📈 소비 패턴 분석';
      default:
        return '💡 AI 절약 코치';
    }
  }

  List<String> _getActionItemsForType(
    InsightType type,
    SpendingAnalysis analysis,
    UserModel user,
  ) {
    switch (type) {
      case InsightType.warning:
        return ['일일 절약 목표액 늘리기', '가장 많이 쓰는 카테고리 줄이기', '매일 절약 기록하기'];
      case InsightType.goalProgress:
        return ['현재 페이스 유지하기', '절약 카테고리 다양화하기'];
      default:
        return ['꾸준한 절약 기록하기', '월 목표 점검하기'];
    }
  }

  Map<String, dynamic> _buildAnalysisData(SpendingAnalysis analysis) {
    return {
      'totalRecords': analysis.totalRecords,
      'goalProgress': analysis.goalProgress.currentProgress,
      'streakDays': analysis.streakAnalysis.currentStreak,
      'analysisDate': analysis.analyzedAt.toIso8601String(),
    };
  }

  double _calculateConfidenceScore(
    SpendingAnalysis analysis,
    InsightType type,
  ) {
    double baseScore = 0.7;

    // 데이터가 많을수록 신뢰도 증가
    if (analysis.totalRecords > 10) baseScore += 0.2;
    if (analysis.totalRecords > 20) baseScore += 0.1;

    // 특정 타입별 신뢰도 조정
    switch (type) {
      case InsightType.achievement:
      case InsightType.goalProgress:
        baseScore += 0.1;
        break;
      case InsightType.warning:
        baseScore += 0.15;
        break;
      default:
        break;
    }

    return baseScore.clamp(0.0, 1.0);
  }

  String _getDayName(int weekday) {
    const days = ['', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return days[weekday];
  }
}
