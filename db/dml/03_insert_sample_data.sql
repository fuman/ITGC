-- ============================================================
-- ITGC 포털 - 샘플 데이터 (개발/테스트용)
-- ============================================================

-- ========== 조직 ==========
INSERT INTO itgc_organization (org_code, org_name, org_type, head_name, itgc_owner, sort_order)
VALUES
  ('GRP-HOLD', '(주)그룹홀딩스',  'COMPANY', '김회장',  '이감사팀장', 1),
  ('GRP-A',    '(주)그룹사A',      'COMPANY', '최대표',  '박감사',     2),
  ('GRP-B',    '(주)그룹사B',      'COMPANY', '정대표',  '김감사',     3),
  ('GRP-C',    '(주)그룹사C',      'COMPANY', '이대표',  '최감사',     4)
ON CONFLICT (org_code) DO NOTHING;

INSERT INTO itgc_organization (parent_id, org_code, org_name, org_type, head_name, itgc_owner, sort_order)
SELECT o.id, d.org_code, d.org_name, 'DEPT', d.head_name, d.itgc_owner, d.sort_order
FROM itgc_organization o,
     (VALUES
       ('GRP-A', 'DEPT-IT-OPS',  'IT운영팀',     '박팀장',  '박운영',    1),
       ('GRP-A', 'DEPT-IT-SEC',  '정보보안팀',   '이팀장',  '이보안',    2),
       ('GRP-A', 'DEPT-DEV',     '개발팀',       '김팀장',  '김개발',    3),
       ('GRP-A', 'DEPT-INFRA',   'IT인프라팀',   '정팀장',  '정인프라',  4),
       ('GRP-A', 'DEPT-DBA',     'DBA팀',        '안팀장',  '김DBA',     5),
       ('GRP-A', 'DEPT-HR-SYS',  'HR시스템팀',   '조팀장',  '최시스템',  6),
       ('GRP-A', 'DEPT-AUDIT',   '감사팀',       '윤팀장',  '김감사',    7)
     ) AS d(parent_code, org_code, org_name, head_name, itgc_owner, sort_order)
WHERE o.org_code = d.parent_code
ON CONFLICT (org_code) DO NOTHING;

-- ========== 사용자 ==========
INSERT INTO itgc_user (org_id, username, password, name, email, dept, role, company)
SELECT o.id, u.username, '$2a$10$rM/encrypted.password.hash.example', u.name, u.email, u.dept, u.role::VARCHAR, u.company
FROM itgc_organization o,
     (VALUES
       ('GRP-HOLD', 'admin',        '관리자',   'admin@group.com',            'IT기획팀',   'ADMIN',   '(주)그룹홀딩스'),
       ('GRP-A',    'kim.audit',    '김감사',   'kim.itaudit@group-a.com',    'IT감사팀',   'LEAD',    '(주)그룹사A'),
       ('GRP-A',    'lee.security', '이보안',   'lee.security@group-a.com',   '정보보안팀', 'OWNER',   '(주)그룹사A'),
       ('GRP-A',    'park.review',  '박검토',   'park.review@group-a.com',    'IT감사팀',   'AUDITOR', '(주)그룹사A'),
       ('GRP-A',    'choi.system',  '최시스템', 'choi.system@group-a.com',    'HR시스템팀', 'OWNER',   '(주)그룹사A'),
       ('GRP-A',    'jung.infra',   '정인프라', 'jung.infra@group-a.com',     'IT인프라팀', 'OWNER',   '(주)그룹사A')
     ) AS u(parent_code, username, name, email, dept, role, company)
WHERE o.org_code = u.parent_code
ON CONFLICT (username) DO NOTHING;

-- ========== 위험 ==========
INSERT INTO itgc_risk
  (org_id, risk_code, category, risk_name, risk_description,
   inherent_likelihood, inherent_impact,
   residual_likelihood, residual_impact,
   risk_owner, dept, status, related_process)
SELECT o.id, r.risk_code, r.category, r.risk_name, r.risk_description,
       r.inh_l, r.inh_i, r.res_l, r.res_i,
       r.risk_owner, r.dept, r.status, r.process
