import 'transaction.dart';

class Budget {
  final String id;
  final String name;
  final double amount;
  final TransactionCategory category;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final double spent;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.spent = 0.0,
  });

  double get remainingAmount => amount - spent;
  double get spentPercentage => amount > 0 ? (spent / amount) * 100 : 0;
  bool get isOverBudget => spent > amount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'category': category.name,
    'period': period.name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'isActive': isActive,
    'spent': spent,
  };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'] as String,
    name: json['name'] as String,
    amount: (json['amount'] as num).toDouble(),
    category: TransactionCategory.values.byName(json['category'] as String),
    period: BudgetPeriod.values.byName(json['period'] as String),
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    isActive: json['isActive'] as bool? ?? true,
    spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
  );

  Budget copyWith({
    String? id,
    String? name,
    double? amount,
    TransactionCategory? category,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    double? spent,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      spent: spent ?? this.spent,
    );
  }
}

enum BudgetPeriod {
  weekly, // 주간
  monthly, // 월간
  yearly, // 연간
}

extension BudgetPeriodExtension on BudgetPeriod {
  String get displayName {
    switch (this) {
      case BudgetPeriod.weekly:
        return '주간';
      case BudgetPeriod.monthly:
        return '월간';
      case BudgetPeriod.yearly:
        return '연간';
    }
  }
}
