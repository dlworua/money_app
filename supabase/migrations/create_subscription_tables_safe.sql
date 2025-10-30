-- =====================================================
-- 안전한 구독 시스템 테이블 생성 스크립트
-- 기존 정책이 있으면 삭제하고 다시 생성
-- =====================================================

-- 1. 기존 정책 삭제 (있다면)
DROP POLICY IF EXISTS "Users can view own terms agreements" ON public.terms_agreements;
DROP POLICY IF EXISTS "Users can insert own terms agreements" ON public.terms_agreements;
DROP POLICY IF EXISTS "Users can update own terms agreements" ON public.terms_agreements;
DROP POLICY IF EXISTS "Users can view own subscriptions" ON public.user_subscriptions;
DROP POLICY IF EXISTS "Users can insert own subscriptions" ON public.user_subscriptions;
DROP POLICY IF EXISTS "Users can update own subscriptions" ON public.user_subscriptions;
DROP POLICY IF EXISTS "Users can view own payment transactions" ON public.payment_transactions;
DROP POLICY IF EXISTS "Users can insert own payment transactions" ON public.payment_transactions;
DROP POLICY IF EXISTS "Users can view own point payment transactions" ON public.point_payment_transactions;
DROP POLICY IF EXISTS "Users can insert own point payment transactions" ON public.point_payment_transactions;

-- 2. 약관 동의 테이블 생성
CREATE TABLE IF NOT EXISTS public.terms_agreements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  service_terms BOOLEAN NOT NULL DEFAULT false,
  privacy_policy BOOLEAN NOT NULL DEFAULT false,
  marketing_consent BOOLEAN NOT NULL DEFAULT false,
  age_confirmation BOOLEAN NOT NULL DEFAULT false,
  agreed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id)
);

-- 약관 동의 테이블 인덱스
CREATE INDEX IF NOT EXISTS idx_terms_agreements_user_id ON public.terms_agreements(user_id);

-- 약관 동의 테이블 RLS 정책
ALTER TABLE public.terms_agreements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own terms agreements"
  ON public.terms_agreements
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own terms agreements"
  ON public.terms_agreements
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own terms agreements"
  ON public.terms_agreements
  FOR UPDATE
  USING (auth.uid() = user_id);

-- 3. 사용자 구독 테이블 생성
CREATE TABLE IF NOT EXISTS public.user_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tier TEXT NOT NULL DEFAULT 'free' CHECK (tier IN ('free', 'pro', 'premium')),
  subscribed_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  monthly_transactions_used INTEGER NOT NULL DEFAULT 0,
  budgets_used INTEGER NOT NULL DEFAULT 0,
  savings_goals_used INTEGER NOT NULL DEFAULT 0,
  last_reset_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id)
);

-- 사용자 구독 테이블 인덱스
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON public.user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_tier ON public.user_subscriptions(tier);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_expires_at ON public.user_subscriptions(expires_at);

-- 사용자 구독 테이블 RLS 정책
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscriptions"
  ON public.user_subscriptions
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own subscriptions"
  ON public.user_subscriptions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own subscriptions"
  ON public.user_subscriptions
  FOR UPDATE
  USING (auth.uid() = user_id);

-- 4. 결제 내역 테이블 생성 (인앱 결제 추적용)
CREATE TABLE IF NOT EXISTS public.payment_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subscription_tier TEXT NOT NULL CHECK (subscription_tier IN ('pro', 'premium')),
  amount INTEGER NOT NULL, -- 원화 단위
  currency TEXT NOT NULL DEFAULT 'KRW',
  payment_method TEXT NOT NULL, -- 'app_store', 'google_play', 'points'
  transaction_id TEXT, -- 스토어 거래 ID
  receipt_data TEXT, -- 영수증 데이터 (암호화 권장)
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 결제 내역 테이블 인덱스
CREATE INDEX IF NOT EXISTS idx_payment_transactions_user_id ON public.payment_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_transactions_status ON public.payment_transactions(status);
CREATE INDEX IF NOT EXISTS idx_payment_transactions_transaction_id ON public.payment_transactions(transaction_id);

-- 결제 내역 테이블 RLS 정책
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own payment transactions"
  ON public.payment_transactions
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own payment transactions"
  ON public.payment_transactions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 5. 포인트 결제 내역 테이블 생성 (포인트로 구독 결제 시)
CREATE TABLE IF NOT EXISTS public.point_payment_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subscription_tier TEXT NOT NULL CHECK (subscription_tier IN ('pro', 'premium')),
  points_used INTEGER NOT NULL,
  points_remaining INTEGER NOT NULL,
  discount_rate DECIMAL(5,2), -- 할인율 (예: 10.00 = 10%)
  final_amount INTEGER NOT NULL, -- 실제 차감 포인트
  status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'refunded')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 포인트 결제 내역 테이블 인덱스
CREATE INDEX IF NOT EXISTS idx_point_payment_transactions_user_id ON public.point_payment_transactions(user_id);

-- 포인트 결제 내역 테이블 RLS 정책
ALTER TABLE public.point_payment_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own point payment transactions"
  ON public.point_payment_transactions
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own point payment transactions"
  ON public.point_payment_transactions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 6. updated_at 자동 업데이트 트리거 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 기존 트리거 삭제 후 다시 생성
DROP TRIGGER IF EXISTS update_terms_agreements_updated_at ON public.terms_agreements;
DROP TRIGGER IF EXISTS update_user_subscriptions_updated_at ON public.user_subscriptions;
DROP TRIGGER IF EXISTS update_payment_transactions_updated_at ON public.payment_transactions;
DROP TRIGGER IF EXISTS update_point_payment_transactions_updated_at ON public.point_payment_transactions;

CREATE TRIGGER update_terms_agreements_updated_at
  BEFORE UPDATE ON public.terms_agreements
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_subscriptions_updated_at
  BEFORE UPDATE ON public.user_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payment_transactions_updated_at
  BEFORE UPDATE ON public.payment_transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_point_payment_transactions_updated_at
  BEFORE UPDATE ON public.point_payment_transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 7. 월별 사용량 리셋 함수 (스케줄러로 매월 1일에 실행)
CREATE OR REPLACE FUNCTION reset_monthly_subscription_usage()
RETURNS void AS $$
BEGIN
  UPDATE public.user_subscriptions
  SET
    monthly_transactions_used = 0,
    last_reset_date = NOW()
  WHERE
    EXTRACT(MONTH FROM last_reset_date) != EXTRACT(MONTH FROM NOW())
    OR EXTRACT(YEAR FROM last_reset_date) != EXTRACT(YEAR FROM NOW());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. 회원가입 시 기본 Free 요금제 자동 생성 트리거
CREATE OR REPLACE FUNCTION create_default_subscription()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_subscriptions (user_id, tier)
  VALUES (NEW.id, 'free')
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 기존 트리거 삭제 후 다시 생성
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_default_subscription();

-- 9. 구독 만료 확인 함수 (스케줄러로 매일 실행 권장)
CREATE OR REPLACE FUNCTION check_expired_subscriptions()
RETURNS void AS $$
BEGIN
  UPDATE public.user_subscriptions
  SET tier = 'free'
  WHERE
    expires_at IS NOT NULL
    AND expires_at < NOW()
    AND tier != 'free';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 완료 메시지
DO $$
BEGIN
  RAISE NOTICE '✅ 구독 시스템 테이블 생성 완료!';
  RAISE NOTICE '   - terms_agreements';
  RAISE NOTICE '   - user_subscriptions';
  RAISE NOTICE '   - payment_transactions';
  RAISE NOTICE '   - point_payment_transactions';
END $$;
