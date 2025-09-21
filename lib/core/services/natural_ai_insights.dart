import '../../data/models/transaction.dart';
import '../../core/enums/coaching_style.dart';
import '../../data/models/ai_coaching_insight.dart';

/// 자연스러운 AI 인사이트 생성을 위한 확장 메서드들
extension NaturalAIInsights on dynamic {
  
  /// 2-3건 거래 초기 패턴 분석
  Map<String, dynamic> _generateEarlyPatternInsight(
    int transactionCount,
    double totalSpending, 
    int diversity,
    String userName,
    CoachingStyle style
  ) {
    final avgAmount = totalSpending / transactionCount;
    final isSmallSpender = avgAmount < 20000;
    
    String title;
    String message;
    List<String> actions;
    
    switch (style) {
      case CoachingStyle.friendly:
        title = isSmallSpender 
            ? '👍 $userName, 아껴쓰는 습관 좋은데!'
            : '🤔 $userName, 이거 패턴이 보이는걸?';
        message = isSmallSpender
            ? '와 진짜! $transactionCount건 기록했는데 평균 ${_formatCurrency(avgAmount)}? 진짜 알뜰살뜰하네! 이런 식으로 계속 하면 절약 마스터 될 것 같은데? 더 기록해봐!'
            : '음... $transactionCount건 기록했는데 평균이 ${_formatCurrency(avgAmount)}네? 나쁘지 않지만 혹시 큰 지출들이 있는 건 아니야? 좀 더 기록해보면 확실한 패턴을 알 수 있을 것 같아!';
        actions = diversity >= 2
            ? ['다양한 카테고리 지출 좋아! 계속 기록해', '예산도 카테고리별로 세워보자', '수입도 기록하면 완벽해']
            : ['다른 카테고리 지출도 기록해보자', '예산 설정으로 목표 만들기', '수입 기록으로 전체 그림 보기'];
        break;
        
      case CoachingStyle.strict:
        title = '📊 초기 패턴 분석';
        message = '$transactionCount건의 거래 분석 결과: 평균 거래액 ${_formatCurrency(avgAmount)}, 카테고리 다양성 ${diversity}개. ${isSmallSpender ? '지출 규모가 적절하나' : '지출 규모 검토 필요'}, 더 많은 데이터가 정확한 분석에 필수적입니다.';
        actions = [
          '최소 일주일간 모든 지출 기록',
          '카테고리별 예산 할당',
          '지출 패턴 일관성 유지'
        ];
        break;
        
      case CoachingStyle.kind:
        title = '😊 좋은 시작이에요!';
        message = '벌써 $transactionCount건이나 기록해 주셨네요! 평균 ${_formatCurrency(avgAmount)}으로 ${isSmallSpender ? '정말 절약을 잘 하고 계시는 것 같아요' : '적당한 수준의 지출을 하고 계시네요'}. 천천히 더 기록해 주시면 더 정확한 분석을 해드릴 수 있어요.';
        actions = [
          '편한 시간에 추가로 기록해 주세요',
          '예산도 설정해 보시면 도움이 될 거예요',
          '수입도 함께 기록하시면 좋겠어요'
        ];
        break;
        
      case CoachingStyle.motivational:
        title = '🔥 패턴 발견 중!';
        message = '우와! $transactionCount건 기록 완료! 평균 ${_formatCurrency(avgAmount)}의 패턴이 보이기 시작해요! ${isSmallSpender ? '정말 훌륭한 절약 DNA를 가지고 계시는군요!' : '이제 진짜 분석이 재미있어질 것 같아요!'} 계속 이 기세로 나가봅시다!';
        actions = [
          '매일 기록하는 습관 만들어 버리기!',
          '예산 세워서 목표 향해 질주하기!',
          '수입까지 기록해서 완전 정복하기!'
        ];
        break;
        
      case CoachingStyle.analytical:
        title = '📈 초기 데이터 분석';
        message = '표본 크기: $transactionCount건. 평균 거래액: ${_formatCurrency(avgAmount)}. 카테고리 분산도: ${diversity}개. ${isSmallSpender ? '저지출 패턴 감지' : '중간 지출 패턴 확인'}. 통계적 유의성 확보를 위해 추가 데이터 포인트 필요. 현재 신뢰구간: 제한적.';
        actions = [
          '최소 10개 데이터 포인트까지 확장',
          '카테고리별 분산 증대',
          '시계열 데이터 구축을 위한 지속 기록'
        ];
        break;
    }
    
    return {
      'title': title,
      'message': message,
      'type': InsightType.spendingPattern,
      'confidence': 0.75,
      'actions': actions,
    };
  }
  
