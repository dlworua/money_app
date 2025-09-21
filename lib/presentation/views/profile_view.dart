import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/theme/app_theme.dart';
import '../viewmodels/providers.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';

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
        title: const Text('프로필'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
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

  Widget _buildProfileSection(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.secondaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryColor,
            child: Text('💰', style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 16),
          Text(
            '머니 마스터',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monetization_on, color: Colors.amber[600], size: 20),
              const SizedBox(width: 4),
              Text(
                '${user?.coins ?? 0} 코인',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '게임 플레이',
                '${_getTotalGamesPlayed()}회',
                Icons.games,
              ),
              _buildStatItem(
                '연속 접속',
                '${_getStreakDays()}일',
                Icons.local_fire_department,
              ),
              _buildStatItem(
                '절약 달성',
                '${_getSavingAchievements()}회',
                Icons.savings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        // 캘린더 그리드
        ...List.generate(6, (weekIndex) {
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
                        ? Border.all(color: AppTheme.primaryColor, width: 2)
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
              );
            }),
          );
        }).where((row) {
          return (row.children as List).any(
            (child) => child is Expanded && child.child is Container,
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
        color: Colors.white,
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
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
        Text('적음', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
        Text('많음', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
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

  /// 프로필 전용 하단 배너 광고 위젯
  Widget? _buildBottomAd() {
    try {
      // 프로필 전용 광고가 로드되지 않았으면 null 반환
      if (!_isProfileAdLoaded || _profileBannerAd == null) return null;

      return Container(
        height: _profileBannerAd!.size.height.toDouble(),
        decoration: BoxDecoration(
          color: Colors.white,
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
}
