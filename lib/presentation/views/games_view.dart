import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/utils/safe_area_utils.dart';
import '../../data/models/point_history.dart';
import 'number_guess_page.dart';
import 'financial_quiz_page.dart';
import 'card_flip_game_page.dart';
import 'vocabulary_game_page.dart';
import 'speed_typing_page.dart';
import 'color_reaction_page.dart';
import '../viewmodels/providers.dart';

class GamesView extends ConsumerWidget {
  const GamesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final user = state.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: SafeAreaUtils.getSafeResponsivePadding(context, all: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 상단 여백 추가
                  SizedBox(
                    height:
                        MediaQuery.of(context).padding.top +
                        ResponsiveUtils.getIPhone16PlusSpacing(context, 16),
                  ),

                  // 제목
                  Text(
                    '게임 & 활동',
                    style: AppTheme.getHeadingLarge(context).copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        28,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getIPhone16PlusSpacing(context, 4),
                  ),
                  Text(
                    '재미있게 포인트을 모아보세요!',
                    style: AppTheme.getBodyMedium(context).copyWith(
                      color: AppTheme.onBackgroundColor,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        16,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: ResponsiveUtils.getIPhone16PlusSpacing(
                      context,
                      AppTheme.spaceL,
                    ),
                  ),

                  // 보유 포인트 카드
                  _buildCoinCard(context, user),

                  SizedBox(
                    height: ResponsiveUtils.getIPhone16PlusSpacing(
                      context,
                      AppTheme.spaceL,
                    ),
                  ),

                  // 섹션 헤더
                  _buildSectionHeader(context, '인기 게임', '도전하여 포인트를 획득해보세요!'),

                  SizedBox(
                    height: ResponsiveUtils.getIPhone16PlusSpacing(context, 20),
                  ),

                  // 메인 게임 그리드
                  _buildPremiumGamesGrid(context),

                  SizedBox(
                    height: ResponsiveUtils.getIPhone16PlusSpacing(
                      context,
                      AppTheme.spaceL,
                    ),
                  ),

                  // 추가 정보 카드
                  _buildInfoCard(context),
                ],
              ),
            ),
    );
  }

  Widget _buildCoinCard(BuildContext context, user) {
    return GestureDetector(
      onTap: () => _showCoinHistoryDialog(context, user),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(
          ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceL),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.warningColor, Colors.amber[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.warningColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '보유 포인트',
                    style: AppTheme.getBodyMedium(context).copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: ResponsiveUtils.getSafeResponsiveFontSize(
                        context,
                        16,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                ),
              ],
            ),
            SizedBox(
              height: ResponsiveUtils.getIPhone16PlusSpacing(
                context,
                AppTheme.spaceS,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                NumberFormatter.formatInt(user.coins),
                style: AppTheme.getHeadingLarge(context).copyWith(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getSafeResponsiveFontSize(
                    context,
                    36,
                  ),
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getIPhone16PlusSpacing(
                context,
                AppTheme.spaceXS,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '게임으로 더 많은 포인트을 모아보세요!',
                style: AppTheme.getBodySmall(context).copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: ResponsiveUtils.getSafeResponsiveFontSize(
                    context,
                    14,
                  ),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getIPhone16PlusSpacing(
                context,
                AppTheme.spaceM,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceS),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: AppTheme.radiusSmall,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 16,
                  ),
                  const SizedBox(width: AppTheme.spaceXS),
                  Text(
                    '탭하여 포인트 적립/사용 내역 보기',
                    style: AppTheme.getBodySmall(context).copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.getHeadingMedium(context).copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getIPhone16PlusSpacing(context, 2),
              ),
              Text(
                subtitle,
                style: AppTheme.getBodyMedium(context).copyWith(
                  color: AppTheme.onBackgroundColor,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceS,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            gradient: AppTheme.successGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '6개 게임',
              style: AppTheme.getBodySmall(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getSafeResponsiveFontSize(
                  context,
                  12,
                ),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumGamesGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: ResponsiveUtils.getIPhone16PlusSpacing(
        context,
        AppTheme.spaceM,
      ),
      mainAxisSpacing: ResponsiveUtils.getIPhone16PlusSpacing(
        context,
        AppTheme.spaceM,
      ),
      childAspectRatio: ResponsiveUtils.getGameCardAspectRatio(context),
      padding: EdgeInsets.zero, // 상단 패딩 제거
      children: [
        _buildPremiumGameCard(
          context: context,
          title: '숫자 맞추기',
          subtitle: '1~10 숫자 맞추기',
          reward: '0~20',
          icon: Icons.casino_rounded,
          gradientColors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NumberGuessPage()),
          ),
        ),
        _buildPremiumGameCard(
          context: context,
          title: '금융 퀴즈',
          subtitle: '나의 금융지식 수준은?',
          reward: '5-25',
          icon: Icons.account_balance_rounded,
          gradientColors: [Colors.pink[400]!, Colors.pink[600]!],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FinancialQuizPage()),
          ),
        ),
        _buildPremiumGameCard(
          context: context,
          title: '카드 뒤집기',
          subtitle: '같은 카드 짝 찾기',
          reward: '5-25',
          icon: Icons.flip_camera_android_rounded,
          gradientColors: [Colors.blue[400]!, Colors.blue[600]!],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CardFlipGamePage()),
          ),
        ),
        _buildPremiumGameCard(
          context: context,
          title: '영단어 퀴즈',
          subtitle: '나의 영단어 수준은?',
          reward: '5-25',
          icon: Icons.translate_rounded,
          gradientColors: [AppTheme.successColor, Colors.green[600]!],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VocabularyGamePage()),
          ),
        ),
        _buildPremiumGameCard(
          context: context,
          title: '스피드 타이핑',
          subtitle: '빠르게 타이핑하세요',
          reward: '0~20',
          icon: Icons.keyboard_rounded,
          gradientColors: [Colors.deepPurple[400]!, Colors.deepPurple[600]!],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SpeedTypingPage()),
          ),
        ),
        _buildPremiumGameCard(
          context: context,
          title: '반응속도 테스트',
          subtitle: '극한의 반응속도 테스트',
          reward: ' 15',
          icon: Icons.sports_motorsports_rounded,
          gradientColors: [Colors.red[400]!, Colors.red[600]!],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ColorReactionPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumGameCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String reward,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: ResponsiveUtils.getGameCardPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 (아이콘 + 리워드)
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.getIPhone16PlusSpacing(
                          context,
                          AppTheme.spaceS,
                        ),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors.first.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: ResponsiveUtils.getResponsiveIconSize(
                          context,
                          24,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.warningColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.monetization_on_rounded,
                            size: ResponsiveUtils.getResponsiveIconSize(
                              context,
                              12,
                            ),
                            color: AppTheme.warningColor,
                          ),
                          SizedBox(
                            width: ResponsiveUtils.getIPhone16PlusSpacing(
                              context,
                              2,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '$reward 포인트',
                              style: AppTheme.getBodySmall(context).copyWith(
                                color: AppTheme.warningColor,
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    ResponsiveUtils.getSafeResponsiveFontSize(
                                      context,
                                      10,
                                    ),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: ResponsiveUtils.getIPhone16PlusSpacing(
                    context,
                    AppTheme.spaceM,
                  ),
                ),

                // 제목
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: AppTheme.getHeadingSmall(context).copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: ResponsiveUtils.getSafeResponsiveFontSize(
                        context,
                        16,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),

                SizedBox(
                  height: ResponsiveUtils.getIPhone16PlusSpacing(context, 4),
                ),

                // 부제목
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    style: AppTheme.getBodySmall(context).copyWith(
                      color: AppTheme.onBackgroundColor,
                      fontWeight: FontWeight.w500,
                      fontSize: ResponsiveUtils.getSafeResponsiveFontSize(
                        context,
                        14,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),

                SizedBox(
                  height: ResponsiveUtils.getIPhone16PlusSpacing(
                    context,
                    AppTheme.spaceS,
                  ),
                ),
                SizedBox(height: 10),
                // 플레이 버튼
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors
                          .map((c) => c.withValues(alpha: 0.1))
                          .toList(),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: gradientColors.first.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: gradientColors.first,
                        size: ResponsiveUtils.getResponsiveIconSize(
                          context,
                          16,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.getIPhone16PlusSpacing(
                          context,
                          4,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '게임 시작',
                          style: AppTheme.getBodySmall(context).copyWith(
                            color: gradientColors.first,
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveUtils.getSafeResponsiveFontSize(
                              context,
                              14,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceL),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.05),
            AppTheme.accentColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveUtils.getIPhone16PlusSpacing(
                    context,
                    AppTheme.spaceS,
                  ),
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: AppTheme.accentColor,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getIPhone16PlusSpacing(
                  context,
                  AppTheme.spaceS,
                ),
              ),
              Text(
                '게임 팁',
                style: AppTheme.getHeadingSmall(context).copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                ),
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveUtils.getIPhone16PlusSpacing(
              context,
              AppTheme.spaceM,
            ),
          ),
          Text(
            '• 매일 꾸준히 게임하면 연속 기록 보너스를 받을 수 있어요\n'
            '• 각 게임마다 다른 전략이 필요해요\n'
            '• 높은 점수일수록 더 많은 포인트을 획득할 수 있어요\n'
            '• 게임을 통해 얻은 포인트으로 프리미엄 기능을 이용해보세요',
            style: AppTheme.getBodyMedium(context).copyWith(
              color: AppTheme.onBackgroundColor,
              height: 1.6,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            ),
          ),
        ],
      ),
    );
  }

  // 기존 로직 메서드들 (그대로 유지)

  void _showCoinHistoryDialog(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          height: 600,
          padding: const EdgeInsets.all(AppTheme.spaceL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spaceS),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.monetization_on_rounded,
                      color: AppTheme.warningColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '포인트 내역',
                          style: AppTheme.getHeadingSmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          '현재 ${NumberFormatter.formatPoints(user.coins)}',
                          style: AppTheme.getBodyMedium(
                            context,
                          ).copyWith(color: AppTheme.onBackgroundColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceL),

              // 내역 리스트
              Expanded(
                child: user.pointHistory.isEmpty
                    ? _buildEmptyHistory(context)
                    : ListView.builder(
                        itemCount: user.pointHistory.length,
                        itemBuilder: (context, index) {
                          final history = user.pointHistory[index];
                          return _buildRealCoinHistoryItem(context, history);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: AppTheme.spaceM),
          Text(
            '아직 포인트 내역이 없어요',
            style: AppTheme.getHeadingSmall(
              context,
            ).copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            '게임을 플레이해서 포인트를 모아보세요!',
            style: AppTheme.getBodyMedium(
              context,
            ).copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRealCoinHistoryItem(BuildContext context, PointHistory history) {
    final isEarn = history.type == PointHistoryType.earn;
    final iconData = _getHistoryIcon(history.source);
    final iconColor = _getHistoryColor(history.source, isEarn);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceM),
      padding: const EdgeInsets.all(AppTheme.spaceM),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceS),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppTheme.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.description,
                  style: AppTheme.getBodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onBackgroundColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  history.timeAgo,
                  style: AppTheme.getBodySmall(context).copyWith(
                    color: AppTheme.onBackgroundColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isEarn ? '+' : '-'}${NumberFormatter.formatPoints(history.amount)}',
            style: AppTheme.getBodyMedium(context).copyWith(
              fontWeight: FontWeight.w700,
              color: isEarn ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getHistoryIcon(PointHistorySource source) {
    switch (source) {
      case PointHistorySource.numberGuessGame:
        return Icons.casino;
      case PointHistorySource.financialQuiz:
        return Icons.account_balance;
      case PointHistorySource.cardFlipGame:
        return Icons.flip_camera_android_rounded;
      case PointHistorySource.vocabularyGame:
        return Icons.translate_rounded;
      case PointHistorySource.speedTyping:
        return Icons.keyboard_rounded;
      case PointHistorySource.colorReaction:
        return Icons.sports_motorsports_rounded;
      case PointHistorySource.adWatch:
        return Icons.play_circle_fill;
      case PointHistorySource.dailyBonus:
        return Icons.local_fire_department;
      case PointHistorySource.streakBonus:
        return Icons.local_fire_department;
      case PointHistorySource.premiumFeature:
        return Icons.redeem;
      case PointHistorySource.other:
        return Icons.monetization_on;
    }
  }

  Color _getHistoryColor(PointHistorySource source, bool isEarn) {
    if (!isEarn) return AppTheme.errorColor;

    switch (source) {
      case PointHistorySource.numberGuessGame:
        return AppTheme.primaryColor;
      case PointHistorySource.financialQuiz:
        return Colors.pink[500]!;
      case PointHistorySource.cardFlipGame:
        return Colors.blue[500]!;
      case PointHistorySource.vocabularyGame:
        return AppTheme.successColor;
      case PointHistorySource.speedTyping:
        return Colors.deepPurple[500]!;
      case PointHistorySource.colorReaction:
        return Colors.red[500]!;
      case PointHistorySource.adWatch:
        return AppTheme.secondaryColor;
      case PointHistorySource.dailyBonus:
      case PointHistorySource.streakBonus:
        return AppTheme.warningColor;
      case PointHistorySource.premiumFeature:
        return AppTheme.errorColor;
      case PointHistorySource.other:
        return AppTheme.primaryColor;
    }
  }
}