  /// 다양한 지출 패턴 분석
  Map<String, dynamic> _generateDiverseSpendingInsight(
    double totalSpending,
    double dailyAverage,
    MapEntry<String, dynamic>? topCategory,
    int consecutiveDays,
    String userName,
    CoachingStyle style
  ) {
    final topCategoryName = topCategory != null 
        ? TransactionCategory.values.byName(topCategory.key).displayName
        : '미분류';
    final topRatio = topCategory != null 
        ? ((topCategory.value as double) / totalSpending * 100).round()
        : 0;
    
    String title;
    String message;
    List<String> actions;
    
    switch (style) {
      case CoachingStyle.friendly:
        title = '🎯 $userName의 지출 스타일 분석!';
        message = '와! 진짜 다양하게 쓰고 있구나! 총 ${_formatCurrency(totalSpending)} 중에서 $topCategoryName에 $topRatio% 정도 쓰고 있어. 하루 평균 ${_formatCurrency(dailyAverage)}인데, 뭔가 균형잡힌 느낌? ${consecutiveDays}일째 꾸준히 기록 중이니까 이제 진짜 패턴이 보여! 어때, 어디 줄일 만한 곳 보이지 않아?';
        actions = [
          '$topCategoryName 지출을 좀 더 자세히 들여다보기',
          '예산을 카테고리별로 나눠서 설정해보기',
          '이런 식으로 한 달 더 기록해서 트렌드 보기'
        ];
        break;
        
      case CoachingStyle.strict:
        title = '📊 지출 패턴 종합 분석';
        message = '총 지출액 ${_formatCurrency(totalSpending)}, 일평균 ${_formatCurrency(dailyAverage)}. 최대 지출 카테고리는 $topCategoryName($topRatio%). 다양한 카테고리 사용은 긍정적이나 주요 지출처 관리가 핵심입니다. ${consecutiveDays}일간의 지속적 기록은 분석의 신뢰성을 높였습니다.';
        actions = [
          '$topCategoryName 카테고리 지출 한도 설정',
          '각 카테고리별 월간 예산 수립',
          '지출 패턴의 규칙성 점검'
        ];
        break;
        
      case CoachingStyle.kind:
        title = '😊 균형잡힌 지출 패턴이네요!';
        message = '${consecutiveDays}일 동안 꾸준히 기록해 주셔서 감사해요! 총 ${_formatCurrency(totalSpending)} 지출에서 $topCategoryName이 $topRatio%로 가장 높네요. 하루 평균 ${_formatCurrency(dailyAverage)}으로 다양한 카테고리에 골고루 쓰고 계시는 것 같아요. 정말 균형감각이 좋으세요!';
        actions = [
          '$topCategoryName 부분을 조금 더 세심하게 보세요',
          '예산을 설정하시면 더 체계적이 될 거예요',
          '이런 식으로 계속 기록하시면 완벽해요'
        ];
        break;
        
      case CoachingStyle.motivational:
        title = '💪 균형잡힌 지출왕 $userName!';
        message = '대박! ${consecutiveDays}일 연속 기록 달성! 총 ${_formatCurrency(totalSpending)} 지출에서 $topCategoryName $topRatio%가 최고지만, 나머지도 골고루 분산! 하루 평균 ${_formatCurrency(dailyAverage)}의 안정적인 패턴! 이런 게 바로 프로 절약러의 기본기예요! 이제 최적화만 하면 끝!';
        actions = [
          '$topCategoryName 최적화로 한 단계 업그레이드!',
          '예산 설정해서 목표 달성까지 직진!',
          '이 패턴 유지하며 절약 마스터 등극!'
        ];
        break;
        
      case CoachingStyle.analytical:
        title = '📈 다변량 지출 분석 결과';
        message = '분석 기간: ${consecutiveDays}일. 총 지출: ${_formatCurrency(totalSpending)}. 일평균: ${_formatCurrency(dailyAverage)}. 지배적 카테고리: $topCategoryName($topRatio%). 지출 분산도: 양호. 카테고리 균형도: 적정 수준. 예측 가능성: 높음. 최적화 여지: $topCategoryName 카테고리 중점.';
        actions = [
          '$topCategoryName 카테고리 세부 분석 실시',
          '카테고리별 효율성 지표 계산',
          '지출 최적화 시나리오 모델링'
        ];
        break;
    }
    
    return {
      'title': title,
      'message': message,
      'type': InsightType.spendingPattern,
      'confidence': 0.9,
      'actions': actions,
    };
  }
  
  String _formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }
}