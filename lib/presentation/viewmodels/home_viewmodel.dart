import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/ai_coaching_service.dart';
import '../../core/enums/coaching_style.dart';
import '../../data/models/user_model.dart';
import '../../data/models/ai_coaching_insight.dart';
import '../../data/models/saving_record.dart';
import '../../data/models/transaction.dart';
import '../../data/models/budget.dart';
import '../../data/models/saving_goal.dart';
import '../../data/models/point_history.dart';
import '../../domain/services/user_service.dart';
import '../../domain/services/ad_service.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../core/utils/number_formatter.dart';

class HomeState {
  final UserModel? user;
  final bool isLoading;
  final BannerAd? bannerAd;
  final bool canWatchAd;
  final AiCoachingInsight? currentCoaching;
  final bool showCoachingDialog;
  final List<AiCoachingInsight> recentInsights;
  final List<Transaction> transactions;
  final List<Budget> budgets;
  final List<SavingGoal> goals;

  HomeState({
    this.user,
    this.isLoading = false,
    this.bannerAd,
    this.canWatchAd = true,
    this.currentCoaching,
    this.showCoachingDialog = false,
    this.recentInsights = const [],
    this.transactions = const [],
    this.budgets = const [],
    this.goals = const [],
  });

  HomeState copyWith({
    UserModel? user,
    bool? isLoading,
    BannerAd? bannerAd,
    bool? canWatchAd,
    AiCoachingInsight? currentCoaching,
    bool? showCoachingDialog,
    List<AiCoachingInsight>? recentInsights,
    List<Transaction>? transactions,
    List<Budget>? budgets,
    List<SavingGoal>? goals,
    bool clearBannerAd = false,
    bool clearCurrentCoaching = false,
  }) {
    return HomeState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      bannerAd: clearBannerAd ? null : (bannerAd ?? this.bannerAd),
      canWatchAd: canWatchAd ?? this.canWatchAd,
      currentCoaching: clearCurrentCoaching
          ? null
          : (currentCoaching ?? this.currentCoaching),
      showCoachingDialog: showCoachingDialog ?? this.showCoachingDialog,
      recentInsights: recentInsights ?? this.recentInsights,
      transactions: transactions ?? this.transactions,
      budgets: budgets ?? this.budgets,
      goals: goals ?? this.goals,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final UserService _userService;
  final AdService _adService;
  final AiCoachingService _aiCoaching;
  final TransactionRepository _transactionRepository;

  // 티켓 자동 충전 타이머 (1분마다 체크)
  Timer? _ticketRefillTimer;

  HomeViewModel(
    this._userService,
    this._adService,
    this._aiCoaching,
    this._transactionRepository,
  ) : super(HomeState()) {
    _init();
    _startTicketRefillTimer();
  }

  /// 티켓 자동 충전 타이머 시작 (1분마다 체크)
  void _startTicketRefillTimer() {
    _ticketRefillTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await updateTickets();
    });
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      // 사용자 데이터 로드
      final user = await _userService.getCurrentUser();
      if (user == null) {
        // 새 사용자 생성
        final now = DateTime.now();
        final newUser = UserModel(
          id: now.millisecondsSinceEpoch.toString(),
          name: '절약왕',
          email: 'user@example.com',
          preferredCoachingStyle: CoachingStyle.kind,
          enableDailyCoaching: true,
          lastTicketRefillTime: now, // 티켓 충전 시작 시간 설정
        );
        await _userService.saveUser(newUser);
        state = state.copyWith(user: newUser, isLoading: false);
      } else {
        // 기존 사용자이지만 lastTicketRefillTime이 null인 경우 초기화
        if (user.lastTicketRefillTime == null) {
          final updatedUser = user.copyWith(
            lastTicketRefillTime: DateTime.now(),
          );
          await _userService.saveUser(updatedUser);
          state = state.copyWith(user: updatedUser, isLoading: false);
        } else {
          state = state.copyWith(user: user, isLoading: false);
        }
      }

      // 데이터 로드를 먼저 완료
      await _loadAllData();

      // 티켓 자동 충전 확인
      await updateTickets();

      // 데이터가 로드된 후 AI 코칭 초기화
      await _initializeAiCoaching();