FROM itgc_organization o,
     (VALUES
       ('GRP-A','IT-SEC-001','IT-SEC','권한 없는 시스템 접근',
        '내부 또는 외부 사용자가 권한 없이 중요 시스템에 접근할 위험',
        4,5,2,5,'이보안','정보보안팀','활성','ERP 운영,인사관리'),
       ('GRP-A','IT-CHG-001','IT-CHG','미승인 시스템 변경',
        '정식 변경관리 프로세스 없이 운영 환경에 변경이 적용될 위험',
        3,4,2,4,'김개발','개발팀','활성','시스템 개발'),
       ('GRP-A','IT-OPS-001','IT-OPS','배치 처리 실패 미탐지',
        '중요 배치 작업 실패 시 적시에 탐지하지 못할 위험',
        3,4,3,4,'박운영','IT운영팀','활성','배치처리'),
       ('GRP-A','IT-ACC-001','IT-ACC','퇴직자 계정 미삭제',
        '임직원 퇴직 후 시스템 접근 권한이 적시에 회수되지 않을 위험',
        4,3,3,3,'최시스템','HR시스템팀','활성','인사관리'),
       ('GRP-A','IT-BCM-001','IT-BCM','재해복구 시스템 미검증',
        'DR 시스템의 실제 복구 능력을 정기적으로 검증하지 않을 위험',
        2,5,2,5,'정인프라','IT인프라팀','모니터링','IT인프라운영'),
       ('GRP-A','IT-DATA-001','IT-DATA','데이터 무결성 미검증',
        '시스템 간 데이터 전송 시 무결성 검증이 수행되지 않을 위험',
        3,3,3,3,'김DBA','DBA팀','활성','데이터관리'),
       ('GRP-A','IT-SEC-002','IT-SEC','패치 관리 미흡',
        '운영 시스템의 보안 패치가 적시에 적용되지 않아 취약점 노출 위험',
        3,4,2,4,'이보안','정보보안팀','활성','IT인프라운영'),
       ('GRP-A','IT-ACC-002','IT-ACC','과도한 접근 권한 부여',
        '업무에 필요한 최소 권한 원칙이 준수되지 않는 위험',
        3,4,2,3,'이보안','정보보안팀','활성','접근통제')
     ) AS r(org_code, risk_code, category, risk_name, risk_description,
            inh_l, inh_i, res_l, res_i, risk_owner, dept, status, process)
WHERE o.org_code = r.org_code
ON CONFLICT (risk_code) DO NOTHING;

-- ========== 통제 ==========
INSERT INTO itgc_control
  (org_id, control_code, domain, coso_component, control_name, control_objective,
   control_type, automation, frequency, control_owner, dept,
   is_key_control, effectiveness, design_adequacy)
SELECT o.id, c.ctl_code, c.domain, c.coso, c.ctl_name, c.objective,
       c.ctl_type, c.auto, c.freq, c.owner, c.dept,
       c.is_key, c.effectiveness::VARCHAR, c.design::VARCHAR
