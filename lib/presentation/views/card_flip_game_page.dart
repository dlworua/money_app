import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/theme/app_theme.dart';
import '../viewmodels/providers.dart';

class CardFlipGamePage extends ConsumerStatefulWidget {
  const CardFlipGamePage({super.key});

  @override
  ConsumerState<CardFlipGamePage> createState() => _CardFlipGamePageState();
}

class _CardFlipGamePageState extends ConsumerState<CardFlipGamePage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  final List<CardItem> _cards = [];
  final List<int> _flippedIndexes = [];
  int _currentRound = 1;
  int _totalEarnedCoins = 0;
  bool _isGameActive = false;
  bool _isMatching = false;
  Timer? _gameTimer;
  int _timeLeft = 30; // 30초 제한시간
  bool _isPreviewMode = true; // 미리보기 모드
  Timer? _previewTimer;

  // 라운드별 설정 (5라운드)
  final Map<int, int> _roundSettings = {1: 6, 2: 8, 3: 12, 4: 16, 5: 20};

  @override
  void initState() {
    super.initState();
    _initializeBannerAd();
    _initializeGame();
    _enterFullscreen();
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
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
    final pairCount = (_roundSettings[_currentRound] ?? 6) ~/ 2;
    _cards.clear();
    _flippedIndexes.clear();

    // 카드 쌍 생성
    final icons = [
      Icons.star,
      Icons.favorite,
      Icons.cake,
      Icons.pets,
      Icons.music_note,
      Icons.sports_soccer,
      Icons.local_florist,
      Icons.wb_sunny,
      Icons.umbrella,
      Icons.coffee,
      Icons.restaurant,
      Icons.flight,
      Icons.directions_car,
      Icons.home,
      Icons.school,
      Icons.work,
      Icons.shopping_cart,
      Icons.phone,
      Icons.pedal_bike,
    ];

    for (int i = 0; i < pairCount; i++) {
      _cards.add(CardItem(id: i, icon: icons[i % icons.length]));
      _cards.add(CardItem(id: i, icon: icons[i % icons.length]));
    }

    // 향상된 셔플링 - 여러 번 섞어서 더 랜덤하게
    for (int i = 0; i < 3; i++) {
      _cards.shuffle();
    }
    _timeLeft = 30;
    _isGameActive = false; // 미리보기 중에는 비활성
    _isMatching = false;
    _isPreviewMode = true;

    // 모든 카드를 뒤집어서 3초간 보여주기
    for (var card in _cards) {
      card.isFlipped = true;
    }

    setState(() {});

    // 3초 후 카드들을 뒤집고 게임 시작
    _previewTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        for (var card in _cards) {
          card.isFlipped = false;
        }
        _isPreviewMode = false;
        _isGameActive = true;
        _startTimer();
        setState(() {});
      }
    });
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _gameOver();
      }
    });
  }

  void _onCardTap(int index) {
    if (!_isGameActive ||
        _isMatching ||
        _cards[index].isFlipped ||
        _cards[index].isMatched) {
      return;
    }

    setState(() {
      _cards[index].isFlipped = true;
      _flippedIndexes.add(index);
    });

    if (_flippedIndexes.length == 2) {
      _isMatching = true;
      _checkMatch();
    }
  }

  void _checkMatch() {
    final first = _flippedIndexes[0];
    final second = _flippedIndexes[1];

    if (_cards[first].id == _cards[second].id) {
      // 매치 성공
      setState(() {
        _cards[first].isMatched = true;
        _cards[second].isMatched = true;
        _flippedIndexes.clear();
        _isMatching = false;
      });

      _checkRoundComplete();
    } else {
      // 매치 실패 - 1초 후 뒤집기
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _cards[first].isFlipped = false;
            _cards[second].isFlipped = false;
            _flippedIndexes.clear();
            _isMatching = false;
          });
        }
      });
    }
  }

  void _checkRoundComplete() {
    if (_cards.every((card) => card.isMatched)) {
      _gameTimer?.cancel();
      final roundCoins = 5; // 라운드당 5포인트 고정
      _currentRound++; // 다음 라운드로 증가
      _totalEarnedCoins += roundCoins;

      _showRoundCompleteDialog(roundCoins);
    }
  }

  void _showRoundCompleteDialog(int roundCoins) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          title: Text(
            '라운드 ${_currentRound-1} 완료!',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.celebration, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              Text(
                '$roundCoins 포인트 획득!',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              Text(
                '총 획득: $_totalEarnedCoins 포인트',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              if (_currentRound <= 5) Text(
                '다음 라운드로 진행하시겠습니까?',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ],
          ),
          actions: [
            if (_currentRound <= 5) ...[
              TextButton(onPressed: _exitGame, child: const Text('그만하기')),
              ElevatedButton(onPressed: _nextRound, child: const Text('계속하기')),
            ] else ...[
              ElevatedButton(onPressed: _exitGame, child: const Text('완료')),
            ],
          ],
        );
      },
    );
  }

  void _nextRound() {
    Navigator.of(context).pop(); // 다이얼로그 닫기
    // _currentRound는 이미 _checkRoundComplete에서 증가됨
    _initializeGame();
  }

  void _gameOver() {
    _gameTimer?.cancel();
    _isGameActive = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          title: Text(
            '시간 종료!',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_off, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                '시간이 초과되었습니다.',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              Text(
                '획득 포인트: 0',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 결과 다이얼로그
                Navigator.of(context).pop(); // 게임 페이지
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _exitGame() async {
    _gameTimer?.cancel();

    if (_totalEarnedCoins > 0) {
      final viewModel = ref.read(homeViewModelProvider.notifier);
      await viewModel.playCardFlipGame(_totalEarnedCoins);
    }

    if (mounted) {
      Navigator.of(context).pop(); // 결과 다이얼로그
      Navigator.of(context).pop(); // 게임 페이지
    }
  }

  @override
  void dispose() {
    _exitFullscreen();
    _gameTimer?.cancel();
    _previewTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('카드 뒤집기 게임'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [AppTheme.backgroundColor, Colors.grey[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // 게임 정보
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        '라운드',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      Text(
                        '$_currentRound/5',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        '획득 포인트',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      Text(
                        '$_totalEarnedCoins',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        _isPreviewMode ? '미리보기' : '남은 시간',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _isPreviewMode ? '2s' : '${_timeLeft}s',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isPreviewMode
                              ? Colors.amber[200]
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 게임 보드
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = _getCrossAxisCount();

                    // 더 타이트한 간격으로 화면 활용도 극대화
                    final horizontalSpacing = 3.0;
                    final verticalSpacing = 3.0;

                    // 완전 정사각형 유지
                    final childAspectRatio = 1.0;

                    return Center(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: horizontalSpacing,
                              mainAxisSpacing: verticalSpacing,
                              childAspectRatio: childAspectRatio,
                            ),
                        itemCount: _cards.length,
                        itemBuilder: (context, index) => _buildCard(index),
                      ),
                    );
                  },
                ),
              ),
            ),

          ],
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

  int _getCrossAxisCount() {
    final cardCount = _roundSettings[_currentRound] ?? 6; // 안전한 기본값
    // 카드 수에 따른 최적의 열 수 계산
    if (cardCount <= 4) return 2; // 2x2
    if (cardCount <= 6) return 3; // 3x2
    if (cardCount <= 8) return 4; // 4x2
    if (cardCount <= 12) return 4; // 4x3
    if (cardCount <= 16) return 4; // 4x4
    if (cardCount <= 24) return 6; // 6x4
    if (cardCount <= 32) return 8; // 8x4
    return 10; // 대형 그리드
  }

  Widget _buildCard(int index) {
    final card = _cards[index];
    final isFlipped = card.isFlipped || card.isMatched;

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(1), // 더 타이트한 마진
        decoration: BoxDecoration(
          color: card.isMatched
              ? Colors.green[100]
              : isFlipped
              ? Colors.blue[100]
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: card.isMatched
                ? Colors.green
                : isFlipped
                ? Colors.blue
                : Colors.grey,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 카드 크기에 따른 아이콘 크기 자동 조정
            final iconSize = constraints.maxWidth * 0.4;
            return Center(
              child: isFlipped
                  ? Icon(
                      card.icon,
                      size: iconSize,
                      color: card.isMatched
                          ? Colors.green[700]
                          : Colors.blue[700],
                    )
                  : Icon(
                      Icons.help_outline,
                      size: iconSize,
                      color: Colors.grey[600],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class CardItem {
  final int id;
  final IconData icon;
  bool isFlipped;
  bool isMatched;

  CardItem({
    required this.id,
    required this.icon,
    this.isFlipped = false,
    this.isMatched = false,
  });
}