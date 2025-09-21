import 'package:uuid/uuid.dart';

enum TransactionType {
  income,    // 수입
  expense,   // 지출
  saving,    // 절약
}

enum TransactionCategory {
  // 지출 카테고리
  food,          // 식비
  transport,     // 교통비
  shopping,      // 쇼핑
  utilities,     // 공과금
  healthcare,    // 의료비
  entertainment, // 오락
  education,     // 교육비
  housing,       // 주거비
  insurance,     // 보험료
  other,         // 기타

  // 수입 카테고리
  salary,        // 급여
  bonus,         // 보너스
  investment,    // 투자수익
  freelance,     // 프리랜서
  sideJob,       // 부업
  gift,          // 용돈/선물
  
  // 절약 카테고리
  mealSaving,    // 식비 절약
  transportSaving, // 교통비 절약
  shoppingSaving,  // 쇼핑 절약
  utilitySaving,   // 공과금 절약
  entertainmentSaving, // 오락비 절약
  customSaving,      // 사용자 정의 절약
}

extension TransactionCategoryExtension on TransactionCategory {
  String get displayName {
    switch (this) {
      // 지출
      case TransactionCategory.food: return '식비';
      case TransactionCategory.transport: return '교통비';
      case TransactionCategory.shopping: return '쇼핑';
      case TransactionCategory.utilities: return '공과금';
      case TransactionCategory.healthcare: return '의료비';
      case TransactionCategory.entertainment: return '오락';
      case TransactionCategory.education: return '교육비';
      case TransactionCategory.housing: return '주거비';
      case TransactionCategory.insurance: return '보험료';
      case TransactionCategory.other: return '기타';
      // 수입
      case TransactionCategory.salary: return '급여';
      case TransactionCategory.bonus: return '보너스';
      case TransactionCategory.investment: return '투자수익';
      case TransactionCategory.freelance: return '프리랜서';
      case TransactionCategory.sideJob: return '부업';
      case TransactionCategory.gift: return '용돈/선물';
      // 절약
      case TransactionCategory.mealSaving: return '식비 절약';
      case TransactionCategory.transportSaving: return '교통비 절약';
      case TransactionCategory.shoppingSaving: return '쇼핑 절약';
      case TransactionCategory.utilitySaving: return '공과금 절약';
      case TransactionCategory.entertainmentSaving: return '오락비 절약';
      case TransactionCategory.customSaving: return '절약';
    }
  }

  String get emoji {
    switch (this) {
      // 지출
      case TransactionCategory.food: return '🍽️';
      case TransactionCategory.transport: return '🚗';
      case TransactionCategory.shopping: return '🛒';
      case TransactionCategory.utilities: return '💡';
      case TransactionCategory.healthcare: return '🏥';
      case TransactionCategory.entertainment: return '🎮';
      case TransactionCategory.education: return '📚';
      case TransactionCategory.housing: return '🏠';
      case TransactionCategory.insurance: return '🛡️';
      case TransactionCategory.other: return '📝';
      // 수입
      case TransactionCategory.salary: return '💼';
      case TransactionCategory.bonus: return '🎁';
      case TransactionCategory.investment: return '📈';
      case TransactionCategory.freelance: return '💻';
      case TransactionCategory.sideJob: return '⚡';
      case TransactionCategory.gift: return '💝';
      // 절약
      case TransactionCategory.mealSaving: return '🥗';
      case TransactionCategory.transportSaving: return '🚲';
      case TransactionCategory.shoppingSaving: return '🛍️';
      case TransactionCategory.utilitySaving: return '💡';
      case TransactionCategory.entertainmentSaving: return '🎯';
      case TransactionCategory.customSaving: return '💰';
    }
  }

  // 거래 유형별 카테고리 필터링
  static List<TransactionCategory> getCategoriesForType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return [
          TransactionCategory.salary,
          TransactionCategory.bonus,
          TransactionCategory.investment,
          TransactionCategory.freelance,
          TransactionCategory.sideJob,
          TransactionCategory.gift,
          TransactionCategory.other, // 기타는 모든 유형에서 사용 가능
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
          TransactionCategory.other, // 기타는 모든 유형에서 사용 가능
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
}

class Transaction {
  final String id;
  final TransactionType type;
  final TransactionCategory category;
  final double amount;
  final String description;
  final DateTime date;
  final String? note;
  final String? receiptImagePath;

  Transaction({
    String? id,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.note,
    this.receiptImagePath,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'category': category.name,
    'amount': amount,
    'description': description,
    'date': date.toIso8601String(),
    'note': note,
    'receiptImagePath': receiptImagePath,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    type: TransactionType.values.byName(json['type'] as String),
    category: TransactionCategory.values.byName(json['category'] as String),
    amount: (json['amount'] as num).toDouble(),
    description: json['description'] as String,
    date: DateTime.parse(json['date'] as String),
    note: json['note'] as String?,
    receiptImagePath: json['receiptImagePath'] as String?,
  );

  Transaction copyWith({
    String? id,
    TransactionType? type,
    TransactionCategory? category,
    double? amount,
    String? description,
    DateTime? date,
    String? note,
    String? receiptImagePath,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }
}