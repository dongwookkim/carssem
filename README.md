# 카쎔 (CarSSEM)

AI 기반 자동차 정비 관리 앱

정비소에서 받은 명세서를 촬영하면 AI가 자동으로 분석하여 차량별 정비 이력을 관리하고, 정비소를 평가할 수 있습니다.

## 주요 기능

- **명세서 스캔 & AI 분석**: 카메라로 촬영하면 GPT-4 Vision이 자동으로 항목 추출
- **차량 관리**: 여러 차량 등록 및 차량별 정비 이력 관리
- **정비 이력**: 날짜, 정비소, 비용, 항목별 상세 기록
- **정비소 평가**: 별점 및 리뷰 시스템

## 기술 스택

| 영역 | 기술 |
|------|------|
| Frontend | Flutter (iOS/Android) |
| Backend | Supabase (PostgreSQL, Auth, Storage) |
| Serverless | Supabase Edge Functions |
| AI | OpenAI GPT-4 Vision API |
| 상태관리 | Riverpod |

## 프로젝트 구조

```
lib/
├── core/
│   ├── constants/      # 앱 상수
│   ├── router/         # GoRouter 설정
│   ├── theme/          # 테마, 색상
│   └── widgets/        # 공통 위젯
├── features/
│   ├── auth/           # 로그인, 회원가입
│   ├── car/            # 차량 관리
│   ├── home/           # 홈 화면
│   ├── maintenance/    # 정비 이력
│   ├── profile/        # 마이페이지
│   └── scan/           # 명세서 스캔
├── models/             # 데이터 모델
├── providers/          # Riverpod Provider
├── services/           # API 서비스
└── main.dart
```

## 시작하기

### 1. 환경 설정

```bash
# 저장소 클론
git clone <repository-url>
cd carssem/src/app

# 의존성 설치
flutter pub get
```

### 2. 환경변수 설정

`.env` 파일 생성:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 3. Supabase 설정

1. [Supabase](https://supabase.com)에서 새 프로젝트 생성
2. SQL Editor에서 마이그레이션 실행:
   - `supabase/migrations/001_initial_schema.sql`
   - `supabase/migrations/002_storage_policies.sql`

### 4. Edge Function 배포

```bash
# Supabase CLI 설치
npm install -g supabase

# 로그인 및 프로젝트 연결
supabase login
supabase link --project-ref YOUR_PROJECT_REF

# OpenAI API 키 설정
supabase secrets set OPENAI_API_KEY=your-openai-key

# Edge Function 배포
supabase functions deploy analyze-receipt
```

### 5. 앱 실행

```bash
# iOS
flutter run -d iPhone

# Android
flutter run -d android
```

## 스크린샷

| 홈 | 스캔 | 분석 결과 | 정비 이력 |
|:--:|:--:|:--:|:--:|
| 차량 목록 | 명세서 촬영 | AI 분석 | 이력 관리 |

## API 흐름

```
1. 사용자: 명세서 촬영
2. 앱 → Supabase Storage: 이미지 업로드
3. 앱 → Edge Function: 분석 요청
4. Edge Function → OpenAI: GPT-4 Vision 호출
5. OpenAI → Edge Function → 앱: 분석 결과 반환
6. 앱 → Supabase DB: 정비 이력 저장
```

## 데이터 모델

- `users` - 사용자 정보
- `cars` - 차량 정보
- `maintenance_records` - 정비 이력
- `maintenance_items` - 정비 항목 상세
- `garages` - 정비소 정보
- `reviews` - 정비소 리뷰

## 라이선스

MIT License
