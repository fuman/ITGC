-- ============================================================
-- ITGC 포털 - 전체 샘플 데이터 (개발/테스트용)
-- 대상 테이블: 12개 전체
-- 작성일: 2026-03-04
-- ※ 운영 환경에는 절대 실행하지 마십시오.
-- ============================================================

BEGIN;

-- ============================================================
-- 1. 조직 (itgc_organization)
-- ============================================================

-- 그룹사 (COMPANY)
INSERT INTO itgc_organization (org_code, org_name, org_type, head_name, itgc_owner, sort_order)
VALUES
  ('GRP-HOLD', '(주)그룹홀딩스',   'COMPANY', '김회장',  '이감사팀장', 1),
  ('GRP-A',    '(주)그룹사A',       'COMPANY', '최대표',  '박감사팀장', 2),
  ('GRP-B',    '(주)그룹사B',       'COMPANY', '정대표',  '김감사팀장', 3),
  ('GRP-C',    '(주)그룹사C',       'COMPANY', '이대표',  '최감사팀장', 4)
ON CONFLICT (org_code) DO NOTHING;

-- 부서 (DEPT) - 그룹사A
INSERT INTO itgc_organization (parent_id, org_code, org_name, org_type, head_name, itgc_owner, sort_order)
SELECT p.id, d.org_code, d.org_name, 'DEPT', d.head_name, d.itgc_owner, d.sort_order
FROM itgc_organization p
JOIN (VALUES
  ('GRP-A', 'DEPT-IT-AUDIT', 'IT감사팀',     '김감사',   '김감사팀장', 1),
  ('GRP-A', 'DEPT-IT-SEC',   '정보보안팀',   '이보안',   '이보안팀장', 2),
  ('GRP-A', 'DEPT-IT-OPS',   'IT운영팀',     '박운영',   '박운영팀장', 3),
  ('GRP-A', 'DEPT-IT-DEV',   '개발팀',       '정개발',   '정개발팀장', 4),
  ('GRP-A', 'DEPT-IT-INFRA', 'IT인프라팀',   '최인프라', '최인프라팀장', 5),
  ('GRP-A', 'DEPT-DBA',      'DBA팀',        '강DBA',    '강DBA팀장',  6),
  ('GRP-A', 'DEPT-HR-SYS',   'HR시스템팀',   '조시스템', '조시스템팀장', 7)
) AS d(parent_code, org_code, org_name, head_name, itgc_owner, sort_order)
  ON p.org_code = d.parent_code
ON CONFLICT (org_code) DO NOTHING;

-- 부서 (DEPT) - 그룹사B
INSERT INTO itgc_organization (parent_id, org_code, org_name, org_type, head_name, itgc_owner, sort_order)
SELECT p.id, d.org_code, d.org_name, 'DEPT', d.head_name, d.itgc_owner, d.sort_order
FROM itgc_organization p
JOIN (VALUES
  ('GRP-B', 'DEPT-B-IT',     'IT팀',         '한IT',     '한IT팀장',   1),
  ('GRP-B', 'DEPT-B-AUDIT',  '감사팀',       '오감사',   '오감사팀장', 2)
) AS d(parent_code, org_code, org_name, head_name, itgc_owner, sort_order)
  ON p.org_code = d.parent_code
ON CONFLICT (org_code) DO NOTHING;

-- ============================================================
-- 2. 사용자 (itgc_user)
-- bcrypt hash: 'itgc1234' → $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
-- ============================================================
INSERT INTO itgc_user (org_id, username, password, name, email, dept, role, company)
SELECT p.id, u.username,
       '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
       u.name, u.email, u.dept, u.role, u.company
FROM itgc_organization p
JOIN (VALUES
  ('GRP-HOLD', 'admin',         '시스템관리자',  'admin@group.com',          'IT기획팀',   'ADMIN',   '(주)그룹홀딩스'),
  ('GRP-A',    'kim.audit',     '김감사',        'kim.audit@group-a.com',    'IT감사팀',   'LEAD',    '(주)그룹사A'),
  ('GRP-A',    'lee.security',  '이보안',        'lee.sec@group-a.com',      '정보보안팀', 'OWNER',   '(주)그룹사A'),
  ('GRP-A',    'park.review',   '박검토',        'park.review@group-a.com',  'IT감사팀',   'AUDITOR', '(주)그룹사A'),
  ('GRP-A',    'choi.system',   '최시스템',      'choi.sys@group-a.com',     'HR시스템팀', 'OWNER',   '(주)그룹사A'),
  ('GRP-A',    'jung.infra',    '정인프라',      'jung.infra@group-a.com',   'IT인프라팀', 'OWNER',   '(주)그룹사A'),
  ('GRP-A',    'kang.dba',      '강DBA',         'kang.dba@group-a.com',     'DBA팀',      'OWNER',   '(주)그룹사A'),
  ('GRP-A',    'jeon.ops',      '전운영',        'jeon.ops@group-a.com',     'IT운영팀',   'OWNER',   '(주)그룹사A'),
  ('GRP-A',    'han.dev',       '한개발',        'han.dev@group-a.com',      '개발팀',     'OWNER',   '(주)그룹사A'),
  ('GRP-B',    'oh.audit',      '오감사',        'oh.audit@group-b.com',     '감사팀',     'AUDITOR', '(주)그룹사B'),
  ('GRP-HOLD', 'viewer01',      '열람자1',       'viewer01@group.com',       'IT기획팀',   'VIEWER',  '(주)그룹홀딩스')
) AS u(parent_code, username, name, email, dept, role, company)
  ON p.org_code = u.parent_code
ON CONFLICT (username) DO NOTHING;

-- ============================================================
-- 3. 위험 (itgc_risk)  — inherent_risk, residual_risk 은 트리거가 자동 설정
-- ============================================================
INSERT INTO itgc_risk
  (org_id, risk_code, category, risk_name, risk_description,
   inherent_likelihood, inherent_impact,
   residual_likelihood, residual_impact,
   risk_trend, risk_owner, dept, status, related_process,
   assessment_comment, assessor, last_assessed_date)
SELECT p.id,
       r.risk_code, r.category, r.risk_name, r.risk_description,
       r.inh_l, r.inh_i, r.res_l, r.res_i,
       r.trend, r.owner, r.dept, r.status, r.process,
       r.comment, r.assessor, r.assessed_date::DATE
