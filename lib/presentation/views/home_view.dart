import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money_app/presentation/dialogs/premium_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/enums/coaching_style.dart';
import '../../data/models/user_model.dart';
import '../../data/models/transaction.dart';
import '../viewmodels/providers.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/premium_card.dart';
import '../widgets/premium_buttons.dart';
import '../widgets/animated_expansion_card.dart';
import '../dialogs/add_transaction_dialog.dart';
import 'ai_coaching_page.dart';
import 'account_book_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: state.isLoading
          ? const _LoadingView()
          : state.user == null
          ? const _EmptyState()
          : _buildMainContent(context, state.user!, viewModel, state, ref),
      bottomNavigationBar: _buildBottomAd(state),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    UserModel user,
    dynamic viewModel,
    dynamic state,
    WidgetRef ref,
  ) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, user),
        SliverPadding(
          padding: ResponsiveUtils.getIPhone16PlusPadding(context),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 메인 잔액 카드
              _buildBalanceCard(context, viewModel, user),
              SizedBox(
                height: ResponsiveUtils.getIPhone16PlusSpacing(
                  context,
                  AppTheme.spaceL,
                ),
              ),

              // 오늘의 소비 현황
              _buildTodaySpending(context, viewModel, user, state.transactions),
              SizedBox(
                height: ResponsiveUtils.getIPhone16PlusSpacing(
                  context,
                  AppTheme.spaceL,
                ),
              ),

              // 가계부 빠른 액션
              _buildAccountBookActions(context, viewModel),
              SizedBox(
                height: ResponsiveUtils.getIPhone16PlusSpacing(
                  context,
                  AppTheme.spaceM,
                ),
              ),

              // AI 코칭
              _buildAiCoaching(context, user, ref),
              SizedBox(
                height: ResponsiveUtils.getIPhone16PlusSpacing(
                  context,
                  AppTheme.spaceM,
                ),
              ),

              // 이번 달 소비 분석
              _buildMonthlySpendingAnalysis(context, user, state.transactions),
              SizedBox(
                height: ResponsiveUtils.getIPhone16PlusSpacing(
                  context,
                  AppTheme.spaceM,
                ),
              ),

              // 최근 소비 내역
              _buildRecentSpending(context, user, state.transactions),
              SizedBox(
                height: ResponsiveUtils.getIPhone16PlusSpacing(
                  context,
                  AppTheme.spaceM,
                ),
              ),

              // 프리미엄 배너 (비프리미엄 사용자만)
              if (!user.isPremium) ...[
                _buildPremiumBanner(context),
                SizedBox(
                  height: ResponsiveUtils.getIPhone16PlusSpacing(
                    context,
                    AppTheme.spaceXL,
                  ),
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, UserModel user) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: EdgeInsets.fromLTRB(
            ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceM),
            kToolbarHeight +
                ResponsiveUtils.getIPhone16PlusSpacing(
                  context,
                  AppTheme.spaceM,
                ),
            ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceM),
            ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceM),
          ),
          child: Row(
            children: [
              // 몬트 로고 (SVG)
              SvgPicture.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/mont_logo_final_dark.svg'
                    : 'assets/images/mont_logo_final.svg',
                height: ResponsiveUtils.getResponsiveIconSize(context, 48),
              ),
              const Spacer(),
              if (user.isPremium)
                Container(
                  padding: ResponsiveUtils.getResponsivePaddingCustom(
                    context,
                    horizontal: AppTheme.spaceS,
                    vertical: AppTheme.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.successGradient,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveSize(context, 20),
                    ),
                  ),
                  child: Text(
                    '프리미엄',
                    style: AppTheme.getBodySmall(context).copyWith(
                      color: AppTheme.white(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    HomeViewModel viewModel,
    UserModel user,
  ) {
    return GradientCard(
      gradient: LinearGradient(
        colors: [Colors.green.shade400, Colors.teal.shade400],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '이번 달 절약',
                style: AppTheme.getBodyMedium(context).copyWith(
                  color: AppTheme.white(context).withValues(alpha: 0.9),
                ),
              ),
              Icon(
                Icons.savings_outlined,
                color: AppTheme.white(context).withValues(alpha: 0.9),
                size: ResponsiveUtils.getResponsiveIconSize(context, 20),
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
              NumberFormatter.formatWon(user.currentMonthSaved),
              style: AppTheme.getHeadingLarge(context).copyWith(
                color: AppTheme.white(context),
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
          GestureDetector(
            onTap: () =>
                _showMonthlyGoalSettingDialog(context, viewModel, user),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '목표: ${NumberFormatter.formatWon(user.monthlyGoal)}',
                    style: AppTheme.getBodySmall(context).copyWith(
                      color: AppTheme.white(context).withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  width: ResponsiveUtils.getIPhone16PlusSpacing(
                    context,
                    AppTheme.spaceXS,
                  ),
                ),
                Icon(
                  Icons.edit,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 14),
                  color: AppTheme.white(context).withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getIPhone16PlusSpacing(
              context,
              AppTheme.spaceM,
            ),
          ),
          Container(
            padding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              all: AppTheme.spaceS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.white(context).withValues(alpha: 0.15),
              borderRadius: AppTheme.radiusSmall,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: AppTheme.white(context).withValues(alpha: 0.9),
                  size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                ),
                SizedBox(
                  width: ResponsiveUtils.getIPhone16PlusSpacing(
                    context,
                    AppTheme.spaceXS,
                  ),
                ),
                Flexible(
                  child: Text(
                    '이번 달 ${user.consecutiveDays}일 연속 절약 중',
                    style: AppTheme.getBodySmall(context).copyWith(
                      color: AppTheme.white(context).withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildTodaySpending(
    BuildContext context,
    HomeViewModel viewModel,
    UserModel user,
    List<Transaction> transactions,
  ) {
    // 오늘 사용한 금액을 실제 transactions에서 계산
    final DateTime today = DateTime.now();
    final DateTime todayStart = DateTime(today.year, today.month, today.day);
    final DateTime todayEnd = todayStart.add(const Duration(days: 1));

    final double todaySpent = transactions
        .where(
          (transaction) =>
              transaction.type == TransactionType.expense &&
              transaction.date.isAfter(todayStart) &&
              transaction.date.isBefore(todayEnd),
        )
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    final double dailyBudget = user.dailyBudget; // 사용자 설정 일일 예산
    final double progress = dailyBudget > 0
        ? (todaySpent / dailyBudget).clamp(0.0, 1.0)
        : 0.0;
    final bool isOverBudget = todaySpent > dailyBudget;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '오늘의 소비',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.onSurfaceColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOverBudget
                          ? AppTheme.errorColor.withValues(alpha: 0.1)
                          : AppTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOverBudget ? '예산 초과' : '예산 내',
                      style: AppTheme.bodySmall.copyWith(
                        color: isOverBudget
                            ? AppTheme.errorColor
                            : AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceS),
                  GestureDetector(
                    onTap: () =>
                        _showBudgetSettingDialog(context, viewModel, user),
                    child: Icon(
                      Icons.settings,
                      size: 20,
                      color: AppTheme.onSurfaceColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveUtils.getIPhone16PlusSpacing(
              context,
              AppTheme.spaceM,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    NumberFormatter.formatWon(todaySpent),
                    style: AppTheme.getHeadingLarge(context).copyWith(
                      color: isOverBudget
                          ? AppTheme.errorColor
                          : AppTheme.onSurfaceColor,
                      fontWeight: FontWeight.w700,
                      fontSize: ResponsiveUtils.getSafeResponsiveFontSize(
                        context,
                        28,
                      ),
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getIPhone16PlusSpacing(
                  context,
                  AppTheme.spaceS,
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: ResponsiveUtils.getResponsivePaddingCustom(
                    context,
                    bottom: 4,
                  ),
                  child: Text(
                    '/ ${NumberFormatter.formatWon(dailyBudget)}',
                    style: AppTheme.getBodyMedium(context).copyWith(
                      color: AppTheme.onSurfaceColor.withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceM),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.onSurfaceColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget ? AppTheme.errorColor : Colors.green.shade400,
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            isOverBudget
                ? '일일 예산을 ${NumberFormatter.formatWon(todaySpent - dailyBudget)} 초과했어요'
                : '일일 예산까지 ${NumberFormatter.formatWon(dailyBudget - todaySpent)} 남았어요',
            style: AppTheme.bodySmall.copyWith(
              color: isOverBudget
                  ? AppTheme.errorColor
                  : AppTheme.onSurfaceColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountBookActions(BuildContext context, dynamic viewModel) {
    return AnimatedExpansionCard(
      title: '가계부',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: AppTheme.primaryColor,
      initiallyExpanded: true,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: '가계부 보기',
                  subtitle: '전체 내역 확인',
                  icon: Icons.account_balance_wallet,
                  color: AppTheme.primaryColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const AccountBookView(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceM),
              Expanded(
                child: _buildActionCard(
                  title: '절약 추가',
                  subtitle: '절약한 금액',
                  icon: Icons.savings,
                  color: AppTheme.accentColor,
                  onTap: () => _showAddTransactionDialog(
                    context,
                    TransactionType.saving,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceM),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: '수입 추가',
                  subtitle: '급여, 용돈 등',
                  icon: Icons.add_circle,
                  color: AppTheme.successColor,
                  onTap: () => _showAddTransactionDialog(
                    context,
                    TransactionType.income,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceM),
              Expanded(
                child: _buildActionCard(
                  title: '지출 추가',
                  subtitle: '식비, 교통비 등',
                  icon: Icons.remove_circle,
                  color: AppTheme.errorColor,
                  onTap: () => _showAddTransactionDialog(
                    context,
                    TransactionType.expense,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return PremiumCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppTheme.radiusSmall,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            title,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          Text(
            subtitle,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.onSurfaceColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiCoaching(BuildContext context, UserModel user, WidgetRef ref) {
    return AnimatedExpansionCard(
      title: 'AI 절약 코칭',
      icon: Icons.psychology_rounded,
      iconColor: AppTheme.accentColor,
      initiallyExpanded: false,
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spaceS),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: AppTheme.accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 스마트한 절약 조언',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      Text(
                        'AI가 분석한 맞춤형 절약 팁',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.onSurfaceColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // AI 말투 설정 아이콘
                IconButton(
                  onPressed: () => _showCoachingStyleDialog(context, user, ref),
                  icon: Icon(
                    Icons.settings_rounded,
                    color: AppTheme.onSurfaceColor.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  tooltip: 'AI 말투 설정',
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceM),
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceM),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                ),
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  final homeState = ref.watch(homeViewModelProvider);
                  final currentCoaching = homeState.currentCoaching;
                  final transactions = homeState.transactions;

                  if (currentCoaching != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${currentCoaching.title} (거래: ${transactions.length}개)',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentCoaching.message,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.onSurfaceColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    );
                  }

                  // 기본 메시지 (데이터 없을 때)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '거래: ${transactions.length}개 | 인사이트: ${homeState.recentInsights.length}개',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.accentColor,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transactions.isEmpty
                            ? '가계부에 거래 내역을 추가하면 AI가 맞춤형 절약 팁을 제공해드려요! 📊✨'
                            : 'AI 코칭을 받으려면 "더 많은 조언 보기" 버튼을 눌러주세요! ${transactions.length}건의 거래 데이터를 분석해드릴게요.',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.onSurfaceColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.spaceM),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _requestAiCoachingAndShowDialog(context, ref),
                    icon: const Icon(Icons.lightbulb_outline, size: 18),
                    label: const Text('더 많은 조언 보기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: AppTheme.white(context),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySpendingAnalysis(
    BuildContext context,
    UserModel user,
    List<Transaction> transactions,
  ) {
    // 이번 달 거래 데이터 필터링
    final DateTime now = DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month, 1);
    final DateTime monthEnd = DateTime(now.year, now.month + 1, 0);

    final thisMonthTransactions = transactions
        .where(
          (transaction) =>
              transaction.type == TransactionType.expense &&
              transaction.date.isAfter(monthStart) &&
              transaction.date.isBefore(monthEnd.add(const Duration(days: 1))),
        )
        .toList();

    // 카테곦0리별 소비 계산
    final Map<String, double> categorySpending = {};
    for (final transaction in thisMonthTransactions) {
      final categoryName = _getCategoryDisplayName(transaction.category);
      categorySpending[categoryName] =
          (categorySpending[categoryName] ?? 0) + transaction.amount;
    }

    // 데이터가 없으면 빈 상태 표시
    if (categorySpending.isEmpty) {
      return _buildEmptySpendingAnalysis();
    }

    final double totalSpent = categorySpending.values.fold(0, (a, b) => a + b);

    return AnimatedExpansionCard(
      title: '이번 달 소비 분석',
      icon: Icons.analytics_rounded,
      iconColor: AppTheme.primaryColor,
      initiallyExpanded: false,
      child: PremiumCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '총 소비',
                  style: AppTheme.getBodyMedium(context).copyWith(
                    color: AppTheme.onSurfaceColor.withValues(alpha: 0.7),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      NumberFormatter.formatWon(totalSpent),
                      style: AppTheme.getHeadingSmall(context).copyWith(
                        color: AppTheme.onSurfaceColor,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: ResponsiveUtils.getIPhone16PlusSpacing(
                context,
                AppTheme.spaceL,
              ),
            ),
            ...categorySpending.entries.map(
              (entry) => _buildSpendingCategoryItem(
                context,
                entry.key,
                entry.value,
                totalSpent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingCategoryItem(
    BuildContext context,
    String category,
    double amount,
    double total,
  ) {
    final double percentage = total > 0 ? (amount / total) : 0.0;
    final Color categoryColor = _getCategoryColor(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceM),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.getIPhone16PlusSpacing(
                        context,
                        AppTheme.spaceS,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        category,
                        style: AppTheme.getBodyMedium(context).copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : AppTheme.onSurfaceColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      NumberFormatter.formatWon(amount),
                      style: AppTheme.getBodyMedium(context).copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : AppTheme.onSurfaceColor,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toStringAsFixed(1)}%',
                    style: AppTheme.getBodySmall(context).copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : AppTheme.onSurfaceColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceS),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppTheme.onSurfaceColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '식비':
        return AppTheme.orange(context);
      case '교통비':
        return AppTheme.blue(context);
      case '쇼핑':
        return AppTheme.pink(context);
      case '기타':
        return AppTheme.getGreyColor(context, 500);
      default:
        return Colors.green.shade400;
    }
  }

  String _getCategoryDisplayName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return '식비';
      case TransactionCategory.transport:
        return '교통비';
      case TransactionCategory.shopping:
        return '쇼핑';
      case TransactionCategory.entertainment:
        return '여가';
      case TransactionCategory.healthcare:
        return '의료비';
      case TransactionCategory.education:
        return '교육비';
      case TransactionCategory.housing:
        return '주거비';
      case TransactionCategory.utilities:
        return '공과금';
      case TransactionCategory.customSaving:
        return '절약';
      case TransactionCategory.investment:
        return '투자';
      case TransactionCategory.insurance:
        return '보험';
      case TransactionCategory.other:
        return '기타';
      default:
        return '기타';
    }
  }

  Widget _buildEmptySpendingAnalysis() {
    return AnimatedExpansionCard(
      title: '이번 달 소비 분석',
      icon: Icons.analytics_rounded,
      iconColor: AppTheme.primaryColor,
      initiallyExpanded: false,
      child: PremiumCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceL),
            child: Column(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 48,
                  color: AppTheme.getGreyColor(context, 400),
                ),
                const SizedBox(height: AppTheme.spaceM),
                Text(
                  '아직 이번 달 소비 데이터가 없어요',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.getSecondaryTextColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceS),
                Text(
                  '소비를 기록하면 분석이 표시됩니다',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSpending(
    BuildContext context,
    UserModel user,
    List<Transaction> transactions,
  ) {
    // 최근 지출 거래 데이터 (최대 5개)
    final recentExpenses =
        transactions
            .where((transaction) => transaction.type == TransactionType.expense)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final recentSpendingList = recentExpenses.take(5).toList();

    if (recentSpendingList.isEmpty) {
      return _buildEmptyRecentSpending(context);
    }

    return AnimatedExpansionCard(
      title: '최근 소비',
      icon: Icons.receipt_long_rounded,
      iconColor: AppTheme.errorColor,
      initiallyExpanded: false,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const AccountBookView(),
                    ),
                  );
                },
                child: Text(
                  '전체보기',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          PremiumCard(
            child: Column(
              children: recentSpendingList.asMap().entries.map((entry) {
                final index = entry.key;
                final transaction = entry.value;
                final isLast = index == recentSpendingList.length - 1;

                return Column(
                  children: [
                    _buildTransactionItem(transaction),
                    if (!isLast) const Divider(height: AppTheme.spaceL),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecentSpending(BuildContext context) {
    return AnimatedExpansionCard(
      title: '최근 소비',
      icon: Icons.receipt_long_rounded,
      iconColor: AppTheme.errorColor,
      initiallyExpanded: false,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const AccountBookView(),
                    ),
                  );
                },
                child: Text(
                  '전체보기',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          PremiumCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceL),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      size: 48,
                      color: AppTheme.getGreyColor(context, 400),
                    ),
                    const SizedBox(height: AppTheme.spaceM),
                    Text(
                      '아직 소비 내역이 없어요',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.getSecondaryTextColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceS),
                    Text(
                      '소비를 기록하면 내역이 표시됩니다',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final categoryName = _getCategoryDisplayName(transaction.category);
    final categoryColor = _getCategoryColor(categoryName);
    final categoryIcon = _getCategoryIcon(transaction.category);
    final timeAgo = _getTimeAgo(transaction.date);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spaceS),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.1),
            borderRadius: AppTheme.radiusSmall,
          ),
          child: Icon(categoryIcon, color: categoryColor, size: 20),
        ),
        const SizedBox(width: AppTheme.spaceM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.description.isEmpty
                    ? categoryName
                    : transaction.description,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              Text(
                timeAgo,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.onSurfaceColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Text(
          '-${NumberFormatter.formatWon(transaction.amount)}',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.errorColor,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transport:
        return Icons.directions_bus;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.healthcare:
        return Icons.local_hospital;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.housing:
        return Icons.home;
      case TransactionCategory.utilities:
        return Icons.flash_on;
      case TransactionCategory.customSaving:
        return Icons.savings;
      case TransactionCategory.investment:
        return Icons.trending_up;
      case TransactionCategory.insurance:
        return Icons.security;
      case TransactionCategory.other:
      default:
        return Icons.more_horiz;
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(transactionDate).inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else if (difference < 7) {
      return '$difference일 전';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return GradientCard(
      gradient: const LinearGradient(
        colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: AppTheme.white(context),
                size: 28,
              ),
              const SizedBox(width: AppTheme.spaceS),
              Text(
                '프리미엄으로 업그레이드',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.white(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            '• 광고 제거\n• 3배 빠른 포인트 적립\n• 무제한 절약 기록\n• 고급 통계 분석',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.white(context).withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppTheme.spaceM),
          PremiumButton(
            text: '프리미엄 시작하기',
            type: ButtonType.secondary,
            onPressed: () {
              // TODO: 프리미엄 업그레이드
              showDialog(
                context: context,
                builder: (context) => const PremiumDialog(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomAd(dynamic state) {
    try {
      if (state.bannerAd == null) return null;

      return Container(
        height: state.bannerAd!.size.height.toDouble(),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black(context).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: AdWidget(ad: state.bannerAd!),
      );
    } catch (e) {
      // 광고 표시 오류 시 null 반환하여 광고 영역을 숨김
      return null;
    }
  }

  // 다이얼로그 메서드들
  void _showAddTransactionDialog(
    BuildContext context,
    TransactionType? initialType,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(initialType: initialType),
    );
  }

  void _showBudgetSettingDialog(
    BuildContext context,
    HomeViewModel viewModel,
    UserModel user,
  ) {
    final controller = TextEditingController(
      text: user.dailyBudget.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일일 예산 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '일일 예산 (원)',
                hintText: '예: 50000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '일일 예산을 설정하여 지출을 효과적으로 관리하세요',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final budget = double.tryParse(controller.text) ?? 50000.0;
              viewModel.updateDailyBudget(budget);
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showMonthlyGoalSettingDialog(
    BuildContext context,
    HomeViewModel viewModel,
    UserModel user,
  ) {
    final controller = TextEditingController(
      text: user.monthlyGoal.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이번 달 절약 목표 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '월 절약 목표 (원)',
                hintText: '예: 100000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '월 절약 목표를 설정���여 절약 습관을 만들어보세요',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final goal = double.tryParse(controller.text) ?? 100000.0;
              viewModel.updateMonthlyGoal(goal);
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _requestAiCoachingAndShowDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // 로딩 표시 (선택사항)
      // showDialog로 로딩 스피너 표시할 수 있지만 일단 생략

      // 직접 AI 코칭 요청 - 이미 state가 업데이트됨
      final viewModel = ref.read(homeViewModelProvider.notifier);
      await viewModel.requestPersonalizedCoaching();

      // 다이얼로그 표시 (mounted 체크)
      if (context.mounted) {
        _showAiCoachingDialog(context);
      }
    } catch (error) {
      // 에러 처리 - 사용자에게 메시지 표시할 수 있음
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI 조언을 가져오는 중 문제가 발생했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  void _showAiCoachingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final homeState = ref.watch(homeViewModelProvider);
          final insights = homeState.recentInsights;

          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.psychology, color: AppTheme.blue(context)),
                const SizedBox(width: 8),
                const Text('AI 절약 코칭'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: insights.isNotEmpty
                    ? insights
                          .map(
                            (insight) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildCoachingCard(
                                insight.title,
                                insight.message,
                              ),
                            ),
                          )
                          .toList()
                    : [
                        _buildCoachingCard(
                          '🚀 시작해보세요!',
                          '가계부에 거래 내역을 추가하면 AI가 맞춤형 분석과 절약 조언을 제공해드려요.',
                        ),
                        const SizedBox(height: 16),
                        _buildCoachingCard(
                          '💡 기본 절약 팁',
                          '매일 작은 지출도 기록하는 습관이 절약의 첫걸음입니다. 오늘부터 시작해보세요!',
                        ),
                      ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 현재 다이얼로그 닫기
                  Navigator.pop(context);
                  // 🧠 AI 코칭 페이지로 이동 (실제 가계부 데이터 100% 연동)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiCoachingPage(),
                    ),
                  );
                },
                child: const Text('맞춤 조언 받기'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCoachingCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.blue(context, 50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.blue(context, 100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.blue(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : AppTheme.getTextColor(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showCoachingStyleDialog(
    BuildContext context,
    UserModel user,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.psychology_rounded, color: AppTheme.blue(context)),
              const SizedBox(width: 8),
              const Text('AI 말투 설정'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: CoachingStyle.values.map((style) {
              final isSelected = user.preferredCoachingStyle == style;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.blue(context)
                        : AppTheme.getGreyColor(context, 300),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected ? AppTheme.blue(context, 50) : null,
                ),
                child: ListTile(
                  leading: Icon(
                    _getCoachingStyleIcon(style),
                    color: isSelected
                        ? AppTheme.blue(context)
                        : AppTheme.getSecondaryTextColor(context),
                  ),
                  title: Text(
                    _getCoachingStyleName(style),
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.blue(context)
                          : AppTheme.getTextColor(context),
                    ),
                  ),
                  subtitle: Text(
                    _getCoachingStyleDescription(style),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                  onTap: () async {
                    if (user.preferredCoachingStyle != style) {
                      final viewModel = ref.read(
                        homeViewModelProvider.notifier,
                      );
                      await viewModel.changeCoachingStyle(style);
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  IconData _getCoachingStyleIcon(CoachingStyle style) {
    switch (style) {
      case CoachingStyle.friendly:
        return Icons.sentiment_very_satisfied_rounded;
      case CoachingStyle.strict:
        return Icons.business_center_rounded;
      case CoachingStyle.kind:
        return Icons.favorite_rounded;
      case CoachingStyle.motivational:
        return Icons.rocket_launch_rounded;
      case CoachingStyle.analytical:
        return Icons.analytics_rounded;
    }
  }

  String _getCoachingStyleName(CoachingStyle style) {
    switch (style) {
      case CoachingStyle.friendly:
        return '친구처럼';
      case CoachingStyle.strict:
        return '냉철하게';
      case CoachingStyle.kind:
        return '친절하게';
      case CoachingStyle.motivational:
        return '열정적으로';
      case CoachingStyle.analytical:
        return '분석적으로';
    }
  }

  String _getCoachingStyleDescription(CoachingStyle style) {
    switch (style) {
      case CoachingStyle.friendly:
        return '"와! 진짜 잘하고 있어!"';
      case CoachingStyle.strict:
        return '"분석 결과 개선이 필요합니다"';
      case CoachingStyle.kind:
        return '"정말 잘하고 계세요!"';
      case CoachingStyle.motivational:
        return '"대박! 이런 게 프로야!"';
      case CoachingStyle.analytical:
        return '"데이터 분석 결과입니다"';
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: AppTheme.getGreyColor(context, 400),
          ),
          const SizedBox(height: AppTheme.spaceM),
          Text(
            '데이터를 불러올 수 없습니다',
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
