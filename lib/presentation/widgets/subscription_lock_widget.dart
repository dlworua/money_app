import 'package:flutter/material.dart';
import '../../data/models/subscription_tier.dart';

/// 요금제 잠금 위젯
///
/// Free 요금제 사용자가 유료 기능에 접근할 때 표시되는 잠금 화면
class SubscriptionLockWidget extends StatelessWidget {
  final String featureName;
  final SubscriptionTier requiredTier;
  final VoidCallback onUpgradePressed;

  const SubscriptionLockWidget({
    super.key,
    required this.featureName,
    required this.requiredTier,
    required this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 잠금 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // 제목
              Text(
                '$featureName 잠금',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // 설명
              Text(
                '${requiredTier.displayName} 요금제부터 사용 가능합니다',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // 가격 정보
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade400.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green.shade400,
                    width: 1,
                  ),
                ),
                child: Text(
                  '월 ${_formatPrice(requiredTier.price)}원',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade300,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 업그레이드 버튼
              ElevatedButton(
                onPressed: onUpgradePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${requiredTier.displayName} 업그레이드',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 닫기 버튼
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '나중에 하기',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

/// 뿌옇게 잠긴 콘텐츠 위젯
///
/// Free 요금제 사용자에게 콘텐츠를 흐릿하게 보여주고 잠금 아이콘 표시
class BlurredLockContent extends StatelessWidget {
  final Widget child;
  final String featureName;
  final SubscriptionTier requiredTier;
  final VoidCallback onUpgradePressed;

  const BlurredLockContent({
    super.key,
    required this.child,
    required this.featureName,
    required this.requiredTier,
    required this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 뿌옇게 처리된 원본 콘텐츠
        Opacity(
          opacity: 0.3,
          child: IgnorePointer(
            child: child,
          ),
        ),

        // 잠금 오버레이
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _showUpgradeDialog(context);
            },
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 잠금 아이콘
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 안내 텍스트
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${requiredTier.displayName} 요금제 필요',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: SubscriptionLockWidget(
          featureName: featureName,
          requiredTier: requiredTier,
          onUpgradePressed: () {
            Navigator.pop(context);
            onUpgradePressed();
          },
        ),
      ),
    );
  }
}
