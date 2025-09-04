class AppConstants {
  static const String appTitle = '💡 스마트 절약 챌린지';
  
  // 게임 설정
  static const int rewardedAdCoins = 50;
  static const int interstitialAdCoins = 10;
  static const int premiumMultiplier = 3;
  
  // 광고 단위 ID
  // TODO: AdMob 콘솔에서 발급받은 실제 광고 단위 ID로 교체하세요
  // 형식: 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'
  
  // ⚠️ 현재는 테스트 광고 - 실제 배포 전에 반드시 교체 필요!
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // 배너 광고
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // 리워드 광고  
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // 전면 광고
  
  // 실제 광고 ID 예시 (실제 사용시 주석 해제하고 위의 테스트 ID 주석 처리):
  // static const String bannerAdUnitId = 'ca-app-pub-1234567890123456/1234567890';
  // static const String rewardedAdUnitId = 'ca-app-pub-1234567890123456/0987654321'; 
  // static const String interstitialAdUnitId = 'ca-app-pub-1234567890123456/1122334455';
  
  // 레벨/경험치 설정
  static const int experiencePerLevel = 1000;
  static const int levelUpBonusMultiplier = 100;
  
  // 프리미엄 제한
  static const int freeUserMonthlyLimit = 50;
  
  // 게임 보상
  static const int numberGuessWinCoins = 75;
  static const int numberGuessLoseCoins = 5;
  static const int numberGuessWinExp = 15;
  static const int numberGuessLoseExp = 3;
  
  // 절약 관련
  static const double defaultMonthlyGoal = 100000.0;
  static const List<String> defaultCategories = [
    '식비',
    '교통비',
    '쇼핑',
    '기타'
  ];
  
  // 쿨다운 시간 (초)
  static const int adCooldownSeconds = 1;
  
  // 업적 기준
  static const double firstSavingMilestone = 100000.0;
  static const double millionSavingMilestone = 1000000.0;
  static const int weeklyConsecutiveDays = 7;
  static const int monthlyConsecutiveDays = 30;
}