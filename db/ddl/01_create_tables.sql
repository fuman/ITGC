-- ============================================================
-- ITGC 포털 - PostgreSQL DDL
-- COSO 2013 Framework 기반 IT 일반통제 관리 시스템
-- 작성일: 2026-03-04
-- ============================================================

-- 스키마 생성 (선택)
-- CREATE SCHEMA itgc AUTHORIZATION itgc_user;
-- SET search_path = itgc, public;

-- ============================================================
-- 공통 함수
-- ============================================================

-- 위험 수준 계산 함수
CREATE OR REPLACE FUNCTION fn_calc_risk_level(p_likelihood INT, p_impact INT)
RETURNS VARCHAR AS $$
DECLARE
    v_score INT;
BEGIN
    v_score := COALESCE(p_likelihood, 0) * COALESCE(p_impact, 0);
    IF    v_score >= 20 THEN RETURN '심각';
    ELSIF v_score >= 12 THEN RETURN '높음';
    ELSIF v_score >= 6  THEN RETURN '중간';
    ELSIF v_score >= 3  THEN RETURN '낮음';
    ELSE                     RETURN '미미';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- updated_at 자동 갱신 함수
CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 1. 조직 테이블 (그룹사 / 부서)
-- ============================================================
CREATE TABLE IF NOT EXISTS itgc_organization (
    id              BIGSERIAL       PRIMARY KEY,
    parent_id       BIGINT          REFERENCES itgc_organization(id) ON DELETE SET NULL,
    org_code        VARCHAR(50)     NOT NULL UNIQUE,
    org_name        VARCHAR(200)    NOT NULL,
    org_type        VARCHAR(20)     NOT NULL CHECK (org_type IN ('COMPANY','DEPT')),
    head_name       VARCHAR(100),
    itgc_owner      VARCHAR(100),
    sort_order      INT             DEFAULT 0,
    is_active       BOOLEAN         DEFAULT TRUE,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    created_by      VARCHAR(100),
    updated_by      VARCHAR(100)
);

CREATE TRIGGER trg_org_updated_at
    BEFORE UPDATE ON itgc_organization
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

COMMENT ON TABLE  itgc_organization              IS '조직 테이블 (그룹사/부서)';
COMMENT ON COLUMN itgc_organization.org_type     IS 'COMPANY: 그룹사, DEPT: 부서';

-- ============================================================
-- 2. 사용자 테이블
-- ============================================================
CREATE TABLE IF NOT EXISTS itgc_user (
    id              BIGSERIAL       PRIMARY KEY,
    org_id          BIGINT          REFERENCES itgc_organization(id),
    username        VARCHAR(100)    NOT NULL UNIQUE,
    password        VARCHAR(255)    NOT NULL,
    name            VARCHAR(100)    NOT NULL,
    email           VARCHAR(200)    NOT NULL UNIQUE,
    dept            VARCHAR(100),
    role            VARCHAR(50)     NOT NULL DEFAULT 'VIEWER'
                                    CHECK (role IN ('ADMIN','LEAD','AUDITOR','OWNER','VIEWER')),
    company         VARCHAR(200),
    last_login      TIMESTAMP,
    is_active       BOOLEAN         DEFAULT TRUE,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    created_by      VARCHAR(100)
);

CREATE TRIGGER trg_user_updated_at
    BEFORE UPDATE ON itgc_user
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

COMMENT ON TABLE  itgc_user         IS '사용자 테이블';
COMMENT ON COLUMN itgc_user.role    IS 'ADMIN:시스템관리자, LEAD:IT감사팀장, AUDITOR:IT감사자, OWNER:통제담당자, VIEWER:열람자';

