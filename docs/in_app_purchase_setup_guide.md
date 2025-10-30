# 인앱 결제 설정 가이드 (In-App Purchase Setup Guide)

## 📋 목차
1. [개요](#개요)
2. [App Store Connect 설정 (iOS)](#app-store-connect-설정-ios)
3. [Google Play Console 설정 (Android)](#google-play-console-설정-android)
4. [Flutter 앱 설정](#flutter-앱-설정)
5. [테스트 방법](#테스트-방법)
6. [문제 해결](#문제-해결)

---

## 개요

Money App의 인앱 결제 시스템은 **3단계 구독 모델**을 사용합니다:

### 요금제

| 요금제 | 가격 | 주요 혜택 |
|--------|------|-----------|
| **Free** | 무료 | • 거래 추가: 월 100회<br>• 예산/목표: 각 10회<br>• AI 코칭: 사용 불가<br>• 광고 표시 |
| **Pro** | 월 4,900원 | • 거래 추가: 무제한<br>• 예산/목표: 각 50회 (누적)<br>• AI 코칭: 기본 모델<br>• 광고 제거 (게임 제외)<br>• 리워드 2배 |
| **Premium** | 월 9,900원 | • 거래 추가: 무제한<br>• 예산/목표: 무제한<br>• AI 코칭: 프리미엄 모델<br>• 전체 광고 제거<br>• 리워드 3배<br>• 티켓 대기 5분 |

### 상품 ID

앱에서 사용하는 인앱 결제 상품 ID:
- **Pro 월간 구독**: `money_app_pro_monthly`
- **Premium 월간 구독**: `money_app_premium_monthly`

---

## App Store Connect 설정 (iOS)

### 1. App Store Connect 로그인

1. [App Store Connect](https://appstoreconnect.apple.com/)에 로그인
2. **나의 앱** 클릭
3. Money App 선택 (앱이 없다면 먼저 생성)

### 2. 인앱 구매 항목 생성

#### 2.1. 자동 갱신 구독 그룹 생성

1. 왼쪽 메뉴에서 **인앱 구입** 클릭
2. **자동 갱신 구독** 탭 선택
3. **구독 그룹 생성** 클릭
4. 구독 그룹 정보 입력:
   - **참조 이름**: Money App Subscriptions
   - **App Store에 표시되는 이름**: Money App 프리미엄

#### 2.2. Pro 구독 상품 생성

1. 구독 그룹 내에서 **+ 버튼** 클릭
2. 구독 정보 입력:
   - **참조 이름**: Pro 월간 구독
   - **제품 ID**: `money_app_pro_monthly` ⚠️ **정확히 일치해야 함**
   - **구독 기간**: 1개월

3. 가격 설정:
   - **대한민국**: ₩4,900
   - 다른 국가는 자동 변환 또는 수동 설정

4. App Store 정보 입력:
   - **구독 표시 이름**: Pro 플랜
   - **설명**: 광고 제거 및 기본 AI 코칭

5. 검수 정보:
   - **스크린샷**: 구독 화면 캡처 (필수)
   - **검수 노트**: 구독 기능 설명

#### 2.3. Premium 구독 상품 생성

1. 동일한 구독 그룹 내에서 **+ 버튼** 클릭
2. 구독 정보 입력:
   - **참조 이름**: Premium 월간 구독
   - **제품 ID**: `money_app_premium_monthly` ⚠️ **정확히 일치해야 함**
   - **구독 기간**: 1개월

3. 가격 설정:
   - **대한민국**: ₩9,900

4. App Store 정보 입력:
   - **구독 표시 이름**: Premium 플랜
   - **설명**: 전체 광고 제거 및 프리미엄 AI 코칭

### 3. 샌드박스 테스터 계정 생성

1. **사용자 및 액세스** → **Sandbox 테스터** 이동
2. **테스터 추가 (+)** 클릭
3. 테스트용 Apple ID 생성:
   - **이메일**: 실제 Apple ID가 아닌 테스트용 이메일
   - **비밀번호**: 테스트용 비밀번호
   - **이름/성**: 테스터 정보
   - **국가**: 대한민국

⚠️ **주의**: Sandbox 테스터는 실제 Apple ID를 사용하면 안 됩니다!

### 4. 계약 및 세무 정보 설정

1. **계약, 세무 및 금융** 메뉴 이동
2. **유료 앱 계약** 활성화
3. 은행 계좌 및 세무 정보 입력
4. ⚠️ **이 설정이 완료되어야 실제 결제가 가능합니다**

---

## Google Play Console 설정 (Android)

### 1. Google Play Console 로그인

1. [Google Play Console](https://play.google.com/console/)에 로그인
2. Money App 선택 (앱이 없다면 먼저 생성)

### 2. 인앱 상품 생성

#### 2.1. 구독 기본 설정

1. 왼쪽 메뉴에서 **수익 창출** → **구독** 선택
2. **구독 만들기** 클릭

#### 2.2. Pro 구독 상품 생성

1. 상품 세부정보 입력:
   - **제품 ID**: `money_app_pro_monthly` ⚠️ **정확히 일치해야 함**
   - **이름**: Pro 플랜
   - **설명**: 광고 제거 및 기본 AI 코칭

2. 가격 및 구독 기간:
   - **기본 기간**: 1개월
   - **가격**: ₩4,900

3. 혜택 설명:
   ```
   • 거래 추가 무제한
   • 광고 제거 (게임 제외)
   • AI 코칭 기본 모델
   • 리워드 광고 2배
   • 예산/목표 각 50회
   ```

4. **저장** 및 **활성화**

#### 2.3. Premium 구독 상품 생성

1. **구독 만들기** 클릭
2. 상품 세부정보 입력:
   - **제품 ID**: `money_app_premium_monthly` ⚠️ **정확히 일치해야 함**
   - **이름**: Premium 플랜
   - **설명**: 전체 광고 제거 및 프리미엄 AI 코칭

3. 가격 및 구독 기간:
   - **기본 기간**: 1개월
   - **가격**: ₩9,900

4. 혜택 설명:
   ```
   • 거래 추가 무제한
   • 전체 광고 제거
   • AI 코칭 프리미엄 모델
   • 리워드 광고 3배
   • 예산/목표 무제한
   • 게임 티켓 대기시간 5분
   ```

5. **저장** 및 **활성화**

### 3. 라이선스 테스터 추가

1. **수익 창출 설정** → **라이선스 테스터** 이동
2. 테스트용 Google 계정 이메일 추가
3. **저장**

⚠️ **주의**: 테스터 계정은 실제 결제가 발생하지 않습니다!

### 4. 결제 프로필 설정

1. **설정** → **결제 프로필** 이동
2. 판매자 계정 생성
3. 은행 계좌 및 세무 정보 입력
4. ⚠️ **이 설정이 완료되어야 실제 결제가 가능합니다**

---

## Flutter 앱 설정

### 1. 패키지 추가 (이미 완료)

`pubspec.yaml`에 이미 추가되어 있습니다:
```yaml
dependencies:
  in_app_purchase: ^3.2.0
```

### 2. iOS 권한 설정

`ios/Runner/Info.plist`에 다음 추가:
```xml
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>
```

### 3. Android 권한 설정

`android/app/src/main/AndroidManifest.xml`에 다음 추가:
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

### 4. 상품 ID 확인

`lib/core/services/in_app_purchase_service.dart` 파일에서 상품 ID 확인:
```dart
static const String proMonthlyProductId = 'money_app_pro_monthly';
static const String premiumMonthlyProductId = 'money_app_premium_monthly';
```

⚠️ **중요**: App Store Connect와 Google Play Console에서 설정한 Product ID와 정확히 일치해야 합니다!

### 5. 서비스 초기화

앱 시작 시 `InAppPurchaseService`를 초기화:
```dart
final iapService = InAppPurchaseService();
await iapService.initialize();
```

### 6. 구매 처리

구매 시작:
```dart
await iapService.buySubscription(
  InAppPurchaseService.proMonthlyProductId
);
```

구매 완료 콜백 설정:
```dart
iapService.onPurchaseCompleted = (purchaseDetails) {
  // Supabase에 구독 정보 저장
  // 사용자 요금제 업그레이드
};
```

---

## 테스트 방법

### iOS 테스트

1. **Xcode에서 앱 빌드**:
   ```bash
   flutter build ios
   open ios/Runner.xcworkspace
   ```

2. **실제 기기에 설치** (시뮬레이터는 인앱 결제 불가):
   - Xcode에서 실제 iPhone 선택
   - Run 버튼 클릭

3. **기기 설정**:
   - 설정 → App Store → Sandbox 계정
   - 기존 Apple ID 로그아웃
   - Sandbox 테스터 계정으로 로그인

4. **앱에서 구독 시도**:
   - Premium Dialog 열기
   - Pro 또는 Premium 선택
   - 구독하기 클릭
   - Sandbox 계정으로 로그인 (처음 한 번만)
   - 구매 확인

5. **구독 상태 확인**:
   - 설정 → Apple ID → 구독 → Sandbox 구독 확인

⚠️ **Sandbox 테스트 특징**:
- 실제 결제 발생하지 않음
- 구독 기간이 빠르게 갱신됨 (1개월 → 5분)
- 영수증은 실제와 다름

### Android 테스트

1. **내부 테스트 트랙 생성**:
   - Play Console → 테스트 → 내부 테스트
   - 새 버전 만들기
   - AAB 파일 업로드

2. **테스터 등록**:
   - 내부 테스트 → 테스터 관리
   - 이메일 목록 추가

3. **앱 다운로드**:
   - 테스터에게 Play Store 링크 전송
   - 내부 테스트 버전 설치

4. **앱에서 구독 시도**:
   - Premium Dialog 열기
   - Pro 또는 Premium 선택
   - 구독하기 클릭
   - Google 계정으로 로그인
   - "테스트 구매" 확인 (무료)

5. **구독 상태 확인**:
   - Play Store → 계정 → 결제 및 정기 결제 → 구독

⚠️ **내부 테스트 특징**:
- 실제 결제 발생하지 않음
- "테스트 구매" 메시지 표시
- 영수증은 실제와 동일

---

## 문제 해결

### iOS 문제

#### 1. "Cannot connect to iTunes Store" 에러
**원인**: Sandbox 계정 미설정
**해결**:
- 설정 → App Store → Sandbox 계정 설정
- 기존 Apple ID 로그아웃 필수

#### 2. "Product not found" 에러
**원인**: 상품 ID 불일치 또는 App Store Connect 미승인
**해결**:
- App Store Connect에서 상품 ID 확인
- 상품 상태가 "준비 완료"인지 확인
- 앱 코드의 Product ID와 일치하는지 확인

#### 3. 시뮬레이터에서 테스트 불가
**원인**: iOS 시뮬레이터는 인앱 결제 미지원
**해결**:
- 실제 iPhone 기기 사용

### Android 문제

#### 1. "Item unavailable" 에러
**원인**: Play Console에서 상품 미활성화
**해결**:
- Play Console → 수익 창출 → 구독
- 상품 상태 "활성화" 확인

#### 2. "This version of the application is not enabled for In-app Billing" 에러
**원인**: 내부 테스트 트랙 미설정
**해결**:
- Play Console → 테스트 → 내부 테스트
- AAB 파일 업로드 및 버전 출시

#### 3. 테스터 계정으로 구매 안 됨
**원인**: 테스터 목록 미등록
**해결**:
- Play Console → 라이선스 테스터 추가
- 내부 테스트 트랙 테스터 추가

---

## 체크리스트

### App Store Connect
- [ ] 자동 갱신 구독 그룹 생성
- [ ] Pro 구독 상품 생성 (`money_app_pro_monthly`)
- [ ] Premium 구독 상품 생성 (`money_app_premium_monthly`)
- [ ] Sandbox 테스터 계정 생성
- [ ] 계약 및 세무 정보 설정

### Google Play Console
- [ ] Pro 구독 상품 생성 (`money_app_pro_monthly`)
- [ ] Premium 구독 상품 생성 (`money_app_premium_monthly`)
- [ ] 라이선스 테스터 추가
- [ ] 결제 프로필 설정
- [ ] 내부 테스트 트랙 생성

### Flutter 앱
- [ ] `in_app_purchase` 패키지 추가 완료
- [ ] iOS 권한 설정 (`Info.plist`)
- [ ] Android 권한 설정 (`AndroidManifest.xml`)
- [ ] 상품 ID 확인 (코드와 스토어 일치)
- [ ] `InAppPurchaseService` 초기화 로직 구현
- [ ] 구매 완료 콜백 구현
- [ ] Supabase 구독 데이터 저장 로직 구현

### 테스트
- [ ] iOS Sandbox 테스트 완료
- [ ] Android 내부 테스트 완료
- [ ] 구매 복원 기능 테스트
- [ ] 구독 만료 시나리오 테스트

---

## 참고 자료

- [Flutter In-App Purchase 공식 문서](https://pub.dev/packages/in_app_purchase)
- [App Store Connect 가이드](https://developer.apple.com/app-store-connect/)
- [Google Play Billing 가이드](https://developer.android.com/google/play/billing)
- [Supabase 인증 문서](https://supabase.com/docs/guides/auth)

---

## 추가 작업 필요 사항

### 1. 영수증 검증 (서버 측)

현재는 클라이언트에서만 구매 처리를 하고 있습니다. **프로덕션 환경에서는 반드시 서버 측 영수증 검증이 필요합니다**:

- **iOS**: App Store Server API를 통한 영수증 검증
- **Android**: Google Play Developer API를 통한 영수증 검증

### 2. Supabase Edge Functions 구현

영수증 검증을 위한 Supabase Edge Function 생성:
```typescript
// supabase/functions/verify-purchase/index.ts
export async function handler(req: Request) {
  const { receipt, platform } = await req.json();

  if (platform === 'ios') {
    // App Store 영수증 검증
  } else if (platform === 'android') {
    // Google Play 영수증 검증
  }

  // 검증 성공 시 Supabase DB 업데이트
}
```

### 3. 구독 상태 동기화

- 앱 시작 시 구독 상태 확인
- 만료된 구독 자동 다운그레이드
- 구독 갱신 알림

### 4. 프로모션 코드

- App Store 프로모션 코드 설정
- Google Play 프로모션 코드 설정
- 앱 내 프로모션 코드 입력 UI

---

**Last Updated**: 2025-10-30
**Version**: 1.0.0
