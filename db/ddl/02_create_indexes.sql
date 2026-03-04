-- ============================================================
-- ITGC 포털 - 인덱스 생성 DDL
-- ============================================================

-- ========== itgc_organization ==========
CREATE INDEX IF NOT EXISTS idx_org_parent_id   ON itgc_organization(parent_id);
CREATE INDEX IF NOT EXISTS idx_org_type        ON itgc_organization(org_type);
CREATE INDEX IF NOT EXISTS idx_org_is_active   ON itgc_organization(is_active);

-- ========== itgc_user ==========
CREATE INDEX IF NOT EXISTS idx_user_org_id     ON itgc_user(org_id);
CREATE INDEX IF NOT EXISTS idx_user_role       ON itgc_user(role);
CREATE INDEX IF NOT EXISTS idx_user_is_active  ON itgc_user(is_active);

-- ========== itgc_risk ==========
CREATE INDEX IF NOT EXISTS idx_risk_org_id         ON itgc_risk(org_id);
CREATE INDEX IF NOT EXISTS idx_risk_category       ON itgc_risk(category);
CREATE INDEX IF NOT EXISTS idx_risk_inherent_risk  ON itgc_risk(inherent_risk);
CREATE INDEX IF NOT EXISTS idx_risk_status         ON itgc_risk(status);
CREATE INDEX IF NOT EXISTS idx_risk_dept           ON itgc_risk(dept);
-- 위험 매트릭스 조회용 복합 인덱스
CREATE INDEX IF NOT EXISTS idx_risk_matrix
    ON itgc_risk(inherent_likelihood, inherent_impact);

-- ========== itgc_control ==========
CREATE INDEX IF NOT EXISTS idx_ctrl_org_id        ON itgc_control(org_id);
CREATE INDEX IF NOT EXISTS idx_ctrl_domain        ON itgc_control(domain);
CREATE INDEX IF NOT EXISTS idx_ctrl_coso          ON itgc_control(coso_component);
CREATE INDEX IF NOT EXISTS idx_ctrl_type          ON itgc_control(control_type);
CREATE INDEX IF NOT EXISTS idx_ctrl_effectiveness ON itgc_control(effectiveness);
CREATE INDEX IF NOT EXISTS idx_ctrl_is_active     ON itgc_control(is_active);

-- ========== itgc_risk_control_mapping ==========
CREATE INDEX IF NOT EXISTS idx_mapping_risk_id    ON itgc_risk_control_mapping(risk_id);
CREATE INDEX IF NOT EXISTS idx_mapping_ctrl_id    ON itgc_risk_control_mapping(control_id);

-- ========== itgc_eval_plan ==========
CREATE INDEX IF NOT EXISTS idx_plan_org_id        ON itgc_eval_plan(org_id);
CREATE INDEX IF NOT EXISTS idx_plan_year_qtr      ON itgc_eval_plan(eval_year, eval_quarter);
CREATE INDEX IF NOT EXISTS idx_plan_control_id    ON itgc_eval_plan(control_id);
CREATE INDEX IF NOT EXISTS idx_plan_assignee      ON itgc_eval_plan(assignee);
CREATE INDEX IF NOT EXISTS idx_plan_status        ON itgc_eval_plan(status);

-- ========== itgc_eval_sample ==========
CREATE INDEX IF NOT EXISTS idx_sample_plan_id     ON itgc_eval_sample(plan_id);
CREATE INDEX IF NOT EXISTS idx_sample_result      ON itgc_eval_sample(test_result);

-- ========== itgc_eval_result ==========
CREATE INDEX IF NOT EXISTS idx_result_plan_id     ON itgc_eval_result(plan_id);
CREATE INDEX IF NOT EXISTS idx_result_ctrl_id     ON itgc_eval_result(control_id);
CREATE INDEX IF NOT EXISTS idx_result_year_qtr    ON itgc_eval_result(eval_year, eval_quarter);
CREATE INDEX IF NOT EXISTS idx_result_effect      ON itgc_eval_result(effectiveness);

-- ========== itgc_finding ==========
CREATE INDEX IF NOT EXISTS idx_finding_org_id         ON itgc_finding(org_id);
CREATE INDEX IF NOT EXISTS idx_finding_severity       ON itgc_finding(severity);
CREATE INDEX IF NOT EXISTS idx_finding_status         ON itgc_finding(status);
CREATE INDEX IF NOT EXISTS idx_finding_dept           ON itgc_finding(dept);
CREATE INDEX IF NOT EXISTS idx_finding_due_date       ON itgc_finding(due_date);
CREATE INDEX IF NOT EXISTS idx_finding_ctrl_id        ON itgc_finding(related_control_id);
CREATE INDEX IF NOT EXISTS idx_finding_risk_id        ON itgc_finding(related_risk_id);
-- 기한초과 조회용 부분 인덱스
CREATE INDEX IF NOT EXISTS idx_finding_overdue
    ON itgc_finding(due_date)
    WHERE status IN ('미결','조치중');

-- ========== itgc_remediation_history ==========
CREATE INDEX IF NOT EXISTS idx_rem_finding_id     ON itgc_remediation_history(finding_id);
CREATE INDEX IF NOT EXISTS idx_rem_action_date    ON itgc_remediation_history(action_date DESC);

-- ========== itgc_report ==========
CREATE INDEX IF NOT EXISTS idx_report_type        ON itgc_report(report_type);
CREATE INDEX IF NOT EXISTS idx_report_year_qtr    ON itgc_report(eval_year, eval_quarter);
CREATE INDEX IF NOT EXISTS idx_report_created_at  ON itgc_report(created_at DESC);