-- ============================================================
-- 3. 위험 테이블 (COSO - 위험 평가)
-- ============================================================
CREATE TABLE IF NOT EXISTS itgc_risk (
    id                      BIGSERIAL       PRIMARY KEY,
    org_id                  BIGINT          REFERENCES itgc_organization(id),
    risk_code               VARCHAR(50)     NOT NULL UNIQUE,
    category                VARCHAR(50)     NOT NULL,
    -- IT-OPS: IT운영, IT-SEC: 정보보안, IT-CHG: 변경관리, IT-ACC: 접근통제, IT-BCM: 업무연속성, IT-DATA: 데이터무결성
    risk_name               VARCHAR(200)    NOT NULL,
    risk_description        TEXT,
    inherent_likelihood     SMALLINT        NOT NULL CHECK (inherent_likelihood BETWEEN 1 AND 5),
    inherent_impact         SMALLINT        NOT NULL CHECK (inherent_impact     BETWEEN 1 AND 5),
    inherent_score          SMALLINT        GENERATED ALWAYS AS (inherent_likelihood * inherent_impact) STORED,
    inherent_risk           VARCHAR(20),    -- fn_calc_risk_level 로 자동 계산
    residual_likelihood     SMALLINT        CHECK (residual_likelihood BETWEEN 1 AND 5),
    residual_impact         SMALLINT        CHECK (residual_impact     BETWEEN 1 AND 5),
    residual_score          SMALLINT,
    residual_risk           VARCHAR(20),
    risk_trend              VARCHAR(10)     CHECK (risk_trend IN ('상승','유지','하락')),
    risk_owner              VARCHAR(100),
    dept                    VARCHAR(100),
    status                  VARCHAR(30)     DEFAULT '활성'
                                            CHECK (status IN ('활성','모니터링','수용','완화')),
    related_process         VARCHAR(500),
    assessment_comment      TEXT,
    assessor                VARCHAR(100),
    last_assessed_date      DATE,
    created_at              TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    created_by              VARCHAR(100),
    updated_by              VARCHAR(100)
);

CREATE TRIGGER trg_risk_updated_at
    BEFORE UPDATE ON itgc_risk
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- inherent_risk 자동 계산 트리거
CREATE OR REPLACE FUNCTION fn_calc_risk_levels()
RETURNS TRIGGER AS $$
BEGIN
    NEW.inherent_risk := fn_calc_risk_level(NEW.inherent_likelihood, NEW.inherent_impact);
    IF NEW.residual_likelihood IS NOT NULL AND NEW.residual_impact IS NOT NULL THEN
        NEW.residual_score := NEW.residual_likelihood * NEW.residual_impact;
        NEW.residual_risk  := fn_calc_risk_level(NEW.residual_likelihood, NEW.residual_impact);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_risk_calc_levels
    BEFORE INSERT OR UPDATE ON itgc_risk
    FOR EACH ROW EXECUTE FUNCTION fn_calc_risk_levels();

COMMENT ON TABLE  itgc_risk             IS '위험 테이블 (COSO 위험평가 구성요소)';
COMMENT ON COLUMN itgc_risk.category    IS 'IT-OPS/IT-SEC/IT-CHG/IT-ACC/IT-BCM/IT-DATA';

-- ============================================================
-- 4. 통제 테이블 (COSO - 통제 활동)
-- ============================================================
CREATE TABLE IF NOT EXISTS itgc_control (
    id                  BIGSERIAL       PRIMARY KEY,
    org_id              BIGINT          REFERENCES itgc_organization(id),
    control_code        VARCHAR(50)     NOT NULL UNIQUE,
    domain              VARCHAR(50)     NOT NULL,
    -- 접근통제, 변경관리, IT운영, 업무연속성, 정보보안
    coso_component      VARCHAR(10)     DEFAULT 'CA'
                                        CHECK (coso_component IN ('CE','RA','CA','IC','MA')),
    control_name        VARCHAR(200)    NOT NULL,
    control_objective   TEXT,
    control_description TEXT,
    control_type        VARCHAR(30)     CHECK (control_type IN ('예방통제','탐지통제','교정통제')),
    automation          VARCHAR(20)     CHECK (automation IN ('자동','수동','반자동')),
    frequency           VARCHAR(20)     CHECK (frequency IN ('상시','일일','주간','월간','분기','반기','연간','수시')),
    control_owner       VARCHAR(100),
    dept                VARCHAR(100),
    is_key_control      BOOLEAN         DEFAULT FALSE,
    is_itdm_control     BOOLEAN         DEFAULT FALSE,
    effectiveness       VARCHAR(30)     DEFAULT '미평가'
                                        CHECK (effectiveness IN ('효과적','부분 효과적','비효과적','미평가')),
    design_adequacy     VARCHAR(30)     CHECK (design_adequacy IN ('적합','부분 적합','부적합','미평가')),
    design_issue        TEXT,
    improvement_needed  TEXT,
    design_evaluator    VARCHAR(100),
    last_test_date      DATE,
    is_active           BOOLEAN         DEFAULT TRUE,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR(100),
    updated_by          VARCHAR(100)
);

CREATE TRIGGER trg_control_updated_at
    BEFORE UPDATE ON itgc_control
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

COMMENT ON TABLE  itgc_control                  IS '통제 테이블 (COSO 통제활동 구성요소)';
COMMENT ON COLUMN itgc_control.coso_component   IS 'CE:통제환경, RA:위험평가, CA:통제활동, IC:정보및의사소통, MA:모니터링';

