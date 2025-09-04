import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/logger_service.dart';

class AdRepository {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // 배너 광고 로드
  Future<BannerAd?> loadBannerAd() async {
    try {
      LoggerService.info('Loading banner ad');
      
      // 기존 광고가 있으면 먼저 dispose
      _bannerAd?.dispose();
      _bannerAd = null;
      
      _bannerAd = BannerAd(
        adUnitId: AppConstants.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            LoggerService.info('Banner ad loaded successfully');
          },
          onAdFailedToLoad: (ad, error) {
            LoggerService.error('Banner ad failed to load', error);
            ad.dispose();
            _bannerAd = null;
          },
          onAdClosed: (ad) {
            LoggerService.info('Banner ad closed');
          },
          onAdOpened: (ad) {
            LoggerService.info('Banner ad opened');
          },
        ),
      );

      await _bannerAd!.load();
      return _bannerAd;
    } catch (error) {
      LoggerService.error('Banner ad load exception', error);
      _bannerAd?.dispose();
      _bannerAd = null;
      // 광고 로드 실패는 앱 동작에 치명적이지 않으므로 예외를 던지지 않고 null 반환
      return null;
    }
  }

  // 전면 광고 로드
  Future<void> loadInterstitialAd({
    required Function() onAdDismissed,
    required Function(int) onEarnCoins,
  }) async {
    await InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.setImmersiveMode(true);

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onEarnCoins(AppConstants.interstitialAdCoins);
              onAdDismissed();
            },
          );
        },
        onAdFailedToLoad: (error) {
          LoggerService.error('InterstitialAd failed to load', error);
        },
      ),
    );
  }

  // 보상형 광고 로드
  Future<void> loadRewardedAd({required Function(int) onEarnCoins}) async {
    await RewardedAd.load(
      adUnitId: AppConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadRewardedAd(onEarnCoins: onEarnCoins); // 다음 광고 미리 로드
            },
          );
        },
        onAdFailedToLoad: (error) {
          LoggerService.error('RewardedAd failed to load', error);
        },
      ),
    );
  }

  // 전면 광고 표시
  void showInterstitialAd() {
    _interstitialAd?.show();
  }

  // 보상형 광고 표시
  void showRewardedAd(Function(int) onEarnCoins) {
    _rewardedAd?.show(
      onUserEarnedReward: (ad, reward) {
        onEarnCoins(AppConstants.rewardedAdCoins);
      },
    );
  }

  // 광고 정리
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
