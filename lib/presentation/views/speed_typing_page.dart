import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/utils/responsive_utils.dart';
import '../viewmodels/providers.dart';
import '../../data/typing_stories_data.dart';

class SpeedTypingPage extends ConsumerStatefulWidget {
  const SpeedTypingPage({super.key});

  @override
  ConsumerState<SpeedTypingPage> createState() => _SpeedTypingPageState();
}

class _SpeedTypingPageState extends ConsumerState<SpeedTypingPage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  Timer? _gameTimer;
  int _timeLeft = 60;
  bool _isGameActive = false;

  TypingStory? _currentStory;
  int _currentSentenceIndex = 0;
  int _correctSentences = 0;
  int _totalSentences = 0;
  bool _showTitle = true;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeBannerAd();
    _initializeGame();
  }

  void _initializeBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
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
    _currentStory = TypingStoriesData.getRandomStory();
    _currentSentenceIndex = 0;
    _correctSentences = 0;
    _totalSentences = 0;
    _timeLeft = 60;
    _isGameActive = false;
    _showTitle = true;
    _textController.clear();

    setState(() {});
  }

  void _startGame() {
    _isGameActive = true;
    _focusNode.requestFocus();
    _startTimer();
    setState(() {});
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });
  }

  void _checkInput() {
    if (!_isGameActive || _currentStory == null) return;

    final typedText = _textController.text.trim();

    if (_showTitle) {
      // 제목 입력 - 항상 다음으로 넘어가고 정답일 경우 점수 추가
      _totalSentences++;
      if (typedText == _currentStory!.title) {
        _correctSentences++;
      }
      _showTitle = false;
      _currentSentenceIndex = 0;
    } else {
      // 문장 입력 - 항상 다음으로 넘어가고 정답일 경우 점수 추가
      final currentSentence = _currentStory!.sentences[_currentSentenceIndex];
      _totalSentences++;

      if (typedText == currentSentence) {
        _correctSentences++;
      }

      _currentSentenceIndex++;

      // 모든 문장을 완료하면 새로운 이야기 시작
      if (_currentSentenceIndex >= _currentStory!.sentences.length) {
        _currentStory = TypingStoriesData.getRandomStory();
        _showTitle = true;
        _currentSentenceIndex = 0;
      }
    }

    _textController.clear();
    _focusNode.requestFocus();
    setState(() {});
  }

  void _endGame() async {
    _gameTimer?.cancel();
    _isGameActive = false;

    // 점수 계산 (타수 기준으로 계산)
    final accuracy = _totalSentences > 0
        ? _correctSentences / _totalSentences
        : 0.0;

    // 타수 계산: 완성한 문장들의 총 글자수를 60초 기준으로 계산 후 분당으로 환산
    int totalChars = _correctSentences * 20; // 평균 문장 길이로 근사치 계산
    final typingSpeed = totalChars; // 60초 = 1분이므로 그대로 분당 타수

    int coins = 0;

    // 포인트 계산 로직 (타수 기준)
    if (accuracy >= 0.9 && typingSpeed >= 200) {
      coins = 20; // 완벽 (200타 이상 + 90% 정확도)
    } else if (accuracy >= 0.8 && typingSpeed >= 150) {
      coins = 15; // 우수
    } else if (accuracy >= 0.7 && typingSpeed >= 100) {
      coins = 10; // 좋음
    } else if (accuracy >= 0.5 && typingSpeed >= 50) {
      coins = 5; // 보통
    }

    if (coins > 0) {
      final viewModel = ref.read(homeViewModelProvider.notifier);
      await viewModel.playSpeedTypingGame(coins);
    }

    if (mounted) {
      _showGameResult(coins, accuracy, typingSpeed);
    }
  }

  void _showGameResult(int coins, double accuracy, int typingSpeed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('타이핑 완료!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              coins > 15
                  ? Icons.star
                  : coins > 10
                  ? Icons.thumb_up
                  : Icons.emoji_events,
              color: coins > 15
                  ? Colors.amber
                  : coins > 10
                  ? Colors.blue
                  : Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text('완성한 문장: $_correctSentences개'),
            Text('총 시도한 문장: $_totalSentences개'),
            Text('정확도: ${(accuracy * 100).round()}%'),
            Text('타자속도: $typingSpeed타'),
            const SizedBox(height: 4),
            Text(
              typingSpeed >= 200
                  ? '🔥 타자왕!'
                  : typingSpeed >= 150
                  ? '⚡ 고수!'
                  : typingSpeed >= 100
                  ? '👍 잘하네요!'
                  : '💪 연습이 필요해요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '획득 포인트: $coins개',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeGame();
            },
            child: const Text('다시하기'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery를 사용해 키보드 높이 확인
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      // 키보드가 올라올 때 화면이 축소되지 않도록 설정
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('🚀 스피드 타이핑'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        // 키보드가 올라올 때 스크롤 가능하도록 설정
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          // 화면 전체 높이에서 앱바와 키보드 높이를 뺀 크기
          height: MediaQuery.of(context).size.height - 
                  kToolbarHeight - 
                  MediaQuery.of(context).padding.top -
                  keyboardHeight,
          child: Column(
            children: [
          // 게임 정보
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.purple[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('남은 시간', style: TextStyle(fontSize: 12)),
                    Text(
                      '${_timeLeft}s',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _timeLeft <= 5 ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('완성한 문장', style: TextStyle(fontSize: 12)),
                    Text(
                      '$_correctSentences',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('총 시도', style: TextStyle(fontSize: 12)),
                    Text(
                      '$_totalSentences',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 게임 영역
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isGameActive && _timeLeft == 60) ...[
                    const Icon(Icons.keyboard, size: 64, color: Colors.purple),
                    SizedBox(
                      height: ResponsiveUtils.getIPhone16PlusSpacing(
                        context,
                        24,
                      ),
                    ),
                    const Text(
                      '화면에 나타나는 문장을 정확하고 빠르게 입력하세요!',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '60초 동안 최대한 많은 문장을 입력해보세요',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        '게임 시작',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ] else if (_isGameActive && _currentStory != null) ...[
                    // 제목 또는 현재 문장 표시
                    if (_showTitle) ...[
                      // 제목 표시
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.amber[50]!, Colors.orange[50]!],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber[300]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '📖 제목',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _currentStory!.title,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // 문장 표시
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.purple[50]!, Colors.pink[50]!],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.purple[200]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '📝 문장 ${_currentSentenceIndex + 1}/${_currentStory!.sentences.length}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _currentStory!.sentences[_currentSentenceIndex],
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // 현재 입력 내용 미리보기
                    if (_textController.text.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📝 입력중인 내용:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _textController.text,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 입력 필드 (자동 포커스 개선)
                    GestureDetector(
                      onTap: () {
                        _focusNode.requestFocus();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _focusNode.hasFocus
                                ? Colors.purple[400]!
                                : Colors.purple[300]!,
                            width: _focusNode.hasFocus ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.1),
                              blurRadius: _focusNode.hasFocus ? 8 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          autofocus: true,
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: '여기에 입력하세요...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onSubmitted: (_) => _checkInput(),
                          onChanged: (_) {
                            // 실시간으로 포커스 상태 업데이트
                            setState(() {});
                          },
                        ),
                      ),
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getIPhone16PlusSpacing(
                        context,
                        24,
                      ),
                    ),

                    ElevatedButton(
                      onPressed: _checkInput,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('확인'),
                    ),
                  ],
                ],
              ),
            ),
          ),

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
}
