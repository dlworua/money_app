/// 약관 동의 모델
class TermsAgreementModel {
  final String userId;
  final bool serviceTerms; // 서비스 이용약관 (필수)
  final bool privacyPolicy; // 개인정보 처리방침 (필수)
  final bool marketingConsent; // 마케팅 정보 수신 (선택)
  final bool ageConfirmation; // 만 14세 이상 확인 (필수)
  final DateTime agreedAt;

  TermsAgreementModel({
    required this.userId,
    required this.serviceTerms,
    required this.privacyPolicy,
    required this.marketingConsent,
    required this.ageConfirmation,
    required this.agreedAt,
  });

  /// 필수 약관이 모두 동의되었는지 확인
  bool get isAllRequiredAgreed {
    return serviceTerms && privacyPolicy && ageConfirmation;
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'service_terms': serviceTerms,
      'privacy_policy': privacyPolicy,
      'marketing_consent': marketingConsent,
      'age_confirmation': ageConfirmation,
      'agreed_at': agreedAt.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory TermsAgreementModel.fromJson(Map<String, dynamic> json) {
    return TermsAgreementModel(
      userId: json['user_id'] as String,
      serviceTerms: json['service_terms'] as bool,
      privacyPolicy: json['privacy_policy'] as bool,
      marketingConsent: json['marketing_consent'] as bool? ?? false,
      ageConfirmation: json['age_confirmation'] as bool,
      agreedAt: DateTime.parse(json['agreed_at'] as String),
    );
  }

  /// 복사본 생성
  TermsAgreementModel copyWith({
    String? userId,
    bool? serviceTerms,
    bool? privacyPolicy,
    bool? marketingConsent,
    bool? ageConfirmation,
    DateTime? agreedAt,
  }) {
    return TermsAgreementModel(
      userId: userId ?? this.userId,
      serviceTerms: serviceTerms ?? this.serviceTerms,
      privacyPolicy: privacyPolicy ?? this.privacyPolicy,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      ageConfirmation: ageConfirmation ?? this.ageConfirmation,
      agreedAt: agreedAt ?? this.agreedAt,
    );
  }
}
