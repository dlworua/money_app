import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/providers.dart';
import '../dialogs/add_transaction_dialog.dart';
import '../../data/models/transaction.dart';
import '../../data/models/budget.dart';
import '../../data/models/saving_goal.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          '가계부',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: [
            const Tab(text: '내역', icon: Icon(Icons.list_alt, size: 20)),
            const Tab(text: '통계', icon: Icon(Icons.analytics, size: 20)),
            const Tab(
              text: '예산',
              icon: Icon(Icons.account_balance_wallet, size: 20),
            ),
            const Tab(text: '목표', icon: Icon(Icons.flag, size: 20)),
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
        backgroundColor: Colors.green.shade400,
        icon: const Icon(Icons.add, color: Colors.white, size: 24),
        label: const Text(
          '거래 추가',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTransactionListTab() {
    return Column(
      children: [
        // 월 선택기
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
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
                child: Text(
                  '${_selectedDate.year}년 ${_selectedDate.month}월',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

            return Column(
              children: [
                // 월 요약 카드
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade50, Colors.teal.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                      Container(width: 1, height: 40.0, color: Colors.grey.shade300),
                      Expanded(
                        child: _buildSummaryItem(
                          '지출',
                          expense,
                          Icons.trending_down,
                          Colors.red,
                        ),
                      ),
                      Container(width: 1, height: 40.0, color: Colors.grey.shade300),
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
                ),

              ],
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
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '이번 달 거래 내역이 없습니다.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '첫 거래를 추가해보세요!',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
        Icon(icon, color: color, size: 24.0),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            fontSize: 12.0,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _formatCurrency(amount),
            style: TextStyle(
              color: color,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  String _formatTransactionDate(DateTime date) {
    return '${date.month}월 ${date.day}일';
  }

  Widget _buildTransactionItemWithData(Transaction transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    final isIncome = transaction.type == TransactionType.income;
    final color = isExpense
        ? Colors.red
        : (isIncome ? Colors.blue : Colors.green);
    final sign = isExpense ? '-' : '+';

    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
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
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                transaction.category.emoji,
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.category.displayName} • ${_formatTransactionDate(transaction.date)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
                // 메모 표시 추가
                if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.note!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            '$sign${_formatCurrency(transaction.amount).replaceAll('원', '')}원',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                    colors: [Colors.purple.shade100, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${now.month}월 수지',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _formatCurrency(netAmount, showSign: true),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: netAmount >= 0
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '수입 ${_formatCurrency(income).replaceAll('원', '')} - 지출 ${_formatCurrency(expense).replaceAll('원', '')}',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade700
                            : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    if (saving > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '절약 ${_formatCurrency(saving, showSign: true)}',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.green.shade600,
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
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '이번 달 지출 내역이 없습니다.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '거래를 추가하면 통계를 확인할 수 있어요!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Theme.of(context).chipTheme.backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '전체 지출의 ${(percentage * 100).round()}%',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
      padding: const EdgeInsets.all(16),
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
              try {
                final homeState = ref.watch(homeViewModelProvider);
                final budgets = homeState.budgets;

                // 로딩 상태 처리
                if (homeState.isLoading) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // 빈 상태 처리
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
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '설정된 예산이 없습니다.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '첫 예산을 추가해보세요!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 예산 리스트 표시
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: budgets.length,
                  itemBuilder: (context, index) {
                    return _buildBudgetItemWithData(budgets[index]);
                  },
                );
              } catch (error) {
                // 에러 발생 시 기본 빈 상태 표시
                return Container(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '예산 데이터를 불러올 수 없습니다.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '잠시 후 다시 시도해주세요.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
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
            ? Border.all(color: Colors.red.shade300, width: 1)
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
              Expanded(
                child: Row(
                  children: [
                    Text(
                      budget.category.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        budget.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    '${_formatCurrency(budget.spent)} / ${_formatCurrency(budget.amount)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isOverBudget
                          ? Colors.red
                          : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8)),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showDeleteBudgetDialog(budget),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage > 1.0 ? 1.0 : percentage,
            backgroundColor: Theme.of(context).chipTheme.backgroundColor,
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
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                '${percentage > 1 ? (percentage * 100).toInt() : budget.spentPercentage.toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverBudget ? Colors.red.shade600 : Colors.grey.shade600,
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
      padding: const EdgeInsets.all(16),
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
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '설정된 목표가 없습니다.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '첫 절약 목표를 추가해보세요!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  return _buildGoalItemWithData(goals[index]);
                },
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.black,
                      ),
                    ),
                    if (goal.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        goal.description ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: goal.isCompleted
                          ? Colors.green.shade100
                          : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      goal.isCompleted ? '완료!' : '${(percentage * 100).round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: goal.isCompleted
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showDeleteGoalDialog(goal),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Theme.of(context).chipTheme.backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              goal.isCompleted ? Colors.green.shade600 : Colors.blue.shade600,
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Flexible(
                child: Text(
                  '목표: ${_formatCurrency(goal.targetAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'D-${goal.remainingDays}',
                style: TextStyle(
                  fontSize: 12,
                  color: goal.remainingDays <= 7
                      ? Colors.red.shade600
                      : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }

  void _showAddBudgetDialog() {
    showDialog(context: context, builder: (context) => _AddBudgetDialog());
  }

  void _showAddGoalDialog() {
    showDialog(context: context, builder: (context) => _AddGoalDialog());
  }

  // 예산 삭제 다이얼로그
  void _showDeleteBudgetDialog(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('예산 삭제'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${budget.name} 예산을 삭제하시겠습니까?'),
            const SizedBox(height: 8),
            Text(
              '삭제된 예산은 복구할 수 없습니다.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
            onPressed: () => _deleteBudget(budget),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  // 절약 목표 삭제 다이얼로그 (감정적인 메시지)
  void _showDeleteGoalDialog(SavingGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.favorite_border, color: Colors.red),
            SizedBox(width: 8),
            Text('목표를 포기하시나요?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${goal.name} 목표를 정말 포기하시겠습니까?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💪 현재 진행률: ${(goal.progress * 100).round()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.black,
                    ),
                  ),
                  Text(
                    '💰 모인 금액: ${_formatCurrency(goal.currentAmount)}',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.black,
                    ),
                  ),
                  Text(
                    '🎯 남은 금액: ${_formatCurrency(goal.remainingAmount)}',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.black,
                    ),
                  ),
                  if (goal.remainingDays > 0)
                    Text(
                      '📅 남은 기간: ${goal.remainingDays}일',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.black,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '포기하면 지금까지의 노력이 사라집니다.\n정말 삭제하시겠습니까?',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '계속 도전할래요!',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          ElevatedButton(
            onPressed: () => _deleteGoal(goal),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('포기할게요...'),
          ),
        ],
      ),
    );
  }

  // 예산 삭제 실행
  void _deleteBudget(Budget budget) async {
    try {
      final homeViewModel = ref.read(homeViewModelProvider.notifier);
      await homeViewModel.deleteBudget(budget.id);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예산이 삭제되었습니다')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // 절약 목표 삭제 실행
  void _deleteGoal(SavingGoal goal) async {
    try {
      final homeViewModel = ref.read(homeViewModelProvider.notifier);
      await homeViewModel.deleteSavingGoal(goal.id);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('목표가 삭제되었습니다. 언제든 새로운 도전을 시작하세요!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
      );
    }
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
    // 예산 관리 테마 색상 (그린/틸 계열)
    final themeColor = Colors.green.shade600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.80,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColor, themeColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '예산 추가',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '지출 관리를 위한 예산 설정',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            // 본문
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 예산 이름
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '예산 이름',
                          labelStyle: TextStyle(color: themeColor, fontSize: 13),
                          hintStyle: TextStyle(fontSize: 12),
                          prefixIcon: Icon(
                            Icons.edit_outlined,
                            color: themeColor,
                            size: 20,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: themeColor, width: 2),
                          ),
                        ),
                        style: TextStyle(fontSize: 14),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return '예산 이름을 입력해주세요';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // 카테고리 선택
                      Text(
                        '카테고리',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: TransactionCategory.values
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
                              final isSelected = _selectedCategory == category;
                              return InkWell(
                                onTap: () =>
                                    setState(() => _selectedCategory = category),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 36,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? themeColor.withValues(alpha: 0.1)
                                        : Theme.of(context).brightness == Brightness.dark
                                            ? Colors.grey[800]
                                            : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? themeColor
                                          : Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey[700]!
                                              : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        category.emoji,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        category.displayName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? themeColor
                                              : Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ),
                      const SizedBox(height: 18),

                      // 예산 금액
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: '예산 금액',
                          labelStyle: TextStyle(color: themeColor, fontSize: 13),
                          hintStyle: TextStyle(fontSize: 12),
                          suffixText: '원',
                          suffixStyle: TextStyle(fontSize: 13),
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: themeColor,
                            size: 20,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: themeColor, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyInputFormatter()],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return '예산 금액을 입력해주세요';
                          final numericValue = value!.replaceAll(',', '');
                          if (double.tryParse(numericValue) == null) {
                            return '올바른 금액을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // 예산 기간
                      Text(
                        '예산 기간',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: BudgetPeriod.values.map((period) {
                          final isSelected = _selectedPeriod == period;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _selectedPeriod = period),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 36,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? themeColor.withValues(alpha: 0.1)
                                        : Theme.of(context).brightness == Brightness.dark
                                            ? Colors.grey[800]
                                            : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? themeColor
                                          : Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey[700]!
                                              : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      period.displayName,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? themeColor
                                            : Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 버튼
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[700]!
                              : Colors.grey[400]!,
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveBudget,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

        // 예산 추가 후 상태가 이미 업데이트되므로 추가 작업 불필요

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
    // 절약 목표 테마 색상 (틸/블루 계열)
    final themeColor = Colors.teal.shade600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.80,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColor, themeColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.flag,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '절약 목표 추가',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '목표 달성을 위한 계획 세우기',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            // 본문
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 목표 이름
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '목표 이름',
                          labelStyle: TextStyle(color: themeColor, fontSize: 13),
                          hintText: '예: 여행 자금, 비상금 등',
                          hintStyle: TextStyle(fontSize: 12),
                          prefixIcon: Icon(
                            Icons.star_outline,
                            color: themeColor,
                            size: 20,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: themeColor, width: 2),
                          ),
                        ),
                        style: TextStyle(fontSize: 14),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return '목표 이름을 입력해주세요';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // 목표 금액
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: '목표 금액',
                          labelStyle: TextStyle(color: themeColor, fontSize: 13),
                          hintStyle: TextStyle(fontSize: 12),
                          suffixText: '원',
                          suffixStyle: TextStyle(fontSize: 13),
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: themeColor,
                            size: 20,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: themeColor, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyInputFormatter()],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return '목표 금액을 입력해주세요';
                          final numericValue = value!.replaceAll(',', '');
                          if (double.tryParse(numericValue) == null) {
                            return '올바른 금액을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // 목표 날짜
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 2),
                            ),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: themeColor, size: 20),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '목표 날짜',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 목표 설명
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: '목표 설명 (선택사항)',
                          labelStyle: TextStyle(color: themeColor, fontSize: 13),
                          hintText: '목표에 대한 추가 설명을 입력하세요',
                          hintStyle: TextStyle(fontSize: 12),
                          prefixIcon: Icon(
                            Icons.note_outlined,
                            color: themeColor,
                            size: 20,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: themeColor, width: 2),
                          ),
                        ),
                        style: TextStyle(fontSize: 13),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 버튼
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[700]!
                              : Colors.grey[400]!,
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveGoal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