FROM itgc_organization p
JOIN (VALUES
  -- 접근통제 (IT-ACC)
  ('GRP-A','IT-ACC-001','IT-ACC','퇴직자 계정 미삭제',
   '임직원 퇴직 후 시스템 접근 권한이 적시에 회수되지 않을 위험',
   4,3,2,3,'유지','최시스템','HR시스템팀','활성','인사관리,접근통제',
   '반기 재검토 시 미삭제 계정 다수 발견','김감사','2026-01-15'),
  ('GRP-A','IT-ACC-002','IT-ACC','과도한 접근 권한 부여',
   '업무 필요 최소 권한 원칙 미준수로 과도한 권한이 부여될 위험',
   3,4,2,3,'하락','이보안','정보보안팀','활성','접근통제',
   '직무분리 검토 결과 일부 개선','김감사','2026-01-15'),
  ('GRP-A','IT-ACC-003','IT-ACC','특권 계정 공유 사용',
   '관리자 계정을 복수 사용자가 공유하여 개인 책임 추적이 불가한 위험',
   4,5,2,4,'하락','이보안','정보보안팀','활성','접근통제,감사추적',
   '공유 계정 8건 확인, 개선 조치 진행 중','김감사','2026-01-15'),

  -- 변경관리 (IT-CHG)
  ('GRP-A','IT-CHG-001','IT-CHG','미승인 시스템 변경',
   '정식 변경관리 프로세스 없이 운영 환경에 변경이 적용될 위험',
   3,4,2,4,'유지','한개발','개발팀','활성','시스템 개발,변경관리',
   '긴급변경 3건 사후 승인 처리','박검토','2026-01-20'),
  ('GRP-A','IT-CHG-002','IT-CHG','변경 테스트 미흡',
   '운영 배포 전 충분한 테스트 및 검증이 수행되지 않을 위험',
   3,3,2,3,'유지','한개발','개발팀','활성','시스템 개발',
   '테스트 케이스 커버리지 부족','박검토','2026-01-20'),

  -- IT운영 (IT-OPS)
  ('GRP-A','IT-OPS-001','IT-OPS','배치 처리 실패 미탐지',
   '중요 배치 작업 실패 시 적시에 탐지하지 못할 위험',
   3,4,3,3,'상승','전운영','IT운영팀','활성','배치처리,IT운영',
   '모니터링 알람 미설정 건수 증가','박검토','2026-01-22'),
  ('GRP-A','IT-OPS-002','IT-OPS','시스템 가용성 저하',
   '핵심 시스템의 예기치 않은 장애로 업무 연속성이 침해될 위험',
   2,5,2,4,'유지','전운영','IT운영팀','모니터링','IT운영,업무연속성',
   'SLA 99.5% 이상 유지 중','박검토','2026-01-22'),

  -- 업무연속성 (IT-BCM)
  ('GRP-A','IT-BCM-001','IT-BCM','재해복구 시스템 미검증',
   'DR 시스템의 실제 복구 능력을 정기 검증하지 않을 위험',
   2,5,2,4,'유지','최인프라','IT인프라팀','모니터링','IT인프라,업무연속성',
   'DR 테스트 연 1회 미실시','김감사','2026-02-01'),
  ('GRP-A','IT-BCM-002','IT-BCM','백업 무결성 미검증',
   '백업 데이터의 무결성·복구 가능 여부를 주기적으로 검증하지 않을 위험',
   2,4,1,3,'하락','최인프라','IT인프라팀','활성','백업관리',
   '일일 자동 검증 스크립트 도입 후 개선','김감사','2026-02-01'),

  -- 정보보안 (IT-SEC)
  ('GRP-A','IT-SEC-001','IT-SEC','권한 없는 시스템 접근',
   '내부·외부 사용자가 권한 없이 중요 시스템에 접근할 위험',
   4,5,2,5,'하락','이보안','정보보안팀','활성','ERP 운영,인사관리',
   'MFA 도입 후 위험 수준 감소','김감사','2026-02-05'),
  ('GRP-A','IT-SEC-002','IT-SEC','보안 패치 미적용',
   '운영 시스템 보안 패치가 적시에 적용되지 않아 취약점에 노출될 위험',
   3,4,2,3,'유지','이보안','정보보안팀','활성','IT인프라운영,보안관리',
   '월간 패치 프로세스 수립 완료','김감사','2026-02-05'),

  -- 데이터무결성 (IT-DATA)
  ('GRP-A','IT-DATA-001','IT-DATA','데이터 무결성 미검증',
   '시스템 간 데이터 전송 시 무결성 검증이 수행되지 않을 위험',
   3,3,2,3,'유지','강DBA','DBA팀','활성','데이터관리,ERP연계',
   'ERP-분석시스템 인터페이스 검증 부재','김감사','2026-02-10'),
  ('GRP-A','IT-DATA-002','IT-DATA','개인정보 비암호화 저장',
   '중요 개인정보가 암호화되지 않고 DB에 저장될 위험',
   2,5,1,4,'하락','강DBA','DBA팀','활성','데이터관리,개인정보보호',
   '주요 개인정보 컬럼 암호화 완료 90%','김감사','2026-02-10')
) AS r(org_code, risk_code, category, risk_name, risk_description,
        inh_l, inh_i, res_l, res_i, trend, owner, dept, status, process,
        comment, assessor, assessed_date)
  ON p.org_code = r.org_code
ON CONFLICT (risk_code) DO NOTHING;

-- ============================================================
-- 4. 통제 (itgc_control)
-- ============================================================
INSERT INTO itgc_control
  (org_id, control_code, domain, coso_component, control_name, control_objective,
   control_description, control_type, automation, frequency,
   control_owner, dept, is_key_control, is_itdm_control,
   effectiveness, design_adequacy, design_evaluator, last_test_date)
SELECT p.id,
       c.ctl_code, c.domain, c.coso, c.ctl_name, c.objective, c.description,
       c.ctl_type, c.auto, c.freq, c.owner, c.dept,
       c.is_key, c.is_itdm,
       c.effectiveness, c.design, c.evaluator, c.last_test::DATE
