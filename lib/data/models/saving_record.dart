class SavingRecord {
  final String id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String? customCategory;

  SavingRecord({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.customCategory,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'category': category,
    'description': description,
    'date': date.toIso8601String(),
    'customCategory': customCategory,
  };

  factory SavingRecord.fromJson(Map<String, dynamic> json) => SavingRecord(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    category: json['category'] as String,
    description: json['description'] as String,
    date: DateTime.parse(json['date'] as String),
    customCategory: json['customCategory'] as String?,
  );
}