-- ============================================================
-- 5. 위험-통제 매핑
-- ============================================================
CREATE TABLE IF NOT EXISTS itgc_risk_control_mapping (
    id              BIGSERIAL       PRIMARY KEY,
    risk_id         BIGINT          NOT NULL REFERENCES itgc_risk(id)    ON DELETE CASCADE,
    control_id      BIGINT          NOT NULL REFERENCES itgc_control(id) ON DELETE CASCADE,
    risk_code       VARCHAR(50),
    control_code    VARCHAR(50),
    mapping_type    VARCHAR(20)     DEFAULT '직접' CHECK (mapping_type IN ('직접','지원')),
    coverage_ratio  SMALLINT        DEFAULT 0 CHECK (coverage_ratio BETWEEN 0 AND 100),
    is_key_mapping  BOOLEAN         DEFAULT FALSE,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    created_by      VARCHAR(100),
    UNIQUE (risk_id, control_id)
);

COMMENT ON TABLE  itgc_risk_control_mapping IS '위험-통제 매핑 테이블';

-- ============================================================
-- 6. 운영평가 계획
-- ============================================================
CREATE TABLE IF NOT EXISTS itgc_eval_plan (
    id                  BIGSERIAL       PRIMARY KEY,
    org_id              BIGINT          REFERENCES itgc_organization(id),
    eval_year           SMALLINT        NOT NULL,
    eval_quarter        SMALLINT        NOT NULL CHECK (eval_quarter BETWEEN 1 AND 4),
    control_id          BIGINT          REFERENCES itgc_control(id),
    control_code        VARCHAR(50)     NOT NULL,
    control_name        VARCHAR(200),
    domain              VARCHAR(50),
    assignee            VARCHAR(100),
    planned_start_date  DATE,
    planned_end_date    DATE,
    actual_start_date   DATE,
    actual_end_date     DATE,
    sampling_count      SMALLINT        DEFAULT 0,
    sampling_method     VARCHAR(30)     CHECK (sampling_method IN ('전수','확률적','비통계적','판단적')),
    status              VARCHAR(20)     DEFAULT '예정'
                                        CHECK (status IN ('예정','진행중','완료','지연')),
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR(100)
);

CREATE TRIGGER trg_eval_plan_updated_at
    BEFORE UPDATE ON itgc_eval_plan
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

COMMENT ON TABLE itgc_eval_plan IS '운영평가 계획 테이블';

-- ============================================================
-- 7. 평가 샘플
-- ============================================================
CREATE TABLE IF NOT EXISTS itgc_eval_sample (
    id                  BIGSERIAL       PRIMARY KEY,
    plan_id             BIGINT          NOT NULL REFERENCES itgc_eval_plan(id) ON DELETE CASCADE,
    sample_no           VARCHAR(20)     NOT NULL,
    transaction_date    DATE,
    transaction_id      VARCHAR(200),
    description         TEXT,
    evidence_status     VARCHAR(20)     DEFAULT '미수집'
                                        CHECK (evidence_status IN ('수집완료','수집중','미수집')),
    test_result         VARCHAR(20)     CHECK (test_result IN ('통과','예외','해당없음')),
    exception_note      TEXT,
    evidence_file       VARCHAR(500),
    tester              VARCHAR(100),
    tested_at           TIMESTAMP,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (plan_id, sample_no)
);

CREATE TRIGGER trg_eval_sample_updated_at
    BEFORE UPDATE ON itgc_eval_sample
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

COMMENT ON TABLE itgc_eval_sample IS '운영평가 샘플 테이블';

-- ============================================================
-- 8. 평가 결과 (운영평가 결론)
-- ============================================================
CREATE TABLE IF NOT EXISTS itgc_eval_result (
    id                  BIGSERIAL       PRIMARY KEY,
    plan_id             BIGINT          NOT NULL REFERENCES itgc_eval_plan(id),
    control_id          BIGINT          REFERENCES itgc_control(id),
    control_code        VARCHAR(50),
    eval_year           SMALLINT,
    eval_quarter        SMALLINT,
    sample_count        SMALLINT        DEFAULT 0,
    exception_count     SMALLINT        DEFAULT 0,
    exception_rate      NUMERIC(5,2)    DEFAULT 0.00,
    effectiveness       VARCHAR(30)     CHECK (effectiveness IN ('효과적','부분 효과적','비효과적')),
    evaluator           VARCHAR(100),
    evaluation_date     DATE,
    comment             TEXT,
    recommendation      TEXT,
    finding_created     SMALLINT        DEFAULT 0,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (plan_id)
);

CREATE TRIGGER trg_eval_result_updated_at
    BEFORE UPDATE ON itgc_eval_result
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