FROM itgc_organization p
JOIN (VALUES
  -- 접근통제
  ('GRP-A','CTRL-ACC-001','접근통제','CA',
   '사용자 계정 등록·변경·삭제 승인',
   '권한 없는 시스템 접근 방지',
   '신규·변경·삭제 계정 요청 시 소관 팀장 및 정보보안팀 승인을 득한 후 처리',
   '예방통제','수동','수시','이보안','정보보안팀',TRUE,TRUE,'효과적','적합','김감사','2026-03-07'),
  ('GRP-A','CTRL-ACC-002','접근통제','CA',
   '특권 계정 반기 재검토',
   '과도한 관리자 권한 방지',
   '반기 1회 특권 계정 보유 현황을 전수 검토하고 불필요 계정을 회수',
   '탐지통제','수동','반기','이보안','정보보안팀',TRUE,FALSE,'부분 효과적','부분 적합','김감사','2026-03-14'),
  ('GRP-A','CTRL-ACC-003','접근통제','CA',
   '퇴직자 계정 즉시 비활성화',
   '퇴직 당일 시스템 접근 차단',
   'HR 시스템에서 퇴직 처리 시 IT 시스템 계정을 동일 영업일 내 비활성화',
   '예방통제','반자동','수시','최시스템','HR시스템팀',TRUE,TRUE,'부분 효과적','적합','김감사','2026-03-14'),
  ('GRP-A','CTRL-ACC-004','접근통제','CA',
   '직무분리 현황 분기 검토',
   '이해충돌 방지 및 직무분리 준수',
   '분기별 직무분리 매트릭스에 따른 역할 충돌 계정 검토 및 조치',
   '탐지통제','수동','분기','이보안','정보보안팀',FALSE,FALSE,'미평가','미평가',NULL,NULL),

  -- 변경관리
  ('GRP-A','CTRL-CHG-001','변경관리','CA',
   '변경 요청 및 승인 관리',
   '미승인 변경 방지',
   '모든 운영 변경에 대해 변경관리시스템(CMS) 등록 및 IT운영팀장·정보보안팀 승인 필수',
   '예방통제','반자동','수시','한개발','개발팀',TRUE,TRUE,'효과적','적합','박검토','2026-03-21'),
  ('GRP-A','CTRL-CHG-002','변경관리','CA',
   '변경 후 운영 검증 테스트',
   '변경 오류 조기 탐지',
   '운영 배포 전 UAT 수행, 배포 후 24시간 이내 정상 동작 확인 및 결과 기록',
   '탐지통제','수동','수시','한개발','개발팀',FALSE,FALSE,'부분 효과적','적합','박검토','2026-03-21'),
  ('GRP-A','CTRL-CHG-003','변경관리','CA',
   '긴급변경 사후 승인 검토',
   '긴급변경 통제 보완',
   '긴급변경 발생 후 48시간 이내 변경관리위원회 사후 승인 및 원인·결과 보고',
   '탐지통제','수동','수시','한개발','개발팀',FALSE,FALSE,'부분 효과적','부분 적합','박검토','2026-03-21'),

  -- IT운영
  ('GRP-A','CTRL-OPS-001','IT운영','CA',
   '배치 작업 실행 결과 모니터링',
   '배치 오류 조기 탐지 및 알림',
   '중요 배치 작업 완료 여부 자동 확인 및 실패 시 담당자 즉시 알림',
   '탐지통제','자동','일일','전운영','IT운영팀',TRUE,FALSE,'비효과적','부적합','박검토','2026-03-31'),
  ('GRP-A','CTRL-OPS-002','IT운영','CA',
   '시스템 가용성 모니터링',
   '핵심 시스템 장애 조기 탐지',
   '24x7 시스템 가용성 모니터링 및 임계값 초과 시 에스컬레이션 체계 운영',
   '탐지통제','자동','상시','전운영','IT운영팀',FALSE,FALSE,'효과적','적합','박검토','2026-02-28'),
  ('GRP-A','CTRL-OPS-003','IT운영','CA',
   '로그 무결성 검토',
   '이상 행위 탐지 및 감사 추적',
   '주요 시스템 로그 보관 및 월 1회 이상 비정상 접근 패턴 검토',
   '탐지통제','반자동','월간','이보안','정보보안팀',FALSE,FALSE,'부분 효과적','적합','박검토','2026-02-28'),

  -- 업무연속성
  ('GRP-A','CTRL-BCM-001','업무연속성','MA',
   'DR 복구 테스트 실시',
   'DR 복구 능력 검증 및 RTO/RPO 충족',
   '연 1회 이상 DR 테스트를 실시하고 결과를 경영진에 보고',
   '탐지통제','수동','반기','최인프라','IT인프라팀',TRUE,FALSE,'미평가','미평가',NULL,NULL),
  ('GRP-A','CTRL-BCM-002','업무연속성','MA',
   '백업 데이터 무결성 일일 검증',
   '백업 신뢰성 확보',
   '데이터 백업 완료 후 자동 검증 스크립트 실행 및 오류 발생 시 즉시 알림',
   '탐지통제','자동','일일','최인프라','IT인프라팀',TRUE,FALSE,'효과적','적합','김감사','2026-03-31'),

  -- 정보보안
  ('GRP-A','CTRL-SEC-001','정보보안','CA',
   '취약점 정기 스캔',
   '보안 취약점 조기 탐지',
   '월 1회 내·외부 취약점 스캔 실시 및 High·Critical 취약점 30일 이내 패치',
   '탐지통제','자동','월간','이보안','정보보안팀',FALSE,FALSE,'효과적','적합','김감사','2026-02-28'),
  ('GRP-A','CTRL-SEC-002','정보보안','CA',
   '보안 패치 적용 통제',
   '알려진 취약점의 적시 패치',
   '운영시스템 보안 패치를 월 1회 정기 패치 창(Maintenance Window)에 일괄 적용',
   '예방통제','반자동','월간','이보안','정보보안팀',FALSE,FALSE,'부분 효과적','적합','김감사','2026-02-28'),
  ('GRP-A','CTRL-SEC-003','정보보안','CA',
   '개인정보 암호화 관리',
   '중요 개인정보 유출 방지',
   '주민번호·계좌번호 등 법정 개인정보의 DB 저장·전송 시 암호화 적용',
   '예방통제','자동','상시','강DBA','DBA팀',FALSE,TRUE,'부분 효과적','적합','김감사','2026-03-01')
) AS c(org_code, ctl_code, domain, coso, ctl_name, objective, description,
        ctl_type, auto, freq, owner, dept, is_key, is_itdm,
        effectiveness, design, evaluator, last_test)
  ON p.org_code = c.org_code
ON CONFLICT (control_code) DO NOTHING;

-- ============================================================
-- 5. 위험-통제 매핑 (itgc_risk_control_mapping)
-- ============================================================
INSERT INTO itgc_risk_control_mapping
  (risk_id, control_id, risk_code, control_code, mapping_type, coverage_ratio, is_key_mapping)
SELECT r.id, c.id, r.risk_code, c.control_code, m.mtype, m.coverage, m.is_key
FROM itgc_risk r
JOIN itgc_control c ON TRUE
JOIN (VALUES
  ('IT-ACC-001','CTRL-ACC-002','직접',60,TRUE),
  ('IT-ACC-001','CTRL-ACC-003','직접',80,TRUE),
  ('IT-ACC-002','CTRL-ACC-002','직접',75,TRUE),
  ('IT-ACC-002','CTRL-ACC-004','지원',40,FALSE),
  ('IT-ACC-003','CTRL-ACC-001','직접',70,TRUE),
  ('IT-ACC-003','CTRL-ACC-002','지원',20,FALSE),
  ('IT-CHG-001','CTRL-CHG-001','직접',85,TRUE),
  ('IT-CHG-001','CTRL-CHG-003','지원',30,FALSE),
  ('IT-CHG-002','CTRL-CHG-002','직접',80,TRUE),
  ('IT-CHG-002','CTRL-CHG-001','지원',40,FALSE),
  ('IT-OPS-001','CTRL-OPS-001','직접',90,TRUE),
  ('IT-OPS-001','CTRL-OPS-002','지원',30,FALSE),
  ('IT-OPS-002','CTRL-OPS-002','직접',85,TRUE),
  ('IT-BCM-001','CTRL-BCM-001','직접',95,TRUE),
  ('IT-BCM-002','CTRL-BCM-002','직접',90,TRUE),
  ('IT-BCM-002','CTRL-BCM-001','지원',40,FALSE),
  ('IT-SEC-001','CTRL-ACC-001','직접',65,TRUE),
  ('IT-SEC-001','CTRL-OPS-003','지원',35,FALSE),
  ('IT-SEC-002','CTRL-SEC-001','직접',70,TRUE),
  ('IT-SEC-002','CTRL-SEC-002','직접',80,TRUE),
  ('IT-DATA-001','CTRL-OPS-003','지원',45,FALSE),
  ('IT-DATA-002','CTRL-SEC-003','직접',85,TRUE)
) AS m(rcode, ccode, mtype, coverage, is_key)
  ON r.risk_code = m.rcode AND c.control_code = m.ccode
