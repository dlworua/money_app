import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/enhanced_ai_coach.dart';
import '../../core/utils/number_formatter.dart';
import '../viewmodels/providers.dart';

/// AI 맞춤 조언 독립 페이지
class AiCoachingPage extends ConsumerWidget {
  const AiCoachingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI 절약 코치'),
        backgroundColor: Colors.green.shade400,
        foregroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: FutureBuilder<ComprehensiveInsight>(
        future: _generateInsight(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingView();
          }

          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          }

          final insight = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spaceM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(insight),
                const SizedBox(height: AppTheme.spaceM),
                _buildMainAnalysisCard(context, insight),
                const SizedBox(height: AppTheme.spaceM),
                _buildStrategiesCard(insight),
                const SizedBox(height: AppTheme.spaceM),
                _buildActionableAdviceCard(context, insight),
                if (insight.opportunities.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spaceM),
                  _buildOpportunitiesCard(insight),
                ],
                if (insight.predictions['available'] == true) ...[
                  const SizedBox(height: AppTheme.spaceM),
                  _buildPredictionsCard(insight),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🔄 실제 가계부 데이터를 로드하여 AI 인사이트 생성
  Future<ComprehensiveInsight> _generateInsight(WidgetRef ref) async {
    final state = ref.read(homeViewModelProvider);
    final coach = EnhancedAiCoach();

    final user = state.user;
    if (user == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다');
    }

    final transactionRepository = ref.read(transactionRepositoryProvider);
    final transactions = await transactionRepository.getTransactions();
    final budgets = await transactionRepository.getBudgets();

    return await coach.generateComprehensiveInsight(user, transactions, budgets);
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppTheme.spaceM),
          Text(
            '🧠 AI가 당신의 가계부를 분석하고 있어요...',
            style: AppTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.spaceS),
          Text(
            '모든 데이터를 꼼꼼히 살펴보는 중이에요 ⚡',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: AppTheme.spaceM),
          const Text(
            '분석 중 오류가 발생했어요',
            style: AppTheme.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            error,
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ComprehensiveInsight insight) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceS),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 분석 완료',
                  style: AppTheme.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXS),
                Text(
                  '신뢰도: ${insight.confidenceScore.toStringAsFixed(0)}%',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                if (insight.spendingAnalysis['isEmpty'] != true) ...[
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(
                    '${insight.behaviorPatterns.length}가지 패턴 발견',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAnalysisCard(BuildContext context, ComprehensiveInsight insight) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Colors.green.shade400,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spaceS),
              Text(
                '종합 분석 결과',
                style: AppTheme.headingSmall.copyWith(
                  color: Colors.green.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spaceM),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.shade400.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              _cleanMarkdown(insight.personalizedMessage),
              style: AppTheme.bodyMedium.copyWith(
                height: 1.6,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategiesCard(ComprehensiveInsight insight) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.amber.shade400,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spaceS),
              Text(
                '절약 전략',
                style: AppTheme.headingSmall.copyWith(
                  color: Colors.amber.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceM),
          ...insight.strategies.map((strategy) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spaceS),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceS),
                Expanded(
                  child: Text(
                    strategy.title,
                    style: AppTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionableAdviceCard(BuildContext context, ComprehensiveInsight insight) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist_rounded,
                color: Colors.blue.shade400,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spaceS),
              Text(
                '실행 가능한 조언',
                style: AppTheme.headingSmall.copyWith(
                  color: Colors.blue.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceM),
          ...insight.actionableAdvice.asMap().entries.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spaceS),
            padding: const EdgeInsets.all(AppTheme.spaceM),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.shade100,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.value.title,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value.description,
                        style: AppTheme.bodySmall.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : AppTheme.onBackgroundColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildOpportunitiesCard(ComprehensiveInsight insight) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Colors.green.shade400,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spaceS),
              Text(
                '절약 기회',
                style: AppTheme.headingSmall.copyWith(
                  color: Colors.green.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceM),
          ...insight.opportunities.map((opportunity) => Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spaceS),
            padding: const EdgeInsets.all(AppTheme.spaceM),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getPriorityColor(opportunity['priority'] ?? 'LOW')
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(opportunity['priority'] ?? 'LOW'),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        opportunity['priority'] ?? 'LOW',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceS),
                    Expanded(
                      child: Text(
                        opportunity['title'] ?? '',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceS),
                Text(
                  opportunity['message'] ?? '',
                  style: AppTheme.bodySmall,
                ),
                if (opportunity['potentialSaving'] != null) ...[
                  const SizedBox(height: AppTheme.spaceS),
                  Text(
                    '예상 절약액: ${_formatCurrency(opportunity['potentialSaving'] as double)}',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPredictionsCard(ComprehensiveInsight insight) {
    final predictions = insight.predictions;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.query_stats,
                color: Colors.purple.shade400,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spaceS),
              Text(
                '미래 예측',
                style: AppTheme.headingSmall.copyWith(
                  color: Colors.purple.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceM),
          if (predictions['nextMonthSpending'] != null) ...[
            _buildPredictionItem(
              '다음 달 예상 지출',
              _formatCurrency(predictions['nextMonthSpending'] as double),
              Icons.calendar_month,
            ),
            const SizedBox(height: AppTheme.spaceS),
          ],
          if (predictions['savingOpportunity'] != null) ...[
            _buildPredictionItem(
              '절약 가능 금액',
              _formatCurrency(predictions['savingOpportunity'] as double),
              Icons.savings,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPredictionItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.purple.shade400,
          size: 20,
        ),
        const SizedBox(width: AppTheme.spaceS),
        Text(
          label,
          style: AppTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.purple.shade700,
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return AppTheme.errorColor;
      case 'MEDIUM':
        return AppTheme.warningColor;
      case 'LOW':
        return AppTheme.successColor;
      default:
        return Colors.green.shade400;
    }
  }

  /// 통화 포맷 헬퍼 메서드 (천 단위 콤마 포함)
  String _formatCurrency(double amount) {
    final intAmount = amount.toInt();

    if (intAmount >= 10000) {
      // 1만원 이상: "1,234만원"
      final man = intAmount ~/ 10000;
      final rest = intAmount % 10000;
      if (rest == 0) {
        return '${NumberFormatter.formatNumber(man)}만원';
      } else {
        // 나머지가 있으면 천 단위까지 표시
        return '${NumberFormatter.formatNumber(man)}만 ${NumberFormatter.formatNumber(rest)}원';
      }
    } else if (intAmount >= 1000) {
      // 1천원 이상 1만원 미만: "5,000원"
      return '${NumberFormatter.formatNumber(intAmount)}원';
    } else {
      // 1천원 미만: "500원"
      return '$intAmount원';
    }
  }

  /// 마크다운 문법을 자연스러운 텍스트로 변환
  String _cleanMarkdown(String text) {
    var cleaned = text;

    // ** 굵은 글씨 ** 제거
    cleaned = cleaned.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');

    // * 기울임 * 제거 (단, ** 이후에 처리)
    cleaned = cleaned.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');

    // # 제목 표시 제거 (###, ##, # 모두)
    cleaned = cleaned.replaceAll(RegExp(r'^#{1,3}\s+', multiLine: true), '');

    // - 리스트 기호를 • 로 변경
    cleaned = cleaned.replaceAll(RegExp(r'^\s*-\s+', multiLine: true), '• ');

    // ` 코드 블록 제거
    cleaned = cleaned.replaceAll(RegExp(r'`([^`]+)`'), r'$1');

    // $ 기호 제거 (달러 표시처럼 보이는 문제 해결)
    cleaned = cleaned.replaceAll(r'$', '');

    // \n을 실제 줄바꿈으로 변환
    cleaned = cleaned.replaceAll(r'\n', '\n');

    // 연속된 줄바꿈을 하나로 정리
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return cleaned.trim();
  }
}
