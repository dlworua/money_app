import 'package:uuid/uuid.dart';

class SavingGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final String? description;
  final bool isCompleted;
  final DateTime? completedAt;

  const SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.createdAt,
    this.description,
    this.isCompleted = false,
    this.completedAt,
  });

  factory SavingGoal.create({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    String? description,
  }) {
    return SavingGoal(
      id: const Uuid().v4(),
      name: name,
      targetAmount: targetAmount,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      description: description,
    );
  }

  // 진행률 계산 (0.0 ~ 1.0)
  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  // 진행률 백분율
  double get progressPercentage => progress * 100;

  // 남은 금액
  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, double.infinity);

  // 남은 일수
  int get remainingDays {
    final now = DateTime.now();
    if (targetDate.isBefore(now)) return 0;
    return targetDate.difference(now).inDays;
  }

  // 일일 목표 저축액
  double get dailyTargetAmount {
    if (remainingDays <= 0) return remainingAmount;
    return remainingAmount / remainingDays;
  }

  SavingGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory SavingGoal.fromJson(Map<String, dynamic> json) {
    return SavingGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: DateTime.parse(json['targetDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
    );
  }
}