import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/providers.dart';

/// 프리미엄 구독 다이얼로그
class PremiumDialog extends ConsumerStatefulWidget {
  const PremiumDialog({super.key});

  @override
  ConsumerState<PremiumDialog> createState() => _PremiumDialogState();
}

class _PremiumDialogState extends ConsumerState<PremiumDialog> {
  // 선택된 플랜 (0: 월간, 1: 연간)
  int _selectedPlan = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(homeViewModelProvider).user;
    final isPremium = user?.isPremium ?? false;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[600]!, Colors.amber[800]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
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
                              isPremium ? '프리미엄 관리' : '프리미엄 플랜',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isPremium ? '구독 중인 프리미엄' : '더 많은 혜택을 누리세요',
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
                ],
              ),
            ),

            // 본문
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isPremium) ...[
                      // 프리미엄 혜택
                      const Text(
                        '프리미엄 혜택',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBenefit(
                        icon: Icons.block,
                        title: '광고 완전 제거',
                        description: '모든 배너/전면 광고 제거',
                        color: Colors.red,
                      ),
                      _buildBenefit(
                        icon: Icons.workspace_premium,
                        title: '3배 포인트',
                        description: '모든 게임에서 3배 포인트 획득',
                        color: Colors.amber,
                      ),
                      _buildBenefit(
                        icon: Icons.all_inclusive,
                        title: '무제한 거래 기록',
                        description: '제한 없이 거래 내역 저장',
                        color: Colors.blue,
                      ),
                      _buildBenefit(
                        icon: Icons.analytics,
                        title: '고급 통계',
                        description: '상세한 지출 분석 및 인사이트',
                        color: Colors.green,
                      ),
                      _buildBenefit(
                        icon: Icons.support_agent,
                        title: '우선 고객 지원',
                        description: '24시간 우선 지원 서비스',
                        color: Colors.purple,
                      ),

                      const SizedBox(height: 24),

                      // 플랜 선택
                      const Text(
                        '플랜 선택',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 월간 플랜
                      _buildPlanCard(
                        index: 0,
                        title: '월간 플랜',
                        price: '₩4,900',
                        period: '/월',
                        description: '언제든지 취소 가능',
                        badge: null,
                      ),

                      const SizedBox(height: 12),

                      // 연간 플랜 (인기)
                      _buildPlanCard(
                        index: 1,
                        title: '연간 플랜',
                        price: '₩49,000',
                        period: '/년',
                        description: '월간 대비 17% 할인',
                        badge: '인기',
                      ),
                    ] else ...[
                      // 프리미엄 사용자 정보
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber[100]!,
                              Colors.amber[50]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber[300]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              size: 64,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '프리미엄 회원',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[900],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '모든 프리미엄 혜택을 누리고 계십니다',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '다음 결제일: 2025년 11월 13일',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 혜택 요약
                      const Text(
                        '현재 이용 중인 혜택',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActiveBenefit('광고 완전 제거'),
                      _buildActiveBenefit('3배 포인트 적립'),
                      _buildActiveBenefit('무제한 거래 기록'),
                      _buildActiveBenefit('고급 통계 분석'),
                      _buildActiveBenefit('우선 고객 지원'),
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
                  if (!isPremium) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleSubscribe(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _selectedPlan == 0
                              ? '월 ₩4,900로 시작하기'
                              : '연 ₩49,000로 시작하기',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '7일 무료 체험 후 자동 결제',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _handleCancelSubscription(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.red[400]!),
                          foregroundColor: Colors.red[600],
                        ),
                        child: const Text(
                          '구독 해지',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  /// 혜택 아이템
  Widget _buildBenefit({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 플랜 카드
  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String period,
    required String description,
    String? badge,
  }) {
    final isSelected = _selectedPlan == index;

    return InkWell(
      onTap: () => setState(() => _selectedPlan = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.amber[600]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.amber[900] : Colors.black,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[600],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 12,
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
                  color: isSelected ? Colors.amber[600] : Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.amber[900] : Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 활성 혜택 아이템
  Widget _buildActiveBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// 구독하기
  void _handleSubscribe(BuildContext context) {
    // TODO: 실제 결제 로직 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프리미엄 구독'),
        content: Text(
          _selectedPlan == 0
              ? '월간 플랜(₩4,900/월)을 구독하시겠습니까?\n\n7일 무료 체험 후 자동 결제됩니다.'
              : '연간 플랜(₩49,000/년)을 구독하시겠습니까?\n\n7일 무료 체험 후 자동 결제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // 목 데이터로 프리미엄 활성화
              ref.read(homeViewModelProvider.notifier).togglePremium();
              Navigator.pop(context); // 확인 다이얼로그 닫기
              Navigator.pop(context); // 프리미엄 다이얼로그 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 프리미엄 구독이 완료되었습니다!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
            ),
            child: const Text('구독하기'),
          ),
        ],
      ),
    );
  }

  /// 구독 해지
  void _handleCancelSubscription(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구독 해지'),
        content: const Text(
          '정말 프리미엄 구독을 해지하시겠습니까?\n\n다음 결제일까지는 프리미엄 혜택을 계속 이용할 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // 목 데이터로 프리미엄 비활성화
              ref.read(homeViewModelProvider.notifier).togglePremium();
              Navigator.pop(context); // 확인 다이얼로그 닫기
              Navigator.pop(context); // 프리미엄 다이얼로그 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('프리미엄 구독이 해지되었습니다'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('해지하기'),
          ),
        ],
      ),
    );
  }
}
