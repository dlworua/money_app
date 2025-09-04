import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/services/logger_service.dart';
import '../../data/repositories/ad_repository.dart';
import 'user_service.dart';

class AdService {
  final AdRepository _adRepository;
  final UserService _userService;
  
  AdService(this._adRepository, this._userService);
  
  Future<BannerAd?> loadBannerAd() async {
    try {
      final bannerAd = await _adRepository.loadBannerAd();
      LoggerService.info('Banner ad loaded through service');
      return bannerAd;
    } catch (error) {
      LoggerService.error('Failed to load banner ad through service', error);
      rethrow;
    }
  }
  
  Future<void> loadRewardedAd({Function(int)? onEarnCoins}) async {
    try {
      await _adRepository.loadRewardedAd(onEarnCoins: onEarnCoins ?? (coins) async {
        final user = await _userService.getUser();
        if (user != null) {
          await _userService.addCoins(coins, isPremium: user.isPremium);
          LoggerService.info('Rewarded ad completed, earned $coins coins (premium: ${user.isPremium})');
        }
      });
      
      LoggerService.info('Rewarded ad loaded through service');
    } catch (error) {
      LoggerService.error('Failed to load rewarded ad through service', error);
      rethrow;
    }
  }
  
  Future<void> showRewardedAd({Function(int)? onEarnCoins}) async {
    try {
      _adRepository.showRewardedAd(onEarnCoins ?? (coins) async {
        final user = await _userService.getUser();
        if (user != null) {
          await _userService.addCoins(coins, isPremium: user.isPremium);
          LoggerService.info('Rewarded ad reward processed: $coins coins');
        }
      });
    } catch (error) {
      LoggerService.error('Failed to show rewarded ad', error);
      rethrow;
    }
  }
  
  Future<void> showInterstitialAd() async {
    try {
      final user = await _userService.getUser();
      if (user == null) throw AdLoadException('사용자 데이터를 찾을 수 없습니다');
      
      await _adRepository.loadInterstitialAd(
        onAdDismissed: () {
          LoggerService.info('Interstitial ad dismissed');
        },
        onEarnCoins: (coins) async {
          await _userService.addCoins(coins, isPremium: user.isPremium);
          LoggerService.info('Interstitial ad completed, earned $coins coins');
        },
      );
      
      _adRepository.showInterstitialAd();
    } catch (error) {
      LoggerService.error('Failed to show interstitial ad', error);
      rethrow;
    }
  }
  
  void dispose() {
    _adRepository.dispose();
  }
}