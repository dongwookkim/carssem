-- maintenance_items 테이블에 system, description, role, reason 컬럼 추가
ALTER TABLE maintenance_items ADD COLUMN IF NOT EXISTS system TEXT;
ALTER TABLE maintenance_items ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE maintenance_items ADD COLUMN IF NOT EXISTS role TEXT;
ALTER TABLE maintenance_items ADD COLUMN IF NOT EXISTS reason TEXT;

-- 시스템별 표준 작업 단계 테이블
CREATE TABLE IF NOT EXISTS system_work_steps (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  system TEXT NOT NULL,
  step_order INT NOT NULL,
  title TEXT NOT NULL,
  sub_steps TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(system, step_order)
);

-- RLS 활성화 (읽기 전용 공개 데이터)
ALTER TABLE system_work_steps ENABLE ROW LEVEL SECURITY;
CREATE POLICY "system_work_steps_read" ON system_work_steps
  FOR SELECT USING (true);

-- 초기 데이터: 14개 시스템 분류별 표준 작업 단계
-- 01. 엔진·연료·흡기 정비
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('엔진·연료·흡기 정비', 1, '차량 점검 및 진단', ARRAY['엔진룸 외관 점검', '오일 레벨 및 상태 확인', '연료 계통 누유 점검']),
('엔진·연료·흡기 정비', 2, '엔진 오일 및 필터 교체', ARRAY['엔진 오일 드레인 플러그 분리', '폐유 배출', '오일 필터 교체', '신품 오일 주입']),
('엔진·연료·흡기 정비', 3, '연료 필터 및 흡기 계통 정비', ARRAY['연료 필터 교체', '에어 필터 교체', '흡기 매니폴드 점검 및 청소']),
('엔진·연료·흡기 정비', 4, '인젝터 및 연료 펌프 점검', ARRAY['인젝터 분사 패턴 점검', '연료 펌프 압력 확인', '연료 라인 누유 점검']),
('엔진·연료·흡기 정비', 5, '조립 및 시동 테스트', ARRAY['분리 부품 재조립', '오일 레벨 최종 확인', '시동 후 누유 점검', '공회전 상태 확인']);

-- 02. 브레이크 시스템 정비
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('브레이크 시스템 정비', 1, '차량 고정 및 휠 탈거', ARRAY['차량 리프트 상승', '앞·뒤 휠 분리', '브레이크 계통 외관 점검']),
('브레이크 시스템 정비', 2, '브레이크 패드 탈거 및 점검', ARRAY['캘리퍼 분리', '기존 패드 마모 상태 확인', '디스크 손상 여부 점검']),
('브레이크 시스템 정비', 3, '브레이크 디스크 교체', ARRAY['기존 디스크 분리', '허브 접촉면 정리', '새 디스크 장착 및 고정']),
('브레이크 시스템 정비', 4, '브레이크 패드 신품 장착', ARRAY['신품 패드 장착', '캘리퍼 복원', '작동 상태 확인']),
('브레이크 시스템 정비', 5, '브레이크 오일 교환', ARRAY['기존 브레이크 오일 배출', 'DOT4 규격 오일 주입', '에어 빼기(블리딩) 작업']),
('브레이크 시스템 정비', 6, '휠 재장착 및 제동 테스트', ARRAY['휠 체결', '브레이크 페달 감각 확인', '저속 제동 테스트']);

-- 03. 구동·점화 계통 정비
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('구동·점화 계통 정비', 1, '점화 계통 점검', ARRAY['점화 플러그 상태 확인', '점화 코일 저항 측정', '고압 케이블 점검']),
('구동·점화 계통 정비', 2, '점화 플러그 교체', ARRAY['기존 플러그 탈거', '전극 간극 확인', '신품 플러그 장착 및 토크 체결']),
('구동·점화 계통 정비', 3, '구동 계통 점검', ARRAY['드라이브 샤프트 점검', 'CV 부트 상태 확인', '구동축 베어링 점검']),
('구동·점화 계통 정비', 4, '시동 및 작동 테스트', ARRAY['시동 걸림 상태 확인', '가속 응답성 테스트', '이상 진동 점검']);

