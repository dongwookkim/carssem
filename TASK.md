# TASK: 카쎔 (CarSSEM) 개발 태스크

## Phase 1: MVP

### 1.1 프로젝트 초기 설정
- [ ] Flutter 프로젝트 생성
- [ ] 폴더 구조 설정 (feature-first 구조)
  ```
  lib/
  ├── core/
  │   ├── constants/
  │   ├── theme/
  │   ├── utils/
  │   └── widgets/
  ├── features/
  │   ├── auth/
  │   ├── car/
  │   ├── scan/
  │   ├── maintenance/
  │   ├── garage/
  │   └── profile/
  ├── models/
  ├── providers/
  ├── services/
  └── main.dart
  ```
- [ ] 필수 패키지 설치
  - [ ] supabase_flutter
  - [ ] flutter_riverpod
  - [ ] go_router
  - [ ] image_picker
  - [ ] cached_network_image
  - [ ] flutter_dotenv
  - [ ] intl
- [ ] 환경변수 설정 (.env)
  - [ ] SUPABASE_URL
  - [ ] SUPABASE_ANON_KEY
- [ ] Supabase 프로젝트 생성 및 연동
- [ ] 앱 테마 설정 (colors, typography)

### 1.2 Supabase 데이터베이스 및 Edge Function 설정
- [ ] users 테이블 생성
- [ ] cars 테이블 생성
- [ ] maintenance_records 테이블 생성
- [ ] maintenance_items 테이블 생성
- [ ] garages 테이블 생성
- [ ] reviews 테이블 생성
- [ ] RLS (Row Level Security) 정책 설정
- [ ] Storage bucket 생성 (receipts, cars, profiles)
- [ ] Edge Function 설정
  - [ ] Supabase CLI 설치
  - [ ] analyze-receipt 함수 생성
  - [ ] OPENAI_API_KEY 환경변수 설정 (Supabase Dashboard)
  - [ ] Edge Function 배포
  - [ ] 함수 호출 테스트

### 1.3 사용자 인증 기능
- [ ] AuthService 구현
  - [ ] 이메일 회원가입
  - [ ] 이메일 로그인
  - [ ] 로그아웃
  - [ ] 비밀번호 재설정
  - [ ] 세션 관리
- [ ] AuthProvider 구현 (Riverpod)
- [ ] 스플래시 화면 구현
- [ ] 로그인 화면 구현
- [ ] 회원가입 화면 구현
- [ ] 인증 상태에 따른 라우팅 처리

### 1.4 차량 관리 기능
- [ ] Car 모델 클래스 생성
- [ ] CarService 구현
  - [ ] 차량 등록 (Create)
  - [ ] 차량 목록 조회 (Read)
  - [ ] 차량 상세 조회 (Read)
  - [ ] 차량 정보 수정 (Update)
  - [ ] 차량 삭제 (Delete)
- [ ] CarProvider 구현
- [ ] 차량 목록 화면 구현
- [ ] 차량 등록/수정 화면 구현
- [ ] 차량 상세 화면 구현
- [ ] 차량 이미지 업로드 기능

### 1.5 명세서 스캔 및 AI 분석 기능
- [ ] ReceiptAnalysisService 구현
  - [ ] 이미지 Storage 업로드
  - [ ] Edge Function (analyze-receipt) 호출
  - [ ] JSON 응답 파싱 및 모델 변환
  - [ ] 에러 핸들링
- [ ] ImagePickerService 구현
  - [ ] 카메라 촬영
  - [ ] 갤러리 선택
- [ ] ScanProvider 구현
- [ ] 스캔 화면 구현
  - [ ] 카메라/갤러리 선택 UI
  - [ ] 이미지 미리보기
  - [ ] 분석 중 로딩 UI
- [ ] 분석 결과 화면 구현
  - [ ] 분석 결과 표시
  - [ ] 결과 수정 기능
  - [ ] 차량 선택 기능
  - [ ] 저장 버튼

### 1.6 정비 이력 관리 기능
- [ ] MaintenanceRecord 모델 클래스 생성
- [ ] MaintenanceItem 모델 클래스 생성
- [ ] MaintenanceService 구현
  - [ ] 정비 이력 저장
  - [ ] 차량별 이력 조회
  - [ ] 이력 상세 조회
  - [ ] 이력 삭제
- [ ] MaintenanceProvider 구현
- [ ] 정비 이력 목록 화면 구현
  - [ ] 차량 필터
  - [ ] 날짜순 정렬
  - [ ] 이력 카드 UI
