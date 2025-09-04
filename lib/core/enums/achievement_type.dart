enum AchievementType {
  firstSaving('첫 10만원 절약'),
  millionSaving('백만원 절약 달성'),
  weeklyStreak('일주일 연속 절약'),
  monthlyStreak('한달 연속 절약');

  const AchievementType(this.displayName);
  final String displayName;
}