ON CONFLICT (risk_id, control_id) DO NOTHING;

-- ============================================================
-- 6. 운영평가 계획 (itgc_eval_plan)
-- ============================================================
INSERT INTO itgc_eval_plan
  (org_id, eval_year, eval_quarter, control_id, control_code, control_name,
   domain, assignee, planned_start_date, planned_end_date,
   actual_start_date, actual_end_date,
   sampling_count, sampling_method, status, created_by)
SELECT p.id,
       ep.yr, ep.qtr, c.id, c.control_code, c.control_name, c.domain,
       ep.assignee,
       ep.plan_start::DATE, ep.plan_end::DATE,
       ep.act_start::DATE,  ep.act_end::DATE,
       ep.samp_cnt, ep.method, ep.status, 'kim.audit'
FROM itgc_organization p
JOIN itgc_control c ON TRUE
JOIN (VALUES
  -- 2025년 3분기 (완료)
  ('GRP-A','CTRL-ACC-001',2025,3,'이보안','2025-07-01','2025-07-07','2025-07-01','2025-07-07',25,'확률적','완료'),
  ('GRP-A','CTRL-CHG-001',2025,3,'박검토','2025-07-08','2025-07-14','2025-07-08','2025-07-14',30,'확률적','완료'),
  ('GRP-A','CTRL-OPS-002',2025,3,'전운영','2025-07-15','2025-07-21','2025-07-15','2025-07-21',10,'판단적','완료'),
  ('GRP-A','CTRL-BCM-002',2025,3,'최인프라','2025-07-22','2025-07-31','2025-07-22','2025-07-31',5,'전수','완료'),
  -- 2025년 4분기 (완료)
  ('GRP-A','CTRL-ACC-002',2025,4,'이보안','2025-10-01','2025-10-14','2025-10-01','2025-10-14',1,'전수','완료'),
  ('GRP-A','CTRL-CHG-002',2025,4,'박검토','2025-10-15','2025-10-21','2025-10-15','2025-10-21',25,'비통계적','완료'),
  ('GRP-A','CTRL-OPS-001',2025,4,'전운영','2025-10-22','2025-10-31','2025-10-22','2025-10-31',20,'비통계적','완료'),
  ('GRP-A','CTRL-SEC-001',2025,4,'이보안','2025-11-01','2025-11-15','2025-11-01','2025-11-15',3,'전수','완료'),
  -- 2026년 1분기 (진행중/완료)
  ('GRP-A','CTRL-ACC-001',2026,1,'이보안','2026-01-02','2026-01-10','2026-01-02','2026-01-10',25,'확률적','완료'),
  ('GRP-A','CTRL-ACC-003',2026,1,'이보안','2026-01-11','2026-01-17','2026-01-11','2026-01-17',15,'비통계적','완료'),
  ('GRP-A','CTRL-CHG-001',2026,1,'박검토','2026-01-18','2026-01-31','2026-01-18','2026-01-31',30,'확률적','완료'),
  ('GRP-A','CTRL-OPS-002',2026,1,'전운영','2026-02-01','2026-02-07','2026-02-01','2026-02-07',10,'판단적','완료'),
  ('GRP-A','CTRL-BCM-002',2026,1,'최인프라','2026-02-08','2026-02-14','2026-02-08','2026-02-14',5,'전수','완료'),
  -- 2026년 1분기 (진행중)
  ('GRP-A','CTRL-ACC-002',2026,1,'이보안','2026-02-15','2026-02-28','2026-02-15',NULL,1,'전수','진행중'),
  ('GRP-A','CTRL-OPS-001',2026,1,'전운영','2026-03-01','2026-03-15',NULL,NULL,20,'비통계적','예정'),
  ('GRP-A','CTRL-SEC-001',2026,1,'이보안','2026-03-16','2026-03-31',NULL,NULL,3,'전수','예정'),
  -- 2026년 2분기 (예정)
  ('GRP-A','CTRL-CHG-003',2026,2,'박검토','2026-04-01','2026-04-15',NULL,NULL,25,'비통계적','예정'),
  ('GRP-A','CTRL-BCM-001',2026,2,'최인프라','2026-04-16','2026-04-30',NULL,NULL,1,'전수','예정'),
  ('GRP-A','CTRL-SEC-002',2026,2,'이보안','2026-05-01','2026-05-15',NULL,NULL,3,'전수','예정'),
  ('GRP-A','CTRL-ACC-004',2026,2,'이보안','2026-05-16','2026-05-31',NULL,NULL,0,'전수','예정')
) AS ep(org_code, ctrl_code, yr, qtr, assignee,
        plan_start, plan_end, act_start, act_end,
        samp_cnt, method, status)
  ON p.org_code = ep.org_code AND c.control_code = ep.ctrl_code;

-- ============================================================
-- 7. 평가 샘플 (itgc_eval_sample)  — 완료된 계획 대상
-- ============================================================

-- CTRL-ACC-001 2026Q1 샘플 (plan 조회)
INSERT INTO itgc_eval_sample
  (plan_id, sample_no, transaction_date, transaction_id, description,
   evidence_status, test_result, exception_note, evidence_file, tester, tested_at)
SELECT ep.id,
       s.sno, s.tdate::DATE, s.tid, s.desc,
       s.ev_status, s.result, s.exc_note, s.ev_file, s.tester,
       s.tested_at::TIMESTAMP
