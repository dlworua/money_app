import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../viewmodels/providers.dart';

class NumberGuessPage extends ConsumerStatefulWidget {
  const NumberGuessPage({super.key});

  @override
  ConsumerState<NumberGuessPage> createState() => _NumberGuessPageState();
}

class _NumberGuessPageState extends ConsumerState<NumberGuessPage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
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

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
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

  void _playNumberGuess(int number) async {
    final viewModel = ref.read(homeViewModelProvider.notifier);

    final isCorrect = await viewModel.playNumberGuessGame(number);

    if (!mounted) return;

    // 결과 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCorrect ? Icons.celebration : Icons.sentiment_dissatisfied,
              color: isCorrect ? Colors.green : Colors.orange,
              size: ResponsiveUtils.getResponsiveIconSize(context, 28),
            ),
            SizedBox(width: ResponsiveUtils.getIPhone16PlusSpacing(context, 8)),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isCorrect ? '🎉 정답!' : '😅 틀렸어요',
                  style: AppTheme.getHeadingMedium(context),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          padding: ResponsiveUtils.getResponsivePaddingCustom(context, all: 16),
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green[50] : Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.stars : Icons.refresh,
                color: isCorrect ? Colors.green[600] : Colors.orange[600],
                size: ResponsiveUtils.getResponsiveIconSize(context, 40),
              ),
              SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, 8)),
              Flexible(
                child: Text(
                  isCorrect
                      ? '축하합니다! 20 포인트을 획득했습니다!'
                      : '아쉽지만 틀렸네요. 다음에 다시 도전해보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 16),
                    color: isCorrect ? Colors.green[800] : Colors.orange[800],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCorrect) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+20 포인트',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                      fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // 결과 다이얼로그만 닫기
            child: Text('다시 게임하기', style: AppTheme.getBodyMedium(context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 결과 다이얼로그 닫기
              _exitFullscreen();
              Navigator.of(context).pop(); // 게임 페이지 닫기
            },
            child: Text('게임 종료', style: AppTheme.getBodyMedium(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedNumberButton(int number) {
    // 숫자별로 다른 색상 그라데이션
    List<Color> getNumberColors(int num) {
      final colorSets = [
        [Colors.red[400]!, Colors.red[600]!],          // 1
        [Colors.pink[400]!, Colors.pink[600]!],        // 2
        [Colors.purple[400]!, Colors.purple[600]!],    // 3
        [Colors.deepPurple[400]!, Colors.deepPurple[600]!], // 4
        [Colors.indigo[400]!, Colors.indigo[600]!],    // 5
        [Colors.blue[400]!, Colors.blue[600]!],        // 6
        [Colors.cyan[400]!, Colors.cyan[600]!],        // 7
        [Colors.teal[400]!, Colors.teal[600]!],        // 8
        [Colors.green[400]!, Colors.green[600]!],      // 9
        [Colors.orange[400]!, Colors.orange[600]!],    // 10
      ];
      return colorSets[num - 1];
    }

    final colors = getNumberColors(number);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveSize(context, 16)),
        boxShadow: [
          BoxShadow(
            color: colors[1].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveSize(context, 16)),
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _playNumberGuess(number),
          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveSize(context, 16)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors[0], colors[1], colors[1].withValues(alpha: 0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.7, 1.0],
              ),
              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveSize(context, 16)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: ResponsiveUtils.getResponsivePaddingCustom(context, all: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveSize(context, 8)),
                      ),
                      child: Text(
                        '$number',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 24),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, 4)),
                    Container(
                      width: ResponsiveUtils.getSafeResponsiveSize(context, 16),
                      height: ResponsiveUtils.getSafeResponsiveSize(context, 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.getIPhone16PlusSpacing(context, 6)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(ResponsiveUtils.getSafeResponsiveSize(context, 8)),
              ),
              child: Icon(
                Icons.casino_rounded, 
                color: Colors.white, 
                size: ResponsiveUtils.getResponsiveIconSize(context, 20),
              ),
            ),
            SizedBox(width: ResponsiveUtils.getIPhone16PlusSpacing(context, 12)),
            Flexible(
              child: Text(
                '🎯 숫자 맞추기',
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 18),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor, Colors.indigo[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.indigo[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getIPhone16PlusPadding(context),
            child: Column(
              children: [
                // 헤로 헤더 카드 (높이를 제한하여 오버플로우 방지)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(ResponsiveUtils.getIPhone16PlusSpacing(context, 24)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.blue[50]!.withValues(alpha: 0.3),
                          Colors.indigo[50]!.withValues(alpha: 0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 메인 아이콘
                        Container(
                          padding: EdgeInsets.all(ResponsiveUtils.getIPhone16PlusSpacing(context, 16)),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.casino_rounded,
                            color: Colors.white,
                            size: ResponsiveUtils.getResponsiveIconSize(context, 40),
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, 16)),
                        
                        // 타이틀
                        Text(
                          '🎲 숫자 맞추기 게임',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 20),
                            fontWeight: FontWeight.w800,
                            color: Colors.indigo[800],
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, 12)),
                        
                        // 설명
                        Container(
                          padding: EdgeInsets.all(ResponsiveUtils.getIPhone16PlusSpacing(context, 12)),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '1부터 10까지의 숫자 중\n하나를 선택해보세요!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 14),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, 8)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.getIPhone16PlusSpacing(context, 12), 
                                  vertical: ResponsiveUtils.getIPhone16PlusSpacing(context, 6)
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber[100],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '정답 시 20 포인트!',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getSafeResponsiveFontSize(context, 12),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, 24)),

                // 숫자 버튼 그리드 (높이 제한)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(ResponsiveUtils.getIPhone16PlusSpacing(context, 16)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey[50]!.withValues(alpha: 0.5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: ResponsiveUtils.getSafeResponsiveSize(context, 8),
                        mainAxisSpacing: ResponsiveUtils.getSafeResponsiveSize(context, 8),
                        childAspectRatio: 1,
                      ),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        final number = index + 1;
                        return _buildEnhancedNumberButton(number);
                      },
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveUtils.getIPhone16PlusSpacing(context, 20)),

                // 배너 광고
                if (_isAdLoaded && _bannerAd != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _exitFullscreen();
    _bannerAd?.dispose();
    super.dispose();
  }
}
