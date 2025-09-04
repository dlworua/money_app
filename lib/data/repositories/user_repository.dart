import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/enums/achievement_type.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/services/logger_service.dart';
import '../../core/utils/error_handler.dart';

class UserRepository {
  static const String _userKey = 'user_data';

  Future<UserModel?> getUser() async {
    try {
      LoggerService.info('Getting user data from SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userData = UserModel.fromJson(json.decode(userJson));
        LoggerService.info('User data loaded successfully');
        return userData;
      }

      LoggerService.info('Creating new user');
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Guest User',
        email: 'guest@example.com',
        coins: 0,
        isPremium: false,
        savingRecordsThisMonth: 0,
        level: 1,
        experience: 0,
        totalSaved: 0.0,
        monthlyGoal: AppConstants.defaultMonthlyGoal,
        currentMonthSaved: 0.0,
        consecutiveDays: 0,
        achievements: const [],
        categories: AppConstants.defaultCategories,
        dailySpinCount: 0,
        totalGamesPlayed: 0,
      );

      await saveUser(newUser);
      return newUser;
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace, context: 'getUser');
      throw UserDataException('사용자 데이터를 불러오는데 실패했습니다', originalError: error);
    }
  }

  Future<void> saveUser(UserModel user) async {
    try {
      LoggerService.info('Saving user data to SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(user.toJson()));
      LoggerService.info('User data saved successfully');
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace, context: 'saveUser');
      throw UserDataException('사용자 데이터를 저장하는데 실패했습니다', originalError: error);
    }
  }

  Future<void> updateCoins(int coins) async {
    final user = await getUser();
    if (user != null) {
      final updatedUser = user.copyWith(coins: user.coins + coins);
      await saveUser(updatedUser);
    }
  }

  Future<void> updateExperience(int experience) async {
    final user = await getUser();
    if (user == null) return;

    final newExperience = user.experience + experience;
    final newLevel = _calculateLevel(newExperience);
    final hasLeveledUp = newLevel > user.level;

    var updatedUser = user.copyWith(experience: newExperience, level: newLevel);

    // 레벨업 시 보너스 포인트 지급
    if (hasLeveledUp) {
      final levelUpBonus = newLevel * AppConstants.levelUpBonusMultiplier;
      updatedUser = updatedUser.copyWith(
        coins: updatedUser.coins + levelUpBonus,
      );
    }

    await saveUser(updatedUser);
  }

  Future<void> addSavingAmount(double amount, String category) async {
    final user = await getUser();
    if (user == null) return;

    final now = DateTime.now();
    final isNewMonth =
        user.lastCheckInDate == null ||
        user.lastCheckInDate!.month != now.month ||
        user.lastCheckInDate!.year != now.year;

    final newTotalSaved = user.totalSaved + amount;
    final newMonthSaved = isNewMonth ? amount : user.currentMonthSaved + amount;

    // 연속 일수 계산
    int newConsecutiveDays = user.consecutiveDays;
    if (user.lastCheckInDate == null ||
        _daysBetween(user.lastCheckInDate!, now) == 1) {
      newConsecutiveDays += 1;
    } else if (_daysBetween(user.lastCheckInDate!, now) > 1) {
      newConsecutiveDays = 1;
    }

    // 업적 체크
    final newAchievements = _checkAchievements(
      user,
      newTotalSaved,
      newConsecutiveDays,
    );

    final updatedUser = user.copyWith(
      totalSaved: newTotalSaved,
      currentMonthSaved: newMonthSaved,
      consecutiveDays: newConsecutiveDays,
      lastCheckInDate: now,
      achievements: newAchievements,
      savingRecordsThisMonth: isNewMonth ? 1 : user.savingRecordsThisMonth + 1,
    );

    await saveUser(updatedUser);

    // 경험치 추가 (절약 금액의 1%를 경험치로)
    await updateExperience((amount * 0.01).round());
  }

  Future<bool> canAddSavingRecord() async {
    final user = await getUser();
    if (user == null) return false;

    if (user.isPremium) return true;
    return user.savingRecordsThisMonth < AppConstants.freeUserMonthlyLimit;
  }

  int _calculateLevel(int experience) {
    return (experience / AppConstants.experiencePerLevel).floor() + 1;
  }

  int _daysBetween(DateTime from, DateTime to) {
    return (to.difference(from).inHours / 24).round();
  }

  List<String> _checkAchievements(
    UserModel user,
    double totalSaved,
    int consecutiveDays,
  ) {
    final achievements = List<String>.from(user.achievements);

    if (totalSaved >= AppConstants.firstSavingMilestone &&
        !achievements.contains(AchievementType.firstSaving.displayName)) {
      achievements.add(AchievementType.firstSaving.displayName);
    }

    if (totalSaved >= AppConstants.millionSavingMilestone &&
        !achievements.contains(AchievementType.millionSaving.displayName)) {
      achievements.add(AchievementType.millionSaving.displayName);
    }

    if (consecutiveDays >= AppConstants.weeklyConsecutiveDays &&
        !achievements.contains(AchievementType.weeklyStreak.displayName)) {
      achievements.add(AchievementType.weeklyStreak.displayName);
    }

    if (consecutiveDays >= AppConstants.monthlyConsecutiveDays &&
        !achievements.contains(AchievementType.monthlyStreak.displayName)) {
      achievements.add(AchievementType.monthlyStreak.displayName);
    }

    return achievements;
  }
}
