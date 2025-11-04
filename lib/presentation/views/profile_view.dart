import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show Platform;

import '../../core/theme/app_theme.dart';
import '../../core/utils/number_formatter.dart';
import '../viewmodels/providers.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../providers/auth_provider.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';
import '../dialogs/subscription_dialog.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  DateTime _currentMonth = DateTime.now();
  int _currentQuarter = DateTime.now().month <= 3
      ? 1
      : DateTime.now().month <= 6
      ? 2
      : DateTime.now().month <= 9
      ? 3
      : 4;

  final TransactionRepository _transactionRepository = TransactionRepository();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  // 프로필 전용 배너 광고
  BannerAd? _profileBannerAd;
  bool _isProfileAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _initializeProfileBannerAd();
  }

  /// 프로필 전용 배너 광고 초기화
  void _initializeProfileBannerAd() {
    _profileBannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // 테스트 ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isProfileAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _profileBannerAd?.load();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _transactionRepository.getTransactions();
      if (mounted) {
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final user = state.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('프로필', style: TextStyle(color: AppTheme.white(context))),
        backgroundColor: Colors.green.shade400,
        foregroundColor: AppTheme.white(context),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 섹션
            _buildProfileSection(user),

            const SizedBox(height: 24),

            // 토스 스타일 캘린더 섹션
            _buildCalendarSection(),

            const SizedBox(height: 24),

            // GitHub 잔디심기 스타일 섹션
            _buildGrassPlantingSection(),

            const SizedBox(height: 24),

            // 설정 섹션
            _buildSettingsSection(context, user),

            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAd(),
    );
  }

  @override
  void dispose() {
    _profileBannerAd?.dispose();
    super.dispose();
  }

  /// 프로필 섹션 - 컴팩트 디자인
  Widget _buildProfileSection(user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.grey.shade800, Colors.grey.shade900]
              : [Colors.green.shade50, Colors.teal.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.grey.shade700
              : Colors.green.shade400.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // 상단: 프로필 + 코인 (한 줄로 정리)
          Row(
            children: [
              // 프로필 아바타
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.green.shade400,
                child: const Text('💰', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),

              // 이름 + 코인
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '머니 마스터',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: AppTheme.amber(context, 600),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${NumberFormatter.formatNumber(user?.coins ?? 0)} 코인',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.amber(context, 700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 구분선
          Container(
            height: 1,
            color: isDark
                ? Colors.grey.shade700
                : Colors.green.shade400.withValues(alpha: 0.1),
          ),

          const SizedBox(height: 12),

          // 하단: 통계 정보 (컴팩트하게 가로 배치)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompactStatItem(
                Icons.games,
                '${_getTotalGamesPlayed()}',
                '게임',
              ),
              _buildCompactStatItem(
                Icons.local_fire_department,
                '${_getStreakDays()}일',
                '연속접속',
              ),
              _buildCompactStatItem(
                Icons.savings,
                '${_getSavingAchievements()}',
                '절약달성',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 컴팩트한 통계 아이템
  Widget _buildCompactStatItem(IconData icon, String value, String label) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, color: Colors.green.shade400, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextColor(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppTheme.getTextColor(context)),
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getGreyColor(context, 300)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getGreyColor(context).withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🗓️ 가계부 캘린더',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month - 1,
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    '${_currentMonth.year}.${_currentMonth.month.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month + 1,
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendar(),
          const SizedBox(height: 16),
          _buildCalendarLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        // 요일 헤더
        Row(
          children: ['일', '월', '화', '수', '목', '금', '토']
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        // 캘린더 그리드
        ...List.generate(((daysInMonth + firstWeekday) / 7).ceil(), (
          weekIndex,
        ) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 45));
              }

              final date = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                dayNumber,
              );
              final dayData = _getDayData(date);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    // 해당 날짜의 거래 내역 다이얼로그 표시
                    _showTransactionsForDate(context, date);
                  },
                  child: Container(
                    height: 45,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: _getDayColor(dayData),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          date.day == DateTime.now().day &&
                              date.month == DateTime.now().month &&
                              date.year == DateTime.now().year
                          ? Border.all(color: Colors.green.shade400, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getTextColor(dayData),
                          ),
                        ),
                        if (dayData['hasData'] == true)
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _getIndicatorColor(dayData),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Widget _buildCalendarLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('수입', Colors.blue[100]!, Colors.blue),
        _buildLegendItem('지출', Colors.red[100]!, Colors.red),
        _buildLegendItem('절약', Colors.green[100]!, Colors.green),
        _buildLegendItem('균형', Colors.purple[100]!, Colors.purple),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color bgColor, Color? textColor) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGrassPlantingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🌱 가계부 키우기',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentQuarter = _currentQuarter > 1
                            ? _currentQuarter - 1
                            : 4;
                      });
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    '${DateTime.now().year}년 $_currentQuarter분기',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentQuarter = _currentQuarter < 4
                            ? _currentQuarter + 1
                            : 1;
                      });
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '분기별로 가계부 작성 현황을 확인해보세요!',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuarterlyGrassGrid(),
          const SizedBox(height: 16),
          _buildGrassLegend(),
        ],
      ),
    );
  }

  Widget _buildQuarterlyGrassGrid() {
    final now = DateTime.now();
    final year = now.year;

    // 분기별 시작/종료일 계산
    late DateTime startDate, endDate;
    List<String> monthLabels = [];

    switch (_currentQuarter) {
      case 1: // 1-3월
        startDate = DateTime(year, 1, 1);
        endDate = DateTime(year, 3, 31);
        monthLabels = ['1월', '2월', '3월'];
        break;
      case 2: // 4-6월
        startDate = DateTime(year, 4, 1);
        endDate = DateTime(year, 6, 30);
        monthLabels = ['4월', '5월', '6월'];
        break;
      case 3: // 7-9월
        startDate = DateTime(year, 7, 1);
        endDate = DateTime(year, 9, 30);
        monthLabels = ['7월', '8월', '9월'];
        break;
      case 4: // 10-12월
        startDate = DateTime(year, 10, 1);
        endDate = DateTime(year, 12, 31);
        monthLabels = ['10월', '11월', '12월'];
        break;
    }

    // 분기의 총 주수 계산 (약 13주)
    final totalDays = endDate.difference(startDate).inDays + 1;
    final totalWeeks = (totalDays / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 월 라벨
          Row(
            children: [
              const SizedBox(width: 25), // 요일 라벨 공간
              ...monthLabels.map(
                (month) => Expanded(
                  child: Text(
                    month,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 잔디 그리드
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 요일 라벨
              Column(
                children: [
                  const SizedBox(height: 1.9),
                  ...['월', '', '수', '', '금', '', '일'].map(
                    (day) => Container(
                      height: 11,
                      width: 20,
                      alignment: Alignment.centerRight,
                      child: Text(
                        day,
                        style: TextStyle(fontSize: 8, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // 잔디 격자 (더 큰 셀)
              Expanded(
                child: SizedBox(
                  height: 84, // 7 days * 11 height + margins
                  child: Row(
                    children: List.generate(totalWeeks, (weekIndex) {
                      return Expanded(
                        child: Column(
                          children: List.generate(7, (dayIndex) {
                            final date = startDate.add(
                              Duration(days: weekIndex * 7 + dayIndex),
                            );

                            // 분기 범위를 벗어나거나 미래 날짜인 경우
                            if (date.isAfter(endDate) || date.isAfter(now)) {
                              return Container(
                                width: double.infinity,
                                height: 11,
                                margin: const EdgeInsets.all(0.5),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }

                            final intensity = _getBudgetingIntensity(date);
                            return Container(
                              width: double.infinity,
                              height: 11,
                              margin: const EdgeInsets.all(0.5),
                              decoration: BoxDecoration(
                                color: _getGrassColor(intensity),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrassLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '적음',
          style: TextStyle(fontSize: 12, color: AppTheme.getTextColor(context)),
        ),
        Row(
          children: List.generate(5, (index) {
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: _getGrassColor(index),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        Text(
          '많음',
          style: TextStyle(fontSize: 12, color: AppTheme.getTextColor(context)),
        ),
      ],
    );
  }

  /// 특정 날짜의 거래 내역을 보여주는 다이얼로그
  void _showTransactionsForDate(BuildContext context, DateTime date) {
    // 해당 날짜의 거래 내역 필터링
    final dayTransactions = _transactions.where((transaction) {
      return transaction.date.year == date.year &&
          transaction.date.month == date.month &&
          transaction.date.day == date.day;
    }).toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${date.year}년 ${date.month}월 ${date.day}일',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '총 ${dayTransactions.length}건의 거래',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // 거래 내역 리스트
              if (dayTransactions.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '이 날짜에는 거래 내역이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dayTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = dayTransactions[index];
                      return _buildTransactionItem(transaction);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 거래 내역 아이템 위젯
  Widget _buildTransactionItem(Transaction transaction) {
    // 거래 타입에 따른 색상 및 아이콘 설정
    Color typeColor;
    IconData typeIcon;
    String typeLabel;

    switch (transaction.type) {
      case TransactionType.income:
        typeColor = Colors.blue;
        typeIcon = Icons.arrow_downward;
        typeLabel = '수입';
        break;
      case TransactionType.expense:
        typeColor = Colors.red;
        typeIcon = Icons.arrow_upward;
        typeLabel = '지출';
        break;
      case TransactionType.saving:
        typeColor = Colors.green;
        typeIcon = Icons.savings;
        typeLabel = '절약';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 12),

          // 거래 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      transaction.category.displayName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (transaction.note != null &&
                    transaction.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.note!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // 금액
          Text(
            '${transaction.type == TransactionType.income ? '+' : '-'}${NumberFormatter.formatNumber(transaction.amount.toInt())}원',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }

  // 데이터 관련 헬퍼 메서드들
  Map<String, dynamic> _getDayData(DateTime date) {
    if (_isLoading) {
      return {'income': 0, 'expense': 0, 'savings': 0, 'hasData': false};
    }

    // 해당 날짜의 거래 내역 필터링
    final dayTransactions = _transactions.where((transaction) {
      return transaction.date.year == date.year &&
          transaction.date.month == date.month &&
          transaction.date.day == date.day;
    }).toList();

    if (dayTransactions.isEmpty) {
      return {'income': 0, 'expense': 0, 'savings': 0, 'hasData': false};
    }

    // 수입, 지출, 절약 계산
    double income = 0;
    double expense = 0;
    double savings = 0;

    for (final transaction in dayTransactions) {
      switch (transaction.type) {
        case TransactionType.income:
          income += transaction.amount;
          break;
        case TransactionType.expense:
          expense += transaction.amount;
          break;
        case TransactionType.saving:
          savings += transaction.amount;
          break;
      }
    }

    return {
      'income': income.toInt(),
      'expense': expense.toInt(),
      'savings': savings.toInt(),
      'hasData': true,
    };
  }

  Color _getDayColor(Map<String, dynamic> dayData) {
    if (dayData['hasData'] != true) return Colors.grey[100]!;

    final income = dayData['income'] as int;
    final expense = dayData['expense'] as int;

    if (income > expense * 1.2) return Colors.blue[100]!; // 수입이 많음
    if (expense > income * 1.2) return Colors.red[100]!; // 지출이 많음
    if (dayData['savings'] > 0) return Colors.green[100]!; // 절약
    return Colors.purple[100]!; // 균형
  }

  Color _getTextColor(Map<String, dynamic> dayData) {
    if (dayData['hasData'] != true) return Colors.grey[600]!;

    final income = dayData['income'] as int;
    final expense = dayData['expense'] as int;

    if (income > expense * 1.2) return Colors.blue[700]!;
    if (expense > income * 1.2) return Colors.red[700]!;
    if (dayData['savings'] > 0) return Colors.green[700]!;
    return Colors.purple[700]!;
  }

  Color _getIndicatorColor(Map<String, dynamic> dayData) {
    final income = dayData['income'] as int;
    final expense = dayData['expense'] as int;

    if (income > expense * 1.2) return Colors.blue[600]!;
    if (expense > income * 1.2) return Colors.red[600]!;
    if (dayData['savings'] > 0) return Colors.green[600]!;
    return Colors.purple[600]!;
  }

  int _getBudgetingIntensity(DateTime date) {
    if (_isLoading) return 0;

    // 해당 날짜의 거래 내역 개수 계산
    final dayTransactions = _transactions.where((transaction) {
      return transaction.date.year == date.year &&
          transaction.date.month == date.month &&
          transaction.date.day == date.day;
    }).toList();

    final transactionCount = dayTransactions.length;

    // 거래 개수에 따른 강도 계산 (0-4 레벨)
    if (transactionCount == 0) return 0;
    if (transactionCount == 1) return 1;
    if (transactionCount == 2) return 2;
    if (transactionCount <= 4) return 3;
    return 4; // 5개 이상
  }

  Color _getGrassColor(int intensity) {
    switch (intensity) {
      case 0:
        return Colors.grey[200]!;
      case 1:
        return Colors.green[200]!;
      case 2:
        return Colors.green[400]!;
      case 3:
        return Colors.green[600]!;
      case 4:
        return Colors.green[800]!;
      default:
        return Colors.grey[200]!;
    }
  }

  // 통계 관련 헬퍼 메서드들
  int _getTotalGamesPlayed() {
    final user = ref.read(homeViewModelProvider).user;
    if (user == null) return 0;

    // 사용자의 총 게임 플레이 횟수 (대략 계산)
    // 실제로는 별도의 게임 통계 저장소가 있어야 하지만,
    // 현재는 코인 획득량을 기반으로 추정
    return (user.coins / 10).floor(); // 평균 10코인당 1게임으로 추정
  }

  int _getStreakDays() {
    if (_isLoading || _transactions.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;

    // 오늘부터 거슬러 올라가며 연속 거래일 계산
    for (int i = 0; i < 30; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final hasTransaction = _transactions.any((t) {
        final transactionDate = DateTime(t.date.year, t.date.month, t.date.day);
        return transactionDate.isAtSameMomentAs(checkDate);
      });

      if (hasTransaction) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  int _getSavingAchievements() {
    if (_isLoading) return 0;

    // 절약 거래 개수 계산
    final savingTransactions = _transactions
        .where((t) => t.type == TransactionType.saving)
        .length;

    return savingTransactions;
  }

  /// 설정 섹션
  Widget _buildSettingsSection(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getGreyColor(context, 300)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getGreyColor(context).withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚙️ 설정',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 프로필 관리
          _buildSettingItem(
            icon: Icons.person_outline,
            title: '프로필 편집',
            subtitle: '닉네임 및 프로필 사진 변경',
            onTap: () {
              // TODO: 프로필 편집 기능 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프로필 편집 기능 준비 중입니다')),
              );
            },
          ),

          _buildDivider(),

          // 테마 설정
          _buildSettingItem(
            icon: Icons.palette_outlined,
            title: '테마 설정',
            subtitle: '라이트/다크 모드 변경',
            onTap: () {
              _showThemeDialog(context);
            },
          ),

          _buildDivider(),

          // 프리미엄
          _buildSettingItem(
            icon: user?.isPremium == true
                ? Icons.workspace_premium
                : Icons.workspace_premium_outlined,
            title: user?.isPremium == true ? '프리미엄 관리' : '프리미엄 가입',
            subtitle: user?.isPremium == true
                ? '프리미엄 혜택 확인 및 해지'
                : '광고 제거 및 3배 포인트',
            iconColor: Colors.amber[700]!,
            onTap: () {
              // 요금제 다이얼로그 표시
              showDialog(
                context: context,
                builder: (context) => const SubscriptionDialog(),
              );
            },
          ),

          _buildDivider(),

          // 계정 연동
          _buildSettingItem(
            icon: Icons.link,
            title: '계정 연동',
            subtitle: '다른 로그인 방식 추가',
            iconColor: Colors.blue[700]!,
            onTap: () {
              _showLinkAccountDialog(context);
            },
          ),

          _buildDivider(),

          // 로그아웃
          _buildSettingItem(
            icon: Icons.logout,
            title: '로그아웃',
            subtitle: '다른 계정으로 로그인',
            iconColor: Colors.orange[700]!,
            onTap: () async {
              final authRepo = ref.read(authRepositoryProvider);

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('로그아웃'),
                  content: const Text('로그아웃 하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        try {
                          await authRepo.signOut();

                          if (mounted) {
                            // 로그인 화면으로 이동
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('로그아웃 실패: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('로그아웃'),
                    ),
                  ],
                ),
              );
            },
          ),

          _buildDivider(),

          // 회원탈퇴
          _buildSettingItem(
            icon: Icons.person_remove_outlined,
            title: '회원 탈퇴',
            subtitle: '계정 및 모든 데이터 삭제',
            iconColor: Colors.red[700]!,
            onTap: () {
              // TODO: 회원탈퇴 기능 구현
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('회원 탈퇴'),
                  content: const Text('정말 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('회원탈퇴 기능 준비 중입니다')),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('탈퇴'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 설정 아이템 위젯
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.green.shade400).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.green.shade400,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  /// 구분선
  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[200],
    );
  }

  /// 테마 선택 다이얼로그
  void _showThemeDialog(BuildContext context) {
    final currentThemeMode = ref.read(themeViewModelProvider);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.palette_outlined, color: Colors.green.shade400),
              const SizedBox(width: 8),
              const Text('테마 설정'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 라이트 모드
              ListTile(
                leading: const Icon(Icons.light_mode, color: Colors.amber),
                title: const Text('라이트 모드'),
                trailing: currentThemeMode == ThemeMode.light
                    ? Icon(Icons.check_circle, color: Colors.green.shade400)
                    : null,
                onTap: () {
                  ref
                      .read(themeViewModelProvider.notifier)
                      .setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              // 다크 모드
              ListTile(
                leading: const Icon(Icons.dark_mode, color: Colors.indigo),
                title: const Text('다크 모드'),
                trailing: currentThemeMode == ThemeMode.dark
                    ? Icon(Icons.check_circle, color: Colors.green.shade400)
                    : null,
                onTap: () {
                  ref
                      .read(themeViewModelProvider.notifier)
                      .setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              // 시스템 설정 따르기
              ListTile(
                leading: const Icon(Icons.settings_suggest, color: Colors.grey),
                title: const Text('시스템 설정 따르기'),
                trailing: currentThemeMode == ThemeMode.system
                    ? Icon(Icons.check_circle, color: Colors.green.shade400)
                    : null,
                onTap: () {
                  ref
                      .read(themeViewModelProvider.notifier)
                      .setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  /// 프로필 전용 하단 배너 광고 위젯
  Widget? _buildBottomAd() {
    try {
      // 프로필 전용 광고가 로드되지 않았으면 null 반환
      if (!_isProfileAdLoaded || _profileBannerAd == null) return null;

      return Container(
        height: _profileBannerAd!.size.height.toDouble(),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: AdWidget(ad: _profileBannerAd!),
      );
    } catch (e) {
      // 광고 표시 오류 시 null 반환하여 광고 영역을 숨김
      return null;
    }
  }

  /// 계정 연동 다이얼로그
  void _showLinkAccountDialog(BuildContext context) {
    final authRepo = ref.read(authRepositoryProvider);
    final currentUser = Supabase.instance.client.auth.currentUser;

    // 현재 연결된 provider 확인
    final linkedProviders = currentUser?.appMetadata['providers'] as List? ?? [];
    final hasGoogle = linkedProviders.contains('google');
    final hasApple = linkedProviders.contains('apple');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 연동'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '다른 기기에서도 같은 계정으로 로그인하려면\n로그인 방식을 추가로 연결하세요.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Google 연동 버튼
            if (!hasGoogle)
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _linkGoogleAccount(context, authRepo);
                },
                icon: const Text('G', style: TextStyle(fontWeight: FontWeight.bold)),
                label: const Text('Google 계정 연결'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                ),
              )
            else
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Google 계정 연결됨'),
                dense: true,
              ),

            const SizedBox(height: 8),

            // Apple 연동 버튼 (iOS만)
            if (Platform.isIOS) ...[
              if (!hasApple)
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _linkAppleAccount(context, authRepo);
                  },
                  icon: const Icon(Icons.apple),
                  label: const Text('Apple 계정 연결'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                )
              else
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Apple 계정 연결됨'),
                  dense: true,
                ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  /// Google 계정 연동
  Future<void> _linkGoogleAccount(BuildContext context, authRepo) async {
    try {
      final response = await authRepo.linkGoogleAccount();
      if (response.user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Google 계정이 연결되었습니다\n같은 이메일을 사용하면 다른 기기에서도 로그인할 수 있습니다'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Google 계정 연결 실패';
        if (e.toString().contains('취소') || e.toString().contains('CANCEL')) {
          errorMsg = '연결이 취소되었습니다';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Apple 계정 연동
  Future<void> _linkAppleAccount(BuildContext context, authRepo) async {
    try {
      final response = await authRepo.linkAppleAccount();
      if (response.user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Apple 계정이 연결되었습니다\n같은 이메일을 사용하면 다른 기기에서도 로그인할 수 있습니다'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Apple 계정 연결 실패';
        if (e.toString().contains('취소') || e.toString().contains('CANCEL')) {
          errorMsg = '연결이 취소되었습니다';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
