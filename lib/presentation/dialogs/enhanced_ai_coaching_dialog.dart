import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/enhanced_ai_coach.dart';
import '../../core/utils/number_formatter.dart';
import '../viewmodels/providers.dart';

class EnhancedAiCoachingDialog extends ConsumerWidget {
  const EnhancedAiCoachingDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog.fullscreen(
      child: Scaffold(
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
                  _buildMainAnalysisCard(insight),
                  const SizedBox(height: AppTheme.spaceM),
                  _buildStrategiesCard(insight),
                  const SizedBox(height: AppTheme.spaceM),
                  _buildActionableAdviceCard(insight),
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
      ),
    );
  }
  
  /// 🔄 실제 가계부 데이터를 로드하여 AI 인사이트 생성
  Future<ComprehensiveInsight> _generateInsight(WidgetRef ref) async {
    final state = ref.read(homeViewModelProvider);
    final coach = EnhancedAiCoach();

    // state.user가 null일 경우를 처리
    final user = state.user;
    if (user == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다');
    }

    // 🎯 실제 거래 내역과 예산 데이터를 TransactionRepository에서 로드
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
            '분석 중 문제가 발생했어요',
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

  Widget _buildMainAnalysisCard(ComprehensiveInsight insight) {
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
            child: Builder(
              builder: (context) => Text(
                _cleanMarkdown(insight.personalizedMessage),
                style: AppTheme.bodyMedium.copyWith(
                  height: 1.6,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategiesCard(ComprehensiveInsight insight) {
    if (insight.strategies.isEmpty) return const SizedBox.shrink();
    
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
                color: Colors.green.shade400,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spaceS),
              Text(
                '맞춤형 전략',
                style: AppTheme.headingSmall.copyWith(
                  color: Colors.green.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceM),
          ...insight.strategies.map((strategy) => Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spaceS),
            padding: const EdgeInsets.all(AppTheme.spaceM),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.shade400.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        strategy.title,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade400,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(strategy.priority),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        strategy.priority,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceS),
                Text(
                  strategy.description,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceS),
                Row(
                  children: [
                    Icon(
                      Icons.savings_outlined,
                      size: 16,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '예상 절약: ${_formatCurrency(strategy.expectedSaving.toDouble())}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceM),
                    Icon(
                      Icons.schedule_outlined,
                      size: 16,
                      color: Colors.teal.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      strategy.timeframe,
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.teal.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionableAdviceCard(ComprehensiveInsight insight) {
    if (insight.actionableAdvice.isEmpty) return const SizedBox.shrink();
    
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
              const Icon(
                Icons.check_circle_outline,
                color: AppTheme.successColor,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spaceS),
              Text(
                '실행 가능한 조언',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceM),
          ...insight.actionableAdvice.take(5).map((advice) => Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spaceS),
            padding: const EdgeInsets.all(AppTheme.spaceM),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceS),
                Expanded(
                  child: Builder(
                    builder: (context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advice.title,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          advice.description,
                          style: AppTheme.bodySmall.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade700
                                : AppTheme.onBackgroundColor,
                          ),
                        ),
                      ],
                    ),
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
              const Icon(
                Icons.trending_up_outlined,
                color: AppTheme.warningColor,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spaceS),
              Text(
                '절약 기회',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceM),
          ...insight.opportunities.take(3).map((opportunity) => Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spaceS),
            padding: const EdgeInsets.all(AppTheme.spaceM),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.warningColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opportunity['title'] as String,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warningColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXS),
                Text(
                  opportunity['message'] as String,
                  style: AppTheme.bodySmall,
                ),
                const SizedBox(height: AppTheme.spaceS),
                Text(
                  '💡 ${opportunity['suggestion']}',
                  style: AppTheme.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.green.shade400,
                  ),
                ),
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
                Icons.psychology_outlined,
                color: Colors.teal.shade400,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spaceS),
              Text(
                'AI 예측 분석',
                style: AppTheme.headingSmall.copyWith(
                  color: Colors.teal.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceM),
          
          // 목표 달성 확률
          if (predictions['goalAchievementProbability'] != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.successColor.withValues(alpha: 0.1),
                    AppTheme.successColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '목표 달성 확률',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceS),
                  Text(
                    '${((predictions['goalAchievementProbability'] as double) * 100).round()}%',
                    style: AppTheme.headingLarge.copyWith(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // 위험 요소
          if (predictions['riskFactors'] != null && 
              (predictions['riskFactors'] as List).isNotEmpty) ...[
            const SizedBox(height: AppTheme.spaceM),
            Text(
              '주의사항',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: AppTheme.spaceS),
            ...(predictions['riskFactors'] as List<String>).map((risk) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      size: 16,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        risk,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ),
          ],
        ],
      ),
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
    // **굵은 글씨** 제거
    var cleaned = text.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');

    // *기울임* 제거
    cleaned = cleaned.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');

    // \n을 실제 줄바꿈으로 변환
    cleaned = cleaned.replaceAll(r'\n', '\n');

    // ### 제목 처리
    cleaned = cleaned.replaceAll(RegExp(r'###\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'##\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'#\s*'), '');

    // - 리스트 기호를 자연스럽게
    cleaned = cleaned.replaceAll(RegExp(r'^\s*-\s+', multiLine: true), '• ');

    // ` 코드 블록 제거
    cleaned = cleaned.replaceAll(RegExp(r'`([^`]+)`'), r'$1');

    return cleaned.trim();
  }
}