FROM itgc_eval_plan ep
JOIN itgc_control c ON c.id = ep.control_id
JOIN (VALUES
  -- CTRL-ACC-001 2026Q1 샘플 5건
  ('CTRL-ACC-001',2026,1,'S-001','2026-01-03','ACC-20260103-001','사용자 계정 신규 등록 건 (홍길동)','수집완료','통과',NULL,'증빙/ACC001_01.pdf','이보안','2026-01-05 14:00:00'),
  ('CTRL-ACC-001',2026,1,'S-002','2026-01-04','ACC-20260104-002','사용자 계정 수정 건 (권한 변경)','수집완료','통과',NULL,'증빙/ACC001_02.pdf','이보안','2026-01-05 14:30:00'),
  ('CTRL-ACC-001',2026,1,'S-003','2026-01-05','ACC-20260105-003','사용자 계정 삭제 건','수집완료','통과',NULL,'증빙/ACC001_03.pdf','이보안','2026-01-06 09:00:00'),
  ('CTRL-ACC-001',2026,1,'S-004','2026-01-06','ACC-20260106-004','계정 잠금 해제 건','수집완료','예외','승인 기록 없이 처리됨','증빙/ACC001_04.pdf','이보안','2026-01-06 09:30:00'),
  ('CTRL-ACC-001',2026,1,'S-005','2026-01-07','ACC-20260107-005','외주 직원 계정 등록 건','수집완료','통과',NULL,'증빙/ACC001_05.pdf','이보안','2026-01-07 11:00:00'),

  -- CTRL-CHG-001 2026Q1 샘플 5건
  ('CTRL-CHG-001',2026,1,'S-001','2026-01-20','CHG-20260120-001','ERP 모듈 패치 배포','수집완료','통과',NULL,'증빙/CHG001_01.pdf','박검토','2026-01-25 10:00:00'),
  ('CTRL-CHG-001',2026,1,'S-002','2026-01-21','CHG-20260121-002','인사 시스템 UI 개선','수집완료','통과',NULL,'증빙/CHG001_02.pdf','박검토','2026-01-25 10:30:00'),
  ('CTRL-CHG-001',2026,1,'S-003','2026-01-22','CHG-20260122-003','배치 스케줄 변경','수집완료','예외','테스트 결과서 미첨부','증빙/CHG001_03.pdf','박검토','2026-01-26 09:00:00'),
  ('CTRL-CHG-001',2026,1,'S-004','2026-01-25','CHG-20260125-004','DB 테이블 구조 변경','수집완료','통과',NULL,'증빙/CHG001_04.pdf','박검토','2026-01-26 09:30:00'),
  ('CTRL-CHG-001',2026,1,'S-005','2026-01-28','CHG-20260128-005','인터페이스 수정 배포','수집완료','통과',NULL,'증빙/CHG001_05.pdf','박검토','2026-01-28 16:00:00'),

  -- CTRL-BCM-002 2026Q1 샘플 5건
  ('CTRL-BCM-002',2026,1,'S-001','2026-02-08','BCM-20260208-001','2026-02-08 자정 백업 검증','수집완료','통과',NULL,'증빙/BCM002_01.pdf','최인프라','2026-02-09 08:00:00'),
  ('CTRL-BCM-002',2026,1,'S-002','2026-02-09','BCM-20260209-002','2026-02-09 자정 백업 검증','수집완료','통과',NULL,'증빙/BCM002_02.pdf','최인프라','2026-02-10 08:00:00'),
  ('CTRL-BCM-002',2026,1,'S-003','2026-02-10','BCM-20260210-003','2026-02-10 자정 백업 검증','수집완료','통과',NULL,'증빙/BCM002_03.pdf','최인프라','2026-02-11 08:00:00'),
  ('CTRL-BCM-002',2026,1,'S-004','2026-02-11','BCM-20260211-004','2026-02-11 자정 백업 검증','수집완료','통과',NULL,'증빙/BCM002_04.pdf','최인프라','2026-02-12 08:00:00'),
  ('CTRL-BCM-002',2026,1,'S-005','2026-02-12','BCM-20260212-005','2026-02-12 자정 백업 검증','수집완료','통과',NULL,'증빙/BCM002_05.pdf','최인프라','2026-02-13 08:00:00'),

  -- CTRL-OPS-002 2026Q1 샘플 3건
  ('CTRL-OPS-002',2026,1,'S-001','2026-02-01','OPS-20260201-001','핵심 시스템 가용성 로그 2월 1주','수집완료','통과',NULL,'증빙/OPS002_01.pdf','전운영','2026-02-04 09:00:00'),
  ('CTRL-OPS-002',2026,1,'S-002','2026-02-04','OPS-20260204-002','핵심 시스템 가용성 로그 2월 2주','수집완료','통과',NULL,'증빙/OPS002_02.pdf','전운영','2026-02-05 09:00:00'),
  ('CTRL-OPS-002',2026,1,'S-003','2026-02-05','OPS-20260205-003','핵심 시스템 가용성 로그 2월 3주','수집완료','예외','5분 간 서비스 중단 발생','증빙/OPS002_03.pdf','전운영','2026-02-06 09:00:00'),

  -- CTRL-ACC-003 2026Q1 샘플 3건
  ('CTRL-ACC-003',2026,1,'S-001','2026-01-12','ACC3-20260112-001','신입사원 계정 발급 (개발팀 2명)','수집완료','통과',NULL,'증빙/ACC003_01.pdf','이보안','2026-01-13 14:00:00'),
  ('CTRL-ACC-003',2026,1,'S-002','2026-01-14','ACC3-20260114-002','계약직 계정 발급','수집완료','통과',NULL,'증빙/ACC003_02.pdf','이보안','2026-01-14 15:00:00'),
  ('CTRL-ACC-003',2026,1,'S-003','2026-01-15','ACC3-20260115-003','외주 업체 계정 발급 (퇴직 후 3일 경과 후 비활성화 미이행)','수집완료','예외','퇴직일로부터 3일 후 비활성화 지연','증빙/ACC003_03.pdf','이보안','2026-01-15 16:00:00')
) AS s(ctrl_code, yr, qtr, sno, tdate, tid, desc, ev_status, result, exc_note, ev_file, tester, tested_at)
  ON c.control_code = s.ctrl_code AND ep.eval_year = s.yr AND ep.eval_quarter = s.qtr
ON CONFLICT (plan_id, sample_no) DO NOTHING;

-- ============================================================
-- 8. 평가 결과 (itgc_eval_result)  — 완료된 계획 대상
-- ============================================================
INSERT INTO itgc_eval_result
  (plan_id, control_id, control_code, eval_year, eval_quarter,
   sample_count, exception_count, exception_rate,
   effectiveness, evaluator, evaluation_date, comment, recommendation, finding_created)
SELECT ep.id, c.id, c.control_code, ep.eval_year, ep.eval_quarter,
       r.samp_cnt, r.exc_cnt,
       ROUND(r.exc_cnt::NUMERIC / NULLIF(r.samp_cnt,0) * 100, 2),
       r.effectiveness, r.evaluator, r.eval_date::DATE,
       r.comment, r.recommendation, r.finding_cnt
