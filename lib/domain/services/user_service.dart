import 'dart:math';
import '../../core/constants/app_constants.dart';
import '../../core/enums/subscription_plan.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/services/logger_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import 'ai_coaching_service.dart';
import 'streak_service.dart';

class UserService {
  final UserRepository _userRepository;
  
  UserService(this._userRepository);
  
  Future<UserModel?> getUser() async {
    return await _userRepository.getUser();
  }
  
  /// getCurrentUser 메서드 (HomeViewModel에서 사용)
  Future<UserModel?> getCurrentUser() async {
    return await _userRepository.getUser();
  }
  
  /// saveUser 메서드 (HomeViewModel에서 사용)
  Future<void> saveUser(UserModel user) async {
    return await _userRepository.saveUser(user);
  }
  
  Future<void> addCoins(int coins, {bool isPremium = false}) async {
    final user = await _userRepository.getUser();
    if (user == null) throw UserDataException('사용자 데이터를 찾을 수 없습니다');
    
    final finalCoins = isPremium ? coins * AppConstants.premiumMultiplier : coins;
    await _userRepository.updateCoins(finalCoins);
    
    LoggerService.info('Added $finalCoins coins to user ${user.id}');
  }
  
  Future<Map<String, dynamic>> addSavingRecord(double amount, String category) async {
    final user = await _userRepository.getUser();
    if (user == null) throw UserDataException('사용자 데이터를 찾을 수 없습니다');

    final canAdd = await _userRepository.canAddSavingRecord();
    if (!canAdd) {
      throw UserDataException('월 최대 ${AppConstants.freeUserMonthlyLimit}회까지만 기록할 수 있습니다. 프리미엄으로 업그레이드하세요.');
    }
    
    // 🔥 스트릭 보너스 계산
    final streakBonus = StreakService.calculateStreakBonus(amount, user.consecutiveDays);
    
    // 🎮 일일 콤보 계산 (오늘 몇 번째 절약인지)
    final today = DateTime.now();
    final todaySavings = user.savingRecords.where((record) => 
      record.date.year == today.year &&
      record.date.month == today.month &&
      record.date.day == today.day
    ).length;
    
    final comboBonus = StreakService.calculateDailyComboBonus(todaySavings + 1);
    
    // 🎁 특별 이벤트 보너스
    final eventBonus = StreakService.calculateSpecialEventBonus();
    
    // 총 보너스 포인트 계산
    final totalBonusPoints = streakBonus + comboBonus + eventBonus;
    

    // 🧠 AI 맞춤 팁 업데이트 (3일마다)
    List<String> newAiTips = user.aiTips;
    DateTime? newAiTipDate = user.lastAiTipDate;
    
    if (user.lastAiTipDate == null || 
        DateTime.now().difference(user.lastAiTipDate!).inDays >= 3) {
      newAiTips = AiCoachingService.getPersonalizedTips(user);
      newAiTipDate = DateTime.now();
    }

    // 기본 절약 기록 추가
    await _userRepository.addSavingAmount(amount, category);
    
    // 보너스 포인트 추가
    if (totalBonusPoints > 0) {
      await _userRepository.updateCoins(totalBonusPoints);
    }

    // 업데이트된 사용자 정보 가져와서 AI 팁 적용
    final updatedUser = await _userRepository.getUser();
    if (updatedUser != null) {
      final finalUser = updatedUser.copyWith(
        aiTips: newAiTips,
        lastAiTipDate: newAiTipDate,
      );
      await _userRepository.saveUser(finalUser);
    }
    
    LoggerService.info('Added saving record: $amount in $category with $totalBonusPoints bonus points');
    
    // 결과 반환
    return {
      'amount': amount,
      'category': category,
      'streakBonus': streakBonus,
      'comboBonus': comboBonus,
      'eventBonus': eventBonus,
      'totalBonus': totalBonusPoints,
      'newAiTips': user.lastAiTipDate != newAiTipDate,
    };
  }
  
