# 몬트(Mont) 앱 아이콘 설정 가이드

## 📱 현재 상태

Flutter 앱 아이콘 설정이 준비되었습니다!

### 필요한 파일:
1. `assets/images/mont_icon.png` (1024x1024) - 메인 아이콘
2. `assets/images/mont_icon_foreground.png` (1024x1024) - Android Adaptive 아이콘용

---

## 🎨 방법 1: 제공된 SVG 사용

이미 생성된 SVG 파일이 있습니다:
- `assets/images/mont_logo.svg`
- `assets/images/mont_logo_minimal.svg`

### SVG → PNG 변환:

#### 온라인 변환 (추천)
1. https://svgtopng.com/ 접속
2. SVG 파일 업로드
3. Width: 1024px 설정
4. PNG 다운로드
5. `assets/images/mont_icon.png`로 저장

#### Figma/Sketch 사용
1. SVG 파일 열기
2. Export → PNG
3. Scale: 1x (1024x1024)
4. 저장

---

## 🤖 방법 2: AI 이미지 생성

`docs/ai_logo_generation_prompts.md` 파일의 프롬프트를 사용하세요!

### 추천 프롬프트:
```
A minimalist app icon for a finance management app called "Mont".
Clean design with a stylized "M" shape that resembles mountain peaks.
Teal gradient background (#14B8A6 to #0D9488).
White line art symbol in the center.
Modern, professional, iOS app icon style.
Rounded corners.
Flat design, no shadows, no 3D effects.
Ultra minimal, Claude AI app style.
--ar 1:1 --v 6 --style raw
```

### 생성 사이트:
- **ChatGPT Plus** (DALL-E 3): https://chat.openai.com/
- **Midjourney**: https://midjourney.com/
- **Adobe Firefly**: https://firefly.adobe.com/
- **Leonardo.ai**: https://leonardo.ai/

생성 후:
1. 1024x1024 PNG로 다운로드
2. `assets/images/mont_icon.png`로 저장

---

## 🎨 방법 3: 디자인 툴 직접 제작

`docs/logo_design_spec.md` 파일의 스펙을 참고하세요!

### Figma 사용:
1. 새 파일: 1024x1024
2. 배경 사각형 + Teal 그라데이션
3. Corner Radius: 227px
4. M자 산 모양 그리기 (Pen Tool)
5. Export → PNG

### Canva 사용:
1. Custom size: 1024x1024
2. Elements → Shapes
3. Teal 그라데이션 배경
4. Lines로 M자 그리기
5. Download PNG

---

## 📱 Android Adaptive 아이콘 (선택사항)

Android에서 다양한 모양(원형, 사각형 등)으로 표시되는 아이콘입니다.

### 방법 1: 동일한 아이콘 사용
```bash
# mont_icon.png를 복사
cp assets/images/mont_icon.png assets/images/mont_icon_foreground.png
```

### 방법 2: Foreground 전용 제작
배경 없이 흰색 M 심볼만 있는 버전:
- 배경: 투명
- 심볼: 흰색 M
- 크기: 1024x1024
- 여백: 충분히 (200px 이상)

---

## 🚀 아이콘 적용하기

### 1. 패키지 설치
```bash
cd /Users/t2023-m0013/Documents/MyProject/money_app
flutter pub get
```

### 2. 아이콘 파일 준비
다음 파일들이 필요합니다:
- ✅ `assets/images/mont_icon.png` (1024x1024)
- ✅ `assets/images/mont_icon_foreground.png` (1024x1024, 선택사항)

### 3. 아이콘 생성
```bash
dart run flutter_launcher_icons
```

### 4. 확인
```bash
# iOS
open ios/Runner/Assets.xcassets/AppIcon.appiconset/

# Android
ls android/app/src/main/res/mipmap-*/
```

### 5. 앱 재빌드
```bash
# iOS
flutter build ios

# Android
flutter build apk
```

---

## ✅ 체크리스트

### 아이콘 제작
- [ ] 1024x1024 PNG 생성
- [ ] Teal 그라데이션 배경
- [ ] 흰색 M 심볼
- [ ] 둥근 모서리 (227px)
- [ ] 작은 크기에서도 선명

### 파일 저장
- [ ] `assets/images/mont_icon.png` 저장
- [ ] (선택) `assets/images/mont_icon_foreground.png` 저장
- [ ] 파일 크기 확인 (1024x1024)

### Flutter 설정
- [ ] `flutter pub get` 실행
- [ ] `dart run flutter_launcher_icons` 실행
- [ ] 생성된 아이콘 파일 확인
- [ ] 실제 기기에서 테스트

---

## 🎯 빠른 시작 (임시 아이콘)

일단 빨리 진행하고 싶다면:

1. **SVG를 PNG로 변환**:
   ```bash
   # SVG 파일이 있으므로 온라인 변환기 사용
   # https://svgtopng.com/
   ```

2. **저장**:
   ```bash
   # assets/images/mont_icon.png로 저장
   ```

3. **생성**:
   ```bash
   flutter pub get
   dart run flutter_launcher_icons
   ```

4. **완료!**

나중에 더 나은 디자인으로 교체 가능합니다!

---

## 🔄 아이콘 변경하기

언제든지 아이콘을 변경할 수 있습니다:

1. 새 PNG 파일 준비 (1024x1024)
2. `assets/images/mont_icon.png` 교체
3. `dart run flutter_launcher_icons` 재실행
4. 앱 재빌드

---

## 💡 참고 자료

- **SVG 로고**: `assets/images/mont_logo.svg`
- **디자인 스펙**: `docs/logo_design_spec.md`
- **AI 프롬프트**: `docs/ai_logo_generation_prompts.md`
- **Flutter Launcher Icons**: https://pub.dev/packages/flutter_launcher_icons

---

**준비되면 알려주세요!** 🚀