-- 04. 냉각·히터 계통 정비
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('냉각·히터 계통 정비', 1, '냉각 계통 점검', ARRAY['냉각수 레벨 및 상태 확인', '라디에이터 외관 점검', '호스 연결부 누수 점검']),
('냉각·히터 계통 정비', 2, '냉각수 교환', ARRAY['기존 냉각수 배출', '냉각 계통 플러싱', '신품 냉각수 주입']),
('냉각·히터 계통 정비', 3, '부품 교체', ARRAY['서모스탯 교체', '워터펌프 점검 및 교체', '라디에이터 캡 교체']),
('냉각·히터 계통 정비', 4, '에어 빼기 및 테스트', ARRAY['냉각 계통 에어 빼기', '시동 후 수온 변화 확인', '히터 작동 테스트']);

-- 05. 변속기·클러치 정비
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('변속기·클러치 정비', 1, '변속기 점검', ARRAY['변속기 오일 레벨 확인', '오일 상태 및 색상 점검', '누유 여부 확인']),
('변속기·클러치 정비', 2, '변속기 오일 교환', ARRAY['드레인 플러그 분리 및 폐유 배출', '오일 필터/스트레이너 교체', '규격 오일 주입']),
('변속기·클러치 정비', 3, '클러치 계통 점검', ARRAY['클러치 페달 유격 확인', '클러치 디스크 마모 점검', '릴리즈 베어링 상태 확인']),
('변속기·클러치 정비', 4, '시운전 및 변속 테스트', ARRAY['각 단수 변속 확인', '변속 충격 점검', '이상 소음 확인']);

-- 06. 조향·서스펜션 정비
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('조향·서스펜션 정비', 1, '하체 점검', ARRAY['차량 리프트 상승', '서스펜션 부품 육안 점검', '부싱 및 볼조인트 유격 확인']),
('조향·서스펜션 정비', 2, '쇼크 업소버 및 스프링 교체', ARRAY['기존 쇼크 업소버 탈거', '스프링 상태 확인', '신품 부품 장착']),
('조향·서스펜션 정비', 3, '조향 계통 정비', ARRAY['파워 스티어링 오일 점검', '타이로드 엔드 점검 및 교체', '스티어링 랙 점검']),
('조향·서스펜션 정비', 4, '휠 얼라인먼트 및 테스트', ARRAY['4륜 얼라인먼트 조정', '주행 테스트', '핸들 쏠림 확인']);

-- 07. 전기·전자 장치 정비
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('전기·전자 장치 정비', 1, '배터리 및 충전 계통 점검', ARRAY['배터리 전압 측정', '단자 부식 상태 확인', '발전기(얼터네이터) 출력 점검']),
('전기·전자 장치 정비', 2, '전기 장치 점검', ARRAY['등화 장치 작동 확인', '퓨즈 박스 점검', '배선 상태 확인']),
('전기·전자 장치 정비', 3, '부품 교체', ARRAY['배터리 교체', '스타터 모터 점검 및 교체', '센서류 교체']),
('전기·전자 장치 정비', 4, '작동 테스트', ARRAY['시동 걸림 상태 확인', '전장 부품 작동 확인', '경고등 소거']);

-- 08. 타이어·휠 정비
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('타이어·휠 정비', 1, '타이어 상태 점검', ARRAY['트레드 깊이 측정', '편마모 패턴 확인', '사이드월 손상 점검']),
('타이어·휠 정비', 2, '타이어 교체', ARRAY['기존 타이어 탈거', '휠 림 상태 점검', '신품 타이어 장착']),
('타이어·휠 정비', 3, '휠 밸런스 및 얼라인먼트', ARRAY['휠 밸런스 조정', '밸런스 웨이트 부착', '4륜 얼라인먼트 점검']),
('타이어·휠 정비', 4, '공기압 설정 및 테스트', ARRAY['규격 공기압 주입', 'TPMS 센서 확인', '주행 테스트']);