  Future<void> subscribeToPremium(String planId, {int? pointsToUse}) async {
    final user = await _userRepository.getUser();
    if (user == null) throw UserDataException('사용자 데이터를 찾을 수 없습니다');
    
    if (pointsToUse != null) {
      if (user.coins < pointsToUse) {
        throw PremiumSubscriptionException('포인트가 부족합니다. 필요: ${pointsToUse}P, 보유: ${user.coins}P');
      }
    }
    
    final subscriptionPlan = SubscriptionPlan.values.firstWhere(
      (p) => p.id == planId,
      orElse: () => throw PremiumSubscriptionException('잘못된 구독 플랜입니다: $planId'),
    );
    
    final now = DateTime.now();
    final endDate = now.add(Duration(days: subscriptionPlan.days));
    
    final updatedUser = user.copyWith(
      isPremium: true,
      premiumStartDate: now,
      premiumEndDate: endDate,
      subscriptionPlan: planId,
      coins: pointsToUse != null ? user.coins - pointsToUse : user.coins,
    );
    
    await _userRepository.saveUser(updatedUser);
    LoggerService.info('User ${user.id} subscribed to premium plan: $planId');
  }
  
  bool isPremiumActive(UserModel user) {
    if (!user.isPremium || user.premiumEndDate == null) return false;
    return DateTime.now().isBefore(user.premiumEndDate!);
  }
  
  Future<bool> playNumberGuessGame(int userGuess) async {
    final user = await _userRepository.getUser();
    if (user == null) throw GameException('사용자 데이터를 찾을 수 없습니다');
    
    final correctNumber = DateTime.now().millisecond % 10 + 1; // 더 예측 가능한 방식
    final isWin = userGuess == correctNumber;
    
    final baseReward = isWin ? AppConstants.numberGuessWinCoins : AppConstants.numberGuessLoseCoins;
    final finalReward = user.isPremium ? baseReward * AppConstants.premiumMultiplier : baseReward;
    
    final expGain = isWin ? AppConstants.numberGuessWinExp : AppConstants.numberGuessLoseExp;
    
    final updatedUser = user.copyWith(
      totalGamesPlayed: user.totalGamesPlayed + 1,
      coins: user.coins + finalReward,
    );
    
    await _userRepository.saveUser(updatedUser);
    await _userRepository.updateExperience(expGain);
    
    LoggerService.info('Number guess game: user=$userGuess, correct=$correctNumber, win=$isWin, reward=$finalReward');
    return isWin;
  }
  
  Future<void> checkDailyReward() async {
    final user = await _userRepository.getUser();
    if (user == null) return;
    
    final now = DateTime.now();
    final lastReward = user.lastSpinDate;
    
    if (lastReward == null || _isDifferentDay(lastReward, now)) {
      const dailyReward = 100;
      final finalReward = user.isPremium ? dailyReward * AppConstants.premiumMultiplier : dailyReward;
      
      final updatedUser = user.copyWith(
        coins: user.coins + finalReward,
        dailySpinCount: user.dailySpinCount + 1,
        lastSpinDate: now,
      );
      
      await _userRepository.saveUser(updatedUser);
      LoggerService.info('Daily reward claimed: $finalReward coins');
    }
  }
  
  bool _isDifferentDay(DateTime date1, DateTime date2) {
    return date1.year != date2.year || 
           date1.month != date2.month || 
           date1.day != date2.day;
  }


  /// 🧠 AI 절약 목표 추천
  Future<double> getSmartGoalRecommendation() async {
    final user = await _userRepository.getUser();
    if (user == null) return AppConstants.defaultMonthlyGoal;
    
    final recommendation = AiCoachingService.suggestOptimalMonthlyGoal(user);
    LoggerService.info('AI goal recommendation: $recommendation for user ${user.id}');
    return recommendation;
  }

