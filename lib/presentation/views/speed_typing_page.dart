import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../core/theme/app_theme.dart';
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
                  ? AppTheme.amber(context)
                  : coins > 10
                  ? AppTheme.blue(context)
                  : AppTheme.green(context),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '완성한 문장: $_correctSentences개',
              style: TextStyle(color: AppTheme.getTextColor(context)),
            ),
            Text(
              '총 시도한 문장: $_totalSentences개',
              style: TextStyle(color: AppTheme.getTextColor(context)),
            ),
            Text(
              '정확도: ${(accuracy * 100).round()}%',
              style: TextStyle(color: AppTheme.getTextColor(context)),
            ),
            Text(
              '타자속도: $typingSpeed타',
              style: TextStyle(color: AppTheme.getTextColor(context)),
            ),
            const SizedBox(height: 4),
            Text(
              typingSpeed >= 150
                  ? '🔥 타자왕!'
                  : typingSpeed >= 100
                  ? '⚡ 고수!'
                  : typingSpeed >= 50
                  ? '👍 잘하네요!'
                  : '💪 연습이 필요해요!',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.getTextColor(context),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '획득 포인트: $coins개',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.green(context),
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
            onPressed: () async {
              Navigator.of(context).pop();

              // 티켓 확인 및 소모
              final viewModel = ref.read(homeViewModelProvider.notifier);
              final hasTicket = await viewModel.consumeTicket();

              if (!hasTicket && mounted) {
                _showNoTicketDialog();
              } else {
                _initializeGame();
              }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚀 스피드 타이핑'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: AppTheme.white(context),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Column(
        children: [
          // 상단 게임 정보 (고정 영역)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.purple(context, 50),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.black(context).withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  '남은 시간',
                  '${_timeLeft}s',
                  _timeLeft <= 10
                      ? AppTheme.red(context)
                      : AppTheme.black(context),
                ),
                _buildStatColumn(
                  '완성',
                  '$_correctSentences',
                  AppTheme.green(context),
                ),
                _buildStatColumn(
                  '시도',
                  '$_totalSentences',
                  AppTheme.black(context),
                ),
              ],
            ),
          ),

          // 메인 게임 영역 (고정)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isGameActive && _timeLeft == 60)
                    _buildWelcomeScreen()
                  else if (_isGameActive && _currentStory != null)
                    _buildGameScreen(),
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

  /// 상단 스탯 컬럼 위젯
  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.getSecondaryTextColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// 웰컴 화면 위젯
  Widget _buildWelcomeScreen() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.purple(context, 50),
                AppTheme.pink(context, 50),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.purple(context).withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.keyboard_alt_outlined,
                size: 48,
                color: AppTheme.purple(context),
              ),
              const SizedBox(height: 16),
              Text(
                '🚀 스피드 타이핑',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '화면에 나타나는 문장을 정확하고 빠르게 입력하세요!',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.getTextColor(context),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '60초 동안 최대한 많은 문장을 완성해보세요.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.getTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purple(context),
                  foregroundColor: AppTheme.white(context),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  '게임 시작',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 게임 화면 위젯
  Widget _buildGameScreen() {
    return Column(
      children: [
        const SizedBox(height: 20),

        // 제목/문장 카드
        _buildContentCard(),

        const SizedBox(height: 20),

        // 입력 영역과 확인 버튼을 가로로 배치
        _buildInputWithButton(),
      ],
    );
  }

  /// 컨텐츠 카드 (제목/문장)
  Widget _buildContentCard() {
    final isTitle = _showTitle;
    final content = isTitle
        ? _currentStory!.title
        : _currentStory!.sentences[_currentSentenceIndex];
    final label = isTitle
        ? '📖 제목'
        : '📝 문장 ${_currentSentenceIndex + 1}/${_currentStory!.sentences.length}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isTitle
              ? [AppTheme.amber(context, 50), AppTheme.orange(context, 50)]
              : [AppTheme.purple(context, 50), AppTheme.pink(context, 50)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTitle
              ? AppTheme.amber(context, 200)
              : AppTheme.purple(context, 200),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isTitle ? AppTheme.amber(context) : AppTheme.purple(context))
                    .withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          AutoSizeText(
            content,
            style: TextStyle(
              fontSize: isTitle ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.getSecondaryTextColor(context),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: isTitle ? 2 : 3,
            minFontSize: 14,
          ),
        ],
      ),
    );
  }

  /// 입력 영역과 확인 버튼을 가로로 배치
  Widget _buildInputWithButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 텍스트 입력 영역 (확장)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.white(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? AppTheme.purple(context, 400)
                    : AppTheme.getGreyColor(context, 300),
                width: _focusNode.hasFocus ? 2 : 1,
              ),
              boxShadow: [
                if (_focusNode.hasFocus)
                  BoxShadow(
                    color: AppTheme.purple(context).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              autofocus: true,
              style: const TextStyle(fontSize: 16, height: 1.4),
              maxLines: 3,
              minLines: 2,
              decoration: InputDecoration(
                hintText: '여기에 입력하세요...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppTheme.getGreyColor(context, 500),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              onSubmitted: (_) => _checkInput(),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 확인 버튼 (고정 크기)
        SizedBox(
          height: 56, // 텍스트 필드와 비슷한 높이
          child: ElevatedButton(
            onPressed: _checkInput,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.purple(context),
              foregroundColor: AppTheme.white(context),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              '확인',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
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
