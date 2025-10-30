import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/terms_agreement_model.dart';

/// 약관 동의 정보 저장소
class TermsAgreementRepository {
  final SupabaseClient _supabase;

  TermsAgreementRepository(this._supabase);

  /// 사용자 약관 동의 정보 조회
  Future<TermsAgreementModel?> getTermsAgreement(String userId) async {
    try {
      final response = await _supabase
          .from('terms_agreements')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return TermsAgreementModel.fromJson(response);
    } catch (e) {
      print('Error fetching terms agreement: $e');
      return null;
    }
  }

  /// 현재 로그인한 사용자의 약관 동의 정보 조회
  Future<TermsAgreementModel?> getCurrentUserTermsAgreement() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    return getTermsAgreement(userId);
  }

  /// 약관 동의 정보 생성
  Future<TermsAgreementModel?> createTermsAgreement(
    TermsAgreementModel agreement,
  ) async {
    try {
      final response = await _supabase
          .from('terms_agreements')
          .insert(agreement.toJson())
          .select()
          .single();

      return TermsAgreementModel.fromJson(response);
    } catch (e) {
      print('Error creating terms agreement: $e');
      return null;
    }
  }

  /// 약관 동의 정보 업데이트
  Future<TermsAgreementModel?> updateTermsAgreement(
    TermsAgreementModel agreement,
  ) async {
    try {
      final response = await _supabase
          .from('terms_agreements')
          .update(agreement.toJson())
          .eq('user_id', agreement.userId)
          .select()
          .single();

      return TermsAgreementModel.fromJson(response);
    } catch (e) {
      print('Error updating terms agreement: $e');
      return null;
    }
  }

  /// 마케팅 동의 업데이트
  Future<TermsAgreementModel?> updateMarketingConsent(
    String userId,
    bool marketingConsent,
  ) async {
    try {
      final agreement = await getTermsAgreement(userId);
      if (agreement == null) return null;

      final updatedAgreement = agreement.copyWith(
        marketingConsent: marketingConsent,
      );

      return await updateTermsAgreement(updatedAgreement);
    } catch (e) {
      print('Error updating marketing consent: $e');
      return null;
    }
  }

  /// 회원가입 시 약관 동의 저장
  Future<TermsAgreementModel?> saveAgreementOnSignup({
    required String userId,
    required bool serviceTerms,
    required bool privacyPolicy,
    required bool marketingConsent,
    required bool ageConfirmation,
  }) async {
    try {
      final agreement = TermsAgreementModel(
        userId: userId,
        serviceTerms: serviceTerms,
        privacyPolicy: privacyPolicy,
        marketingConsent: marketingConsent,
        ageConfirmation: ageConfirmation,
        agreedAt: DateTime.now(),
      );

      return await createTermsAgreement(agreement);
    } catch (e) {
      print('Error saving agreement on signup: $e');
      return null;
    }
  }
}
