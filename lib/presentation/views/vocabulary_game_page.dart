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
    // 안드로이드 네비게이션 바 숨김 유지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
    });
    _checkAndConsumeTicket();
  }

  /// 티켓 확인 및 소모
  Future<void> _checkAndConsumeTicket() async {
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final hasTicket = await viewModel.consumeTicket();

    if (!hasTicket && mounted) {
      _showNoTicketDialog();
    } else {
      _initializeGame();
    }
  }

  /// 티켓 부족 다이얼로그
  void _showNoTicketDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎫 티켓 부족'),
        content: const Text('게임을 플레이하려면 티켓이 필요합니다.\n티켓은 15분마다 1개씩 자동 충전됩니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 게임 페이지 닫기
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
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
                color: _totalEarnedCoins > 0 ? AppTheme.green(context) : AppTheme.getGreyColor(context, 500),
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
              onPressed: () async {
                Navigator.of(context).pop(); // 결과 다이얼로그

                // 티켓 확인 및 소모
                final viewModel = ref.read(homeViewModelProvider.notifier);
                final hasTicket = await viewModel.consumeTicket();

                if (!hasTicket && mounted) {
                  _showNoTicketDialog();
                } else {
                  _initializeGame(); // 게임 재시작
                }
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
        foregroundColor: AppTheme.white(context),
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
            color: AppTheme.green(context, 50),
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
                  // 한글 뜻 - 가로형으로 컴팩트하게 배치
                  Row(
                    children: [
                      // 아이콘
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.purple(context, 400), AppTheme.blue(context, 400)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.translate,
                          color: AppTheme.white(context),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // 한글 뜻 텍스트
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppTheme.purple(context, 50), AppTheme.blue(context, 50)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.purple(context, 200), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '한글 뜻',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.getGreyColor(context, 500),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentQuestion.korean,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.black(context).withValues(alpha: 0.87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Choose the correct English word',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.getGreyColor(context, 500),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 선택지들 - 크기 조정으로 더 컴팩트하게
                  ...currentQuestion.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    Color? buttonColor;
                    Color? textColor;

                    if (_showResult && _selectedAnswerIndex == index) {
                      if (index == correctAnswerIndex) {
                        buttonColor = AppTheme.green(context);
                        textColor = AppTheme.white(context);
                      } else {
                        buttonColor = AppTheme.red(context);
                        textColor = AppTheme.white(context);
                      }
                    } else if (_showResult && index == correctAnswerIndex) {
                      buttonColor = AppTheme.green(context, 100);
                      textColor = AppTheme.green(context, 700);
                    }

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed: _isAnswered
                            ? null
                            : () => _selectAnswer(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor ?? AppTheme.getGreyColor(context, 100),
                          foregroundColor: textColor ?? AppTheme.black(context),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),

                  // 결과 메시지 - 오버플로우 방지
                  if (_showResult)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (_selectedAnswerIndex == correctAnswerIndex)
                            ? AppTheme.green(context, 50)
                            : AppTheme.red(context, 50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            (_selectedAnswerIndex == correctAnswerIndex)
                                ? '정답이예요! 🎉'
                                : '오답이네요! 😅',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  (_selectedAnswerIndex == correctAnswerIndex)
                                  ? AppTheme.green(context, 700)
                                  : AppTheme.red(context, 700),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '정답: ${currentQuestion.correctAnswer}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getGreyColor(context, 700),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

        ],
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
          color: AppTheme.white(context),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black(context).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
