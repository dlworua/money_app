import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/theme/app_theme.dart';
import '../viewmodels/providers.dart';
import '../../data/vocabulary_data.dart';

class VocabularyGamePage extends ConsumerStatefulWidget {
  const VocabularyGamePage({super.key});

  @override
  ConsumerState<VocabularyGamePage> createState() => _VocabularyGamePageState();
}

class _VocabularyGamePageState extends ConsumerState<VocabularyGamePage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  int _currentQuestionIndex = 0;
  int _totalEarnedCoins = 0;
  bool _isAnswered = false;
  int? _selectedAnswerIndex;
  bool _showResult = false;

  List<VocabularyQuestion> _gameQuestions = [];

  @override
  void initState() {
    super.initState();
    _initializeBannerAd();
    _initializeGame();
  }

  void _initializeBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // 테스트 ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isAdLoaded = true),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    _bannerAd?.load();
  }

  void _initializeGame() {
    // 데이터 파일에서 랜덤으로 5문제 선택
    _gameQuestions = VocabularyData.getRandomQuestions(5);

    // 각 문제의 선택지도 섞기
    for (var question in _gameQuestions) {
      question.options.shuffle();
    }

    _currentQuestionIndex = 0;
    _totalEarnedCoins = 0;
    _isAnswered = false;
    _selectedAnswerIndex = null;
    _showResult = false;

    setState(() {});
  }

  void _selectAnswer(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      _showResult = true;
    });

    final currentQuestion = _gameQuestions[_currentQuestionIndex];
    final selectedAnswer = currentQuestion.options[index];
    final isCorrect = selectedAnswer == currentQuestion.correctAnswer;

    if (isCorrect) {
      _totalEarnedCoins += 5;
    }

    // 1초 후 다음 문제 또는 결과 표시
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _gameQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswerIndex = null;
        _showResult = false;
      });
    } else {
      _showFinalResult();
    }
  }

  void _showFinalResult() async {
    if (_totalEarnedCoins > 0) {
      final viewModel = ref.read(homeViewModelProvider.notifier);
      await viewModel.playVocabularyGame(_totalEarnedCoins);
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('게임 완료!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.school,
                color: _totalEarnedCoins > 0 ? Colors.green : Colors.grey,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text('총 획득 포인트: $_totalEarnedCoins'),
              Text(
                '정답률: ${((_totalEarnedCoins / 5) / _gameQuestions.length * 100).round()}%',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 결과 다이얼로그
                Navigator.of(context).pop(); // 게임 페이지
              },
              child: const Text('확인'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 결과 다이얼로그
                _initializeGame(); // 게임 재시작
              },
              child: const Text('다시하기'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameQuestions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = _gameQuestions[_currentQuestionIndex];
    final correctAnswerIndex = _isAnswered
        ? currentQuestion.options.indexOf(currentQuestion.correctAnswer)
        : -1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('소비 영단어 게임'),
        backgroundColor: AppTheme.successColor,
        foregroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Column(
        children: [
          // 진행도 표시
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('진행도', style: TextStyle(fontSize: 12)),
                    Text(
                      '${_currentQuestionIndex + 1}/${_gameQuestions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('획득 포인트', style: TextStyle(fontSize: 12)),
                    Text(
                      '$_totalEarnedCoins',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 문제 영역
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 한글 뜻 - 더 눈에 띄게
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.purple[50]!, Colors.blue[50]!],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple[200]!, width: 1),
                    ),
                    child: Text(
                      currentQuestion.korean,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Choose the correct English word',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 선택지들
                  ...currentQuestion.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    Color? buttonColor;
                    Color? textColor;

                    if (_showResult && _selectedAnswerIndex == index) {
                      if (index == correctAnswerIndex) {
                        buttonColor = Colors.green;
                        textColor = Colors.white;
                      } else {
                        buttonColor = Colors.red;
                        textColor = Colors.white;
                      }
                    } else if (_showResult && index == correctAnswerIndex) {
                      buttonColor = Colors.green[100];
                      textColor = Colors.green[700];
                    }

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        onPressed: _isAnswered
                            ? null
                            : () => _selectAnswer(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor ?? Colors.grey[100],
                          foregroundColor: textColor ?? Colors.black,
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),

                  // 결과 메시지
                  if (_showResult)
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (_selectedAnswerIndex == correctAnswerIndex)
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            (_selectedAnswerIndex == correctAnswerIndex)
                                ? '정답이예요! 정답은 ${currentQuestion.correctAnswer} 🎉'
                                : '오답이네요! 정답은 ${currentQuestion.correctAnswer} 😅',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  (_selectedAnswerIndex == correctAnswerIndex)
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 배너 광고
          if (_isAdLoaded && _bannerAd != null)
            SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