COMMENT ON TABLE itgc_eval_result IS '운영평가 결과 테이블';

-- ============================================================
-- 9. 발견사항 (COSO - 모니터링)
-- ============================================================
CREATE TABLE IF NOT EXISTS itgc_finding (
    id                      BIGSERIAL       PRIMARY KEY,
    org_id                  BIGINT          REFERENCES itgc_organization(id),
    finding_no              VARCHAR(50)     NOT NULL UNIQUE,
    finding_type            VARCHAR(30)     NOT NULL
                                            CHECK (finding_type IN ('운영평가','내부감사','외부감사','자체점검')),
    title                   VARCHAR(200)    NOT NULL,
    description             TEXT,
    related_control_id      BIGINT          REFERENCES itgc_control(id),
    related_control         VARCHAR(50),
    related_risk_id         BIGINT          REFERENCES itgc_risk(id),
    related_risk            VARCHAR(50),
    eval_result_id          BIGINT          REFERENCES itgc_eval_result(id),
    severity                VARCHAR(20)     NOT NULL
                                            CHECK (severity IN ('심각','높음','중간','낮음')),
    dept                    VARCHAR(100),
    owner                   VARCHAR(100),
    risk_impact             TEXT,
    root_cause              TEXT,
    recommendation          TEXT,
    discovery_date          DATE,
    due_date                DATE,
    completion_date         DATE,
    status                  VARCHAR(30)     DEFAULT '미결'
                                            CHECK (status IN ('미결','조치중','조치완료','기한초과','수용')),
    remediation_progress    SMALLINT        DEFAULT 0 CHECK (remediation_progress BETWEEN 0 AND 100),
    remediation_plan        TEXT,
    created_at              TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    created_by              VARCHAR(100),
    updated_by              VARCHAR(100)
);

CREATE TRIGGER trg_finding_updated_at
    BEFORE UPDATE ON itgc_finding
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

COMMENT ON TABLE  itgc_finding          IS '발견사항 테이블 (COSO 모니터링 구성요소)';
COMMENT ON COLUMN itgc_finding.severity IS '심각/높음/중간/낮음';
COMMENT ON COLUMN itgc_finding.status   IS '미결/조치중/조치완료/기한초과/수용';

-- ============================================================
-- 10. 개선 조치 이력
-- ============================================================
CREATE TABLE IF NOT EXISTS itgc_remediation_history (
    id                  BIGSERIAL       PRIMARY KEY,
    finding_id          BIGINT          NOT NULL REFERENCES itgc_finding(id) ON DELETE CASCADE,
    action_date         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    action_type         VARCHAR(30)     CHECK (action_type IN ('상태변경','진행률갱신','코멘트','증빙첨부')),
    previous_status     VARCHAR(30),
    new_status          VARCHAR(30),
    previous_progress   SMALLINT,
    new_progress        SMALLINT,
    comment             TEXT,
    action_by           VARCHAR(100)
);

COMMENT ON TABLE itgc_remediation_history IS '개선 조치 이력 테이블';

-- ============================================================
-- 11. 보고서
-- ============================================================
CREATE TABLE IF NOT EXISTS itgc_report (
    id              BIGSERIAL       PRIMARY KEY,
    org_id          BIGINT          REFERENCES itgc_organization(id),
    report_type     VARCHAR(50)     NOT NULL,
    -- 운영평가결과, 위험평가, 발견사항현황, COSO종합
    title           VARCHAR(300)    NOT NULL,
    eval_year       SMALLINT,
    eval_quarter    SMALLINT,
    target_company  VARCHAR(200),
    format          VARCHAR(20)     DEFAULT 'PDF' CHECK (format IN ('PDF','Excel','Word','PPT')),
    language        VARCHAR(10)     DEFAULT '한국어',
    file_path       VARCHAR(500),
    file_size       BIGINT,
    status          VARCHAR(20)     DEFAULT '생성중' CHECK (status IN ('생성중','완료','오류')),
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    created_by      VARCHAR(100)
);

COMMENT ON TABLE itgc_report IS '보고서 테이블';

-- ============================================================
-- 12. COSO 설정
-- ============================================================
CREATE TABLE IF NOT EXISTS itgc_coso_config (
    id              BIGSERIAL       PRIMARY KEY,
    config_key      VARCHAR(100)    NOT NULL UNIQUE,
    config_value    TEXT,
    config_type     VARCHAR(30)     CHECK (config_type IN ('WEIGHT','THRESHOLD','SAMPLING','ALERT','GENERAL')),
    description     VARCHAR(500),
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_by      VARCHAR(100)
);

COMMENT ON TABLE itgc_coso_config IS 'COSO 설정 테이블';
