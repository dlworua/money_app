import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/theme/app_theme.dart';
import '../viewmodels/providers.dart';
import '../../data/quiz_data/quiz_data_manager.dart';

class FinancialQuizPage extends ConsumerStatefulWidget {
  const FinancialQuizPage({super.key});

  @override
  ConsumerState<FinancialQuizPage> createState() => _FinancialQuizPageState();
}

class _FinancialQuizPageState extends ConsumerState<FinancialQuizPage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _hasAnswered = false;
  int _currentQuestionIndex = 0;
  int _score = 0;
  final int _totalQuestions = 5;
  String? _selectedAnswer;
  int? _selectedAnswerIndex;
  bool? _isCorrect;

  List<Map<String, dynamic>> _selectedQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _selectRandomQuestions();
    // 안드로이드 네비게이션 바 숨김 유지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
    });
  }

  void _selectRandomQuestions() {
    _selectedQuestions = QuizDataManager.getBalancedQuestions(_totalQuestions);
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // 테스트 ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
      ),
    );
    _bannerAd?.load();
  }

  void _selectAnswer(String answer, int selectedIndex) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _selectedAnswerIndex = selectedIndex;
      _hasAnswered = true;
      _isCorrect =
          selectedIndex == _selectedQuestions[_currentQuestionIndex]['correct'];
      if (_isCorrect!) {
        _score += 5; // 문제당 5점
      }
    });

    // 정답 해설 팝업 표시
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showExplanationDialog();
      }
    });
  }

  void _showExplanationDialog() {
    final currentQuestion = _selectedQuestions[_currentQuestionIndex];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _isCorrect! ? Icons.check_circle : Icons.cancel,
              color: _isCorrect! ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              _isCorrect! ? '정답입니다!' : '오답입니다!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 점수 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isCorrect! ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.stars,
                    color: _isCorrect! ? Colors.green[600] : Colors.orange[600],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _isCorrect! ? '5포인트를 획득했어요!' : '포인트를 획득하지 못했어요..',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isCorrect!
                            ? Colors.green[800]
                            : Colors.orange[800],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 해설
            const Text(
              '해설:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!, width: 1),
              ),
              child: Text(
                currentQuestion['explanation'] ?? '해설이 준비되지 않았습니다.',
                style: const TextStyle(fontSize: 14, height: 1.6),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 해설 다이얼로그 닫기
              _nextQuestion(); // 다음 문제로
            },
            child: Text(
              _currentQuestionIndex < _totalQuestions - 1 ? '다음 문제' : '결과 보기',
            ),
          ),
        ],
      ),
    );
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
        _hasAnswered = false;
        _selectedAnswer = null;
        _selectedAnswerIndex = null;
        _isCorrect = null;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    // 포인트 지급
    final viewModel = ref.read(homeViewModelProvider.notifier);
    viewModel.playFinancialQuiz(_score);

    // 결과 보여주기
    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.celebration,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '퀴즈 완료!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 점수 표시
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[100]!, Colors.orange[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber[300]!, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(Icons.stars, color: Colors.amber[600], size: 40),
                    const SizedBox(height: 8),
                    Text(
                      '$_score점',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_score 포인트 획득!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _currentQuestionIndex = 0;
                        _score = 0;
                        _hasAnswered = false;
                        _selectedAnswer = null;
                        _selectedAnswerIndex = null;
                        _isCorrect = null;
                      });
                      _selectRandomQuestions();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('다시 게임하기'),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('게임 종료'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty) {
      case '기초':
        return Colors.green;
      case '중급':
        return Colors.orange;
      case '고급':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedQuestions.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink[50]!, Colors.purple[50]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final currentQuestion = _selectedQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '금융 퀴즈',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.pink(context, 600),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.pink(context, 400), AppTheme.pink(context, 600)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '진행도',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_currentQuestionIndex + 1}/$_totalQuestions',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '획득 포인트',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink[50]!,
              Colors.purple[50]!,
              AppTheme.getBackgroundColor(context),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 문제 카드 - 크기 조정
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.purple[50]!.withValues(alpha: 0.3),
                      Colors.blue[50]!.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 카테고리/난이도 배지
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getDifficultyColor(currentQuestion['difficulty']),
                            _getDifficultyColor(
                              currentQuestion['difficulty'],
                            ).withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getDifficultyColor(
                              currentQuestion['difficulty'],
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '📊 ${currentQuestion['category'] ?? '금융'} • ${currentQuestion['difficulty'] ?? '기초'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 문제 텍스트 - 크기 조정
                    Text(
                      currentQuestion['question'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 선택지 - 크기 조정
              ...currentQuestion['options'].asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isCorrect = index == currentQuestion['correct'];
                final isSelected = _selectedAnswer == option;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _hasAnswered
                            ? (isCorrect
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : (isSelected && !isCorrect
                                        ? Colors.red.withValues(alpha: 0.2)
                                        : Colors.black.withValues(alpha: 0.05)))
                            : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _hasAnswered
                          ? null
                          : () => _selectAnswer(option, index),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: _hasAnswered
                              ? (isCorrect
                                    ? LinearGradient(
                                        colors: [
                                          Colors.green[100]!,
                                          Colors.green[50]!,
                                        ],
                                      )
                                    : (isSelected && !isCorrect
                                          ? LinearGradient(
                                              colors: [
                                                Colors.red[100]!,
                                                Colors.red[50]!,
                                              ],
                                            )
                                          : LinearGradient(
                                              colors: [
                                                Colors.grey[100]!,
                                                Colors.grey[50]!,
                                              ],
                                            )))
                              : LinearGradient(
                                  colors: [Colors.white, Colors.grey[50]!],
                                ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _hasAnswered
                                ? (isCorrect
                                      ? Colors.green[300]!
                                      : (isSelected && !isCorrect
                                            ? Colors.red[300]!
                                            : Colors.grey[300]!))
                                : Colors.grey[200]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _hasAnswered
                                    ? (isCorrect
                                          ? Colors.green[500]
                                          : (isSelected && !isCorrect
                                                ? Colors.red[500]
                                                : Colors.grey[400]))
                                    : Colors.pink[400],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: _hasAnswered
                                    ? Icon(
                                        isCorrect
                                            ? Icons.check
                                            : (isSelected && !isCorrect
                                                  ? Icons.close
                                                  : Icons
                                                        .radio_button_unchecked),
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : Text(
                                        String.fromCharCode(
                                          (65 + index) as int,
                                        ), // A, B, C, D
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _hasAnswered
                                      ? (isCorrect
                                            ? Colors.green[800]
                                            : (isSelected && !isCorrect
                                                  ? Colors.red[800]
                                                  : Colors.grey[700]))
                                      : Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

            ],
          ),
        ),
      ),
      // 배너 광고를 bottomNavigationBar로 이동
      bottomNavigationBar: _buildBottomAd(),
    );
  }

  /// 하단 배너 광고 위젯 (안드로이드 하단바 가림 방지)
  Widget? _buildBottomAd() {
    if (!_isAdLoaded || _bannerAd == null) return null;

    return SafeArea(
      child: Container(
        height: _bannerAd!.size.height.toDouble(),
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
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
