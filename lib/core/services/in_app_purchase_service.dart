import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../data/models/subscription_tier.dart';
import 'logger_service.dart';

/// 인앱 결제 서비스
/// App Store와 Google Play 인앱 구독 관리
class InAppPurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  /// 구독 상품 ID
  /// iOS: App Store Connect에서 설정한 Product ID
  /// Android: Google Play Console에서 설정한 Product ID
  static const String proMonthlyProductId = 'money_app_pro_monthly';
  static const String premiumMonthlyProductId = 'money_app_premium_monthly';

  /// 사용 가능한 모든 구독 상품 ID
  static const Set<String> _productIds = {
    proMonthlyProductId,
    premiumMonthlyProductId,
  };

  /// 구독 상품 목록
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  /// 구매 완료 콜백
  Function(PurchaseDetails)? onPurchaseCompleted;

  /// 구매 에러 콜백
  Function(String)? onPurchaseError;

  /// 초기화
  Future<void> initialize() async {
    try {
      // 인앱 결제 사용 가능 여부 확인
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        LoggerService.error('❌ 인앱 결제를 사용할 수 없습니다', null);
        return;
      }

      // iOS 전용 설정은 필요 시 추가 가능

      // 구매 업데이트 스트림 구독
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription.cancel(),
        onError: (error) {
          LoggerService.error('❌ 구매 스트림 에러', error);
          onPurchaseError?.call(error.toString());
        },
      );

      // 상품 정보 로드
      await loadProducts();

      // 미완료 구매 복원
      await restorePurchases();

      LoggerService.info('✅ InAppPurchaseService 초기화 완료');
    } catch (e) {
      LoggerService.error('❌ InAppPurchaseService 초기화 실패', e);
    }
  }

  /// 상품 정보 로드
  Future<void> loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        LoggerService.warning(
            '⚠️ 찾을 수 없는 상품 ID: ${response.notFoundIDs}');
      }

      if (response.error != null) {
        LoggerService.error('❌ 상품 로드 에러', response.error);
        return;
      }

      _products = response.productDetails;
      LoggerService.info('✅ ${_products.length}개 상품 로드 완료');

      for (var product in _products) {
        LoggerService.info('  - ${product.id}: ${product.price}');
      }
    } catch (e) {
      LoggerService.error('❌ 상품 로드 실패', e);
    }
  }

  /// 구독 구매 시작
  Future<void> buySubscription(String productId) async {
    try {
      final ProductDetails? productDetails = _products
          .cast<ProductDetails?>()
          .firstWhere(
            (product) => product?.id == productId,
            orElse: () => null,
          );

      if (productDetails == null) {
        onPurchaseError?.call('상품을 찾을 수 없습니다');
        return;
      }

      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);

      // 구독 상품 구매
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      LoggerService.info('🛒 구매 요청: ${productDetails.id}');
    } catch (e) {
      LoggerService.error('❌ 구매 요청 실패', e);
      onPurchaseError?.call(e.toString());
    }
  }

  /// 구매 업데이트 처리
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      LoggerService.info(
          '📦 구매 상태: ${purchaseDetails.status} (${purchaseDetails.productID})');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          // 구매 대기 중 (Google Play는 승인 필요)
          LoggerService.info('⏳ 구매 대기 중...');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // 구매 완료 또는 복원됨
          _handlePurchaseSuccess(purchaseDetails);
          break;

        case PurchaseStatus.error:
          // 구매 실패
          LoggerService.error(
              '❌ 구매 실패', purchaseDetails.error?.message ?? 'Unknown error');
          onPurchaseError?.call(purchaseDetails.error?.message ?? '구매 실패');
          break;

        case PurchaseStatus.canceled:
          // 구매 취소
          LoggerService.info('🚫 구매 취소됨');
          onPurchaseError?.call('구매가 취소되었습니다');
          break;
      }

      // 구매 완료 처리 (중요!)
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// 구매 성공 처리
  Future<void> _handlePurchaseSuccess(PurchaseDetails purchaseDetails) async {
    try {
      // 영수증 검증 (서버 측에서 검증 권장)
      if (Platform.isIOS) {
        final appleReceipt = purchaseDetails.verificationData.serverVerificationData;
        LoggerService.info('🍎 iOS 영수증: ${appleReceipt.substring(0, 50)}...');
      } else if (Platform.isAndroid) {
        final googleReceipt = purchaseDetails.verificationData.serverVerificationData;
        LoggerService.info('🤖 Android 영수증: ${googleReceipt.substring(0, 50)}...');
      }

      // 구매 완료 콜백 호출
      onPurchaseCompleted?.call(purchaseDetails);

      LoggerService.info('✅ 구매 성공: ${purchaseDetails.productID}');
    } catch (e) {
      LoggerService.error('❌ 구매 성공 처리 실패', e);
    }
  }

  /// 구매 복원 (이전 구매 내역 복원)
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      LoggerService.info('🔄 구매 복원 요청 완료');
    } catch (e) {
      LoggerService.error('❌ 구매 복원 실패', e);
      onPurchaseError?.call('구매 복원에 실패했습니다');
    }
  }

  /// 상품 ID로 ProductDetails 조회
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// 구독 티어에 해당하는 상품 ID 가져오기
  static String getProductIdForTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.pro:
        return proMonthlyProductId;
      case SubscriptionTier.premium:
        return premiumMonthlyProductId;
      case SubscriptionTier.free:
        return '';
    }
  }

  /// 상품 ID로 구독 티어 가져오기
  static SubscriptionTier getTierForProductId(String productId) {
    if (productId == proMonthlyProductId) {
      return SubscriptionTier.pro;
    } else if (productId == premiumMonthlyProductId) {
      return SubscriptionTier.premium;
    }
    return SubscriptionTier.free;
  }

  /// 리소스 정리
  void dispose() {
    _subscription.cancel();
  }
}