FROM itgc_eval_plan ep
JOIN itgc_control c ON c.id = ep.control_id
JOIN (VALUES
  -- 2025 Q3
  ('CTRL-ACC-001',2025,3, 25,0,'효과적',     '이보안','2025-07-08','계정 등록·변경·삭제 절차 전반적으로 적절히 운영됨','이상 없음',0),
  ('CTRL-CHG-001',2025,3, 30,2,'부분 효과적','박검토','2025-07-15','긴급변경 2건에 대한 사전 승인 미이행 발견','긴급변경 절차 강화 필요',1),
  ('CTRL-OPS-002',2025,3, 10,0,'효과적',     '전운영','2025-07-22','가용성 모니터링 체계 정상 운영 확인','이상 없음',0),
  ('CTRL-BCM-002',2025,3,  5,0,'효과적',     '최인프라','2025-07-31','백업 검증 스크립트 정상 동작 확인','이상 없음',0),
  -- 2025 Q4
  ('CTRL-ACC-002',2025,4,  1,0,'부분 효과적','이보안','2025-10-14','특권 계정 12건 검토 중 불필요 계정 3건 미삭제','즉시 회수 및 재검토 주기 단축 필요',1),
  ('CTRL-CHG-002',2025,4, 25,1,'부분 효과적','박검토','2025-10-22','변경 후 검증 문서 미작성 1건 발견','검증 절차 체크리스트 의무화 필요',0),
  ('CTRL-OPS-001',2025,4, 20,5,'비효과적',   '전운영','2025-10-31','5건 중 알람 미발송 5건 모두 발견됨','모니터링 솔루션 교체 검토 필요',1),
  ('CTRL-SEC-001',2025,4,  3,0,'효과적',     '이보안','2025-11-15','취약점 스캔 정상 수행 및 패치 이력 확인됨','이상 없음',0),
  -- 2026 Q1
  ('CTRL-ACC-001',2026,1, 5,1,'부분 효과적','이보안','2026-01-08','계정 잠금 해제 1건 무승인 처리 발견','승인 없는 계정 잠금 해제 절차 강화 필요',1),
  ('CTRL-ACC-003',2026,1, 3,1,'부분 효과적','이보안','2026-01-16','퇴직자 계정 비활성화 지연 1건 발견','HR-IT 자동화 연계 구현 필요',1),
  ('CTRL-CHG-001',2026,1, 5,1,'부분 효과적','박검토','2026-01-29','변경 테스트 결과서 미첨부 1건 발견','테스트 증빙 첨부 의무화','1'),
  ('CTRL-OPS-002',2026,1, 3,1,'부분 효과적','전운영','2026-02-06','5분 서비스 중단 사례 발견 (알람은 정상 발송됨)','SLA 미달 원인 분석 및 재발방지 계획 수립 필요',0),
  ('CTRL-BCM-002',2026,1, 5,0,'효과적',     '최인프라','2026-02-13','5일 연속 백업 검증 정상 완료','이상 없음',0)
) AS r(ctrl_code, yr, qtr, samp_cnt, exc_cnt, effectiveness,
        evaluator, eval_date, comment, recommendation, finding_cnt)
  ON c.control_code = r.ctrl_code AND ep.eval_year = r.yr AND ep.eval_quarter = r.qtr
ON CONFLICT (plan_id) DO NOTHING;

-- ============================================================
-- 9. 발견사항 (itgc_finding)
-- ============================================================
INSERT INTO itgc_finding
  (org_id, finding_no, finding_type, title, description,
   related_control_id, related_control,
   related_risk_id,    related_risk,
   severity, dept, owner,
   risk_impact, root_cause, recommendation,
   discovery_date, due_date, completion_date,
   status, remediation_progress, remediation_plan, created_by)
SELECT
  p.id,
  f.fno, f.ftype, f.title, f.description,
  ctrl.id, ctrl.control_code,
  risk.id, risk.risk_code,
  f.severity, f.dept, f.owner,
  f.impact, f.root, f.recom,
  f.disc_dt::DATE, f.due_dt::DATE, f.comp_dt::DATE,
  f.status, f.progress, f.plan, 'kim.audit'
FROM itgc_organization p
JOIN itgc_control ctrl ON TRUE
JOIN itgc_risk    risk ON TRUE
JOIN (VALUES
  ('GRP-A','FND-2026-001','운영평가',
   '관리자 계정 잠금 해제 무승인 처리',
   '2026-01-06 계정 잠금 해제 1건이 팀장 승인 없이 단독 처리된 것이 발견됨',
   'CTRL-ACC-001','IT-ACC-003',
   '높음','정보보안팀','이보안',
   '승인 체계 우회로 인해 무단 계정 활성화 발생 가능',
   '계정 잠금 해제 처리 시 승인 단계를 IT 시스템에서 강제하지 않음',
   '시스템 내 계정 잠금 해제 기능에 2단계 승인 워크플로우 구현',
   '2026-01-08','2026-02-28',NULL,'조치중',60,
   '시스템 개선 개발 착수, 2/28 완료 목표'),

  ('GRP-A','FND-2026-002','운영평가',
   '퇴직자 계정 비활성화 3일 지연',
   '외주 직원 퇴직 후 3일이 경과한 후 계정이 비활성화됨 (규정: 퇴직 당일)',
   'CTRL-ACC-003','IT-ACC-001',
   '높음','HR시스템팀','최시스템',
   '퇴직자 계정을 통한 무단 정보 접근 및 내부 정보 유출 가능성',
   'HR 시스템 퇴직 처리와 IT 계정 비활성화 간 자동 연계 미구축',
   'HR-IT 시스템 실시간 연동 API 구현 및 SLA 내 자동 처리 체계 수립',
   '2026-01-16','2026-03-31',NULL,'조치중',40,
   'HR-IT 연동 API 개발 중, 3월 말 오픈 예정'),

  ('GRP-A','FND-2026-003','운영평가',
   '변경 배포 시 테스트 결과서 미첨부',
   '2026-01-22 배치 스케줄 변경 건에 테스트 결과서가 첨부되지 않고 변경이 승인됨',
   'CTRL-CHG-001','IT-CHG-002',
   '중간','개발팀','한개발',
   '충분한 테스트 없이 변경 배포 시 운영 오류 발생 가능',
   '변경관리 시스템에 테스트 결과서 첨부를 필수 항목으로 설정하지 않음',
   '변경관리 시스템에 테스트 결과서 필수 첨부 제어 기능 추가',
   '2026-01-29','2026-03-15',NULL,'조치중',75,
   '시스템 설정 변경 완료, 현장 적용 교육 예정'),

  ('GRP-A','FND-2026-004','운영평가',
   '배치 모니터링 알람 미동작',
   '2025년 4분기 평가에서 야간 배치 실패 20건 중 알람이 전혀 발송되지 않은 사실 확인',
   'CTRL-OPS-001','IT-OPS-001',
   '심각','IT운영팀','전운영',
   '배치 실패 미인지로 인한 데이터 처리 오류 및 재무 데이터 부정확성 가능',
   '모니터링 솔루션의 알람 수신인 설정이 초기화되어 있었으며 재설정 절차 미비',
   '모니터링 솔루션 알람 설정 검토 및 에스컬레이션 체계 재정립, 주간 알람 점검 수행',
   '2025-10-31','2025-12-31','2025-12-20','조치완료',100,
   '2025-12-20 모니터링 솔루션 재설정 및 에스컬레이션 체계 수립 완료'),

  ('GRP-A','FND-2026-005','운영평가',
   '특권 계정 3건 미회수',
   '2025년 4분기 특권 계정 재검토 시 퇴직자 포함 불필요 계정 3건이 미삭제 상태로 확인',
   'CTRL-ACC-002','IT-ACC-001',
   '높음','정보보안팀','이보안',
   '전 직원 계정을 통한 핵심 시스템 무단 접근 위험',
   '특권 계정 재검토 결과를 IT 시스템에 즉시 반영하는 연계 절차 미비',
   '재검토 결과 확인 즉시 계정 비활성화, 재검토-처리 SLA 명문화',
   '2025-10-14','2025-10-31','2025-10-28','조치완료',100,
   '2025-10-28 3건 계정 삭제 완료'),

  ('GRP-A','FND-2026-006','내부감사',
   '데이터 전송 무결성 검증 미수행',
   'ERP와 경영분석 시스템 간 데이터 인터페이스에 무결성 검증(해시값 비교) 절차 부재',
   'CTRL-OPS-003','IT-DATA-001',
   '중간','DBA팀','강DBA',
   '데이터 오류·변조가 탐지되지 않아 경영 의사결정에 잘못된 정보가 활용될 위험',
   '인터페이스 설계 시 무결성 검증 요건이 반영되지 않았고 운영 중 보완도 미이행',
   '인터페이스 전후 해시값 검증 로직 구현 및 월 1회 정기 정합성 점검 절차 수립',
   '2026-02-15','2026-05-31',NULL,'미결',0,NULL),

  ('GRP-A','FND-2026-007','자체점검',
   '긴급변경 사후 승인 미이행 2건',
   '2025년 3분기 긴급변경 2건이 변경위원회 사후 승인 없이 48시간을 경과한 것으로 확인',
   'CTRL-CHG-003','IT-CHG-001',
   '중간','개발팀','한개발',
   '긴급변경의 적절성 검증 불가 및 통제 체계 형해화 우려',
   '긴급변경 처리 후 사후 승인 요청 트리거가 자동화되지 않음',
   '긴급변경 시스템에 사후 승인 자동 알림 및 기한(48시간) 준수 모니터링 기능 추가',
   '2025-07-15','2025-09-30','2025-09-25','조치완료',100,
   '2025-09-25 긴급변경 자동 알림 기능 구현 완료'),

  ('GRP-A','FND-2026-008','운영평가',
   '가용성 SLA 미충족 (5분 서비스 중단)',
   '2026-02-05 오전 2시 핵심 ERP 시스템이 5분간 서비스 중단, 월간 SLA 99.95% 미충족',
   'CTRL-OPS-002','IT-OPS-002',
   '낮음','IT운영팀','전운영',
   '업무 처리 지연 및 고객 서비스 품질 저하 가능',
   '스토리지 I/O 병목 현상 발생, 사전 용량 계획 미흡',
   '스토리지 용량 계획 절차 수립 및 분기 1회 사전 점검 수행',
   '2026-02-06','2026-04-30',NULL,'조치중',30,
   '스토리지 증설 계획 수립 중')
) AS f(org_code, fno, ftype, title, description, ctrl_code, risk_code,
        severity, dept, owner, impact, root, recom,
        disc_dt, due_dt, comp_dt, status, progress, plan)
  ON p.org_code = f.org_code
 AND ctrl.control_code = f.ctrl_code
 AND risk.risk_code    = f.risk_code
