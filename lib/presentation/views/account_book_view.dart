import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/providers.dart';
import '../../data/models/transaction.dart';
import '../../data/models/budget.dart';
import '../../data/models/saving_goal.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/utils/safe_area_utils.dart';

// 천 단위 컴마 입력 포매터
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 숫자만 추출
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // 천 단위 컴마 추가
    String formatted = _addCommas(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addCommas(String digits) {
    if (digits.length <= 3) return digits;

    return digits.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class AccountBookView extends ConsumerStatefulWidget {
  const AccountBookView({super.key});

  @override
  ConsumerState<AccountBookView> createState() => _AccountBookViewState();
}

class _AccountBookViewState extends ConsumerState<AccountBookView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  // 숫자를 천 단위 컴마 포맷으로 변환하는 함수
  String _formatCurrency(double amount, {bool showSign = false}) {
    String result = amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    if (showSign) {
      result = amount >= 0 ? '+$result' : result;
    }

    return '$result원';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final user = state.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.teal[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '가계부',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 20),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
          ),
          tabs: [
            Tab(
              text: '내역',
              icon: Icon(
                Icons.list_alt,
                size: ResponsiveUtils.getResponsiveIconSize(context, 20),
              ),
            ),
            Tab(
              text: '통계',
              icon: Icon(
                Icons.analytics,
                size: ResponsiveUtils.getResponsiveIconSize(context, 20),
              ),
            ),
            Tab(
              text: '예산',
              icon: Icon(
                Icons.account_balance_wallet,
                size: ResponsiveUtils.getResponsiveIconSize(context, 20),
              ),
            ),
            Tab(
              text: '목표',
              icon: Icon(
                Icons.flag,
                size: ResponsiveUtils.getResponsiveIconSize(context, 20),
              ),
            ),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionListTab(),
                _buildStatisticsTab(),
                _buildBudgetTab(),
                _buildGoalsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionDialog(),
        backgroundColor: Colors.green[400],
        icon: Icon(
          Icons.add,
          color: Colors.white,
          size: ResponsiveUtils.getResponsiveIconSize(context, 24),
        ),
        label: Text(
          '거래 추가',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionListTab() {
    return Column(
      children: [
        // 월 선택기
        Container(
          padding: SafeAreaUtils.getSafeResponsivePadding(context, all: 16),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month - 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_selectedDate.year}년 ${_selectedDate.month}월',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month + 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        // 월 요약
        Consumer(
          builder: (context, ref, child) {
            final homeState = ref.watch(homeViewModelProvider);
            final monthlyTransactions = homeState.transactions
                .where(
                  (t) =>
                      t.date.year == _selectedDate.year &&
                      t.date.month == _selectedDate.month,
                )
                .toList();

            final income = monthlyTransactions
                .where((t) => t.type == TransactionType.income)
                .fold<double>(0, (sum, t) => sum + t.amount);
            final expense = monthlyTransactions
                .where((t) => t.type == TransactionType.expense)
                .fold<double>(0, (sum, t) => sum + t.amount);
            final saving = monthlyTransactions
                .where((t) => t.type == TransactionType.saving)
                .fold<double>(0, (sum, t) => sum + t.amount);

            return Container(
              margin: ResponsiveUtils.getResponsiveMargin(context),
              padding: SafeAreaUtils.getSafeResponsivePadding(context, all: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.teal[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      '수입',
                      income,
                      Icons.trending_up,
                      Colors.blue,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: ResponsiveUtils.getScaledSize(context, 40),
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      '지출',
                      expense,
                      Icons.trending_down,
                      Colors.red,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: ResponsiveUtils.getScaledSize(context, 40),
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      '절약',
                      saving,
                      Icons.savings,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // 거래 내역
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final homeState = ref.watch(homeViewModelProvider);
              final transactions =
                  homeState.transactions
                      .where(
                        (t) =>
                            t.date.year == _selectedDate.year &&
                            t.date.month == _selectedDate.month,
                      )
                      .toList()
                    ..sort((a, b) => b.date.compareTo(a.date));

              if (transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: ResponsiveUtils.getResponsiveIconSize(context, 64),
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${_selectedDate.month}월 거래 내역이 없습니다.',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '첫 거래를 추가해보세요!',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsivePadding(context).left,
                ),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionItemWithData(transaction);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: ResponsiveUtils.getResponsiveIconSize(context, 24),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _formatCurrency(amount),
            style: TextStyle(
              color: color,
              fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItemWithData(Transaction transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    final isIncome = transaction.type == TransactionType.income;
    final color = isExpense
        ? Colors.red
        : (isIncome ? Colors.blue : Colors.green);
    final sign = isExpense ? '-' : '+';

    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getScaledSize(context, 8),
      ),
      padding: SafeAreaUtils.getSafeResponsivePadding(context, all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveUtils.getScaledSize(context, 48),
            height: ResponsiveUtils.getScaledSize(context, 48),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                transaction.category.emoji,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getScaledSize(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: ResponsiveUtils.getScaledSize(context, 2)),
                Text(
                  '${transaction.category.displayName} • ${transaction.date.hour.toString().padLeft(2, '0')}:${transaction.date.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$sign${_formatCurrency(transaction.amount).replaceAll('원', '')}원',
              style: TextStyle(
                fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: SafeAreaUtils.getSafeResponsivePadding(context, all: 16),
      child: Consumer(
        builder: (context, ref, child) {
          final homeState = ref.watch(homeViewModelProvider);
          final now = DateTime.now();

          // 이번 달 거래 내역 필터링
          final monthlyTransactions = homeState.transactions
              .where(
                (t) => t.date.year == now.year && t.date.month == now.month,
              )
              .toList();

          // 수입, 지출, 절약 계산
          final income = monthlyTransactions
              .where((t) => t.type == TransactionType.income)
              .fold<double>(0, (sum, t) => sum + t.amount);
          final expense = monthlyTransactions
              .where((t) => t.type == TransactionType.expense)
              .fold<double>(0, (sum, t) => sum + t.amount);
          final saving = monthlyTransactions
              .where((t) => t.type == TransactionType.saving)
              .fold<double>(0, (sum, t) => sum + t.amount);

          final netAmount = income - expense + saving;

          // 카테고리별 지출 계산
          final categoryExpenses = <TransactionCategory, double>{};
          for (final transaction in monthlyTransactions.where(
            (t) => t.type == TransactionType.expense,
          )) {
            categoryExpenses[transaction.category] =
                (categoryExpenses[transaction.category] ?? 0) +
                transaction.amount;
          }

          // 총 지출이 0인 경우 백분율 계산 방지
          final totalExpense = categoryExpenses.values.fold<double>(
            0,
            (sum, amount) => sum + amount,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이번 달 요약
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[100]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${now.month}월 수지',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _formatCurrency(netAmount, showSign: true),
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 32),
                          fontWeight: FontWeight.bold,
                          color: netAmount >= 0
                              ? Colors.green[600]
                              : Colors.red[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '수입 ${_formatCurrency(income).replaceAll('원', '')} - 지출 ${_formatCurrency(expense).replaceAll('원', '')}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    if (saving > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '절약 ${_formatCurrency(saving, showSign: true)}',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 카테고리별 지출
              const Text(
                '카테고리별 지출',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (categoryExpenses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bar_chart_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '이번 달 지출 내역이 없습니다.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '거래를 추가하면 통계를 확인할 수 있어요!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...categoryExpenses.entries.map(
                  (entry) => _buildCategoryExpenseItemWithData(
                    entry.key,
                    entry.value,
                    totalExpense > 0 ? entry.value / totalExpense : 0,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryExpenseItemWithData(
    TransactionCategory category,
    double amount,
    double percentage,
  ) {
    // 카테고리별 색상 매핑
    final categoryColors = {
      TransactionCategory.food: Colors.orange,
      TransactionCategory.transport: Colors.blue,
      TransactionCategory.shopping: Colors.purple,
      TransactionCategory.utilities: Colors.teal,
      TransactionCategory.healthcare: Colors.red,
      TransactionCategory.entertainment: Colors.pink,
      TransactionCategory.education: Colors.indigo,
      TransactionCategory.housing: Colors.brown,
      TransactionCategory.insurance: Colors.cyan,
    };

    final color = categoryColors[category] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(category.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    category.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _formatCurrency(amount),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '전체 지출의 ${(percentage * 100).round()}%',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(percentage * 100).round()}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTab() {
    return SingleChildScrollView(
      padding: SafeAreaUtils.getSafeResponsivePadding(context, all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '예산 관리',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => _showAddBudgetDialog(),
                icon: const Icon(Icons.add),
                label: const Text('예산 추가'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Consumer(
            builder: (context, ref, child) {
              final homeState = ref.watch(homeViewModelProvider);
              final budgets = homeState.budgets;

              if (budgets.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '설정된 예산이 없습니다.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '첫 예산을 추가해보세요!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: budgets
                    .map((budget) => _buildBudgetItemWithData(budget))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItemWithData(Budget budget) {
    final percentage = budget.spentPercentage / 100;
    final isOverBudget = budget.isOverBudget;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isOverBudget
            ? Border.all(color: Colors.red[300]!, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    budget.category.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    budget.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatCurrency(budget.spent).replaceAll('원', ''),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? Colors.red : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      ' / ${_formatCurrency(budget.amount)}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 14),
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage > 1.0 ? 1.0 : percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget ? Colors.red : Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${budget.period.displayName} 예산',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '${percentage > 1 ? (percentage * 100).toInt() : budget.spentPercentage.toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverBudget ? Colors.red[600] : Colors.grey[600],
                  fontWeight: isOverBudget
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab() {
    return SingleChildScrollView(
      padding: SafeAreaUtils.getSafeResponsivePadding(context, all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '절약 목표',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => _showAddGoalDialog(),
                icon: const Icon(Icons.add),
                label: const Text('목표 추가'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Consumer(
            builder: (context, ref, child) {
              final homeState = ref.watch(homeViewModelProvider);
              final goals = homeState.goals;

              if (goals.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '설정된 목표가 없습니다.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '첫 절약 목표를 추가해보세요!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: goals
                    .map((goal) => _buildGoalItemWithData(goal))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItemWithData(SavingGoal goal) {
    final percentage = goal.progress;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (goal.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        goal.description!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: goal.isCompleted
                      ? Colors.green[100]
                      : Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  goal.isCompleted ? '완료!' : '${(percentage * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: goal.isCompleted
                        ? Colors.green[700]
                        : Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              goal.isCompleted ? Colors.green[600]! : Colors.blue[600]!,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _formatCurrency(goal.currentAmount),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Flexible(
                child: Text(
                  '목표: ${_formatCurrency(goal.targetAmount)}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 12),
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatCurrency(goal.remainingAmount)} 남음',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'D-${goal.remainingDays}',
                style: TextStyle(
                  fontSize: 12,
                  color: goal.remainingDays <= 7
                      ? Colors.red[600]
                      : Colors.grey[600],
                  fontWeight: goal.remainingDays <= 7
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    showDialog(context: context, builder: (context) => _AddTransactionDialog());
  }

  void _showAddBudgetDialog() {
    showDialog(context: context, builder: (context) => _AddBudgetDialog());
  }

  void _showAddGoalDialog() {
    showDialog(context: context, builder: (context) => _AddGoalDialog());
  }
}

// 거래 추가 다이얼로그
class _AddTransactionDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddTransactionDialog> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<_AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  TransactionCategory _selectedCategory = TransactionCategory.food;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 초기 거래 유형에 맞는 카테고리로 설정
    final availableCategories = _getCategoriesForType(_selectedType);
    if (availableCategories.isNotEmpty) {
      _selectedCategory = availableCategories.first;
    }
  }

  // 거래 유형별 카테고리 필터링 헬퍼 메서드
  List<TransactionCategory> _getCategoriesForType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return [
          TransactionCategory.salary,
          TransactionCategory.bonus,
          TransactionCategory.investment,
          TransactionCategory.freelance,
          TransactionCategory.sideJob,
          TransactionCategory.gift,
          TransactionCategory.other,
        ];
      case TransactionType.expense:
        return [
          TransactionCategory.food,
          TransactionCategory.transport,
          TransactionCategory.shopping,
          TransactionCategory.utilities,
          TransactionCategory.healthcare,
          TransactionCategory.entertainment,
          TransactionCategory.education,
          TransactionCategory.housing,
          TransactionCategory.insurance,
          TransactionCategory.other,
        ];
      case TransactionType.saving:
        return [
          TransactionCategory.mealSaving,
          TransactionCategory.transportSaving,
          TransactionCategory.shoppingSaving,
          TransactionCategory.utilitySaving,
          TransactionCategory.entertainmentSaving,
          TransactionCategory.customSaving,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '거래 추가',
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
        ),
      ),
      content: SizedBox(
        width: ResponsiveUtils.getSafeResponsiveSize(context, 400, maxRatio: 0.9),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 거래 유형 선택
                DropdownButtonFormField<TransactionType>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: '거래 유형',
                    labelStyle: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    ),
                  ),
                  items: TransactionType.values.map((type) {
                    String text;
                    switch (type) {
                      case TransactionType.income:
                        text = '수입';
                        break;
                      case TransactionType.expense:
                        text = '지출';
                        break;
                      case TransactionType.saving:
                        text = '절약';
                        break;
                    }
                    return DropdownMenuItem(value: type, child: Text(text));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      // 거래 유형이 변경될 때 해당 유형의 첫 번째 카테고리로 설정
                      final availableCategories = _getCategoriesForType(
                        _selectedType,
                      );
                      if (availableCategories.isNotEmpty) {
                        _selectedCategory = availableCategories.first;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 카테고리 선택
                DropdownButtonFormField<TransactionCategory>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: '카테고리',
                    labelStyle: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    ),
                  ),
                  items: _getCategoriesForType(_selectedType).map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Text(category.emoji),
                          const SizedBox(width: 8),
                          Text(category.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value!),
                ),
                const SizedBox(height: 16),

                // 금액
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: '금액',
                    suffixText: '원',
                    labelStyle: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  validator: (value) {
                    if (value?.isEmpty ?? true) return '금액을 입력해주세요';
                    // 컴마 제거 후 숫자 변환
                    final numericValue = value!.replaceAll(',', '');
                    if (double.tryParse(numericValue) == null)
                      return '올바른 금액을 입력해주세요';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 설명
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: '설명',
                    labelStyle: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return '설명을 입력해주세요';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 날짜
                ListTile(
                  title: const Text('날짜'),
                  subtitle: Text(
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                ),

                // 메모 (선택사항)
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: '메모 (선택사항)',
                    hintText: '추가 정보를 입력하세요',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: _saveTransaction, child: const Text('저장')),
      ],
    );
  }

  void _saveTransaction() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final amount = double.parse(_amountController.text.replaceAll(',', ''));

        // HomeViewModel의 addTransaction 메서드 호출
        final homeViewModel = ref.read(homeViewModelProvider.notifier);
        await homeViewModel.addTransaction(
          type: _selectedType,
          category: _selectedCategory,
          amount: amount,
          description: _descriptionController.text,
          date: _selectedDate,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('거래가 추가되었습니다!')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

// 예산 추가 다이얼로그
class _AddBudgetDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<_AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionCategory _selectedCategory = TransactionCategory.food;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('예산 추가'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '예산 이름'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return '예산 이름을 입력해주세요';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<TransactionCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: '카테고리'),
                items: TransactionCategory.values
                    .where(
                      (cat) => [
                        TransactionCategory.food,
                        TransactionCategory.transport,
                        TransactionCategory.shopping,
                        TransactionCategory.utilities,
                        TransactionCategory.healthcare,
                        TransactionCategory.entertainment,
                        TransactionCategory.education,
                        TransactionCategory.housing,
                      ].contains(cat),
                    )
                    .map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Text(category.emoji),
                            const SizedBox(width: 8),
                            Text(category.displayName),
                          ],
                        ),
                      );
                    })
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: '예산 금액',
                  suffixText: '원',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) {
                  if (value?.isEmpty ?? true) return '예산 금액을 입력해주세요';
                  // 컴마 제거 후 숫자 변환
                  final numericValue = value!.replaceAll(',', '');
                  if (double.tryParse(numericValue) == null)
                    return '올바른 금액을 입력해주세요';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<BudgetPeriod>(
                value: _selectedPeriod,
                decoration: const InputDecoration(labelText: '예산 기간'),
                items: BudgetPeriod.values.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(period.displayName),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedPeriod = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: _saveBudget, child: const Text('저장')),
      ],
    );
  }

  void _saveBudget() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final amount = double.parse(_amountController.text.replaceAll(',', ''));

        final homeViewModel = ref.read(homeViewModelProvider.notifier);
        await homeViewModel.addBudget(
          name: _nameController.text,
          category: _selectedCategory,
          amount: amount,
          period: _selectedPeriod,
        );

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('예산이 추가되었습니다!')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

// 목표 추가 다이얼로그
class _AddGoalDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends ConsumerState<_AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('절약 목표 추가'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '목표 이름'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return '목표 이름을 입력해주세요';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: '목표 금액',
                  suffixText: '원',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) {
                  if (value?.isEmpty ?? true) return '목표 금액을 입력해주세요';
                  // 컴마 제거 후 숫자 변환
                  final numericValue = value!.replaceAll(',', '');
                  if (double.tryParse(numericValue) == null)
                    return '올바른 금액을 입력해주세요';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              ListTile(
                title: const Text('목표 날짜'),
                subtitle: Text(
                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '목표 설명 (선택사항)',
                  hintText: '예: 여행 자금, 비상금 등',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: _saveGoal, child: const Text('저장')),
      ],
    );
  }

  void _saveGoal() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final amount = double.parse(_amountController.text.replaceAll(',', ''));

        final homeViewModel = ref.read(homeViewModelProvider.notifier);
        await homeViewModel.addSavingGoal(
          name: _nameController.text,
          targetAmount: amount,
          targetDate: _selectedDate,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
        );

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('절약 목표가 추가되었습니다!')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