  /// 📊 절약 통계 및 분석
  Future<Map<String, dynamic>> getSavingAnalytics() async {
    final user = await _userRepository.getUser();
    if (user == null) return {};

    final now = DateTime.now();
    final thisMonth = user.savingRecords.where((record) =>
      record.date.year == now.year && record.date.month == now.month
    ).toList();

    final categoryStats = <String, double>{};
    for (final record in thisMonth) {
      categoryStats[record.category] = (categoryStats[record.category] ?? 0) + record.amount;
    }

    final achievementRate = user.monthlyGoal > 0 
        ? user.currentMonthSaved / user.monthlyGoal 
        : 0.0;

    final prediction = AiCoachingService.predictGoalAchievementProbability(user);
    
    return {
      'monthlyProgress': achievementRate,
      'goalAchievementProbability': prediction,
      'categoryBreakdown': categoryStats,
      'streakTitle': StreakService.getStreakTitle(user.consecutiveDays),
      'streakMultiplier': StreakService.getStreakMultiplier(user.consecutiveDays),
      'daysToNextLevel': StreakService.getDaysToNextStreakLevel(user.consecutiveDays),
      'streakBenefits': StreakService.getStreakBenefits(user.consecutiveDays),
      'aiTips': user.aiTips,
    };
  }

  /// 🏆 월간 성과 보고서 생성
  Future<Map<String, dynamic>> generateMonthlyReport() async {
    final user = await _userRepository.getUser();
    if (user == null) return {};

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthRecords = user.savingRecords.where((record) =>
      record.date.isAfter(monthStart.subtract(const Duration(days: 1)))
    ).toList();

    final totalSaved = monthRecords.fold<double>(0, (sum, record) => sum + record.amount);
    final recordCount = monthRecords.length;
    final avgPerDay = recordCount > 0 ? totalSaved / recordCount : 0.0;
    
    final achievementRate = user.monthlyGoal > 0 ? totalSaved / user.monthlyGoal : 0.0;
    
    // 월간 보너스 계산
    final monthlyBonus = StreakService.calculateMonthlyAchievementBonus(user);
    if (monthlyBonus > 0) {
      await _userRepository.updateCoins(monthlyBonus);
    }

    return {
      'totalSaved': totalSaved,
      'recordCount': recordCount,
      'averagePerRecord': avgPerDay,
      'goalAchievementRate': achievementRate,
      'monthlyBonus': monthlyBonus,
      'streak': user.consecutiveDays,
      'level': user.level,
      'achievements': user.achievements.length,
      'grade': _calculateMonthlyGrade(achievementRate, user.consecutiveDays),
    };
  }

  String _calculateMonthlyGrade(double achievementRate, int streak) {
    if (achievementRate >= 1.5 && streak >= 25) return 'S+';
    if (achievementRate >= 1.3 && streak >= 20) return 'S';
    if (achievementRate >= 1.1 && streak >= 15) return 'A+';
    if (achievementRate >= 1.0 && streak >= 10) return 'A';
    if (achievementRate >= 0.8 && streak >= 7) return 'B+';
    if (achievementRate >= 0.6) return 'B';
    if (achievementRate >= 0.4) return 'C';
    return 'D';
  }

  /// 🎁 럭키 드로우 시스템
  Future<Map<String, dynamic>> playLuckyDraw() async {
    final user = await _userRepository.getUser();
    if (user == null) throw GameException('사용자 데이터를 찾을 수 없습니다');
    
    if (user.coins < 100) {
      throw GameException('럭키 드로우에는 100P가 필요합니다.');
    }

    final random = Random();
    final luck = random.nextDouble();
    
    int prize = 0;
    String message = '';
    
    if (luck < 0.01) { // 1% 확률 대박
      prize = 5000;
      message = '🎊 대박! 5000P 획득!';
    } else if (luck < 0.05) { // 4% 확률 잭팟
      prize = 1000;
      message = '🎉 잭팟! 1000P 획득!';
    } else if (luck < 0.20) { // 15% 확률 성공
      prize = 300;
      message = '⭐ 성공! 300P 획득!';
    } else if (luck < 0.50) { // 30% 확률 소성공
      prize = 150;
      message = '👍 소성공! 150P 획득!';
    } else { // 50% 확률 위로상
      prize = 50;
      message = '😅 위로상! 50P 획득!';
    }

    // 100P 차감하고 당첨금 추가
    final finalCoins = -100 + prize;
    await _userRepository.updateCoins(finalCoins);

    LoggerService.info('Lucky draw: spent 100P, won ${prize}P');

    return {
      'spent': 100,
      'won': prize,
      'net': finalCoins,
      'message': message,
    };
  }
}