      // 광고 초기화
      await _initializeBannerAd();
    } catch (error) {
      LoggerService.error('HomeViewModel 초기화 실패: $error');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _initializeAiCoaching() async {
    final user = state.user;
    if (user == null) {
      LoggerService.error('🚫 AI 코칭 초기화: 사용자 정보 없음');
      return;
    }

    try {
      LoggerService.info('🤖 AI 코칭 초기화 시작...');
      
      // 기존 인사이트 로드
      final recentInsights = _aiCoaching.getRecentInsights(user, limit: 5);
      LoggerService.info('📚 기존 인사이트 ${recentInsights.length}개 로드됨');
      
      // 거래 데이터가 있다면 자동으로 한 번 AI 코칭 생성
      final transactions = state.transactions;
      final budgets = state.budgets;
      
      LoggerService.info('📊 현재 데이터: 거래 ${transactions.length}개, 예산 ${budgets.length}개');
      
      // 1건 이상의 거래가 있으면 자동으로 AI 코칭 생성
      if (transactions.isNotEmpty) {
        LoggerService.info('🎯 거래 데이터 발견 - AI 코칭 자동 생성 시작');
        
        // 새로운 개선된 AI 코칭 생성
        final coaching = await _aiCoaching.getFinancialCoaching(
          user,
          transactions,
          budgets,
        );
        
        LoggerService.info('💡 AI 코칭 생성됨: ${coaching.title}');
        LoggerService.info('📝 메시지: ${coaching.message.substring(0, 50)}...');
        
        final updatedUser = _aiCoaching.addCoachingInsight(user, coaching);
        await _userService.saveUser(updatedUser);
        
        state = state.copyWith(
          user: updatedUser,
          currentCoaching: coaching,
          recentInsights: [coaching, ...recentInsights].take(5).toList(),
        );
        
        LoggerService.info('✅ 자동 AI 코칭 홈화면 표시 완료!');
      } else {
        // 거래 데이터가 없을 때도 기본 환영 메시지 생성
        final welcomeCoaching = AiCoachingInsight(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          createdAt: DateTime.now(),
          style: user.preferredCoachingStyle,
          title: '🎉 가계부 관리 시작!',
          message: '안녕하세요! 가계부를 시작해보세요. 거래를 기록하시면 맞춤형 절약 조언을 받을 수 있어요.',
          type: InsightType.general,
          analysisData: {'isEmpty': true},
          confidenceScore: 1.0,
          actionItems: [
            '첫 번째 거래를 기록해보세요',
            '카테고리별로 정확히 분류하기',
            '꾸준히 기록하면 더 정확한 분석 받기'
          ],
        );
        
        final updatedUser = _aiCoaching.addCoachingInsight(user, welcomeCoaching);
        await _userService.saveUser(updatedUser);
        
        state = state.copyWith(
          user: updatedUser,
          currentCoaching: welcomeCoaching,
          recentInsights: [welcomeCoaching, ...recentInsights].take(5).toList(),
        );
        
        LoggerService.info('📝 환영 메시지 생성 및 표시 완료');
      }
      
      LoggerService.info('🎉 AI 코칭 초기화 완료!');
    } catch (error, stackTrace) {
      LoggerService.error('❌ AI 코칭 초기화 실패: $error');
      LoggerService.error('스택 트레이스: $stackTrace');
    }
  }

  Future<void> _initializeBannerAd() async {
    try {
      final bannerAd = BannerAd(
        adUnitId: AppConstants.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            LoggerService.info('배너 광고 로드 완료');
            state = state.copyWith(bannerAd: ad as BannerAd);
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            LoggerService.error('배너 광고 로드 실패: $error');
            ad.dispose();
          },
        ),
      );
      await bannerAd.load();
    } catch (error) {
      LoggerService.error('배너 광고 초기화 실패: $error');
    }
  }

  // AI 코칭 관련 메서드들

  /// 코칭 스타일 변경
  Future<void> changeCoachingStyle(CoachingStyle style) async {
    final user = state.user;
    if (user == null) return;

    try {
      final updatedUser = _aiCoaching.updateCoachingStyle(user, style);
      await _userService.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);

      // 새로운 스타일로 코칭 생성
      await requestPersonalizedCoaching();
    } catch (error) {
      LoggerService.error('코칭 스타일 변경 실패: $error');
    }
  }

  /// 맞춤형 코칭 요청 (사용자가 직접 요청할 때만)
  Future<void> requestPersonalizedCoaching() async {
    final user = state.user;
    if (user == null) return;

    LoggerService.info('🤖 사용자가 맞춤 코칭을 요청했습니다!');

    try {
      // 가계부 데이터 기반 맞춤 코칭
      final transactions = _getUserTransactions();
      final budgets = _getUserBudgets();

      LoggerService.info(
        '📊 데이터 준비: 거래내역 ${transactions.length}개, 예산 ${budgets.length}개',
      );

      // 예산 초과가 있는지 먼저 체크 (더 중요한 알림)
      final budgetAlert = await _aiCoaching.getBudgetOverspendAlert(
        user,
        transactions,
        budgets,
      );

      AiCoachingInsight coaching;

      // 데이터가 없는 경우 안내 메시지 표시
      if (transactions.isEmpty && budgets.isEmpty) {
        coaching = AiCoachingInsight(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          createdAt: DateTime.now(),
          style: user.preferredCoachingStyle,
          title: '🎯 가계부 시작하기',
          message:
              '아직 거래내역과 예산이 없네요! 가계부 탭에서 수입, 지출, 예산을 추가해보세요. 데이터가 쌓이면 더 정교한 절약 조언을 받을 수 있어요!',
          type: InsightType.general,
          analysisData: {'isEmpty': true},
          confidenceScore: 1.0,
          actionItems: [
            '가계부 → 거래 추가 버튼으로 수입/지출을 기록해보세요',
            '가계부 → 예산 탭에서 월 예산을 설정해보세요',
            '가계부 → 목표 탭에서 절약 목표를 만들어보세요',
          ],
        );
        LoggerService.info('📋 빈 데이터 - 시작 가이드 제공');
      } else if (budgetAlert != null) {
        coaching = budgetAlert;
        LoggerService.info('⚠️ 예산 초과 감지: ${coaching.title}');
      } else {
        coaching = await _aiCoaching.getFinancialCoaching(
          user,
          transactions,
          budgets,
        );
        LoggerService.info('💡 일반 재무 코칭: ${coaching.title}');
      }

      final updatedUser = _aiCoaching.addCoachingInsight(user, coaching);
      await _userService.saveUser(updatedUser);

      // 절약 기회도 함께 로드
      final opportunities = await _aiCoaching.getSavingOpportunityAlerts(
        user,
        transactions,
        budgets,
      );
      LoggerService.info('🎯 절약 기회 ${opportunities.length}개 발견');

      state = state.copyWith(
        user: updatedUser,
        currentCoaching: coaching,
        showCoachingDialog: true,
        recentInsights: [
          ...opportunities,
          ..._aiCoaching.getRecentInsights(updatedUser, limit: 3),
        ],
      );

      LoggerService.info('✅ 코칭 다이얼로그 표시 완료!');
    } catch (error) {
      LoggerService.error('❌ 맞춤형 코칭 요청 실패: $error');

      // 에러가 발생해도 기본 코칭은 제공
      final defaultCoaching = AiCoachingInsight(
        id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        style: user.preferredCoachingStyle,
        title: '🤖 AI 절약 코치',
        message: '죄송합니다! 일시적인 오류가 발생했어요. 가계부를 더 작성해주시면 맞춤형 분석을 제공할게요!',
        type: InsightType.general,
        analysisData: {'error': error.toString()},
        confidenceScore: 1.0,
        actionItems: ['수입과 지출을 꾸준히 기록해보세요.', '잠시 후 다시 시도해보세요.'],
      );

      final updatedUser = _aiCoaching.addCoachingInsight(user, defaultCoaching);
      await _userService.saveUser(updatedUser);

      state = state.copyWith(
        user: updatedUser,
        currentCoaching: defaultCoaching,
        showCoachingDialog: true,
      );

      LoggerService.info('🆘 폴백 코칭 표시됨');
    }
  }

  /// 성취 축하 메시지 생성
  Future<void> celebrateAchievement(String achievement) async {
    final user = state.user;
    if (user == null) return;

    try {
      final coaching = await _aiCoaching.generateAchievementCelebration(
        user,
        achievement,
      );
      final updatedUser = _aiCoaching.addCoachingInsight(user, coaching);
      await _userService.saveUser(updatedUser);

      state = state.copyWith(
        user: updatedUser,
        currentCoaching: coaching,
        showCoachingDialog: true,
        recentInsights: _aiCoaching.getRecentInsights(updatedUser, limit: 5),
      );
    } catch (error) {
      LoggerService.error('성취 축하 메시지 생성 실패: $error');
    }
  }

  /// 경고 메시지 생성
  Future<void> showUrgentWarning() async {
    final user = state.user;
    if (user == null) return;

    try {
      final coaching = await _aiCoaching.generateUrgentWarning(user);
      final updatedUser = _aiCoaching.addCoachingInsight(user, coaching);
      await _userService.saveUser(updatedUser);

      state = state.copyWith(
        user: updatedUser,
        currentCoaching: coaching,
        showCoachingDialog: true,
        recentInsights: _aiCoaching.getRecentInsights(updatedUser, limit: 5),
      );
    } catch (error) {
      LoggerService.error('경고 메시지 생성 실패: $error');
    }
  }

  /// 주간 리뷰 생성
  Future<void> generateWeeklyReview() async {
    final user = state.user;
    if (user == null) return;

    try {
      final coaching = await _aiCoaching.generateWeeklyReview(user);
      if (coaching != null) {
        final updatedUser = _aiCoaching.addCoachingInsight(user, coaching);
        await _userService.saveUser(updatedUser);

        state = state.copyWith(
          user: updatedUser,
          currentCoaching: coaching,
          showCoachingDialog: true,
          recentInsights: _aiCoaching.getRecentInsights(updatedUser, limit: 5),
        );
      }
    } catch (error) {
      LoggerService.error('주간 리뷰 생성 실패: $error');
    }
  }

  /// 코칭 읽음 표시
  Future<void> markCoachingAsRead(String insightId) async {
    final user = state.user;
    if (user == null) return;

    try {
      final updatedUser = _aiCoaching.markInsightAsRead(user, insightId);
      await _userService.saveUser(updatedUser);
      state = state.copyWith(
        user: updatedUser,
        recentInsights: _aiCoaching.getRecentInsights(updatedUser, limit: 5),
      );
    } catch (error) {
      LoggerService.error('코칭 읽음 표시 실패: $error');
    }
  }

  /// 코칭 다이얼로그 닫기
  void dismissCoachingDialog() {
    if (state.currentCoaching != null) {
      markCoachingAsRead(state.currentCoaching!.id);
    }
    state = state.copyWith(
      showCoachingDialog: false,
      clearCurrentCoaching: true,
    );
  }

  /// AI 코칭 설정 업데이트
  Future<void> updateCoachingSettings({
    bool? enableDailyCoaching,
    bool? enableWeeklyReview,
  }) async {
    final user = state.user;
    if (user == null) return;

    try {
      final updatedUser = _aiCoaching.updateCoachingSettings(
        user,
        enableDailyCoaching: enableDailyCoaching,
        enableWeeklyReview: enableWeeklyReview,
      );
      await _userService.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);
    } catch (error) {
      LoggerService.error('코칭 설정 업데이트 실패: $error');
    }
  }

  /// 코칭 통계 가져오기
  Map<String, dynamic> getCoachingStats() {
    final user = state.user;
    if (user == null) return {};
    return _aiCoaching.getCoachingStats(user);
  }

  /// 읽지 않은 인사이트 개수
  int getUnreadInsightCount() {
    final user = state.user;
    if (user == null) return 0;
    return _aiCoaching.getUnreadInsightCount(user);
  }

  // 기존 광고 관련 메서드들

  /// 리워드 광고 시청
  Future<void> watchRewardedAd() async {
    final user = state.user;
    if (user == null || !state.canWatchAd) return;

    try {
      state = state.copyWith(canWatchAd: false);
      final rewardedAd = await _adService.loadRewardedAd();
      if (rewardedAd != null) {
        await _adService.showRewardedAd(rewardedAd);
      }

      // 광고 시청 성공으로 가정하고 포인트 추가
      final updatedUser = await _addPointHistory(
        user,
        PointHistoryType.earn,
        PointHistorySource.adWatch,
        AppConstants.rewardedAdCoins,
        '리워드 광고 시청',
      );
      await _userService.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);

      // 광고 시청 성취 축하 제거 (AI 코칭 없음)
    } catch (error) {
      LoggerService.error('리워드 광고 시청 실패: $error');
    } finally {
      // 1시간 후 다시 시청 가능
      Future.delayed(const Duration(hours: 1), () {
        try {
          state = state.copyWith(canWatchAd: true);
        } catch (e) {
          // StateNotifier가 dispose된 경우 무시
        }
      });
    }
  }

  /// 인터스티셜 광고 시청
  Future<void> showInterstitialAd() async {
    try {
      await _adService.showInterstitialAd();

      final user = state.user;
      if (user != null) {
        final updatedUser = user.copyWith(
          coins: user.coins + AppConstants.interstitialAdCoins,
        );
        await _userService.saveUser(updatedUser);
        state = state.copyWith(user: updatedUser);
      }
    } catch (error) {
      LoggerService.error('인터스티셜 광고 실패: $error');
    }
  }

  /// 숫자 맞추기 게임 플레이
  Future<bool> playNumberGuessGame(int guessedNumber) async {
    final user = state.user;
    if (user == null) return false;

    try {
      // 1~10 랜덤 숫자 생성
      final correctNumber = DateTime.now().millisecond % 10 + 1;
      final isCorrect = guessedNumber == correctNumber;

      if (isCorrect) {
        // 정답시 포인트 보상
        final rewardCoins = 20;
        final updatedUser = await _addPointHistory(
          user,
          PointHistoryType.earn,
          PointHistorySource.numberGuessGame,
          rewardCoins,
          '숫자 맞추기 게임 성공',
        );
        final finalUser = updatedUser.copyWith(
          totalGamesPlayed: user.totalGamesPlayed + 1,
        );
        await _userService.saveUser(finalUser);
        state = state.copyWith(user: finalUser);

        // 성취 축하 제거 (AI 코칭 없음)
      } else {
        // 오답시 게임 카운트만 증가
        final updatedUser = user.copyWith(
          totalGamesPlayed: user.totalGamesPlayed + 1,
        );
        await _userService.saveUser(updatedUser);
        state = state.copyWith(user: updatedUser);
      }

      return isCorrect;
    } catch (error) {
      LoggerService.error('숫자 맞추기 게임 실패: $error');
      return false;
    }
  }

  /// 일일 보상 받기
  Future<void> claimDailyReward() async {
    final user = state.user;
    if (user == null) return;

    // 일일 보상 수령 가능 여부 확인
    if (user.lastSpinDate != null) {
      final daysSinceLastSpin = DateTime.now()
          .difference(user.lastSpinDate!)
          .inDays;
      if (daysSinceLastSpin < 1) return; // 하루가 지나지 않았으면 리턴
    }

    try {
      final baseReward = 100;
      final streakBonus = user.consecutiveDays * 5; // 연속일 당 5포인트 보너스
      final totalReward = baseReward + streakBonus;

      final tempUser = await _addPointHistory(
        user,
        PointHistoryType.earn,
        PointHistorySource.dailyBonus,
        totalReward,
        '일일 보너스 (연속 ${user.consecutiveDays + 1}일)',
      );
      final updatedUser = tempUser.copyWith(
        dailySpinCount: user.dailySpinCount + 1,
        lastSpinDate: DateTime.now(),
        consecutiveDays: user.consecutiveDays + 1,
        lastCheckInDate: DateTime.now(),
      );

      await _userService.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);

      // 성취 축하 제거 (AI 코칭 없음)
    } catch (error) {
      LoggerService.error('일일 보상 수령 실패: $error');
    }
  }

  /// 절약 기록 추가
  Future<void> addSavingRecord(
    double amount,
    String category,
    String description,
  ) async {
    final user = state.user;
    if (user == null) return;

    try {
      // SavingRecord 생성 (import 필요)
      final savingRecord = SavingRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        category: category,
        description: description,
        date: DateTime.now(),
      );

      // 새로운 절약 기록 추가
      final updatedRecords = [...user.savingRecords, savingRecord];

      // 사용자 데이터 업데이트
      final updatedUser = user.copyWith(
        savingRecords: updatedRecords,
        currentMonthSaved: user.currentMonthSaved + amount,
        totalSaved: user.totalSaved + amount,
        consecutiveDays: _calculateConsecutiveDays(user, DateTime.now()),
        lastCheckInDate: DateTime.now(),
        coins: user.coins + (amount / 1000).round(), // 1000원당 1포인트
      );

      await _userService.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);

      // AI 코칭 제거 (자동 축하 없음)
    } catch (error) {
      LoggerService.error('절약 기록 추가 실패: $error');
    }
  }

  /// 연속 절약 일수 계산
  int _calculateConsecutiveDays(UserModel user, DateTime newDate) {
    if (user.lastCheckInDate == null) return 1;

    final daysDiff = newDate.difference(user.lastCheckInDate!).inDays;

    if (daysDiff == 1) {
      // 연속 기록
      return user.consecutiveDays + 1;
    } else if (daysDiff == 0) {
      // 같은 날
      return user.consecutiveDays;
    } else {
      // 연속 기록 끊김
      return 1;
    }
  }

  // 모든 데이터 로드
  Future<void> _loadAllData() async {
    try {
      final transactions = await _transactionRepository.getTransactions();
      
      // 예산과 목표는 거래 데이터와 연동하여 업데이트
      final updatedBudgets = await _transactionRepository.updateAllBudgetSpending();
      final updatedGoals = await _transactionRepository.updateAllGoalProgress();

      state = state.copyWith(
        transactions: transactions,
        budgets: updatedBudgets,
        goals: updatedGoals,
      );

      LoggerService.info(
        '모든 데이터 로드 완료 - 거래: ${transactions.length}, 예산: ${updatedBudgets.length}, 목표: ${updatedGoals.length}',
      );

      // 기존 데이터 상태 로그
      if (transactions.isNotEmpty) {
        LoggerService.info('💾 기존 거래 내역 발견: ${transactions.length}건');
        final recentTransaction = transactions.last;
        LoggerService.info('🔍 최근 거래: ${recentTransaction.description} ${recentTransaction.amount}원');
        
        // 몇 개 거래 내용 출력해서 확인
        for (int i = 0; i < transactions.length && i < 3; i++) {
          final t = transactions[i];
          LoggerService.info('   거래 ${i+1}: ${t.description} ${t.amount}원 (${t.date.toString().substring(0, 10)})');
        }
      } else {
        LoggerService.info('📭 저장된 거래 내역이 없습니다');
      }
    } catch (error) {
      LoggerService.error('데이터 로드 실패: $error');
    }
  }

  // 연관 데이터 업데이트 (거래 추가 후 예산/목표 재계산 + AI 코칭 업데이트)
  Future<void> _updateRelatedData() async {
    try {
      final updatedBudgets = await _transactionRepository
          .updateAllBudgetSpending();
      final updatedGoals = await _transactionRepository.updateAllGoalProgress();
      final transactions = await _transactionRepository.getTransactions();

      // UI 먼저 즉시 업데이트 (빠른 반응성)
      state = state.copyWith(
        transactions: transactions,
        budgets: updatedBudgets,
        goals: updatedGoals,
      );

      // AI 코칭은 백그라운드에서 처리 (블로킹 없음)
      _updateAiCoachingAfterTransaction();
    } catch (error) {
      LoggerService.error('연관 데이터 업데이트 실패: $error');
    }
  }

  // 거래 후 AI 코칭 업데이트
  Future<void> _updateAiCoachingAfterTransaction() async {
    final user = state.user;
    if (user == null) {
      LoggerService.error('🚫 거래 후 AI 업데이트: 사용자 정보 없음');
      return;
    }

    try {
      LoggerService.info('🔄 거래 후 AI 코칭 업데이트 시작...');
      
      // 새로운 거래 데이터를 기반으로 AI 코칭 생성
      final transactions = state.transactions;
      final budgets = state.budgets;
      
      LoggerService.info('📊 업데이트된 데이터: 거래 ${transactions.length}개, 예산 ${budgets.length}개');

      // 예산 초과 체크가 우선
      final budgetAlert = await _aiCoaching.getBudgetOverspendAlert(
        user, transactions, budgets);

      if (budgetAlert != null) {
        LoggerService.info('⚠️ 예산 초과 감지됨!');
        
        // 예산 초과시 즉시 알림
        final updatedUser = _aiCoaching.addCoachingInsight(user, budgetAlert);
        await _userService.saveUser(updatedUser);
        
        state = state.copyWith(
          user: updatedUser,
          currentCoaching: budgetAlert,
        );
        LoggerService.info('💥 예산 초과 알림 UI 업데이트: ${budgetAlert.title}');
      } else {
        LoggerService.info('💡 일반 재무 코칭 생성 중...');
        
        // 일반적인 재무 코칭 업데이트
        final coaching = await _aiCoaching.getFinancialCoaching(
          user, transactions, budgets);
        
        LoggerService.info('✨ 새 AI 코칭 생성: ${coaching.title}');
        LoggerService.info('📝 메시지: ${coaching.message.substring(0, 50)}...');
        
        final updatedUser = _aiCoaching.addCoachingInsight(user, coaching);
        await _userService.saveUser(updatedUser);
        
        state = state.copyWith(
          user: updatedUser,
          currentCoaching: coaching,
        );
        LoggerService.info('🎯 재무 코칭 UI 업데이트 완료!');
      }
    } catch (error, stackTrace) {
      LoggerService.error('❌ 거래 후 AI 코칭 업데이트 실패: $error');
      LoggerService.error('스택 트레이스: $stackTrace');
    }
  }

  // 빈 거래내역으로 초기화 (사용자가 직접 추가)
  List<Transaction> _getUserTransactions() {
    return state.transactions;
  }

  // 빈 예산으로 초기화 (사용자가 직접 추가)
  List<Budget> _getUserBudgets() {
    return state.budgets;
  }

  // 거래 추가 기능
  Future<void> addTransaction({
    required TransactionType type,
    required TransactionCategory category,
    required double amount,
    required String description,
    DateTime? date,
    String? note,
  }) async {
    try {
      final transaction = Transaction(
        type: type,
        category: category,
        amount: amount,
        description: description,
        date: date ?? DateTime.now(),
        note: note,
      );

      // Repository에 저장
      await _transactionRepository.saveTransaction(transaction);

      // 거래 추가 후 예산과 목표 업데이트
      await _updateRelatedData();

      LoggerService.info(
        '✅ 거래 추가됨: ${transaction.description} ${transaction.amount}원',
      );
    } catch (error) {
      LoggerService.error('❌ 거래 추가 실패: $error');
      rethrow;
    }
  }

  // 예산 추가 기능
  Future<void> addBudget({
    required String name,
    required double amount,
    required TransactionCategory category,
    required BudgetPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final now = DateTime.now();
      final budget = Budget(
        id: 'budget_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        amount: amount,
        category: category,
        period: period,
        startDate: startDate ?? DateTime(now.year, now.month, 1),
        endDate: endDate ?? DateTime(now.year, now.month + 1, 0),
        spent: 0.0,
      );

      // Repository에 저장
      await _transactionRepository.saveBudget(budget);

      // 상태 업데이트
      final updatedBudgets = [...state.budgets, budget];
      state = state.copyWith(budgets: updatedBudgets);

      LoggerService.info('✅ 예산 추가됨: ${budget.name} ${budget.amount}원');
    } catch (error) {
      LoggerService.error('❌ 예산 추가 실패: $error');
      rethrow;
    }
  }

  // 절약 목표 추가 기능
  Future<void> addSavingGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    String? description,
  }) async {
    try {
      final goal = SavingGoal.create(
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
        description: description,
      );

      // Repository에 저장
      await _transactionRepository.saveSavingGoal(goal);

      // 상태 업데이트
      final updatedGoals = [...state.goals, goal];
      state = state.copyWith(goals: updatedGoals);

      LoggerService.info('✅ 절약 목표 추가됨: ${goal.name} ${goal.targetAmount}원');
    } catch (error) {
      LoggerService.error('❌ 절약 목표 추가 실패: $error');
      rethrow;
    }
  }

  // 월 절약 목표 업데이트 기능
  Future<void> updateMonthlyGoal(double newGoal) async {
    try {
      final user = state.user;
      if (user == null) return;

      final updatedUser = user.copyWith(monthlyGoal: newGoal);
      await _userService.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);

      LoggerService.info('✅ 월 절약 목표 업데이트됨: ${NumberFormatter.formatWon(newGoal)}');
    } catch (error) {
      LoggerService.error('❌ 월 절약 목표 업데이트 실패: $error');
      rethrow;
    }
  }

  // 일일 예산 업데이트 기능
  Future<void> updateDailyBudget(double newBudget) async {
    try {
      final user = state.user;
      if (user == null) return;

      final updatedUser = user.copyWith(dailyBudget: newBudget);
      await _userService.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);

      LoggerService.info('✅ 일일 예산 업데이트됨: ${NumberFormatter.formatWon(newBudget)}');
    } catch (error) {
      LoggerService.error('❌ 일일 예산 업데이트 실패: $error');
      rethrow;
    }
  }

  /// 금융 퀴즈 플레이
  Future<void> playFinancialQuiz(int wonCoins) async {
    final user = state.user;
    if (user == null) return;
    try {
      final updatedUser = await _addPointHistory(
        user,
        PointHistoryType.earn,
        PointHistorySource.financialQuiz,
        wonCoins,
        '금융 퀴즈 완료',
      );
      final finalUser = updatedUser.copyWith(
        totalGamesPlayed: user.totalGamesPlayed + 1,
      );
      await _userService.saveUser(finalUser);
      state = state.copyWith(user: finalUser);

      LoggerService.info('금융퀴즈 완료: $wonCoins 포인트 획득');
    } catch (error) {
      LoggerService.error('금융퀴즈 실패: $error');
    }
  }

  /// 반응속도 게임 플레이
  Future<void> playColorReactionGame(int wonCoins) async {
    final user = state.user;
    if (user == null) return;
    try {
      final updatedUser = await _addPointHistory(
        user,
        PointHistoryType.earn,
        PointHistorySource.colorReaction,
        wonCoins,
        '반응속도 테스트 완료',
      );
      final finalUser = updatedUser.copyWith(
        totalGamesPlayed: user.totalGamesPlayed + 1,
      );
      await _userService.saveUser(finalUser);
      state = state.copyWith(user: finalUser);

      LoggerService.info('반응속도 게임 완료: $wonCoins 포인트 획득');
    } catch (error) {
      LoggerService.error('반응속도 게임 실패: $error');
    }
  }

  /// 스피드 타이핑 게임 플레이
  Future<void> playSpeedTypingGame(int wonCoins) async {
    final user = state.user;
    if (user == null) return;
    try {
      final updatedUser = await _addPointHistory(
        user,
        PointHistoryType.earn,
        PointHistorySource.speedTyping,
        wonCoins,
        '스피드 타이핑 완료',
      );
      final finalUser = updatedUser.copyWith(
        totalGamesPlayed: user.totalGamesPlayed + 1,
      );
      await _userService.saveUser(finalUser);
      state = state.copyWith(user: finalUser);

      LoggerService.info('스피드 타이핑 게임 완료: $wonCoins 포인트 획득');
    } catch (error) {
      LoggerService.error('스피드 타이핑 게임 실패: $error');
    }
  }

  /// 영단어 게임 플레이
  Future<void> playVocabularyGame(int wonCoins) async {
    final user = state.user;
    if (user == null) return;
    try {
      final updatedUser = await _addPointHistory(
        user,
        PointHistoryType.earn,
        PointHistorySource.vocabularyGame,
        wonCoins,
        '영단어 퀴즈 완료',
      );
      final finalUser = updatedUser.copyWith(
        totalGamesPlayed: user.totalGamesPlayed + 1,
      );
      await _userService.saveUser(finalUser);
      state = state.copyWith(user: finalUser);

      LoggerService.info('영단어 게임 완료: $wonCoins포인트 획득');
    } catch (error) {
      LoggerService.error('영단어 게임 실패: $error');
    }
  }

  /// 카드 뒤집기 게임 플레이
  Future<void> playCardFlipGame(int wonCoins) async {
    final user = state.user;
    if (user == null) return;
    try {
      final updatedUser = await _addPointHistory(
        user,
        PointHistoryType.earn,
        PointHistorySource.cardFlipGame,
        wonCoins,
        '카드 뒤집기 게임 완료',
      );
      final finalUser = updatedUser.copyWith(
        totalGamesPlayed: user.totalGamesPlayed + 1,
      );
      await _userService.saveUser(finalUser);
      state = state.copyWith(user: finalUser);

      LoggerService.info('카드 뒤집기 게임 완료: $wonCoins 포인트 획득');
    } catch (error) {
      LoggerService.error('카드 뒤집기 게임 실패: $error');
    }
  }

  /// 예산 삭제
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _transactionRepository.deleteBudget(budgetId);
      final updatedBudgets = state.budgets.where((b) => b.id != budgetId).toList();
      state = state.copyWith(budgets: updatedBudgets);
      
      LoggerService.info('✅ 예산 삭제됨: $budgetId');
    } catch (error) {
      LoggerService.error('❌ 예산 삭제 실패: $error');
      rethrow;
    }
  }

  /// 절약 목표 삭제
  Future<void> deleteSavingGoal(String goalId) async {
    try {
      await _transactionRepository.deleteSavingGoal(goalId);
      final updatedGoals = state.goals.where((g) => g.id != goalId).toList();
      state = state.copyWith(goals: updatedGoals);
      
      LoggerService.info('✅ 절약 목표 삭제됨: $goalId');
    } catch (error) {
      LoggerService.error('❌ 절약 목표 삭제 실패: $error');
      rethrow;
    }
  }


  /// 포인트 히스토리 추가 Helper 메서드
  Future<UserModel> _addPointHistory(
    UserModel user,
    PointHistoryType type,
    PointHistorySource source,
    int amount,
    String description,
  ) async {
    final history = PointHistory(
      id: 'history_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      source: source,
      amount: amount,
      createdAt: DateTime.now(),
      description: description,
    );

    final updatedHistory = [history, ...user.pointHistory];
    final newCoins = type == PointHistoryType.earn 
        ? user.coins + amount 
        : user.coins - amount;

    return user.copyWith(
      coins: newCoins,
      pointHistory: updatedHistory,
    );
  }

  // 🎫 티켓 시스템 관련 메서드들
  
  /// 티켓 자동 충전 확인 및 업데이트
  Future<void> updateTickets() async {
    final user = state.user;
    if (user == null) return;
    
    final now = DateTime.now();
    final lastRefill = user.lastTicketRefillTime ?? now;
    final timeSinceLastRefill = now.difference(lastRefill);

    // 15분(900초)마다 1개씩 충전, 최대 maxTickets개
    const refillInterval = 900; // 15분
    final ticketsToAdd = (timeSinceLastRefill.inSeconds / refillInterval).floor();

    if (ticketsToAdd > 0 && user.gameTickets < user.maxTickets) {
      var newTickets = user.gameTickets + ticketsToAdd;
      var newMaxTickets = user.maxTickets;

      // 티켓이 기본 최대치(10)를 초과하는 경우, maxTickets를 점진적으로 줄임
      if (newTickets > 10) {
        final excessTickets = newTickets - 10;
        newMaxTickets = (user.maxTickets - excessTickets).clamp(10, user.maxTickets);
        newTickets = newTickets.clamp(0, newMaxTickets);
      } else {
        newTickets = newTickets.clamp(0, user.maxTickets);
      }

      // lastTicketRefillTime을 충전된 티켓 수만큼 앞으로 이동 (남은 초 유지)
      final newLastRefillTime = lastRefill.add(Duration(seconds: ticketsToAdd * refillInterval));

      final updatedUser = user.copyWith(
        gameTickets: newTickets,
        maxTickets: newMaxTickets,
        lastTicketRefillTime: newLastRefillTime,
      );

      await _userService.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);
      
      LoggerService.info('🎫 티켓 자동 충전: ${user.gameTickets} → $newTickets');
    }
  }
  
  /// 게임 시작 시 티켓 1개 소모
  Future<bool> consumeTicket() async {
    final user = state.user;
    if (user == null) return false;
    
    // 먼저 티켓 충전 확인
    await updateTickets();
    final updatedUser = state.user!;
    
    if (updatedUser.gameTickets <= 0) {
      LoggerService.info('🎫 티켓 부족: ${updatedUser.gameTickets}');
      return false;
    }

    final now = DateTime.now();
    final wasMaxTickets = updatedUser.gameTickets >= updatedUser.maxTickets;

    final finalUser = updatedUser.copyWith(
      gameTickets: updatedUser.gameTickets - 1,
      // 최대 티켓에서 소모한 경우, 타이머를 15분으로 리셋
      lastTicketRefillTime: wasMaxTickets ? now : updatedUser.lastTicketRefillTime,
    );

    await _userService.saveUser(finalUser);
    state = state.copyWith(user: finalUser);

    LoggerService.info('🎫 티켓 소모: ${updatedUser.gameTickets} → ${finalUser.gameTickets}${wasMaxTickets ? ' (타이머 리셋)' : ''}');
    return true;
  }
  
  /// 리워드 광고 시청으로 티켓 3개 지급
  Future<void> watchAdForTickets() async {
    final user = state.user;
    if (user == null) return;
    
    try {
      // 리워드 광고 로드 및 표시
      final rewardedAd = await _adService.loadRewardedAd();
      if (rewardedAd != null) {
        await _adService.showRewardedAd(rewardedAd);
        
        // 티켓 3개 추가
        var newTickets = user.gameTickets + 3;
        var newMaxTickets = user.maxTickets;
        
        // 리워드로 얻은 티켓이 기본 최대치를 초과하면 maxTickets 증가
        if (newTickets > user.maxTickets) {
          newMaxTickets = newTickets;
        }
        
        final updatedUser = user.copyWith(
          gameTickets: newTickets,
          maxTickets: newMaxTickets,
        );
        
        await _userService.saveUser(updatedUser);
        state = state.copyWith(user: updatedUser);
        
        LoggerService.info('🎫 광고 시청으로 티켓 획득: ${user.gameTickets} → $newTickets');
      }
    } catch (error) {
      LoggerService.error('🎫 티켓 광고 시청 실패: $error');
      rethrow;
    }
  }
  
  /// 리워드 광고 시청으로 포인트 50개 지급
  Future<void> watchAdForPoints() async {
    final user = state.user;
    if (user == null) return;
    
    try {
      // 리워드 광고 로드 및 표시
      final rewardedAd = await _adService.loadRewardedAd();
      if (rewardedAd != null) {
        await _adService.showRewardedAd(rewardedAd);
        
        // 포인트 50개 추가
        final updatedUser = await _addPointHistory(
          user,
          PointHistoryType.earn,
          PointHistorySource.adWatch,
          50,
          '리워드 광고 시청',
        );
        
        await _userService.saveUser(updatedUser);
        state = state.copyWith(user: updatedUser);
        
        LoggerService.info('💰 광고 시청으로 포인트 획득: +50');
      }
    } catch (error) {
      LoggerService.error('💰 포인트 광고 시청 실패: $error');
      rethrow;
    }
  }
  
  /// 티켓 충전까지 남은 시간 계산 (초 단위)
  int getTimeUntilNextTicket() {
    final user = state.user;
    if (user == null || user.gameTickets >= user.maxTickets) return 0;
    
    final now = DateTime.now();
    final lastRefill = user.lastTicketRefillTime ?? now;
    final timeSinceLastRefill = now.difference(lastRefill);
    
    return (300 - (timeSinceLastRefill.inSeconds % 300)).clamp(0, 300);
  }

  // 🎯 프리미엄 관련 메서드들

  /// 프리미엄 상태 토글 (목 데이터용)
  Future<void> togglePremium() async {
    final user = state.user;
    if (user == null) return;

    try {
      final updatedUser = user.copyWith(isPremium: !user.isPremium);
      await _userService.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);

      LoggerService.info('프리미엄 상태 변경: ${updatedUser.isPremium}');
    } catch (error) {
      LoggerService.error('프리미엄 상태 변경 실패: $error');
    }
  }

  @override
  void dispose() {
    _ticketRefillTimer?.cancel();
    state.bannerAd?.dispose();
    super.dispose();
  }
}
