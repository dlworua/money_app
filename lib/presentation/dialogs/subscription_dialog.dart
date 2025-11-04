import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/subscription_tier.dart';
import '../viewmodels/providers.dart';

/// 요금제 구독 다이얼로그 (Free/Pro/Premium 3단계)
class SubscriptionDialog extends ConsumerStatefulWidget {
  const SubscriptionDialog({super.key});

  @override
  ConsumerState<SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends ConsumerState<SubscriptionDialog> {
  // 선택된 플랜 (0: Free, 1: Pro, 2: Premium)
  int _selectedPlan = 1; // 기본값 Pro

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(homeViewModelProvider).user;
    // TODO: UserModel에 subscriptionTier 필드 추가 필요
    // 현재는 isPremium 기반으로 임시 매핑
    final currentTier = user?.isPremium == true
        ? SubscriptionTier.premium
        : SubscriptionTier.free;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGradientColors(currentTier),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTierIcon(currentTier),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${currentTier.displayName} 플랜',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentTier.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // 본문
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 플랜 선택
                    const Text(
                      '요금제 선택',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Free 플랜
                    _buildPlanCard(
                      tier: SubscriptionTier.free,
                      index: 0,
                      isCurrentPlan: currentTier == SubscriptionTier.free,
                    ),

                    const SizedBox(height: 12),

                    // Pro 플랜 (인기)
                    _buildPlanCard(
                      tier: SubscriptionTier.pro,
                      index: 1,
                      badge: '인기',
                      isCurrentPlan: currentTier == SubscriptionTier.pro,
                    ),

                    const SizedBox(height: 12),

                    // Premium 플랜 (추천)
                    _buildPlanCard(
                      tier: SubscriptionTier.premium,
                      index: 2,
                      badge: '추천',
                      isCurrentPlan: currentTier == SubscriptionTier.premium,
                    ),

                    const SizedBox(height: 24),

                    // 선택된 플랜 상세 정보
                    if (_selectedPlan >= 0) ...[
                      const Text(
                        '포함된 혜택',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._getSelectedTier().features.map(
                            (feature) => _buildFeatureItem(feature),
                          ),
                    ],
                  ],
                ),
              ),
            ),

            // 하단 버튼
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  if (_getSelectedTier() != currentTier) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleSubscribe(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getPrimaryColor(_getSelectedTier()),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _getSelectedTier().price == 0
                              ? 'Free 플랜으로 변경'
                              : '월 ₩${_getSelectedTier().price}로 업그레이드',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (_getSelectedTier().price > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        '7일 무료 체험 후 자동 결제',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '현재 사용 중인 플랜입니다',
                              style: TextStyle(
                                color: Colors.green[900],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 선택된 요금제 가져오기
  SubscriptionTier _getSelectedTier() {
    return SubscriptionTier.values[_selectedPlan];
  }

  /// 요금제별 그라데이션 색상
  List<Color> _getGradientColors(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return [Colors.grey[600]!, Colors.grey[800]!];
      case SubscriptionTier.pro:
        return [Colors.blue[600]!, Colors.blue[800]!];
      case SubscriptionTier.premium:
        return [Colors.amber[600]!, Colors.amber[800]!];
    }
  }

  /// 요금제별 아이콘
  IconData _getTierIcon(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return Icons.account_circle;
      case SubscriptionTier.pro:
        return Icons.star;
      case SubscriptionTier.premium:
        return Icons.workspace_premium;
    }
  }

  /// 요금제별 메인 색상
  Color _getPrimaryColor(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return Colors.grey[700]!;
      case SubscriptionTier.pro:
        return Colors.blue[600]!;
      case SubscriptionTier.premium:
        return Colors.amber[600]!;
    }
  }

  /// 플랜 카드
  Widget _buildPlanCard({
    required SubscriptionTier tier,
    required int index,
    required bool isCurrentPlan,
    String? badge,
  }) {
    final isSelected = _selectedPlan == index;
    final baseColor = _getPrimaryColor(tier);

    return InkWell(
      onTap: () => setState(() => _selectedPlan = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? baseColor.withValues(alpha: 0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? baseColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTierIcon(tier),
                  color: baseColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tier.displayName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? baseColor : Colors.black87,
                    ),
                  ),
                ),
                if (isCurrentPlan)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '사용중',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (badge != null && !isCurrentPlan)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? baseColor : Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tier.price == 0 ? '무료' : '₩${tier.price}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? baseColor : Colors.black87,
                  ),
                ),
                if (tier.price > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2, left: 4),
                    child: Text(
                      '/월',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tier.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 기능 항목
  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: _getPrimaryColor(_getSelectedTier()),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// 구독하기
  void _handleSubscribe(BuildContext context) {
    final selectedTier = _getSelectedTier();

    // TODO: 실제 결제 로직 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${selectedTier.displayName} 플랜 구독'),
        content: Text(
          selectedTier.price == 0
              ? 'Free 플랜으로 변경하시겠습니까?\n\n유료 플랜의 혜택이 해제됩니다.'
              : '${selectedTier.displayName} 플랜(₩${selectedTier.price}/월)을 구독하시겠습니까?\n\n7일 무료 체험 후 자동 결제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 실제 구독 처리 로직
              // ref.read(homeViewModelProvider.notifier).upgradeTier(selectedTier);

              Navigator.pop(context); // 확인 다이얼로그 닫기
              Navigator.pop(context); // 구독 다이얼로그 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    selectedTier.price == 0
                        ? 'Free 플랜으로 변경되었습니다'
                        : '🎉 ${selectedTier.displayName} 플랜 구독이 완료되었습니다!',
                  ),
                  backgroundColor:
                      selectedTier.price == 0 ? Colors.orange : Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPrimaryColor(selectedTier),
            ),
            child: Text(selectedTier.price == 0 ? '변경하기' : '구독하기'),
          ),
        ],
      ),
    );
  }
}
