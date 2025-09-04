import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/theme/app_theme.dart';
import '../viewmodels/providers.dart';

class ColorReactionPage extends ConsumerStatefulWidget {
  const ColorReactionPage({super.key});

  @override
  ConsumerState<ColorReactionPage> createState() => _ColorReactionPageState();
}

class _ColorReactionPageState extends ConsumerState<ColorReactionPage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // 게임 상태
  bool _isGameActive = false;
  bool _isWaitingForGreen = false;
  bool _gameCompleted = false;
  int _currentRound = 0;
  final int _totalRounds = 3;

  // F1 신호등 상태 (5개 빨간불)
  List<bool> _redLights = [false, false, false, false, false];
  bool _allLightsOut = false;

  // 타이밍
  DateTime? _greenLightTime;
  final List<int> _reactionTimes = [];
  Timer? _gameTimer;

  // 랜덤 대기 시간 (2-5초)
  int _waitTimeMs = 0;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // 테스트 ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    );
    _bannerAd?.load();
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _currentRound = 0;
      _reactionTimes.clear();
      _gameCompleted = false;
    });
    _startNextRound();
  }

  void _startNextRound() {
    if (_currentRound >= _totalRounds) {
      _endGame();
      return;
    }

    setState(() {
      _currentRound++;
      _redLights = [false, false, false, false, false];
      _allLightsOut = false;
      _isWaitingForGreen = false;
      _greenLightTime = null;
    });

    // F1 스타일 시퀀스 시작
    _startF1Sequence();
  }

  void _startF1Sequence() {
    int lightIndex = 0;

    // 빨간불을 하나씩 켜기 (1초 간격)
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (lightIndex < 5) {
        setState(() {
          _redLights[lightIndex] = true;
        });
        lightIndex++;
      } else {
        timer.cancel();

        // 모든 빨간불이 켜진 후 랜덤 시간 대기
        _waitTimeMs = 2000 + Random().nextInt(3000); // 2-5초

        setState(() {
          _isWaitingForGreen = true;
        });

        // 랜덤 시간 후 모든 불 끄기 (초록불 신호)
        _gameTimer = Timer(Duration(milliseconds: _waitTimeMs), () {
          setState(() {
            _allLightsOut = true;
            _isWaitingForGreen = false;
            _greenLightTime = DateTime.now();
          });
        });
      }
    });
  }

  void _handleTap() {
    if (!_isGameActive) return;

    final now = DateTime.now();

    if (!_allLightsOut) {
      // 너무 빨리 눌렀음 (False start)
      _reactionTimes.add(-1); // -1로 false start 표시
      _showRoundResult(isFalseStart: true);
    } else if (_greenLightTime != null) {
      // 정상적인 반응
      final reactionMs = now.difference(_greenLightTime!).inMilliseconds;
      _reactionTimes.add(reactionMs);
      _showRoundResult(reactionTime: reactionMs);
    }
  }

  void _showRoundResult({bool isFalseStart = false, int? reactionTime}) {
    _gameTimer?.cancel();

    String message;
    Color backgroundColor;

    if (isFalseStart) {
      message = '❌ False Start!\n너무 빨리 눌렀습니다!';
      backgroundColor = Colors.red[50]!;
    } else if (reactionTime != null) {
      if (reactionTime <= 200) {
        message = '🏆 환상적이네요! ${reactionTime}ms\n프로 레이서 수준이에요!';
        backgroundColor = Colors.green[50]!;
      } else if (reactionTime <= 300) {
        message = '⚡ 훌륭해요! ${reactionTime}ms\n매우 빠른 반응이에요!';
        backgroundColor = Colors.blue[50]!;
      } else if (reactionTime <= 500) {
        message = '👍 좋아요! ${reactionTime}ms\n괜찮은 반응속도에요!';
        backgroundColor = Colors.orange[50]!;
      } else {
        message = '🐌 아쉬워요! ${reactionTime}ms\n좀 더 집중해보세요!';
        backgroundColor = Colors.grey[50]!;
      }
    } else {
      message = '시간 초과!';
      backgroundColor = Colors.grey[50]!;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('라운드 $_currentRound 결과'),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 500), () {
                _startNextRound();
              });
            },
            child: Text(_currentRound < _totalRounds ? '다음 라운드' : '결과 보기'),
          ),
        ],
      ),
    );
  }

  void _endGame() async {
    setState(() {
      _isGameActive = false;
      _gameCompleted = true;
    });

    // 점수 계산
    int coins = _calculateCoins();

    // 포인트 지급
    if (coins > 0) {
      final viewModel = ref.read(homeViewModelProvider.notifier);
      await viewModel.playColorReactionGame(coins);
    }

    _showFinalResult(coins);
  }

  int _calculateCoins() {
    int validReactions = _reactionTimes.where((time) => time > 0).length;
    double averageTime = 0;

    if (validReactions > 0) {
      averageTime =
          _reactionTimes.where((time) => time > 0).reduce((a, b) => a + b) /
          validReactions;
    }

    if (validReactions == 3 && averageTime <= 250) {
      return 15; // 완벽! 3/3 + 빠른 반응
    } else if (validReactions >= 2 && averageTime <= 350) {
      return 12; // 우수
    } else if (validReactions >= 2 && averageTime <= 450) {
      return 8; // 보통
    } else if (validReactions >= 1) {
      return 5; // 기본
    }
    return 0;
  }

  void _showFinalResult(int coins) {
    int validReactions = _reactionTimes.where((time) => time > 0).length;
    int falseStarts = _reactionTimes.where((time) => time == -1).length;
    double averageTime = validReactions > 0
        ? _reactionTimes.where((time) => time > 0).reduce((a, b) => a + b) /
              validReactions
        : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [const SizedBox(width: 8), const Text('🏁 측정 완료!')],
        ),
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[50]!, Colors.orange[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.timer, color: Colors.red[600], size: 50),
              ),
              const SizedBox(height: 16),

              // 통계
              _buildStatRow('성공한 반응', '$validReactions / $_totalRounds'),
              _buildStatRow('False Starts', '$falseStarts'),
              if (averageTime > 0)
                _buildStatRow('평균 반응시간', '${averageTime.round()}ms'),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$coins 포인트 획득!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 결과 다이얼로그 닫기
                Navigator.of(context).pop(); // 게임 페이지 닫기
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '확인',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildF1Light(int index) {
    bool isOn = _allLightsOut ? false : _redLights[index];

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isOn
              ? [Colors.red[300]!, Colors.red[600]!, Colors.red[800]!]
              : [Colors.grey[700]!, Colors.grey[800]!, Colors.grey[900]!],
          stops: const [0.0, 0.7, 1.0],
        ),
        boxShadow: isOn
            ? [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.8),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.red[300]!.withValues(alpha: 0.6),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isOn
                ? RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    colors: [
                      Colors.red[100]!.withValues(alpha: 0.8),
                      Colors.red[400]!.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  )
                : RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    colors: [
                      Colors.grey[600]!.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F1 반응속도 테스트'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 게임 영역
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isGameActive && !_gameCompleted)
                      _buildStartScreen()
                    else if (_isGameActive)
                      _buildGameScreen()
                    else
                      _buildCompletedScreen(),
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
      ),
    );
  }

  Widget _buildStartScreen() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Column(
            children: [
              Icon(Icons.sports_motorsports, size: 60, color: Colors.red[600]),
              const SizedBox(height: 12),
              const Text(
                '반응속도 테스트',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '빨간불이 모두 켜진 후\n모든 불이 꺼지는 순간 탭하세요!\n\n⚠️ 너무 빨리 누르면 False Start!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '게임 시작',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        // 라운드 표시
        Text(
          '라운드 $_currentRound / $_totalRounds',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 30),

        // F1 신호등 - 실제 가로형 디자인
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[900]!, Colors.black87],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[700]!, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // F1 브랜딩
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 신호등 한 줄 배치 (실제 F1 스타일)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) => _buildF1Light(index)),
              ),

              const SizedBox(height: 12),

              // 하단 장식 라인
              Container(
                height: 2,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.red[400]!,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // 상태 텍스트 - 레이싱 스타일
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _allLightsOut
                  ? [Colors.green[400]!, Colors.green[600]!]
                  : _isWaitingForGreen
                  ? [Colors.amber[400]!, Colors.orange[500]!]
                  : [Colors.blue[400]!, Colors.blue[600]!],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color:
                    (_allLightsOut
                            ? Colors.green
                            : _isWaitingForGreen
                            ? Colors.orange
                            : Colors.blue)
                        .withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _allLightsOut
                    ? Icons.flash_on
                    : _isWaitingForGreen
                    ? Icons.hourglass_empty
                    : Icons.traffic,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _allLightsOut
                    ? 'GO! GO! GO!'
                    : _isWaitingForGreen
                    ? '준비하세요...'
                    : '신호등 대기중',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // 탭 영역 - F1 스타일
        GestureDetector(
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _allLightsOut
                    ? [
                        Colors.green[300]!,
                        Colors.green[600]!,
                        Colors.green[800]!,
                      ]
                    : [Colors.grey[300]!, Colors.grey[500]!, Colors.grey[700]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _allLightsOut ? Colors.green[200]! : Colors.grey[400]!,
                width: 3,
              ),
              boxShadow: _allLightsOut
                  ? [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.green[300]!.withValues(alpha: 0.6),
                        blurRadius: 25,
                        spreadRadius: 4,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _allLightsOut ? Icons.touch_app : Icons.pan_tool_outlined,
                    size: 36,
                    color: _allLightsOut ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _allLightsOut ? 'TAP NOW!' : '대기 중...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _allLightsOut ? Colors.white : Colors.grey[600],
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (_allLightsOut)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedScreen() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Text(
        '측정이 완료되었습니다!\n결과를 확인해보세요.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }
}