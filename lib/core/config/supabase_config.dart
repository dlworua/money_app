/// Supabase 설정 파일
///
/// 사용법:
/// 1. Supabase Dashboard에서 Project URL과 anon key를 복사
/// 2. 아래 상수에 붙여넣기
class SupabaseConfig {
  // TODO: Supabase Dashboard에서 복사한 값으로 변경하세요!
  // Project Settings → API → Project URL
  static const String supabaseUrl = 'https://acitjrdfczlwtdwrtwgn.supabase.co';

  // Project Settings → API → anon public key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFjaXRqcmRmY3psd3Rkd3J0d2duIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEyNzg4NzAsImV4cCI6MjA3Njg1NDg3MH0.2w8okcLcCDc0k1B09AzpXZnC3xxajL3iZP6TsZryauA';
}

/// 📌 설정 방법:
///
/// 1. https://supabase.com 접속
/// 2. 왼쪽 하단 "⚙️ Project Settings" 클릭
/// 3. "API" 탭 클릭
/// 4. 다음 값들을 복사:
///    - Project URL: https://xxxxx.supabase.co
///    - anon public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
///
/// 5. 위 상수에 붙여넣기:
///    static const String supabaseUrl = 'https://xxxxx.supabase.co';
///    static const String supabaseAnonKey = 'eyJhbGc...';
///
/// ⚠️ 주의: 이 파일은 .gitignore에 추가하지 않아도 됩니다.
///         anon key는 공개되어도 안전합니다 (RLS로 보호됨)
