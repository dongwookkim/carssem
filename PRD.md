# PRD: 카쎔 (CarSSEM) - AI 자동차 정비 관리 앱

## 1. 제품 개요

**제품명:** 카쎔 (CarSSEM)
**버전:** 1.0
**작성일:** 2025-01-25

정비소에서 받은 정비 명세서를 촬영하면 AI가 자동으로 분석하여 차량별 정비 이력을 관리하고, 정비소를 평가할 수 있는 모바일 앱입니다.

---

## 2. 문제 정의

- 종이 정비 명세서는 분실되기 쉽고 관리가 어려움
- 정비 이력을 체계적으로 추적하기 어려움
- 정비소의 서비스 품질을 객관적으로 비교하기 어려움
- 다음 정비 시기를 놓치는 경우가 많음

---

## 3. 목표

1. 정비 명세서 촬영 → AI 자동 분석 → 데이터 저장 자동화
2. 차량별 정비 이력 통합 관리
3. 정비소 리뷰 및 평점 시스템 구축
4. 정비 알림 기능 제공

---

## 4. 기술 스택

| 영역 | 기술 |
|------|------|
| Frontend | Flutter (iOS/Android) |
| Backend/DB | Supabase (PostgreSQL, Auth, Storage) |
| Serverless | Supabase Edge Functions (Deno) |
| AI 분석 | OpenAI GPT-4 Vision API |
| 상태관리 | Riverpod |
| 로컬 저장소 | Hive / SharedPreferences |

---

## 5. 핵심 기능

### 5.1 사용자 인증
- 이메일/비밀번호 로그인
- 소셜 로그인 (Google, Apple)
- 프로필 관리

### 5.2 차량 관리
- 차량 등록 (차종, 연식, 번호판, 주행거리)
- 여러 차량 등록 가능
- 차량별 상세 정보 조회

### 5.3 정비 명세서 스캔 및 분석
- 카메라로 명세서 촬영
- 갤러리에서 이미지 선택
- GPT-4 Vision으로 명세서 분석
  - 정비 일자
  - 정비소 정보
  - 정비 항목 (부품, 공임)
  - 금액
  - 주행거리
- 분석 결과 확인 및 수정
- 정비 이력으로 저장

### 5.4 정비 이력 관리
- 차량별 정비 이력 목록
- 정비 상세 내역 조회
- 정비 항목별 필터링
- 총 정비 비용 통계

### 5.5 정비소 평가
- 정비소 검색
- 별점 (1-5점) 및 리뷰 작성
- 정비소별 평균 평점
- 리뷰 목록 조회

### 5.6 알림 (v1.1)
- 정기 정비 알림 (엔진오일, 타이어 등)
- 주행거리 기반 알림

---

## 6. 화면 구성

```
├── 스플래시
├── 로그인 / 회원가입
├── 메인 (바텀 네비게이션)
│   ├── 홈
│   │   ├── 내 차량 목록
│   │   └── 최근 정비 요약
│   ├── 스캔
│   │   ├── 카메라 촬영
│   │   ├── AI 분석 중
│   │   └── 분석 결과 확인/수정
│   ├── 정비 이력
│   │   ├── 차량 선택
│   │   ├── 이력 목록
│   │   └── 이력 상세
│   ├── 정비소
│   │   ├── 정비소 목록
│   │   ├── 정비소 상세
│   │   └── 리뷰 작성
│   └── 마이페이지
│       ├── 프로필 수정
│       ├── 차량 관리
│       └── 설정
```

---

## 7. 데이터 모델

### users
```sql
id: uuid (PK)
email: text
name: text
profile_image: text
created_at: timestamp
```

### cars
```sql
id: uuid (PK)
user_id: uuid (FK)
brand: text
model: text
year: integer
license_plate: text
current_mileage: integer
image: text
created_at: timestamp
```

### maintenance_records
```sql
id: uuid (PK)
car_id: uuid (FK)
garage_id: uuid (FK, nullable)
date: date
mileage: integer
total_cost: integer
receipt_image: text
created_at: timestamp
```

