import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/transaction.dart';
import '../viewmodels/providers.dart';

// 천 단위 컴마 입력 포매터
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 숫자만 추출
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digits.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }

    // 천 단위 컴마 추가
    String formatted = _addCommas(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addCommas(String digits) {
    if (digits.length <= 3) return digits;
    
    return digits.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

// 거래 추가 다이얼로그
class AddTransactionDialog extends ConsumerStatefulWidget {
  final TransactionType? initialType;
  
  const AddTransactionDialog({super.key, this.initialType});

  @override
  ConsumerState<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  late TransactionType _selectedType;
  late TransactionCategory _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 초기 거래 유형 설정
    _selectedType = widget.initialType ?? TransactionType.expense;
    // 초기 거래 유형에 맞는 카테고리로 설정
    final availableCategories = _getCategoriesForType(_selectedType);
    if (availableCategories.isNotEmpty) {
      _selectedCategory = availableCategories.first;
    }
  }

  // 거래 유형별 카테고리 필터링 헬퍼 메서드
  List<TransactionCategory> _getCategoriesForType(TransactionType type) {
    return TransactionCategoryExtension.getCategoriesForType(type);
  }

  @override
  Widget build(BuildContext context) {
    // 거래 유형에 따른 색상
    Color typeColor;
    IconData typeIcon;
    switch (_selectedType) {
      case TransactionType.income:
        typeColor = Colors.blue;
        typeIcon = Icons.arrow_downward;
        break;
      case TransactionType.expense:
        typeColor = Colors.red;
        typeIcon = Icons.arrow_upward;
        break;
      case TransactionType.saving:
        typeColor = Colors.green;
        typeIcon = Icons.savings;
        break;
    }

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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [typeColor, typeColor.withValues(alpha: 0.7)],
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
                    child: Icon(typeIcon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '거래 추가',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTypeLabel(_selectedType),
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 거래 유형 선택 (버튼 스타일)
                      const Text(
                        '거래 유형',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: TransactionType.values.map((type) {
                          final isSelected = _selectedType == type;
                          Color color;
                          IconData icon;
                          String label;

                          switch (type) {
                            case TransactionType.income:
                              color = Colors.blue;
                              icon = Icons.arrow_downward;
                              label = '수입';
                              break;
                            case TransactionType.expense:
                              color = Colors.red;
                              icon = Icons.arrow_upward;
                              label = '지출';
                              break;
                            case TransactionType.saving:
                              color = Colors.green;
                              icon = Icons.savings;
                              label = '절약';
                              break;
                          }

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedType = type;
                                    final availableCategories = _getCategoriesForType(_selectedType);
                                    if (availableCategories.isNotEmpty) {
                                      _selectedCategory = availableCategories.first;
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color.withValues(alpha: 0.1)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? color : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        icon,
                                        color: isSelected ? color : Colors.grey[600],
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          color: isSelected ? color : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // 카테고리 선택 (그리드 스타일)
                      const Text(
                        '카테고리',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _getCategoriesForType(_selectedType).map((category) {
                          final isSelected = _selectedCategory == category;
                          return InkWell(
                            onTap: () => setState(() => _selectedCategory = category),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? typeColor.withValues(alpha: 0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? typeColor : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(category.emoji, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 4),
                                  Text(
                                    category.displayName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected ? typeColor : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // 금액
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: '금액',
                          labelStyle: TextStyle(color: typeColor),
                          suffixText: '원',
                          prefixIcon: Icon(Icons.attach_money, color: typeColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: typeColor, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyInputFormatter()],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return '금액을 입력해주세요';
                          final numericValue = value!.replaceAll(',', '');
                          if (double.tryParse(numericValue) == null) return '올바른 금액을 입력해주세요';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // 설명
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: '설명',
                          labelStyle: TextStyle(color: typeColor),
                          prefixIcon: Icon(Icons.description_outlined, color: typeColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: typeColor, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return '설명을 입력해주세요';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // 날짜
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) setState(() => _selectedDate = date);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: typeColor),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '날짜',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 메모
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: '메모 (선택사항)',
                          hintText: '추가 정보를 입력하세요',
                          prefixIcon: Icon(Icons.note_outlined, color: typeColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: typeColor, width: 2),
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: typeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 거래 유형 라벨 반환
  String _getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return '수입 추가';
      case TransactionType.expense:
        return '지출 추가';
      case TransactionType.saving:
        return '절약 추가';
    }
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    // 컴마 제거 후 숫자 변환
    final numericValue = _amountController.text.replaceAll(',', '');
    final amount = double.parse(numericValue);

    homeViewModel.addTransaction(
      type: _selectedType,
      category: _selectedCategory,
      amount: amount,
      description: _descriptionController.text,
      date: _selectedDate,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}