FROM itgc_organization o,
     (VALUES
       ('GRP-A','CTRL-ACC-001','접근통제','CA','사용자 계정 등록/변경/삭제 승인','권한 없는 접근 방지',
        '예방통제','수동','수시','이보안','정보보안팀',TRUE,'효과적','적합'),
       ('GRP-A','CTRL-ACC-002','접근통제','CA','특권 계정 반기 재검토','과도한 권한 방지',
        '탐지통제','수동','반기','이보안','정보보안팀',TRUE,'부분 효과적','부분 적합'),
       ('GRP-A','CTRL-ACC-003','접근통제','CA','신규 입사자 계정 발급 통제','적시 계정 생성 및 최소 권한 부여',
        '예방통제','반자동','수시','이보안','정보보안팀',FALSE,'효과적','적합'),
       ('GRP-A','CTRL-CHG-001','변경관리','CA','변경 요청 및 승인 관리','미승인 변경 방지',
        '예방통제','반자동','수시','김개발','개발팀',TRUE,'효과적','적합'),
       ('GRP-A','CTRL-CHG-002','변경관리','CA','변경 후 테스트 및 검증','변경 오류 탐지',
        '탐지통제','수동','수시','김개발','개발팀',FALSE,'부분 효과적','적합'),
       ('GRP-A','CTRL-CHG-003','변경관리','CA','긴급변경 사후 승인 검토','긴급변경 통제 보완',
        '탐지통제','수동','수시','김개발','개발팀',FALSE,'부분 효과적','부분 적합'),
       ('GRP-A','CTRL-OPS-001','IT운영','CA','배치 작업 모니터링','배치 오류 조기 탐지',
        '탐지통제','자동','일일','박운영','IT운영팀',FALSE,'비효과적','부적합'),
       ('GRP-A','CTRL-OPS-002','IT운영','CA','시스템 성능 모니터링','성능 저하 사전 탐지',
        '탐지통제','자동','상시','박운영','IT운영팀',FALSE,'효과적','적합'),
       ('GRP-A','CTRL-BCM-001','업무연속성','MA','DR 테스트 실시','복구 능력 검증',
        '탐지통제','수동','반기','정인프라','IT인프라팀',TRUE,'미평가','미평가'),
       ('GRP-A','CTRL-BCM-002','업무연속성','MA','백업 데이터 무결성 검증','백업 신뢰성 확보',
        '탐지통제','자동','일일','정인프라','IT인프라팀',TRUE,'효과적','적합'),
       ('GRP-A','CTRL-SEC-001','정보보안','CA','취약점 정기 스캔','보안 취약점 조기 탐지',
        '탐지통제','자동','월간','이보안','정보보안팀',FALSE,'효과적','적합'),
       ('GRP-A','CTRL-SEC-002','정보보안','CA','보안 패치 적용 통제','취약점 패치 적시 적용',
        '예방통제','반자동','월간','이보안','정보보안팀',FALSE,'부분 효과적','적합')
     ) AS c(org_code, ctl_code, domain, coso, ctl_name, objective,
            ctl_type, auto, freq, owner, dept, is_key, effectiveness, design)
WHERE o.org_code = c.org_code
ON CONFLICT (control_code) DO NOTHING;

-- ========== 위험-통제 매핑 ==========
INSERT INTO itgc_risk_control_mapping (risk_id, control_id, risk_code, control_code, mapping_type, coverage_ratio, is_key_mapping)
SELECT r.id, c.id, r.risk_code, c.control_code, m.mapping_type, m.coverage_ratio, m.is_key
FROM itgc_risk r, itgc_control c,
     (VALUES
       ('IT-SEC-001','CTRL-ACC-001','직접',70,TRUE),
       ('IT-SEC-001','CTRL-ACC-002','직접',20,FALSE),
       ('IT-CHG-001','CTRL-CHG-001','직접',80,TRUE),
       ('IT-CHG-001','CTRL-CHG-002','지원',40,FALSE),
       ('IT-OPS-001','CTRL-OPS-001','직접',85,TRUE),
       ('IT-ACC-001','CTRL-ACC-001','직접',60,TRUE),
       ('IT-ACC-001','CTRL-ACC-002','직접',30,FALSE),
       ('IT-BCM-001','CTRL-BCM-001','직접',90,TRUE),
       ('IT-BCM-001','CTRL-BCM-002','지원',50,FALSE),
       ('IT-DATA-001','CTRL-OPS-001','지원',40,FALSE),
       ('IT-SEC-002','CTRL-SEC-001','직접',70,TRUE),
       ('IT-SEC-002','CTRL-SEC-002','직접',80,TRUE),
       ('IT-ACC-002','CTRL-ACC-002','직접',75,TRUE),
       ('IT-ACC-002','CTRL-ACC-003','직접',60,FALSE)
     ) AS m(risk_code, ctrl_code, mapping_type, coverage_ratio, is_key)
WHERE r.risk_code = m.risk_code AND c.control_code = m.ctrl_code
ON CONFLICT (risk_id, control_id) DO NOTHING;

