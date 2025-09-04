import 'financial_quiz_data.dart';
import 'economics_quiz_data.dart';
import 'tax_quiz_data.dart';
import 'business_quiz_data.dart';

class QuizDataManager {
  // 모든 분야의 문제를 통합 관리
  static final List<Map<String, dynamic>> _allQuestions = [
    ...FinancialQuizData.allQuestions, // 230문제
    ...EconomicsQuizData.allQuestions, // 230문제
    ...TaxQuizData.allQuestions, // 300문제
    ...BusinessQuizData.allQuestions, // 240문제
    // 총 1000문제
  ];

  // 분야별 통계
  static const Map<String, int> categoryStats = {
    '금융': 230,
    '경제': 230,
    '세금': 300,
    '경영': 240,
  };

  // 난이도별 통계 (전체)
  static const Map<String, int> difficultyStats = {
    '기초': 400, // 40%
    '중급': 400, // 40%
    '고급': 200, // 20%
  };

  /// 랜덤으로 문제 가져오기 (전체 분야에서)
  static List<Map<String, dynamic>> getRandomQuestions(int count) {
    final shuffled = List<Map<String, dynamic>>.from(_allQuestions)..shuffle();
    return shuffled.take(count).toList();
  }

  /// 특정 분야에서 랜덤 문제 가져오기
  static List<Map<String, dynamic>> getQuestionsByCategory(
    String category,
    int count,
  ) {
    List<Map<String, dynamic>> categoryQuestions;

    switch (category) {
      case '금융':
        categoryQuestions = FinancialQuizData.allQuestions;
        break;
      case '경제':
        categoryQuestions = EconomicsQuizData.allQuestions;
        break;
      case '세금':
        categoryQuestions = TaxQuizData.allQuestions;
        break;
      case '경영':
        categoryQuestions = BusinessQuizData.allQuestions;
        break;
      default:
        categoryQuestions = _allQuestions;
    }

    final shuffled = List<Map<String, dynamic>>.from(categoryQuestions)
      ..shuffle();
    return shuffled.take(count).toList();
  }

  /// 특정 난이도에서 랜덤 문제 가져오기
  static List<Map<String, dynamic>> getQuestionsByDifficulty(
    String difficulty,
    int count,
  ) {
    final filtered = _allQuestions
        .where((q) => q['difficulty'] == difficulty)
        .toList();
    final shuffled = List<Map<String, dynamic>>.from(filtered)..shuffle();
    return shuffled.take(count).toList();
  }

  /// 분야와 난이도를 모두 지정해서 문제 가져오기
  static List<Map<String, dynamic>> getQuestionsByCategoryAndDifficulty(
    String category,
    String difficulty,
    int count,
  ) {
    final categoryQuestions = getQuestionsByCategory(
      category,
      1000,
    ); // 해당 분야 전체
    final filtered = categoryQuestions
        .where((q) => q['difficulty'] == difficulty)
        .toList();
    final shuffled = List<Map<String, dynamic>>.from(filtered)..shuffle();
    return shuffled.take(count).toList();
  }

  /// 균형잡힌 문제 세트 생성 (난이도별 비율 유지)
  /// 기초 40%, 중급 40%, 고급 20% 비율로 구성
  static List<Map<String, dynamic>> getBalancedQuestions(int count) {
    final basicCount = (count * 0.4).round();
    final intermediateCount = (count * 0.4).round();
    final advancedCount = count - basicCount - intermediateCount;

    final questions = <Map<String, dynamic>>[];

    questions.addAll(getQuestionsByDifficulty('기초', basicCount));
    questions.addAll(getQuestionsByDifficulty('중급', intermediateCount));
    questions.addAll(getQuestionsByDifficulty('고급', advancedCount));

    questions.shuffle(); // 순서를 섞어서 반환
    return questions;
  }

  /// 분야별 균형잡힌 문제 세트 생성
  static List<Map<String, dynamic>> getBalancedQuestionsByCategory(
    String category,
    int count,
  ) {
    final basicCount = (count * 0.4).round();
    final intermediateCount = (count * 0.4).round();
    final advancedCount = count - basicCount - intermediateCount;

    final questions = <Map<String, dynamic>>[];

    questions.addAll(
      getQuestionsByCategoryAndDifficulty(category, '기초', basicCount),
    );
    questions.addAll(
      getQuestionsByCategoryAndDifficulty(category, '중급', intermediateCount),
    );
    questions.addAll(
      getQuestionsByCategoryAndDifficulty(category, '고급', advancedCount),
    );

    questions.shuffle(); // 순서를 섞어서 반환
    return questions;
  }

  /// 전체 통계 정보 반환
  static Map<String, dynamic> getStatistics() {
    return {
      'totalQuestions': _allQuestions.length,
      'categoryStats': categoryStats,
      'difficultyStats': difficultyStats,
      'categories': categoryStats.keys.toList(),
      'difficulties': ['기초', '중급', '고급'],
    };
  }

  /// 특정 분야의 난이도별 통계
  static Map<String, int> getCategoryDifficultyStats(String category) {
    List<Map<String, dynamic>> categoryQuestions;

    switch (category) {
      case '금융':
        categoryQuestions = FinancialQuizData.allQuestions;
        break;
      case '경제':
        categoryQuestions = EconomicsQuizData.allQuestions;
        break;
      case '세금':
        categoryQuestions = TaxQuizData.allQuestions;
        break;
      case '경영':
        categoryQuestions = BusinessQuizData.allQuestions;
        break;
      default:
        return {};
    }

    final stats = <String, int>{};
    for (final question in categoryQuestions) {
      final difficulty = question['difficulty'] as String;
      stats[difficulty] = (stats[difficulty] ?? 0) + 1;
    }

    return stats;
  }

  /// 검색 기능 - 키워드로 문제 찾기
  static List<Map<String, dynamic>> searchQuestions(
    String keyword, {
    int? limit,
  }) {
    final results = _allQuestions.where((q) {
      final question = (q['question'] as String).toLowerCase();
      final explanation = (q['explanation'] as String).toLowerCase();
      final searchKeyword = keyword.toLowerCase();

      return question.contains(searchKeyword) ||
          explanation.contains(searchKeyword);
    }).toList();

    if (limit != null && results.length > limit) {
      return results.take(limit).toList();
    }

    return results;
  }

  /// 문제 검증 - 중복 체크 등
  static Map<String, dynamic> validateQuestions() {
    final duplicateQuestions = <String>[];
    final questionTexts = <String>{};

    for (final question in _allQuestions) {
      final questionText = question['question'] as String;
      if (questionTexts.contains(questionText)) {
        duplicateQuestions.add(questionText);
      } else {
        questionTexts.add(questionText);
      }
    }

    return {
      'totalQuestions': _allQuestions.length,
      'uniqueQuestions': questionTexts.length,
      'duplicates': duplicateQuestions,
      'isValid': duplicateQuestions.isEmpty,
    };
  }
}