ON CONFLICT (finding_no) DO NOTHING;

-- ============================================================
-- 10. 개선 조치 이력 (itgc_remediation_history)
-- ============================================================
INSERT INTO itgc_remediation_history
  (finding_id, action_date, action_type, previous_status, new_status,
   previous_progress, new_progress, comment, action_by)
SELECT fi.id,
       h.act_date::TIMESTAMP, h.act_type,
       h.prev_status, h.new_status,
       h.prev_prog, h.new_prog,
       h.comment, h.act_by
FROM itgc_finding fi
JOIN (VALUES
  -- FND-2026-001 이력
  ('FND-2026-001','2026-01-09 09:00:00','상태변경','미결','조치중',0,10,'담당자 배정 및 조치 착수','kim.audit'),
  ('FND-2026-001','2026-01-20 14:00:00','진행률갱신','조치중','조치중',10,30,'시스템 개발 요건 정의 완료','이보안'),
  ('FND-2026-001','2026-02-05 16:00:00','진행률갱신','조치중','조치중',30,60,'개발 완료, 테스트 진행 중','이보안'),
  ('FND-2026-001','2026-02-10 10:00:00','코멘트',NULL,NULL,60,60,'경영층 보고 완료, 3월 운영 반영 예정','kim.audit'),

  -- FND-2026-002 이력
  ('FND-2026-002','2026-01-17 09:00:00','상태변경','미결','조치중',0,10,'HR팀 및 IT팀 공동 TF 구성','kim.audit'),
  ('FND-2026-002','2026-02-01 11:00:00','진행률갱신','조치중','조치중',10,40,'API 설계 문서 완료','최시스템'),
  ('FND-2026-002','2026-02-20 15:00:00','코멘트',NULL,NULL,40,40,'개발 일정 확인 요청','kim.audit'),

  -- FND-2026-003 이력
  ('FND-2026-003','2026-01-30 10:00:00','상태변경','미결','조치중',0,20,'시스템 담당자 조치 지시','kim.audit'),
  ('FND-2026-003','2026-02-10 14:00:00','진행률갱신','조치중','조치중',20,75,'변경관리 시스템 설정 변경 완료','한개발'),
  ('FND-2026-003','2026-02-25 09:00:00','코멘트',NULL,NULL,75,75,'현장 교육 일정 조율 중','박검토'),

  -- FND-2026-004 이력 (조치완료)
  ('FND-2026-004','2025-11-01 09:00:00','상태변경','미결','조치중',0,20,'원인 분석 착수','전운영'),
  ('FND-2026-004','2025-11-15 14:00:00','진행률갱신','조치중','조치중',20,50,'알람 설정 복구 및 추가 설정','전운영'),
  ('FND-2026-004','2025-12-01 10:00:00','진행률갱신','조치중','조치중',50,80,'에스컬레이션 체계 정립','전운영'),
  ('FND-2026-004','2025-12-20 17:00:00','상태변경','조치중','조치완료',80,100,'전체 조치 완료 확인','kim.audit'),
  ('FND-2026-004','2025-12-20 17:30:00','증빙첨부',NULL,NULL,100,100,'조치결과보고서 첨부','kim.audit'),

  -- FND-2026-005 이력 (조치완료)
  ('FND-2026-005','2025-10-15 09:00:00','상태변경','미결','조치중',0,30,'계정 회수 지시','이보안'),
  ('FND-2026-005','2025-10-28 11:00:00','상태변경','조치중','조치완료',30,100,'3건 계정 삭제 완료 확인','kim.audit'),

  -- FND-2026-006 이력
  ('FND-2026-006','2026-02-16 09:00:00','상태변경','미결','미결',0,0,'발견사항 공식 등록','kim.audit'),
  ('FND-2026-006','2026-02-20 14:00:00','코멘트',NULL,NULL,0,0,'담당부서 인지 및 조치 계획 수립 요청','kim.audit'),

  -- FND-2026-007 이력 (조치완료)
  ('FND-2026-007','2025-07-16 09:00:00','상태변경','미결','조치중',0,30,'시스템 개선 요청','한개발'),
  ('FND-2026-007','2025-09-10 15:00:00','진행률갱신','조치중','조치중',30,80,'자동 알림 기능 개발 완료','한개발'),
  ('FND-2026-007','2025-09-25 17:00:00','상태변경','조치중','조치완료',80,100,'운영 반영 및 테스트 완료','kim.audit'),

  -- FND-2026-008 이력
  ('FND-2026-008','2026-02-07 09:00:00','상태변경','미결','조치중',0,10,'스토리지 팀 조치 지시','전운영'),
  ('FND-2026-008','2026-02-20 14:00:00','진행률갱신','조치중','조치중',10,30,'스토리지 증설 예산 요청','전운영')
) AS h(fno, act_date, act_type, prev_status, new_status, prev_prog, new_prog, comment, act_by)
  ON fi.finding_no = h.fno;

