import 'package:flutter/material.dart';

/// 약관 동의 위젯
///
/// 회원가입 시 필수/선택 약관 동의를 받는 UI 컴포넌트
class TermsAgreementWidget extends StatefulWidget {
  final Function(bool serviceTerms, bool privacyPolicy, bool marketingConsent, bool ageConfirmation) onAgreementChanged;

  const TermsAgreementWidget({
    super.key,
    required this.onAgreementChanged,
  });

  @override
  State<TermsAgreementWidget> createState() => _TermsAgreementWidgetState();
}

class _TermsAgreementWidgetState extends State<TermsAgreementWidget> {
  bool _agreeAll = false;
  bool _serviceTerms = false;
  bool _privacyPolicy = false;
  bool _marketingConsent = false;
  bool _ageConfirmation = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 전체 동의 체크박스
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            value: _agreeAll,
            onChanged: (value) {
              setState(() {
                _agreeAll = value ?? false;
                _serviceTerms = _agreeAll;
                _privacyPolicy = _agreeAll;
                _marketingConsent = _agreeAll;
                _ageConfirmation = _agreeAll;
              });
              _notifyChange();
            },
            title: const Text(
              '전체 동의',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: Colors.green.shade600,
          ),
        ),

        const SizedBox(height: 16),

        // 개별 약관 동의
        _buildIndividualTerms(context, isDark),
      ],
    );
  }

  Widget _buildIndividualTerms(BuildContext context, bool isDark) {
    return Column(
      children: [
        // 서비스 이용약관 (필수)
        _buildTermCheckbox(
          title: '[필수] 서비스 이용약관',
          value: _serviceTerms,
          onChanged: (value) {
            setState(() {
              _serviceTerms = value ?? false;
              _checkAllAgreed();
            });
            _notifyChange();
          },
          onDetailTap: () => _showTermsDetail(context, '서비스 이용약관', _getServiceTermsContent()),
        ),

        const SizedBox(height: 8),

        // 개인정보 처리방침 (필수)
        _buildTermCheckbox(
          title: '[필수] 개인정보 처리방침',
          value: _privacyPolicy,
          onChanged: (value) {
            setState(() {
              _privacyPolicy = value ?? false;
              _checkAllAgreed();
            });
            _notifyChange();
          },
          onDetailTap: () => _showTermsDetail(context, '개인정보 처리방침', _getPrivacyPolicyContent()),
        ),

        const SizedBox(height: 8),

        // 만 14세 이상 확인 (필수)
        _buildTermCheckbox(
          title: '[필수] 만 14세 이상입니다',
          value: _ageConfirmation,
          onChanged: (value) {
            setState(() {
              _ageConfirmation = value ?? false;
              _checkAllAgreed();
            });
            _notifyChange();
          },
          showDetail: false,
        ),

        const SizedBox(height: 8),

        // 마케팅 정보 수신 (선택)
        _buildTermCheckbox(
          title: '[선택] 마케팅 정보 수신 동의',
          value: _marketingConsent,
          onChanged: (value) {
            setState(() {
              _marketingConsent = value ?? false;
              _checkAllAgreed();
            });
            _notifyChange();
          },
          onDetailTap: () => _showTermsDetail(context, '마케팅 정보 수신 동의', _getMarketingConsentContent()),
        ),
      ],
    );
  }

  Widget _buildTermCheckbox({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
    VoidCallback? onDetailTap,
    bool showDetail = true,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green.shade600,
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        if (showDetail && onDetailTap != null)
          TextButton(
            onPressed: onDetailTap,
            child: Text(
              '보기',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }

  void _checkAllAgreed() {
    _agreeAll = _serviceTerms && _privacyPolicy && _marketingConsent && _ageConfirmation;
  }

  void _notifyChange() {
    widget.onAgreementChanged(
      _serviceTerms,
      _privacyPolicy,
      _marketingConsent,
      _ageConfirmation,
    );
  }

  void _showTermsDetail(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // 내용
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Text(
                  content,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getServiceTermsContent() {
    return '''
제1조 (목적)
본 약관은 머니 앱(이하 "회사")이 제공하는 서비스의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (정의)
1. "서비스"란 회사가 제공하는 가계부 관리, AI 코칭, 게임 등 모든 기능을 의미합니다.
2. "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 이용하는 회원 및 비회원을 말합니다.
3. "회원"이란 회사와 서비스 이용계약을 체결하고 이용자 아이디를 부여받은 자를 말합니다.

제3조 (약관의 효력 및 변경)
1. 본 약관은 서비스를 이용하고자 하는 모든 이용자에 대하여 그 효력을 발생합니다.
2. 회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 본 약관을 변경할 수 있습니다.

제4조 (서비스의 제공)
1. 회사는 다음과 같은 서비스를 제공합니다:
   - 가계부 기록 및 관리
   - AI 코칭 서비스
   - 금융 교육 게임
   - 통계 및 분석 기능

2. 서비스는 연중무휴 1일 24시간 제공함을 원칙으로 합니다.

제5조 (이용자의 의무)
1. 이용자는 다음 행위를 하여서는 안 됩니다:
   - 허위 정보 등록
   - 타인의 정보 도용
   - 서비스의 운영 방해
   - 부정한 방법으로 서비스 이용

제6조 (개인정보의 보호)
회사는 관계 법령이 정하는 바에 따라 이용자의 개인정보를 보호하기 위해 노력합니다.
''';
  }

  String _getPrivacyPolicyContent() {
    return '''
개인정보 처리방침

머니 앱(이하 "회사")은 이용자의 개인정보를 중요시하며, 개인정보 보호법을 준수하고 있습니다.

1. 수집하는 개인정보의 항목
   - 필수항목: 이메일, 비밀번호, 닉네임
   - 선택항목: 프로필 사진
   - 자동 수집: 서비스 이용 기록, 접속 IP

2. 개인정보의 수집 및 이용 목적
   - 회원 가입 및 관리
   - 서비스 제공
   - 통계 분석 및 서비스 개선
   - 고객 문의 응대

3. 개인정보의 보유 및 이용 기간
   - 회원 탈퇴 시까지
   - 관계 법령에 따라 보존할 필요가 있는 경우 해당 기간까지

4. 개인정보의 제3자 제공
   - 회사는 원칙적으로 이용자의 개인정보를 제3자에게 제공하지 않습니다.
   - 법령에 의한 경우 등 예외적인 경우에만 제공합니다.

5. 개인정보의 파기 절차 및 방법
   - 회원 탈퇴 시 즉시 파기
   - 전자적 파일: 복구 불가능한 방법으로 영구 삭제
   - 종이 문서: 분쇄 또는 소각

6. 이용자의 권리
   - 개인정보 열람 요구
   - 개인정보 정정·삭제 요구
   - 개인정보 처리 정지 요구

7. 개인정보 보호책임자
   - 이름: 이재겸
   - 이메일: support@moneyapp.com
''';
  }

  String _getMarketingConsentContent() {
    return '''
마케팅 정보 수신 동의

1. 목적
   - 신규 서비스 안내
   - 이벤트 및 프로모션 정보 제공
   - 맞춤형 서비스 제공

2. 수신 방법
   - 앱 푸시 알림
   - 이메일
   - SMS (해당시)

3. 수신 동의 철회
   - 앱 내 설정에서 언제든지 철회 가능
   - 수신 동의를 철회하더라도 서비스 이용에는 제한이 없습니다.

4. 유효기간
   - 동의일로부터 회원 탈퇴 시 또는 동의 철회 시까지
''';
  }
}