-- 09. 외장·차체 정비
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('외장·차체 정비', 1, '손상 부위 확인', ARRAY['차체 외관 점검', '손상 범위 측정', '수리 방법 결정']),
('외장·차체 정비', 2, '판금 및 용접', ARRAY['손상 패널 분리', '판금 작업', '용접 및 성형']),
('외장·차체 정비', 3, '도장 작업', ARRAY['표면 연마 및 퍼티 작업', '프라이머 도포', '도색 및 클리어 코팅']),
('외장·차체 정비', 4, '마감 및 검수', ARRAY['광택 작업', '부품 재조립', '최종 외관 검수']);

-- 10. 내장·편의장치 정비
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('내장·편의장치 정비', 1, '내장 부품 점검', ARRAY['시트 및 트림 상태 확인', '편의 장치 작동 점검', '이상 소음 발생 부위 확인']),
('내장·편의장치 정비', 2, '부품 탈거', ARRAY['내장 트림 분리', '해당 부품 접근', '커넥터 분리']),
('내장·편의장치 정비', 3, '수리 및 교체', ARRAY['손상 부품 교체', '배선 수리', '신품 부품 장착']),
('내장·편의장치 정비', 4, '조립 및 작동 테스트', ARRAY['트림 재조립', '전체 작동 확인', '이상 소음 재확인']);

-- 11. 배기·환경 장치 정비
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('배기·환경 장치 정비', 1, '배기 계통 점검', ARRAY['배기 매니폴드 점검', '촉매 변환기 상태 확인', '머플러 및 배기관 누기 점검']),
('배기·환경 장치 정비', 2, '배기 부품 교체', ARRAY['해당 부품 탈거', '가스켓 교체', '신품 부품 장착 및 체결']),
('배기·환경 장치 정비', 3, '환경 장치 점검', ARRAY['산소 센서 점검', 'EGR 밸브 점검 및 청소', 'DPF/GPF 상태 확인']),
('배기·환경 장치 정비', 4, '배기가스 측정 및 테스트', ARRAY['배기가스 농도 측정', '배압 테스트', '경고등 소거 확인']);

-- 12. 윤활·소모품 교체
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('윤활·소모품 교체', 1, '소모품 상태 점검', ARRAY['각종 오일 레벨 확인', '필터류 상태 점검', '벨트 마모 상태 확인']),
('윤활·소모품 교체', 2, '오일류 교환', ARRAY['폐유 배출', '오일 필터 교체', '규격 오일 주입 및 레벨 확인']),
('윤활·소모품 교체', 3, '필터 및 소모품 교체', ARRAY['에어컨 필터 교체', '와이퍼 블레이드 교체', '벨트류 교체']),
('윤활·소모품 교체', 4, '최종 점검', ARRAY['각 오일 레벨 재확인', '교체 부품 작동 확인', '다음 교체 주기 기록']);

-- 13. 정기 점검·진단
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('정기 점검·진단', 1, '외관 및 하체 점검', ARRAY['차체 외관 상태 확인', '하체 부식 및 손상 점검', '타이어 상태 확인']),
('정기 점검·진단', 2, '엔진룸 점검', ARRAY['각종 오일 레벨 확인', '벨트 및 호스 상태 점검', '냉각수 상태 확인']),
('정기 점검·진단', 3, '전자 진단', ARRAY['OBD 스캐너 연결', '고장 코드 확인', '각 시스템 라이브 데이터 점검']),
('정기 점검·진단', 4, '주행 테스트 및 결과 보고', ARRAY['시운전 실시', '이상 항목 정리', '정비 권장 사항 안내']);

-- 14. 기타 정비
INSERT INTO system_work_steps (system, step_order, title, sub_steps) VALUES
('기타 정비', 1, '작업 대상 확인', ARRAY['해당 부위 점검', '작업 범위 결정', '필요 부품 확인']),
('기타 정비', 2, '부품 탈거 및 교체', ARRAY['관련 부품 분리', '손상 부품 교체', '신품 부품 장착']),
('기타 정비', 3, '조립 및 테스트', ARRAY['분리 부품 재조립', '작동 상태 확인', '최종 점검']);