-- ============================================================
-- 11. 보고서 (itgc_report)
-- ============================================================
INSERT INTO itgc_report
  (org_id, report_type, title, eval_year, eval_quarter,
   target_company, format, language, file_path, file_size, status, created_by)
SELECT p.id,
       r.rtype, r.title, r.yr, r.qtr,
       r.target, r.fmt, r.lang, r.fpath, r.fsize, r.status, r.created_by
FROM itgc_organization p
JOIN (VALUES
  ('GRP-HOLD','COSO종합',
   '2025년 3분기 COSO 내부통제 종합 보고서',
   2025,3,'(주)그룹사A','PDF','한국어',
   '/reports/2025/Q3/COSO_COMPREHENSIVE_2025Q3.pdf',1245678,'완료','admin'),

  ('GRP-HOLD','COSO종합',
   '2025년 4분기 COSO 내부통제 종합 보고서',
   2025,4,'(주)그룹사A','PDF','한국어',
   '/reports/2025/Q4/COSO_COMPREHENSIVE_2025Q4.pdf',1389012,'완료','admin'),

  ('GRP-A','운영평가결과',
   '2025년 3분기 IT 일반통제 운영평가 결과 보고서',
   2025,3,'(주)그룹사A','PDF','한국어',
   '/reports/2025/Q3/EVAL_RESULT_2025Q3.pdf',987654,'완료','kim.audit'),

  ('GRP-A','운영평가결과',
   '2025년 4분기 IT 일반통제 운영평가 결과 보고서',
   2025,4,'(주)그룹사A','PDF','한국어',
   '/reports/2025/Q4/EVAL_RESULT_2025Q4.pdf',1102345,'완료','kim.audit'),

  ('GRP-A','위험평가',
   '2026년 상반기 IT 위험평가 결과 보고서',
   2026,NULL,'(주)그룹사A','Excel','한국어',
   '/reports/2026/H1/RISK_ASSESSMENT_2026H1.xlsx',456789,'완료','kim.audit'),

  ('GRP-A','발견사항현황',
   '2026년 1분기 발견사항 및 개선조치 현황 보고서',
   2026,1,'(주)그룹사A','PDF','한국어',
   '/reports/2026/Q1/FINDING_STATUS_2026Q1.pdf',789012,'완료','kim.audit'),

  ('GRP-HOLD','COSO종합',
   '2026년 1분기 COSO 내부통제 종합 보고서 (생성중)',
   2026,1,'전체 그룹사','PDF','한국어',
   NULL,NULL,'생성중','admin')
) AS r(org_code, rtype, title, yr, qtr, target, fmt, lang, fpath, fsize, status, created_by)
  ON p.org_code = r.org_code;

-- ============================================================
-- 12. COSO 설정 (itgc_coso_config)
-- ============================================================
INSERT INTO itgc_coso_config (config_key, config_value, config_type, description)
VALUES
  -- COSO 구성요소별 가중치 (합계 100)
  ('weight.CE', '25', 'WEIGHT',    'COSO 통제환경(CE) 가중치(%)'),
  ('weight.RA', '20', 'WEIGHT',    'COSO 위험평가(RA) 가중치(%)'),
  ('weight.CA', '25', 'WEIGHT',    'COSO 통제활동(CA) 가중치(%)'),
  ('weight.IC', '15', 'WEIGHT',    'COSO 정보및의사소통(IC) 가중치(%)'),
  ('weight.MA', '15', 'WEIGHT',    'COSO 모니터링(MA) 가중치(%)'),
  -- 위험 수준 임계값
  ('threshold.critical.min',  '20', 'THRESHOLD', '심각 위험 최솟값 (가능성×영향도)'),
  ('threshold.critical.max',  '25', 'THRESHOLD', '심각 위험 최댓값'),
  ('threshold.high.min',      '12', 'THRESHOLD', '높음 위험 최솟값'),
  ('threshold.high.max',      '19', 'THRESHOLD', '높음 위험 최댓값'),
  ('threshold.medium.min',     '6', 'THRESHOLD', '중간 위험 최솟값'),
  ('threshold.medium.max',    '11', 'THRESHOLD', '중간 위험 최댓값'),
  ('threshold.low.min',        '3', 'THRESHOLD', '낮음 위험 최솟값'),
  ('threshold.low.max',        '5', 'THRESHOLD', '낮음 위험 최댓값'),
  -- 샘플링 기준
  ('sampling.default_method',     '확률적', 'SAMPLING', '기본 샘플링 방법'),
  ('sampling.exception_threshold', '10',    'SAMPLING', '예외율 임계값(%) — 이 초과 시 비효과적 판정'),
  ('sampling.min_population',       '1',    'SAMPLING', '전수 검토 적용 최대 모집단'),
  ('sampling.confidence_level',    '90',    'SAMPLING', '통계적 샘플링 신뢰 수준(%)'),
  -- 알림 설정
  ('alert.overdue_days',            '7',    'ALERT',    '기한 도래 사전 알림(일 전)'),
  ('alert.escalation_days',        '14',    'ALERT',    '기한 초과 에스컬레이션 기준(일)'),
  ('alert.email_notification',   'true',    'ALERT',    '이메일 알림 활성화 여부'),
  -- 일반 설정
  ('general.eval_period',     'QUARTERLY', 'GENERAL', '기본 평가 주기 (QUARTERLY/SEMI-ANNUAL/ANNUAL)'),
  ('general.auto_report',          'true', 'GENERAL', '평가 완료 시 보고서 자동 생성'),
  ('general.auto_finding',         'true', 'GENERAL', '비효과적 결과 발생 시 발견사항 자동 생성'),
  ('general.doc_retention_years',     '5', 'GENERAL', '평가 증빙 서류 보관 연한(년)')
ON CONFLICT (config_key) DO NOTHING;

COMMIT;

-- 적용 결과 확인
SELECT
    (SELECT COUNT(*) FROM itgc_organization)        AS organizations,
    (SELECT COUNT(*) FROM itgc_user)                AS users,
    (SELECT COUNT(*) FROM itgc_risk)                AS risks,
    (SELECT COUNT(*) FROM itgc_control)             AS controls,
    (SELECT COUNT(*) FROM itgc_risk_control_mapping) AS risk_ctrl_mappings,
    (SELECT COUNT(*) FROM itgc_eval_plan)           AS eval_plans,
    (SELECT COUNT(*) FROM itgc_eval_sample)         AS eval_samples,
    (SELECT COUNT(*) FROM itgc_eval_result)         AS eval_results,
    (SELECT COUNT(*) FROM itgc_finding)             AS findings,
    (SELECT COUNT(*) FROM itgc_remediation_history) AS remediation_histories,
    (SELECT COUNT(*) FROM itgc_report)              AS reports,
    (SELECT COUNT(*) FROM itgc_coso_config)         AS coso_configs;