### maintenance_items
```sql
id: uuid (PK)
record_id: uuid (FK)
category: text (부품/공임/기타)
name: text
quantity: integer
unit_price: integer
total_price: integer
```

### garages
```sql
id: uuid (PK)
name: text
address: text
phone: text
latitude: float
longitude: float
average_rating: float
review_count: integer
created_at: timestamp
```

### reviews
```sql
id: uuid (PK)
garage_id: uuid (FK)
user_id: uuid (FK)
record_id: uuid (FK, nullable)
rating: integer (1-5)
content: text
created_at: timestamp
```

---

## 8. API 설계

### AI 분석 Flow (Edge Function 활용)
```
1. 클라이언트: 이미지 촬영
2. 클라이언트 → Supabase Storage: 이미지 업로드
3. 클라이언트 → Supabase Edge Function: 분석 요청 (이미지 URL 전달)
4. Edge Function → OpenAI API: GPT-4 Vision 호출
5. OpenAI → Edge Function: 분석 결과 반환
6. Edge Function → 클라이언트: 정제된 JSON 응답
7. 클라이언트 → Supabase DB: 정비 이력 저장
```

### Edge Function: analyze-receipt
```typescript
// supabase/functions/analyze-receipt/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { imageUrl } = await req.json()

  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${Deno.env.get("OPENAI_API_KEY")}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "gpt-4-vision-preview",
      messages: [{
        role: "user",
        content: [
          { type: "text", text: `이 자동차 정비 명세서 이미지를 분석해주세요.
다음 JSON 형식으로 응답해주세요:
{
  "date": "YYYY-MM-DD",
  "garage_name": "정비소명",
  "garage_address": "주소",
  "mileage": 숫자,
  "items": [
    {
      "category": "부품|공임|기타",
      "name": "항목명",
      "quantity": 숫자,
      "unit_price": 숫자,
      "total_price": 숫자
    }
  ],
  "total_cost": 숫자
}` },
          { type: "image_url", image_url: { url: imageUrl } }
        ]
      }],
      max_tokens: 1000,
    }),
  })

  const data = await response.json()
  const content = data.choices[0].message.content

  // JSON 파싱 후 반환
  const result = JSON.parse(content)
  return new Response(JSON.stringify(result), {
    headers: { "Content-Type": "application/json" }
  })
})
```

### Flutter에서 Edge Function 호출
```dart
final response = await Supabase.instance.client.functions
    .invoke('analyze-receipt', body: {'imageUrl': uploadedImageUrl});

final analysisResult = response.data as Map<String, dynamic>;
```

---

## 9. 보안 고려사항

- Supabase RLS (Row Level Security) 적용
- 사용자별 데이터 격리
- OpenAI API 키는 Edge Function 환경변수로 서버에서만 관리 (클라이언트 노출 없음)
- 이미지는 private bucket에 저장
- Edge Function은 인증된 사용자만 호출 가능하도록 설정

---

## 10. 개발 마일스톤

### Phase 1: MVP (2주)
- [ ] 프로젝트 셋업 (Flutter + Supabase)
- [ ] 사용자 인증
- [ ] 차량 CRUD
- [ ] 명세서 촬영 및 AI 분석
- [ ] 정비 이력 저장/조회

### Phase 2: 정비소 기능 (1주)
- [ ] 정비소 등록/검색
- [ ] 리뷰 및 평점 시스템

### Phase 3: 고도화 (1주)
- [ ] UI/UX 개선
- [ ] 통계 대시보드
- [ ] 정비 알림 기능
- [ ] 앱스토어 배포

---

## 11. 성공 지표

- MAU (월간 활성 사용자)
- 정비 명세서 스캔 횟수
- AI 분석 정확도 (사용자 수정 비율)
- 정비소 리뷰 작성률
- 앱스토어 평점

---

## 12. 향후 확장 계획

- 정비소 예약 기능
- 차량 소모품 가격 비교
- 중고차 거래 시 정비 이력 공유
- 커뮤니티 기능
