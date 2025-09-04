import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../enums/coaching_style.dart';
import 'ai_coaching_service.dart';

// AI 코칭 서비스 프로바이더
final aiCoachingServiceProvider = Provider<AiCoachingService>((ref) {
  return AiCoachingService();
});

// 사용 예시 클래스
class AiCoachingExample {
  static Future<void> demonstrateAiCoaching() async {
    final coachingService = AiCoachingService();

    // 예시 사용자 (실제로는 UserRepository에서 가져옴)
    UserModel user = UserModel(
      id: 'user123',
      name: '김절약',
      email: 'save@example.com',
      coins: 1500,
      monthlyGoal: 200000,
      currentMonthSaved: 150000,
      consecutiveDays: 15,
      preferredCoachingStyle: CoachingStyle.friendly,
      enableDailyCoaching: true,
    );

    // 1. 일일 코칭 체크
    final dailyCoaching = await coachingService.checkDailyCoaching(user);
    if (dailyCoaching != null) {
      // 로깅: 일일 코칭 제목과 메시지
      // dailyCoaching.title, dailyCoaching.message 사용

      // 사용자 데이터에 코칭 추가
      user = coachingService.addCoachingInsight(user, dailyCoaching);
    }

    // 2. 코칭 스타일 변경
    user = coachingService.updateCoachingStyle(
      user,
      CoachingStyle.motivational,
    );

    // 3. 새로운 스타일로 코칭 받기
    final motivationalCoaching = await coachingService.getPersonalizedCoaching(
      user,
    );
    // 로깅: motivationalCoaching.message 사용
    user = coachingService.addCoachingInsight(user, motivationalCoaching);

    // 4. 성취 축하 메시지
    final achievement = await coachingService.generateAchievementCelebration(
      user,
      '15일 연속 절약',
    );
    // 로깅: achievement.message 사용
    user = coachingService.addCoachingInsight(user, achievement);

    // 5. 주간 리뷰
    final weeklyReview = await coachingService.generateWeeklyReview(user);
    if (weeklyReview != null) {
      // 로깅: weeklyReview.message 사용
    }

    // 6. 코칭 통계
    coachingService.getCoachingStats(user);
    // 로깅: stats 사용 - 예시: stats['totalInsights'], stats['averageConfidence']
  }
}

// HomeViewModel에서 AI 코칭 사용 예시
class HomeViewModelWithAI extends StateNotifier<AsyncValue<UserModel>> {
  final UserRepository _userRepository;
  final AiCoachingService _aiCoaching;

  HomeViewModelWithAI(this._userRepository, this._aiCoaching)
    : super(const AsyncValue.loading()) {
    _initializeWithAiCoaching();
  }

  Future<void> _initializeWithAiCoaching() async {
    try {
      state = const AsyncValue.loading();

      // 사용자 데이터 로드 (실제 메서드명에 맞게 수정 필요)
      var user = await _userRepository.getUser(); // 또는 loadUser() 등
      if (user == null) {
        state = AsyncValue.error('User not found', StackTrace.current);
        return;
      }

      // 일일 코칭 체크
      final coaching = await _aiCoaching.checkDailyCoaching(user);
      if (coaching != null) {
        // 코칭을 사용자 데이터에 추가
        user = _aiCoaching.addCoachingInsight(user, coaching);

        // 사용자 데이터 저장
        await _userRepository.saveUser(user);

        // UI에 코칭 표시 (별도 알림 등)
        _showCoachingNotification(coaching);
      }

      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // 코칭 스타일 변경
  Future<void> changeCoachingStyle(CoachingStyle style) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updatedUser = _aiCoaching.updateCoachingStyle(currentUser, style);
    await _userRepository.saveUser(updatedUser);
    state = AsyncValue.data(updatedUser);
  }

  // 맞춤형 코칭 요청
  Future<void> requestPersonalizedCoaching() async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final coaching = await _aiCoaching.getPersonalizedCoaching(currentUser);
    final updatedUser = _aiCoaching.addCoachingInsight(currentUser, coaching);

    await _userRepository.saveUser(updatedUser);
    state = AsyncValue.data(updatedUser);

    _showCoachingNotification(coaching);
  }

  // 코칭 읽음 표시
  Future<void> markCoachingAsRead(String insightId) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updatedUser = _aiCoaching.markInsightAsRead(currentUser, insightId);
    await _userRepository.saveUser(updatedUser);
    state = AsyncValue.data(updatedUser);
  }

  void _showCoachingNotification(coaching) {
    // 실제 구현에서는 SnackBar, Dialog 등으로 표시
    // 로깅: coaching.title, coaching.message 사용
  }
}

// UI에서 코칭 스타일 선택 위젯 예시
/*
class CoachingStyleSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButton<CoachingStyle>(
      value: CoachingStyle.kind,
      items: CoachingStyle.values.map((style) {
        return DropdownMenuItem(
          value: style,
          child: Text(style.displayName),
        );
      }).toList(),
      onChanged: (style) {
        if (style != null) {
          ref.read(homeViewModelProvider.notifier).changeCoachingStyle(style);
        }
      },
    );
  }
}
*/
