# Google Play Store 배포 가이드

이 문서는 카쎔(carssem) 앱을 Google Play Store에 배포하기 위한 절차를 정리합니다.

## 0. 사전 준비 사항

- [ ] Google Play Console 개발자 계정 등록 ($25, 일회성)
  - https://play.google.com/console/signup
  - 신원 인증(여권/신분증) 및 D-U-N-S 번호(법인의 경우) 필요
- [ ] 개인정보처리방침 URL 호스팅 (Play Console 등록 필수)
  - 현재 앱 내 `lib/features/profile/screens/terms_screen.dart` 내용을 정적 페이지로 게시 권장
  - GitHub Pages, Notion 공개 페이지, 자체 도메인 등 어디든 가능
- [ ] 스토어 등록용 자산 준비
  - 앱 아이콘 512×512 PNG (이미 `assets/icon/icon.png` 존재)
  - 피처 그래픽 1024×500 PNG
  - 스크린샷 최소 2장(폰), 권장 8장 (1080×1920 또는 그 이상)
  - 짧은 설명 (80자 이내), 상세 설명 (4000자 이내)

## 1. 릴리스 키스토어 생성 (최초 1회)

> ⚠️ **중요**: 키스토어를 분실하면 앱 업데이트가 영원히 불가능합니다. 안전한 곳(1Password, iCloud Drive 등)에 백업하세요.

```bash
keytool -genkey -v -keystore ~/carssem-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

비밀번호와 정보를 입력하면 `~/carssem-upload-keystore.jks` 파일이 생성됩니다.

## 2. key.properties 설정

프로젝트 루트의 `android/key.properties` 파일을 다음 내용으로 생성하세요 (이미 `.gitignore`에 등록되어 있음):

```properties
storePassword=<keystore 생성 시 입력한 store 비밀번호>
keyPassword=<keystore 생성 시 입력한 key 비밀번호>
keyAlias=upload
storeFile=/Users/moon/carssem-upload-keystore.jks
```

`storeFile`은 절대 경로 또는 `android/` 디렉토리 기준 상대 경로 모두 가능합니다.

## 3. 버전 관리

배포할 때마다 `pubspec.yaml`의 `version` 값을 올리세요:

```yaml
version: 1.0.0+1   # versionName+versionCode
                   # versionCode는 매 업로드마다 반드시 증가해야 함
```

## 4. App Bundle 빌드

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

빌드 결과: `build/app/outputs/bundle/release/app-release.aab`

## 5. Play Console 업로드

1. Play Console → 앱 만들기 → 이름/언어/카테고리 입력
2. **앱 콘텐츠** 메뉴에서 모두 작성:
   - 개인정보처리방침 URL
   - 광고 포함 여부 (없음)
   - 앱 액세스 권한 (테스트 계정 정보 — 비회원이 자동 로그인되므로 "특별한 액세스 불필요")
   - 콘텐츠 등급 설문 (생활/도구 카테고리)
   - 타겟 사용자층 (모든 연령)
   - **데이터 안전 섹션** (아래 "데이터 안전 폼" 참조)
3. **프로덕션** → **새 버전 만들기** → `app-release.aab` 업로드
4. 출시 노트 작성 → 검토 → 출시

## 6. 데이터 안전(Data Safety) 폼 입력 가이드

| 항목 | 답변 |
|---|---|
| 데이터 수집 | 예 |
| 위치(대략적) | 수집함, 선택적, 정비소 검색용 |
| 사진 및 동영상 | 수집함, 필수, 영수증 분석용 |
| 기기 ID | 수집함, 필수, 비회원 인증용 |
| 데이터 암호화 전송 | 예 (HTTPS) |
| 사용자 데이터 삭제 요청 | 예 (앱 내 회원 탈퇴 기능 있음) |

## 7. 첫 배포 시 권장 흐름

1. **내부 테스트** 트랙으로 먼저 업로드 (검토 없이 즉시 사용 가능, 본인 계정으로 설치 후 동작 확인)
2. 이상 없으면 **프로덕션**으로 승격

## 8. 보안 주의사항 — `.env` 번들링

현재 `pubspec.yaml:82`에 `.env` 파일이 assets로 번들링되고 있습니다. APK/AAB는 압축 해제하면 `.env` 내용을 그대로 추출할 수 있어, **SUPABASE_ANON_KEY, KAKAO_REST_API_KEY 등이 사실상 공개됩니다**.

**위험도 평가:**
- `SUPABASE_ANON_KEY`: anon 키는 본래 공개를 전제로 하며, RLS 정책으로 보호되므로 **수용 가능**
- `KAKAO_REST_API_KEY`: 카카오 개발자 콘솔에서 호출 도메인/패키지 화이트리스트로 제한 가능 → **권장**
- `OPENAI_API_KEY`: 클라이언트가 직접 호출하지 않고 Supabase Edge Function에서만 사용하므로 `.env`에 포함되지 않아야 함 (확인 필요)

**권장 조치:**
1. `.env`에 `OPENAI_API_KEY` 등 서버 전용 키가 포함되어 있지 않은지 확인
2. Kakao API 키는 Android 패키지명(`com.carssem.carssem`) 화이트리스트 등록
3. 장기적으로 `--dart-define` 또는 `--dart-define-from-file`로 빌드 시점 주입 방식으로 마이그레이션

## 9. 적용된 자동 변경 사항 (참고)

이 가이드 작성 과정에서 다음 코드 변경이 이미 반영되었습니다:

- `android/app/src/main/AndroidManifest.xml`: `INTERNET` 권한 추가, `android:label`을 "카쎔"으로 변경
- `android/app/build.gradle.kts`: release 서명 설정 + R8/ProGuard 활성화 (`isMinifyEnabled = true`, `isShrinkResources = true`)
- `android/app/proguard-rules.pro`: Flutter/Supabase/플러그인용 keep 규칙 추가

## 10. 배포 후 체크리스트

- [ ] Play Console에서 ANR/충돌 모니터링 (출시 후 24시간)
- [ ] Supabase 대시보드에서 트래픽/에러 로그 확인
- [ ] 사용자 리뷰 응답 정책 결정