-- ========== 운영평가 계획 ==========
INSERT INTO itgc_eval_plan (org_id, eval_year, eval_quarter, control_id, control_code, control_name, domain, assignee, planned_start_date, planned_end_date, sampling_count, sampling_method, status)
SELECT o.id, 2026, 1, c.id, c.control_code, c.control_name, c.domain,
       p.assignee, p.start_dt::DATE, p.end_dt::DATE, p.sample_cnt, p.method, p.status
FROM itgc_organization o, itgc_control c,
     (VALUES
       ('GRP-A','CTRL-ACC-001','이보안','2026-03-01','2026-03-07',25,'확률적','완료'),
       ('GRP-A','CTRL-ACC-002','이보안','2026-03-08','2026-03-14', 1,'전수',  '진행중'),
       ('GRP-A','CTRL-CHG-001','박검토','2026-03-15','2026-03-21',30,'확률적','진행중'),
       ('GRP-A','CTRL-CHG-002','박검토','2026-03-15','2026-03-21',25,'비통계적','예정'),
       ('GRP-A','CTRL-OPS-001','김감사','2026-03-22','2026-03-31',20,'비통계적','예정'),
       ('GRP-A','CTRL-BCM-001','김감사','2026-04-01','2026-04-15', 1,'전수',  '예정'),
       ('GRP-A','CTRL-SEC-001','이보안','2026-04-16','2026-04-30', 3,'전수',  '예정'),
       ('GRP-A','CTRL-BCM-002','정인프라','2026-03-01','2026-03-31',5,'전수', '완료')
     ) AS p(org_code, ctrl_code, assignee, start_dt, end_dt, sample_cnt, method, status)
WHERE o.org_code = p.org_code AND c.control_code = p.ctrl_code
ON CONFLICT DO NOTHING;

-- ========== 발견사항 ==========
INSERT INTO itgc_finding
  (org_id, finding_no, finding_type, title, description,
   related_control, related_risk, severity, dept, owner,
   risk_impact, root_cause, recommendation,
   discovery_date, due_date, status, remediation_progress, remediation_plan)
SELECT o.id, f.fno, f.ftype, f.title, f.desc,
       f.ctrl, f.risk, f.sev, f.dept, f.owner,
       f.impact, f.root, f.recom,
       f.disc_dt::DATE, f.due_dt::DATE, f.status, f.progress, f.plan
