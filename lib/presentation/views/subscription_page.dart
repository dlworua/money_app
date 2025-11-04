import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/subscription_tier.dart';
import '../viewmodels/providers.dart';
import '../../core/theme/app_theme.dart';

/// 요금제 선택 페이지 (Claude 앱 스타일)
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // 앱바
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              '요금제',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 컨텐츠
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 텍스트
                  const Text(
                    '나에게 맞는\n플랜을 선택하세요',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '언제든지 변경하거나 취소할 수 있습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 요금제 카드들
                  _buildPlanCard(
                    tier: SubscriptionTier.free,
                    index: 0,
                    isCurrentPlan: currentTier == SubscriptionTier.free,
                  ),
                  const SizedBox(height: 16),

                  _buildPlanCard(
                    tier: SubscriptionTier.pro,
                    index: 1,
                    isCurrentPlan: currentTier == SubscriptionTier.pro,
                    badge: '인기',
                  ),
                  const SizedBox(height: 16),

                  _buildPlanCard(
                    tier: SubscriptionTier.premium,
                    index: 2,
                    isCurrentPlan: currentTier == SubscriptionTier.premium,
                    badge: '추천',
                  ),
                  const SizedBox(height: 32),

                  // 기능 비교표
                  _buildComparisonTable(),

                  const SizedBox(height: 100), // 하단 버튼 공간
                ],
              ),
            ),
          ),
        ],
      ),

      // 하단 고정 버튼
      bottomNavigationBar: _buildBottomBar(context, currentTier),
    );
  }

  /// 요금제 카드
  Widget _buildPlanCard({
    required SubscriptionTier tier,
    required int index,
    required bool isCurrentPlan,
    String? badge,
  }) {
    final isSelected = _selectedPlanIndex == index;
    final baseColor = _getPrimaryColor(tier);

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected
              ? baseColor.withValues(alpha: 0.08)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? baseColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTierIcon(tier),
                    color: baseColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tier.displayName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? baseColor : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (badge != null && !isCurrentPlan)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(6),
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
                        ],
                      ),
                      Text(
                        tier.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentPlan)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '사용중',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  )
                else
                  Radio<int>(
                    value: index,
                    groupValue: _selectedPlanIndex,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPlanIndex = value);
                      }
                    },
                    activeColor: baseColor,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 가격
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tier.price == 0 ? '무료' : '₩${_formatPrice(tier.price)}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? baseColor : Colors.black87,
                    height: 1.0,
                  ),
                ),
                if (tier.price > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 4),
                    child: Text(
                      '/월',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 주요 특징 (최대 3개)
            ...tier.features.take(3).map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: baseColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
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
    );
  }

  /// 기능 비교표
  Widget _buildComparisonTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '기능 비교',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 기능별 비교
          _buildComparisonRow(
            '거래 기록',
            ['월 100회', '무제한', '무제한'],
          ),
          _buildComparisonRow(
            '광고',
            ['모든 탭', '게임만', '완전 제거'],
          ),
          _buildComparisonRow(
            '리워드 배율',
            ['1배 (1/20)', '2배 (2/40)', '3배 (4/60)'],
          ),
          _buildComparisonRow(
            'AI 코칭',
            ['사용불가', '기본 모델', '프리미엄'],
          ),
          _buildComparisonRow(
            '예산/목표',
            ['각 10회', '각 50회', '무제한'],
          ),
          _buildComparisonRow(
            '게임 티켓',
            ['30분', '30분', '5분'],
          ),
        ],
      ),
    );
  }

  /// 비교 행
  Widget _buildComparisonRow(String feature, List<String> values) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            feature,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildComparisonCell(
                  values[0],
                  SubscriptionTier.free,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildComparisonCell(
                  values[1],
                  SubscriptionTier.pro,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildComparisonCell(
                  values[2],
                  SubscriptionTier.premium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }

  /// 비교 셀
  Widget _buildComparisonCell(String text, SubscriptionTier tier) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
        ),
        textAlign: TextAlign.center,
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
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _handleSubscribe(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPrimaryColor(selectedTier),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    selectedTier.price == 0
                        ? 'Free 플랜으로 변경'
                        : '월 ₩${_formatPrice(selectedTier.price)}로 시작하기',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (selectedTier.price > 0) ...[
                const SizedBox(height: 12),
                Text(
                  '7일 무료 체험 후 자동 결제',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600]),
                    const SizedBox(width: 12),
                    Text(
                      '현재 사용 중인 플랜입니다',
                      style: TextStyle(
                        fontSize: 15,
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