- [ ] 정비 이력 상세 화면 구현
  - [ ] 정비 항목 목록
  - [ ] 명세서 이미지 보기
  - [ ] 삭제 기능

### 1.7 홈 화면 구현
- [ ] 내 차량 요약 카드
- [ ] 최근 정비 이력 목록
- [ ] 빠른 스캔 버튼
- [ ] 바텀 네비게이션 구현

---

## Phase 2: 정비소 기능

### 2.1 정비소 관리 기능
- [ ] Garage 모델 클래스 생성
- [ ] GarageService 구현
  - [ ] 정비소 등록
  - [ ] 정비소 검색 (이름, 주소)
  - [ ] 정비소 상세 조회
  - [ ] 정비소 목록 조회
- [ ] GarageProvider 구현
- [ ] 정비소 목록 화면 구현
  - [ ] 검색 기능
  - [ ] 평점순/리뷰순 정렬
- [ ] 정비소 상세 화면 구현
  - [ ] 기본 정보 표시
  - [ ] 평균 평점 표시
  - [ ] 리뷰 목록

### 2.2 리뷰 및 평점 기능
- [ ] Review 모델 클래스 생성
- [ ] ReviewService 구현
  - [ ] 리뷰 작성
  - [ ] 리뷰 수정
  - [ ] 리뷰 삭제
  - [ ] 정비소별 리뷰 조회
  - [ ] 평균 평점 계산 (DB trigger 또는 함수)
- [ ] ReviewProvider 구현
- [ ] 리뷰 작성 화면 구현
  - [ ] 별점 선택 UI
  - [ ] 리뷰 텍스트 입력
  - [ ] 정비 이력 연결 (선택)
- [ ] 리뷰 목록 컴포넌트 구현

---

## Phase 3: 고도화

### 3.1 UI/UX 개선
- [ ] 로딩 스켈레톤 UI 추가
- [ ] 에러 핸들링 및 에러 화면
- [ ] 빈 상태 화면 (Empty State)
- [ ] 애니메이션 추가
- [ ] 다크모드 지원
- [ ] 반응형 레이아웃 개선

### 3.2 마이페이지 기능
- [ ] 프로필 조회/수정 화면
- [ ] 프로필 이미지 업로드
- [ ] 내 차량 관리 바로가기
- [ ] 내가 작성한 리뷰 목록
- [ ] 설정 화면
  - [ ] 알림 설정
  - [ ] 로그아웃
  - [ ] 회원탈퇴
  - [ ] 앱 버전 정보

### 3.3 통계 대시보드
- [ ] 월별 정비 비용 차트
- [ ] 정비 항목별 비용 분석
- [ ] 차량별 총 정비 비용
- [ ] 정비 주기 분석

### 3.4 알림 기능 (v1.1)
- [ ] 로컬 알림 설정
- [ ] 정기 정비 알림 등록
  - [ ] 엔진오일 교체
  - [ ] 타이어 교체
  - [ ] 브레이크 패드 등
- [ ] 주행거리 기반 알림
- [ ] 알림 목록 화면

### 3.5 배포 준비
- [ ] 앱 아이콘 및 스플래시 이미지 적용
- [ ] iOS 배포 설정
  - [ ] Bundle ID 설정
  - [ ] 인증서 및 프로비저닝 프로파일
  - [ ] App Store Connect 등록
- [ ] Android 배포 설정
  - [ ] 키스토어 생성
  - [ ] Google Play Console 등록
- [ ] 개인정보처리방침 작성
- [ ] 이용약관 작성

---

## 추가 태스크 (Backlog)

### 소셜 로그인
- [ ] Google 로그인 연동
- [ ] Apple 로그인 연동

### 지도 기능
- [ ] 정비소 지도 표시
- [ ] 현재 위치 기반 주변 정비소

### 정비소 예약 (v2.0)
- [ ] 예약 시스템 설계
- [ ] 예약 화면 구현

### 커뮤니티 (v2.0)
- [ ] 게시판 기능
- [ ] 댓글 기능

---

## 진행 상황

| Phase | 진행률 | 상태 |
|-------|--------|------|
| Phase 1: MVP | 0% | 대기 |
| Phase 2: 정비소 | 0% | 대기 |
| Phase 3: 고도화 | 0% | 대기 |

---

## 참고 사항

- 각 태스크 완료 시 `[ ]`를 `[x]`로 변경
- 이슈 발생 시 태스크 하단에 메모 추가
- 우선순위 변경 시 태스크 순서 조정
