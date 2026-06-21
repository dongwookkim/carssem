---
name: store-release
description: 카쎔(CarSSEM) 앱의 앱스토어/구글플레이 배포용 릴리스 빌드를 만든다. 버전 올리기, 서명 확인, Android App Bundle(.aab)·iOS IPA 빌드, 배포 후 체크리스트(데이터 보안 선언, 강제 업데이트 DB)를 포함한다. "배포 빌드", "스토어 빌드", "릴리스 빌드", "appbundle/ipa 빌드", "버전 올려서 빌드" 같은 요청에 사용한다.
---

# 스토어 배포 빌드 (CarSSEM)

카쎔 Flutter 앱의 Google Play / App Store 배포용 릴리스 빌드를 안전하게 만드는 절차다.
별도 지정이 없으면 **Google Play(Android)** 를 기본으로 한다. "앱스토어/iOS"라고 하면 iOS 절차를 사용한다.

## 0. 사전 점검 (빌드 전 항상 확인)

```bash
# 현재 버전 확인
grep -nE "^version:" pubspec.yaml

# Android 릴리스 서명 설정 존재 확인 (없으면 디버그 키로 서명되어 업로드 거부됨)
ls -la android/key.properties

# 키스토어/서명 정보가 저장소에 커밋되지 않았는지 확인 (유출 방지)
git ls-files | grep -iE "key.properties|\.jks|\.keystore"   # 출력이 있으면 경고할 것

# .env 존재 확인 (SUPABASE_URL/ANON_KEY 등 런타임 설정)
ls -la .env
```

- `android/key.properties`가 없으면 **빌드를 멈추고** 사용자에게 알린다 (서명 불가 → 업로드 거부).
- 위 `git ls-files` 결과에 키스토어/`key.properties`가 나오면 **유출 위험**을 경고한다.

## 1. 버전 올리기

`pubspec.yaml`의 `version: X.Y.Z+N`을 수정한다.

- **버전명(X.Y.Z)**: 버그 수정 릴리스면 patch(+0.0.1), 기능 추가면 minor를 올린다.
- **빌드 넘버(+N)**: Play/App Store는 **항상 직전보다 큰 값**이어야 한다. 반드시 +1 이상 증가시킨다.
- 강제 업데이트는 빌드 넘버가 아니라 **버전명(semver)** 으로 판정된다 (`app_version_service.dart`). 강제 업데이트를 걸 거면 버전명을 반드시 올린다.

예: `1.0.0+3` → 버그 수정 → `1.0.1+4`

## 2. 빌드

### Android (Google Play) — 기본

```bash
flutter build appbundle --release
```

- 산출물: `build/app/outputs/bundle/release/app-release.aab`
- 빌드 로그 끝에 `✓ Built ... app-release.aab` 와 키스토어 서명 적용 여부를 확인한다.
- 빌드 후 `ls -la build/app/outputs/bundle/release/app-release.aab` 로 생성 시각/크기를 확인해 최신 빌드인지 검증한다.

### iOS (App Store)

```bash
flutter build ipa --release
```

- 산출물: `build/ios/ipa/*.ipa`
- 이후 Xcode `Transporter` 또는 `xcrun altool`/`Apple Transporter` 앱으로 업로드.

## 3. 빌드 후 보고 & 체크리스트

빌드 완료 후 사용자에게 다음을 정리해 알린다.

1. **산출물 경로 + 버전(versionName/versionCode) + 빌드 시각.**
2. **이번 릴리스에 포함된 주요 변경 요약.**
3. **업로드 방법**: Play Console → 프로덕션(또는 내부 테스트) → 새 버전 만들기 → `.aab` 업로드.

### 강제 업데이트를 걸 경우 (요청 시)

`app_versions` 테이블의 `min_supported_version`을 이번 버전명으로 올린다.

```sql
update public.app_versions
set min_supported_version = '<이번 버전명>',
    update_message = '안정성 개선을 위해 최신 버전으로 업데이트가 필요합니다.'
where platform = 'android';   -- iOS면 'ios'
```

⚠️ **반드시 새 버전이 스토어에 실제 게시(전체 사용자 제공)된 뒤 실행**한다. 게시 전에 올리면 사용자가 받을 버전이 없는데 강제 업데이트 화면에 갇힌다.

### Play Console 데이터 보안(Data safety) 경고가 뜨면

코드 문제가 아니라 콘솔 설문 미작성이다. 이 앱이 기기 밖으로 전송하는 데이터:

| Play 분류 | 무엇 | 비고 |
|---|---|---|
| 기기 또는 기타 ID | `ANDROID_ID`(디바이스 계정) | 수집·저장, 계정 관리 |
| 사진 및 동영상 | 영수증·차량·프로필 사진 | 수집·저장 (영수증은 OpenAI로 OCR 처리) |
| 개인 정보 → 이름 | 프로필 이름 | 수집·저장(선택) |
| 앱 활동 → 사용자 생성 콘텐츠 | 정비 기록·리뷰 | 수집·저장 |

- 공통: 전송 중 암호화=예(HTTPS), 사용자 삭제 요청 가능=예(앱에 회원탈퇴 기능 있음).
- 위치는 기기 안에서만 사용(서버 미전송) → **"수집 안 함"**.
- 실제 이메일/결제 정보는 수집 안 함(디바이스 계정은 합성 이메일).
- 개인정보처리방침 URL 필수.

## 참고: 프로젝트 고정값

- Android 패키지명 / applicationId: `com.carssem.app`
- 강제 업데이트 판정: `lib/services/app_version_service.dart` (`app_versions` 테이블, semver 비교, 빌드 넘버 무시)
- 디바이스 인증: `lib/services/device_service.dart` (Android=ANDROID_ID, iOS=identifierForVendor)
