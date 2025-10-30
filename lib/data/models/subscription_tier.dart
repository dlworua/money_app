/// 요금제 등급
enum SubscriptionTier {
  free,     // 무료
  pro,      // 프로
  premium,  // 프리미엄
}

/// 요금제 확장 기능
extension SubscriptionTierExtension on SubscriptionTier {
  /// 요금제 이름
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.pro:
        return 'Pro';
      case SubscriptionTier.premium:
        return 'Premium';
    }
  }

  /// 요금제 가격
  int get price {
    switch (this) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.pro:
        return 4900;
      case SubscriptionTier.premium:
        return 9900;
    }
  }

  /// 요금제 설명
  String get description {
    switch (this) {
      case SubscriptionTier.free:
        return '기본 기능으로 시작하기';
      case SubscriptionTier.pro:
        return '광고 없이 쾌적하게';
      case SubscriptionTier.premium:
        return '모든 기능을 무제한으로';
    }
  }

  /// 월 거래 추가 제한 횟수 (null = 무제한)
  int? get monthlyTransactionLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 100;
      case SubscriptionTier.pro:
        return null; // 무제한
      case SubscriptionTier.premium:
        return null; // 무제한
    }
  }

  /// 예산 설정 가능 횟수 (null = 무제한)
  int? get budgetLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 10;
      case SubscriptionTier.pro:
        return 50;
      case SubscriptionTier.premium:
        return null; // 무제한
    }
  }

  /// 절약목표 설정 가능 횟수 (null = 무제한)
  int? get savingsGoalLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 10;
      case SubscriptionTier.pro:
        return 50;
      case SubscriptionTier.premium:
        return null; // 무제한
    }
  }

  /// AI 코칭 사용 가능 여부
  bool get canUseAiCoaching {
    switch (this) {
      case SubscriptionTier.free:
        return false; // AI 사용 불가
      case SubscriptionTier.pro:
        return true; // 기본 모델만
      case SubscriptionTier.premium:
        return true; // 프리미엄 모델
    }
  }

  /// AI 말투 변경 가능 여부
  bool get canChangeAiTone {
    switch (this) {
      case SubscriptionTier.free:
        return false;
      case SubscriptionTier.pro:
        return false; // 말투 변경 불가
      case SubscriptionTier.premium:
        return true; // 말투 변경 가능
    }
  }

  /// AI 맞춤 조언 받기 가능 여부
  bool get canGetCustomAdvice {
    switch (this) {
      case SubscriptionTier.free:
        return false;
      case SubscriptionTier.pro:
        return false;
      case SubscriptionTier.premium:
        return true; // 맞춤 조언 가능
    }
  }

  /// 가계부/홈/프로필 탭 광고 제거 여부 (게임 탭 제외)
  bool get isAdFreeExceptGames {
    switch (this) {
      case SubscriptionTier.free:
        return false; // 모든 곳에 광고
      case SubscriptionTier.pro:
        return true; // 게임 탭 제외 광고 제거
      case SubscriptionTier.premium:
        return true; // 다음 속성에서 전체 제거
    }
  }

  /// 게임 탭 광고까지 모두 제거 여부
  bool get isCompletelyAdFree {
    switch (this) {
      case SubscriptionTier.free:
        return false;
      case SubscriptionTier.pro:
        return false; // 게임 탭은 광고 있음
      case SubscriptionTier.premium:
        return true; // 모든 광고 제거
    }
  }

  /// 리워드 광고 시청 시 포인트 배율
  int get rewardAdPointMultiplier {
    switch (this) {
      case SubscriptionTier.free:
        return 1; // 기본 1/20 포인트
      case SubscriptionTier.pro:
        return 2; // 2배 = 2/40 포인트
      case SubscriptionTier.premium:
        return 3; // 3배 = 4/60 포인트
    }
  }

  /// 리워드 광고 시청 시 티켓 배율
  int get rewardAdTicketMultiplier {
    switch (this) {
      case SubscriptionTier.free:
        return 1; // 기본 1/20 티켓
      case SubscriptionTier.pro:
        return 2; // 2배 = 2/40 티켓
      case SubscriptionTier.premium:
        return 3; // 3배 = 4/60 티켓 (실제로는 게임 티켓 대기시간 5분으로 대체)
    }
  }

  /// 게임 티켓 대기 시간 (분)
  int get gameTicketWaitMinutes {
    switch (this) {
      case SubscriptionTier.free:
        return 30; // 30분 대기
      case SubscriptionTier.pro:
        return 30; // 30분 대기
      case SubscriptionTier.premium:
        return 5; // 5분 대기
    }
  }

  /// 이번달 소비 분석 기능 사용 가능 여부
  bool get canUseMonthlyAnalysis {
    switch (this) {
      case SubscriptionTier.free:
        return true; // Free도 가능
      case SubscriptionTier.pro:
        return true;
      case SubscriptionTier.premium:
        return true;
    }
  }

  /// 고급 통계 기능 사용 가능 여부
  bool get canUseAdvancedStats {
    switch (this) {
      case SubscriptionTier.free:
        return true; // Free도 가능
      case SubscriptionTier.pro:
        return true;
      case SubscriptionTier.premium:
        return true;
    }
  }

  /// 요금제 기능 목록
  List<String> get features {
    switch (this) {
      case SubscriptionTier.free:
        return [
          '가계부 거래추가 제한 월 100회',
          '이번달 소비분석 기능 제공',
          '가계부 내 고급 통계기능 제공',
          '예산 및 절약목표 설정 기능 각 10회 제공',
        ];
      case SubscriptionTier.pro:
        return [
          'Free 요금제 내 모든 기능 포함',
          '가계부 거래추가 무제한',
          '각 탭 광고 제거 (인앱 게임화면 제외)',
          '리워드 광고 시청 시 지급 포인트 및 티켓 2배 증가 (2/40)',
          'AI 코칭 기본 모델 사용가능 (말투변경 불가)',
          '예산 및 절약목표 설정 기능 각 50회 제공',
        ];
      case SubscriptionTier.premium:
        return [
          'Pro 요금제 내 모든 기능 포함',
          '앱 내 모든 광고 제거',
          '리워드 광고 시청 시 지급 포인트 및 티켓 3배 증가 (4/60)',
          'AI 코칭 프리미엄 모델 사용가능 (말투변경가능 + 맞춤조언받기)',
          '게임티켓 대기시간 5분',
          '예산 및 절약목표 설정 기능 무제한',
        ];
    }
  }

  /// 리워드 광고 기본 포인트/티켓 (배율 적용 전)
  static const int baseRewardAdPoint = 1;
  static const int baseRewardAdTicket = 1;

  /// 실제 지급 포인트 계산
  int get actualRewardAdPoint {
    return baseRewardAdPoint * rewardAdPointMultiplier;
  }

  /// 실제 지급 티켓 계산
  int get actualRewardAdTicket {
    return baseRewardAdTicket * rewardAdTicketMultiplier;
  }
}
