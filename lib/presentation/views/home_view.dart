import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../core/utils/responsive_utils.dart';
import '../../data/models/user_model.dart';
import '../../data/models/transaction.dart';
import '../viewmodels/providers.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/premium_card.dart';
import '../widgets/premium_buttons.dart';
import '../widgets/animated_expansion_card.dart';
import '../dialogs/add_transaction_dialog.dart';
import 'account_book_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
              SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceL)),

              // 오늘의 소비 현황
              _buildTodaySpending(context, viewModel, user, state.transactions),
              SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceL)),

              // 가계부 빠른 액션
              _buildAccountBookActions(context, viewModel),
              SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceM)),

              // AI 코칭
              _buildAiCoaching(context, user),
              SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceM)),

              // 이번 달 소비 분석
              _buildMonthlySpendingAnalysis(context, user, state.transactions),
              SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceM)),

              // 최근 소비 내역
              _buildRecentSpending(context, user, state.transactions),
              SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceM)),

              // 프리미엄 배너 (비프리미엄 사용자만)
              if (!user.isPremium) ...[
                _buildPremiumBanner(context),
                SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceXL)),
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
            kToolbarHeight + ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceM),
            ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceM),
            ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceM),
          ),
          child: Row(
            children: [
              Container(
                width: ResponsiveUtils.getResponsiveIconSize(context, 48),
                height: ResponsiveUtils.getResponsiveIconSize(context, 48),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: AppTheme.radiusMedium,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceM)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '안녕하세요! 👋',
                      style: AppTheme.getBodyMedium(context).copyWith(
                        color: AppTheme.onSurfaceColor.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      user.name.isNotEmpty ? user.name : '스마트 절약러',
                      style: AppTheme.getHeadingSmall(context).copyWith(
                        color: AppTheme.onSurfaceColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (user.isPremium)
                Container(
                  padding: ResponsiveUtils.getResponsivePaddingCustom(context,
                    horizontal: AppTheme.spaceS,
                    vertical: AppTheme.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.successGradient,
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveSize(context, 20)),
                  ),
                  child: Text(
                    '프리미엄',
                    style: AppTheme.getBodySmall(context).copyWith(
                      color: Colors.white,
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
      gradient: AppTheme.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '이번 달 절약',
                style: AppTheme.getBodyMedium(context).copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Icon(
                Icons.savings_outlined,
                color: Colors.white.withValues(alpha: 0.9),
                size: ResponsiveUtils.getResponsiveIconSize(context, 20),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceS)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              NumberFormatter.formatWon(user.currentMonthSaved),
              style: AppTheme.getHeadingLarge(context).copyWith(
                color: Colors.white,
                fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 36),
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceXS)),
          GestureDetector(
            onTap: () =>
                _showMonthlyGoalSettingDialog(context, viewModel, user),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '목표: ${NumberFormatter.formatWon(user.monthlyGoal)}',
                    style: AppTheme.getBodySmall(context).copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceXS)),
                Icon(
                  Icons.edit,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 14),
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceM)),
          Container(
            padding: ResponsiveUtils.getResponsivePaddingCustom(context, all: AppTheme.spaceS),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: AppTheme.radiusSmall,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                ),
                SizedBox(width: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceXS)),
                Flexible(
                  child: Text(
                    '이번 달 ${user.consecutiveDays}일 연속 절약 중',
                    style: AppTheme.getBodySmall(context).copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
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
          SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceM)),
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
                      fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 28),
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceS)),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: ResponsiveUtils.getResponsivePaddingCustom(context, bottom: 4),
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
              isOverBudget ? AppTheme.errorColor : AppTheme.primaryColor,
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

  Widget _buildAiCoaching(BuildContext context, UserModel user) {
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
              child: Text(
                '이번 달 식비가 예산의 70%를 차지하고 있어요. 집에서 요리하는 횟수를 늘려보는 건 어떨까요? 한 달에 약 15만원을 절약할 수 있을 거예요!',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.onSurfaceColor,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceM),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAiCoachingDialog(context),
                    icon: const Icon(Icons.lightbulb_outline, size: 18),
                    label: const Text('더 많은 조언 보기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
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
            SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceL)),
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
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.getIPhone16PlusSpacing(context, AppTheme.spaceS)),
                  Flexible(
                    child: Text(
                      category,
                      style: AppTheme.getBodyMedium(context).copyWith(
                        color: AppTheme.onSurfaceColor,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      NumberFormatter.formatWon(amount),
                      style: AppTheme.getBodyMedium(context).copyWith(
                        color: AppTheme.onSurfaceColor,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toStringAsFixed(1)}%',
                    style: AppTheme.getBodySmall(context).copyWith(
                      color: AppTheme.onSurfaceColor.withValues(alpha: 0.6),
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
        return Colors.orange;
      case '교통비':
        return Colors.blue;
      case '쇼핑':
        return Colors.pink;
      case '기타':
        return Colors.grey;
      default:
        return AppTheme.primaryColor;
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
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: AppTheme.spaceM),
                Text(
                  '아직 이번 달 소비 데이터가 없어요',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceS),
                Text(
                  '소비를 기록하면 분석이 표시됩니다',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.grey.shade500,
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
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: AppTheme.spaceM),
                    Text(
                      '아직 소비 내역이 없어요',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceS),
                    Text(
                      '소비를 기록하면 내역이 표시됩니다',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.grey.shade500,
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
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
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
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: AppTheme.spaceS),
              Text(
                '프리미엄으로 업그레이드',
                style: AppTheme.headingSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            '• 광고 제거\n• 3배 빠른 포인트 적립\n• 무제한 절약 기록\n• 고급 통계 분석',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppTheme.spaceM),
          PremiumButton(
            text: '프리미엄 시작하기',
            type: ButtonType.secondary,
            onPressed: () {
              // TODO: 프리미엄 업그레이드
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
              '월 절약 목표를 설정하여 절약 습관을 만들어보세요',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

  void _showAiCoachingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.blue),
            SizedBox(width: 8),
            Text('AI 절약 코칭'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoachingCard(
                '💡 스마트 절약 팁',
                '이번 달 식비가 예산의 70%를 차지하고 있어요. 집에서 요리하는 횟수를 늘려보는 건 어떨까요?',
              ),
              const SizedBox(height: 16),
              _buildCoachingCard(
                '📊 소비 패턴 분석',
                '지난 3개월간 주말 소비가 평일보다 40% 높습니다. 주말 예산을 따로 계획해보세요.',
              ),
              const SizedBox(height: 16),
              _buildCoachingCard(
                '🎯 절약 챌린지',
                '커피 한 잔 줄이기만으로도 한 달에 3만원을 절약할 수 있어요. 도전해보실래요?',
              ),
              const SizedBox(height: 16),
              _buildCoachingCard(
                '🏆 성과 피드백',
                '이번 주 절약 목표를 120% 달성했네요! 정말 대단해요. 이 습관을 계속 유지해보세요.',
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
              // TODO: 개인화된 AI 코칭 기능 구현
              Navigator.pop(context);
            },
            child: const Text('맞춤 조언 받기'),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachingCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
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
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppTheme.spaceM),
          Text(
            '데이터를 불러올 수 없습니다',
            style: AppTheme.headingSmall.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
