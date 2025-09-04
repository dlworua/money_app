import '../../core/enums/coaching_style.dart';

class AiCoachingInsight {
  final String id;
  final DateTime createdAt;
  final CoachingStyle style;
  final String title;
  final String message;
  final InsightType type;
  final Map<String, dynamic> analysisData;
  final double confidenceScore;
  final List<String> actionItems;
  final bool isRead;

  const AiCoachingInsight({
    required this.id,
    required this.createdAt,
    required this.style,
    required this.title,
    required this.message,
    required this.type,
    required this.analysisData,
    required this.confidenceScore,
    required this.actionItems,
    this.isRead = false,
  });

  AiCoachingInsight copyWith({
    String? id,
    DateTime? createdAt,
    CoachingStyle? style,
    String? title,
    String? message,
    InsightType? type,
    Map<String, dynamic>? analysisData,
    double? confidenceScore,
    List<String>? actionItems,
    bool? isRead,
  }) {
    return AiCoachingInsight(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      style: style ?? this.style,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      analysisData: analysisData ?? this.analysisData,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      actionItems: actionItems ?? this.actionItems,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'style': style.name,
      'title': title,
      'message': message,
      'type': type.name,
      'analysisData': analysisData,
      'confidenceScore': confidenceScore,
      'actionItems': actionItems,
      'isRead': isRead,
    };
  }

  factory AiCoachingInsight.fromJson(Map<String, dynamic> json) {
    return AiCoachingInsight(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      style: CoachingStyle.values.firstWhere(
        (style) => style.name == json['style'],
        orElse: () => CoachingStyle.kind,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      type: InsightType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => InsightType.general,
      ),
      analysisData: Map<String, dynamic>.from(json['analysisData']),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      actionItems: List<String>.from(json['actionItems']),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

enum InsightType {
  goalProgress('목표 진행도'),
  spendingPattern('소비 패턴'),
  categoryAnalysis('카테고리 분석'),
  streakMotivation('연속 기록'),
  monthlyReview('월간 리뷰'),
  achievement('성취 축하'),
  warning('경고/주의'),
  general('일반 조언');

  const InsightType(this.displayName);
  final String displayName;
}