FROM itgc_organization o,
     (VALUES
       ('GRP-A','FND-2026-001','운영평가','관리자 계정 다중 사용 발견',
        '복수의 사용자가 동일한 관리자 계정을 공유 사용하는 것이 발견됨',
        'CTRL-ACC-001','IT-SEC-001','심각','정보보안팀','이보안',
        '개인 책임 추적 불가능, 권한 남용 위험 증가',
        '개인 계정 발급 절차 미비 및 관리자 계정 관리 정책 부재',
        '개인별 관리자 계정 발급 및 MFA 적용, 공유 계정 즉시 삭제',
        '2026-03-07','2026-03-15','조치중',65,'개인 계정 재발급 진행 중'),
       ('GRP-A','FND-2026-002','운영평가','퇴직자 계정 15건 미삭제',
        '반기 재검토 결과 퇴직자 15명의 시스템 계정이 활성 상태로 유지됨',
        'CTRL-ACC-002','IT-ACC-001','높음','HR시스템팀','최시스템',
        '퇴직자의 불법 접근 가능성, 정보 유출 위험',
        'HR 시스템과 IT 시스템 간의 퇴직 정보 연동 프로세스 미비',
        'HR-IT 시스템 연동 자동화, 퇴직 당일 계정 비활성화 프로세스 수립',
        '2026-03-14','2026-03-10','기한초과',30,'HR-IT 연동 개발 착수'),
       ('GRP-A','FND-2026-003','운영평가','미승인 변경 3건 발생',
        '긴급 상황을 이유로 승인 없이 운영 환경에 직접 변경이 적용된 사례 3건 발견',
        'CTRL-CHG-001','IT-CHG-001','높음','개발팀','김개발',
        '운영 환경 안정성 위협, 추적 불가 변경으로 인한 오류 발생 가능',
        '긴급변경 절차가 명확하지 않으며 사후 승인 처리도 미이행',
        '긴급변경 절차 수립, 사후 승인 의무화 및 모니터링 강화',
        '2026-03-21','2026-04-05','조치완료',100,'긴급변경 절차 수립 완료'),
       ('GRP-A','FND-2026-004','운영평가','배치 오류 무감지 운영',
        '야간 배치 처리 실패 시 담당자에게 알림이 전달되지 않아 오류가 방치됨',
        'CTRL-OPS-001','IT-OPS-001','중간','IT운영팀','박운영',
        '데이터 처리 지연, 보고서 오류 및 재무 데이터 부정확성 가능',
        '모니터링 시스템의 알람 정책 미수립 및 에스컬레이션 체계 부재',
        '배치 모니터링 솔루션 도입 및 알람 임계값 설정, 에스컬레이션 체계 수립',
        '2026-02-25','2026-04-30','조치중',45,'모니터링 솔루션 검토 중'),
       ('GRP-A','FND-2026-005','내부감사','데이터 정합성 검증 누락',
        'ERP와 분석 시스템 간 데이터 전송 시 무결성 검증 절차가 수행되지 않음',
        NULL,'IT-DATA-001','중간','DBA팀','김DBA',
        '경영 의사결정에 활용되는 데이터의 신뢰성 저하',
        '시스템 인터페이스 설계 시 무결성 검증 요건이 반영되지 않음',
        '데이터 전송 전후 해시값 검증 로직 구현, 정기 데이터 정합성 점검 수행',
        '2026-02-10','2026-05-31','미결',0,NULL)
     ) AS f(org_code, fno, ftype, title, desc, ctrl, risk, sev, dept, owner,
            impact, root, recom, disc_dt, due_dt, status, progress, plan)
WHERE o.org_code = f.org_code
ON CONFLICT (finding_no) DO NOTHING;

-- ========== COSO 설정 초기값 ==========
INSERT INTO itgc_coso_config (config_key, config_value, config_type, description)
VALUES
  ('weight.control_environment',       '25', 'WEIGHT',    'COSO 통제환경 가중치(%)'),
  ('weight.risk_assessment',           '20', 'WEIGHT',    'COSO 위험평가 가중치(%)'),
  ('weight.control_activities',        '25', 'WEIGHT',    'COSO 통제활동 가중치(%)'),
  ('weight.information_communication', '15', 'WEIGHT',    'COSO 정보및의사소통 가중치(%)'),
  ('weight.monitoring_activities',     '15', 'WEIGHT',    'COSO 모니터링 가중치(%)'),
  ('threshold.critical.min',           '20', 'THRESHOLD', '심각 위험 최솟값'),
  ('threshold.critical.max',           '25', 'THRESHOLD', '심각 위험 최댓값'),
  ('threshold.high.min',               '12', 'THRESHOLD', '높음 위험 최솟값'),
  ('threshold.high.max',               '19', 'THRESHOLD', '높음 위험 최댓값'),
  ('threshold.medium.min',             '6',  'THRESHOLD', '중간 위험 최솟값'),
  ('threshold.medium.max',             '11', 'THRESHOLD', '중간 위험 최댓값'),
  ('threshold.low.min',                '3',  'THRESHOLD', '낮음 위험 최솟값'),
  ('threshold.low.max',                '5',  'THRESHOLD', '낮음 위험 최댓값'),
  ('sampling.default_method',          '확률적', 'SAMPLING', '기본 샘플링 방법'),
  ('sampling.exception_threshold',     '10', 'SAMPLING',  '예외율 임계값(%)'),
  ('alert.overdue_days',               '7',  'ALERT',     '기한 도래 알림(일 전)'),
  ('general.auto_report',              'true','GENERAL',  '평가 보고서 자동 생성 여부')
ON CONFLICT (config_key) DO NOTHING;
