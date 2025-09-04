import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SavingRecordDialog extends StatefulWidget {
  final Function(double amount, String category, String description) onSave;

  const SavingRecordDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<SavingRecordDialog> createState() => _SavingRecordDialogState();
}

class _SavingRecordDialogState extends State<SavingRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = '식비';
  final List<String> _categories = [
    '식비',
    '교통비',
    '쇼핑',
    '카페/음료',
    '문화생활',
    '기타',
  ];
  
  final List<IconData> _categoryIcons = [
    Icons.restaurant,
    Icons.directions_bus,
    Icons.shopping_cart,
    Icons.coffee,
    Icons.movie,
    Icons.more_horiz,
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.savings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '절약 기록 추가',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 금액 입력
                  const Text(
                    '절약 금액',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.green[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              suffixText: '원',
                            ),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return '금액을 입력해주세요';
                              }
                              final amount = int.tryParse(value!);
                              if (amount == null || amount <= 0) {
                                return '올바른 금액을 입력해주세요';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 카테고리 선택
                  const Text(
                    '카테고리',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      final isSelected = category == _selectedCategory;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green[50] : Colors.grey[100],
                            border: Border.all(
                              color: isSelected ? Colors.green[400]! : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _categoryIcons[index],
                                color: isSelected ? Colors.green[600] : Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.green[700] : Colors.grey[700],
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 설명 입력 (선택사항)
                  const Text(
                    '설명 (선택사항)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: '어떤 방법으로 절약했나요?',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '절약 기록 저장',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveRecord() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();
      
      widget.onSave(amount, _selectedCategory, description);
      Navigator.of(context).pop();
      
      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${amount.toInt()}원 절약 기록이 저장되었습니다! 🎉'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}