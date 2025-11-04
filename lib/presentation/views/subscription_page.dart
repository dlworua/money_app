import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/subscription_tier.dart';
import '../viewmodels/providers.dart';

/// 요금제 선택 페이지 (iOS 스타일 + 다크모드)
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '요금제',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '나에게 맞는 플랜을 선택하세요',
                  style: TextStyle(
                    fontSize: 15,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // 요금제 탭
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildPlanTab(
                    tier: SubscriptionTier.free,
                    index: 0,
                    isCurrentPlan: currentTier == SubscriptionTier.free,
                    isDark: isDark,
                    cardColor: cardColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPlanTab(
                    tier: SubscriptionTier.pro,
                    index: 1,
                    isCurrentPlan: currentTier == SubscriptionTier.pro,
                    badge: '인기',
                    isDark: isDark,
                    cardColor: cardColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPlanTab(
                    tier: SubscriptionTier.premium,
                    index: 2,
                    isCurrentPlan: currentTier == SubscriptionTier.premium,
                    badge: '추천',
                    isDark: isDark,
                    cardColor: cardColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 기능 비교표
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildComparisonTable(isDark, cardColor, textColor, secondaryTextColor),
            ),
          ),

          // 하단 버튼
          _buildBottomBar(context, currentTier, isDark, backgroundColor, cardColor, textColor),
        ],
      ),
    );
  }

  /// 요금제 탭 (다크모드 대응)
  Widget _buildPlanTab({
    required SubscriptionTier tier,
    required int index,
    required bool isCurrentPlan,
    required bool isDark,
    required Color cardColor,
    String? badge,
  }) {
    final isSelected = _selectedPlanIndex == index;
    final baseColor = _getPrimaryColor(tier);

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: baseColor.withOpacity(isDark ? 0.2 : 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
        ),
        child: Column(
          children: [
            if (badge != null && !isCurrentPlan)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : baseColor.withOpacity(isDark ? 0.3 : 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? baseColor : (isDark ? Colors.white : baseColor),
                  ),
                ),
              )
            else if (isCurrentPlan)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : (isDark ? Colors.green[900]!.withOpacity(0.4) : Colors.green[50]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '사용중',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.green[700]
                        : (isDark ? Colors.green[400] : Colors.green[700]),
                  ),
                ),
              )
            else
              const SizedBox(height: 19),
            const SizedBox(height: 6),
            Text(
              tier.displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              tier.price == 0 ? '무료' : '₩${_formatPrice(tier.price)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white.withOpacity(0.85)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 기능 비교표 (다크모드 대응)
  Widget _buildComparisonTable(bool isDark, Color cardColor, Color textColor, Color secondaryTextColor) {
    final selectedTier = SubscriptionTier.values[_selectedPlanIndex];

    return Column(
      children: [
        // 거래 기록
        _buildFeatureRow(
          icon: Icons.receipt_long_outlined,
          title: '거래 기록',
          values: ['월 100회', '무제한', '무제한'],
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
        ),

        // 광고
        _buildFeatureRow(
          icon: Icons.block_outlined,
          title: '광고',
          values: ['모든 탭', '게임만', '완전 제거'],
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
        ),

        // 리워드
        _buildFeatureRow(
          icon: Icons.card_giftcard_outlined,
          title: '리워드 배율',
          values: ['1배', '2배', '3배'],
          details: ['1/20', '2/40', '4/60'],
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
        ),

        // AI 코칭
        _buildFeatureRow(
          icon: Icons.psychology_outlined,
          title: 'AI 코칭',
          values: ['사용불가', '기본', '프리미엄'],
          details: ['-', '말투변경 ✕', '맞춤조언 ✓'],
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
        ),

        // 예산/목표
        _buildFeatureRow(
          icon: Icons.savings_outlined,
          title: '예산/목표',
          values: ['각 10회', '각 50회', '무제한'],
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
        ),

        // 게임 티켓
        _buildFeatureRow(
          icon: Icons.confirmation_number_outlined,
          title: '티켓 대기',
          values: ['30분', '30분', '5분'],
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
        ),

        // 소비 분석
        _buildFeatureRow(
          icon: Icons.analytics_outlined,
          title: '소비분석',
          values: ['✓', '✓', '✓'],
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
        ),

        // 고급 통계
        _buildFeatureRow(
          icon: Icons.bar_chart_outlined,
          title: '고급 통계',
          values: ['✓', '✓', '✓'],
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
        ),

        const SizedBox(height: 16),

        // 선택된 플랜 요약
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getPrimaryColor(selectedTier).withOpacity(isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTierIcon(selectedTier),
                      color: _getPrimaryColor(selectedTier),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${selectedTier.displayName} 플랜 혜택',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...selectedTier.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: _getPrimaryColor(selectedTier).withOpacity(isDark ? 0.2 : 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 14,
                          color: _getPrimaryColor(selectedTier),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                            height: 1.5,
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

  /// 기능 행 (다크모드 대응)
  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required List<String> values,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    List<String>? details,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: -0.2,
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
                  isDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 기능 값 (다크모드 대응)
  Widget _buildFeatureValue(
    String value,
    String? detail,
    SubscriptionTier tier,
    bool isSelected,
    bool isDark,
  ) {
    final color = isSelected
        ? _getPrimaryColor(tier)
        : (isDark ? Colors.grey[400]! : Colors.grey[700]!);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: color,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          if (detail != null) ...[
            const SizedBox(height: 3),
            Text(
              detail,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// 하단 버튼 바 (다크모드 대응)
  Widget _buildBottomBar(
    BuildContext context,
    SubscriptionTier currentTier,
    bool isDark,
    Color backgroundColor,
    Color cardColor,
    Color textColor,
  ) {
    final selectedTier = SubscriptionTier.values[_selectedPlanIndex];
    final isCurrentPlan = selectedTier == currentTier;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCurrentPlan) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _handleSubscribe(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPrimaryColor(selectedTier),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Center(
                    child: Text(
                      selectedTier.price == 0
                          ? 'Free 플랜으로 변경'
                          : '월 ₩${_formatPrice(selectedTier.price)}로 시작하기',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              if (selectedTier.price > 0) ...[
                const SizedBox(height: 10),
                Text(
                  '7일 무료 체험 · 언제든 해지 가능',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: isDark ? Colors.green[700]! : Colors.green[300]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: isDark ? Colors.green[400] : Colors.green[600],
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '현재 사용 중',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.green[400] : Colors.green[700],
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
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
        return Icons.person_outline_rounded;
      case SubscriptionTier.pro:
        return Icons.star_outline_rounded;
      case SubscriptionTier.premium:
        return Icons.workspace_premium_outlined;
    }
  }

  /// 요금제별 메인 색상
  Color _getPrimaryColor(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return Colors.grey[700]!;
      case SubscriptionTier.pro:
        return const Color(0xFF007AFF); // iOS 파란색
      case SubscriptionTier.premium:
        return const Color(0xFFFF9500); // iOS 오렌지색
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          '${selectedTier.displayName} 플랜 구독',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          selectedTier.price == 0
              ? 'Free 플랜으로 변경하시겠습니까?\n\n유료 플랜의 혜택이 해제됩니다.'
              : '${selectedTier.displayName} 플랜(₩${_formatPrice(selectedTier.price)}/월)을 구독하시겠습니까?\n\n7일 무료 체험 후 자동 결제됩니다.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(
                color: _getPrimaryColor(selectedTier),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
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
            child: Text(
              selectedTier.price == 0 ? '변경하기' : '구독하기',
              style: TextStyle(
                color: _getPrimaryColor(selectedTier),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
