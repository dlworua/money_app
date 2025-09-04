enum PointHistoryType {
  earn,   // 포인트 획득
  spend,  // 포인트 사용
}

enum PointHistorySource {
  numberGuessGame,      // 숫자 맞추기 게임
  financialQuiz,        // 금융 퀴즈
  cardFlipGame,         // 카드 뒤집기 게임
  vocabularyGame,       // 영단어 퀴즈
  speedTyping,          // 스피드 타이핑
  colorReaction,        // 반응속도 테스트
  adWatch,              // 광고 시청
  dailyBonus,           // 일일 보너스
  streakBonus,          // 연속 접속 보너스
  premiumFeature,       // 프리미엄 기능 사용
  other,                // 기타
}

class PointHistory {
  final String id;
  final PointHistoryType type;
  final PointHistorySource source;
  final int amount;
  final DateTime createdAt;
  final String description;

  PointHistory({
    required this.id,
    required this.type,
    required this.source,
    required this.amount,
    required this.createdAt,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'source': source.name,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
    };
  }

  factory PointHistory.fromJson(Map<String, dynamic> json) {
    return PointHistory(
      id: json['id'] as String,
      type: PointHistoryType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => PointHistoryType.earn,
      ),
      source: PointHistorySource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => PointHistorySource.other,
      ),
      amount: json['amount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String,
    );
  }

  // Helper 메서드들
  String get sourceDisplayName {
    switch (source) {
      case PointHistorySource.numberGuessGame:
        return '숫자 맞추기 게임';
      case PointHistorySource.financialQuiz:
        return '금융 퀴즈';
      case PointHistorySource.cardFlipGame:
        return '카드 뒤집기 게임';
      case PointHistorySource.vocabularyGame:
        return '영단어 퀴즈';
      case PointHistorySource.speedTyping:
        return '스피드 타이핑';
      case PointHistorySource.colorReaction:
        return '반응속도 테스트';
      case PointHistorySource.adWatch:
        return '광고 시청';
      case PointHistorySource.dailyBonus:
        return '일일 보너스';
      case PointHistorySource.streakBonus:
        return '연속 접속 보너스';
      case PointHistorySource.premiumFeature:
        return '프리미엄 기능 사용';
      case PointHistorySource.other:
        return '기타';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${createdAt.month}월 ${createdAt.day}일';
    }
  }
}