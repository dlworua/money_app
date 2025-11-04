import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/subscription_tier.dart';
import '../viewmodels/providers.dart';

/// 요금제 선택 페이지 (넷플릭스 스타일)
class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  int _selectedPlanIndex = 1; // 기본값 Pro

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(homeViewModelProvider).user;
    final currentTier = user?.isPremium == true
        ? SubscriptionTier.premium
        : SubscriptionTier.free;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '요금제를 선택하세요',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '언제든지 변경하거나 해지할 수 있습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 요금제 탭
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildPlanTab(
                    tier: SubscriptionTier.free,
                    index: 0,
                    isCurrentPlan: currentTier == SubscriptionTier.free,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPlanTab(
                    tier: SubscriptionTier.pro,
                    index: 1,
                    isCurrentPlan: currentTier == SubscriptionTier.pro,
                    badge: '인기',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPlanTab(
                    tier: SubscriptionTier.premium,
                    index: 2,
                    isCurrentPlan: currentTier == SubscriptionTier.premium,
                    badge: '추천',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 기능 비교표
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildComparisonTable(),
            ),
          ),

          // 하단 버튼
          _buildBottomBar(context, currentTier),
        ],
      ),
    );
  }

  /// 요금제 탭
  Widget _buildPlanTab({
    required SubscriptionTier tier,
    required int index,
    required bool isCurrentPlan,
    String? badge,
  }) {
    final isSelected = _selectedPlanIndex == index;
    final baseColor = _getPrimaryColor(tier);

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [baseColor, baseColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: baseColor, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          children: [
            if (badge != null && !isCurrentPlan)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? baseColor : Colors.white,
                  ),
                ),
              )
            else if (isCurrentPlan)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.green[600],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '사용중',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.green[600] : Colors.white,
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
            const SizedBox(height: 8),
            Text(
              tier.displayName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tier.price == 0 ? '무료' : '₩${_formatPrice(tier.price)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white.withValues(alpha: 0.9) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 기능 비교표 (넷플릭스 스타일)
  Widget _buildComparisonTable() {
    final selectedTier = SubscriptionTier.values[_selectedPlanIndex];

    return Column(
      children: [
        // 거래 기록
        _buildFeatureRow(
          icon: Icons.receipt_long,
          title: '거래 기록',
          values: ['월 100회', '무제한', '무제한'],
        ),

        // 광고
        _buildFeatureRow(
          icon: Icons.block,
          title: '광고',
          values: ['모든 탭', '게임만 표시', '완전 제거'],
        ),

        // 리워드
        _buildFeatureRow(
          icon: Icons.card_giftcard,
          title: '리워드 배율',
          values: ['1배', '2배', '3배'],
          details: ['1/20', '2/40', '4/60'],
        ),

        // AI 코칭
        _buildFeatureRow(
          icon: Icons.psychology,
          title: 'AI 코칭',
          values: ['사용불가', '기본 모델', '프리미엄'],
          details: ['-', '말투변경 불가', '맞춤조언'],
        ),

        // 예산/목표
        _buildFeatureRow(
          icon: Icons.savings,
          title: '예산 및 절약목표',
          values: ['각 10회', '각 50회', '무제한'],
        ),

        // 게임 티켓
        _buildFeatureRow(
          icon: Icons.confirmation_number,
          title: '게임 티켓 대기',
          values: ['30분', '30분', '5분'],
        ),

        // 소비 분석
        _buildFeatureRow(
          icon: Icons.analytics,
          title: '이번달 소비분석',
          values: ['가능', '가능', '가능'],
        ),

        // 고급 통계
        _buildFeatureRow(
          icon: Icons.bar_chart,
          title: '고급 통계',
          values: ['가능', '가능', '가능'],
        ),

        const SizedBox(height: 20),

        // 선택된 플랜 요약
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _getPrimaryColor(selectedTier).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getPrimaryColor(selectedTier).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getTierIcon(selectedTier),
                    color: _getPrimaryColor(selectedTier),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${selectedTier.displayName} 플랜',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getPrimaryColor(selectedTier),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...selectedTier.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check,
                        size: 16,
                        color: _getPrimaryColor(selectedTier),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 기능 행
  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required List<String> values,
    List<String>? details,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: _buildFeatureValue(
                  values[index],
                  details?[index],
                  SubscriptionTier.values[index],
                  _selectedPlanIndex == index,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 기능 값
  Widget _buildFeatureValue(
    String value,
    String? detail,
    SubscriptionTier tier,
    bool isSelected,
  ) {
    final color = isSelected ? _getPrimaryColor(tier) : Colors.grey[700]!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(
              detail,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// 하단 버튼 바
  Widget _buildBottomBar(BuildContext context, SubscriptionTier currentTier) {
    final selectedTier = SubscriptionTier.values[_selectedPlanIndex];
    final isCurrentPlan = selectedTier == currentTier;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCurrentPlan) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _handleSubscribe(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPrimaryColor(selectedTier),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    selectedTier.price == 0
                        ? 'Free 플랜으로 변경'
                        : '월 ₩${_formatPrice(selectedTier.price)}로 시작하기',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (selectedTier.price > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '7일 무료 체험 • 언제든지 해지 가능',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '현재 사용 중인 플랜입니다',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 요금제별 아이콘
  IconData _getTierIcon(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return Icons.person_outline;
      case SubscriptionTier.pro:
        return Icons.star_outline;
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

  /// 가격 포맷팅
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// 구독하기
  void _handleSubscribe(BuildContext context) {
    final selectedTier = SubscriptionTier.values[_selectedPlanIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${selectedTier.displayName} 플랜 구독'),
        content: Text(
          selectedTier.price == 0
              ? 'Free 플랜으로 변경하시겠습니까?\n\n유료 플랜의 혜택이 해제됩니다.'
              : '${selectedTier.displayName} 플랜(₩${_formatPrice(selectedTier.price)}/월)을 구독하시겠습니까?\n\n7일 무료 체험 후 자동 결제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 실제 구독 처리 로직
              Navigator.pop(context); // 확인 다이얼로그 닫기
              Navigator.pop(context); // 구독 페이지 닫기
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
