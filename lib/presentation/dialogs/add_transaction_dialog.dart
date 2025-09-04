import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return AlertDialog(
      title: const Text('거래 추가'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 거래 유형 선택
                DropdownButtonFormField<TransactionType>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: '거래 유형'),
                  items: TransactionType.values.map((type) {
                    String text;
                    switch (type) {
                      case TransactionType.income:
                        text = '수입';
                        break;
                      case TransactionType.expense:
                        text = '지출';
                        break;
                      case TransactionType.saving:
                        text = '절약';
                        break;
                    }
                    return DropdownMenuItem(value: type, child: Text(text));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      // 거래 유형이 변경될 때 해당 유형의 첫 번째 카테고리로 설정
                      final availableCategories = _getCategoriesForType(_selectedType);
                      if (availableCategories.isNotEmpty) {
                        _selectedCategory = availableCategories.first;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // 카테고리 선택
                DropdownButtonFormField<TransactionCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: '카테고리'),
                  items: _getCategoriesForType(_selectedType).map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Text(category.emoji),
                          const SizedBox(width: 8),
                          Text(category.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),
                const SizedBox(height: 16),
                
                // 금액
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: '금액',
                    suffixText: '원',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  validator: (value) {
                    if (value?.isEmpty ?? true) return '금액을 입력해주세요';
                    // 컴마 제거 후 숫자 변환
                    final numericValue = value!.replaceAll(',', '');
                    if (double.tryParse(numericValue) == null) return '올바른 금액을 입력해주세요';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // 설명
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: '설명'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return '설명을 입력해주세요';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // 날짜
                ListTile(
                  title: const Text('날짜'),
                  subtitle: Text('${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                ),
                
                // 메모 (선택사항)
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: '메모 (선택사항)',
                    hintText: '추가 정보를 입력하세요',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveTransaction,
          child: const Text('저장'),
        ),
      ],
    );
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