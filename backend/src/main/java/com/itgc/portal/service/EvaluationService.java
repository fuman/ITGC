package com.itgc.portal.service;

import com.itgc.portal.mapper.EvaluationMapper;
import com.itgc.portal.model.EvaluationPlan;
import com.itgc.portal.model.EvaluationResult;
import com.itgc.portal.model.EvaluationSample;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Year;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class EvaluationService {

    private final EvaluationMapper evaluationMapper;

    // ===== 평가 계획 =====
    public List<EvaluationPlan> findAllPlans(Integer year, Integer quarter, String domain, String status) {
        int targetYear = (year != null) ? year : Year.now().getValue();
        return evaluationMapper.findAllPlans(targetYear, quarter, domain, status);
    }

    public EvaluationPlan findPlanById(Long id) {
        EvaluationPlan plan = evaluationMapper.findPlanById(id);
        if (plan == null) throw new NoSuchElementException("평가 계획을 찾을 수 없습니다: " + id);
        return plan;
    }

    @Transactional
    public EvaluationPlan createPlan(EvaluationPlan plan) {
        if (plan.getStatus() == null) plan.setStatus("예정");
        evaluationMapper.insertPlan(plan);
        return evaluationMapper.findPlanById(plan.getId());
    }

    @Transactional
    public EvaluationPlan updatePlan(Long id, EvaluationPlan plan) {
        findPlanById(id);
        plan.setId(id);
        evaluationMapper.updatePlan(plan);
        return evaluationMapper.findPlanById(id);
    }

    @Transactional
    public void deletePlan(Long id) {
        findPlanById(id);
        evaluationMapper.deletePlan(id);
    }

    // ===== 샘플 =====
    public List<EvaluationSample> findSamplesByPlanId(Long planId) {
        return evaluationMapper.findSamplesByPlanId(planId);
    }

    @Transactional
    public EvaluationSample createSample(EvaluationSample sample) {
        evaluationMapper.insertSample(sample);
        return evaluationMapper.findSampleById(sample.getId());
    }

    @Transactional
    public EvaluationSample updateSample(Long id, EvaluationSample sample) {
        EvaluationSample existing = evaluationMapper.findSampleById(id);
        if (existing == null) throw new NoSuchElementException("샘플을 찾을 수 없습니다: " + id);
        sample.setId(id);
        evaluationMapper.updateSample(sample);
        return evaluationMapper.findSampleById(id);
    }

    @Transactional
    public void deleteSample(Long id) {
        evaluationMapper.deleteSample(id);
    }

    // ===== 결과 =====
    public EvaluationResult findResultByPlanId(Long planId) {
        return evaluationMapper.findResultByPlanId(planId);
    }

    @Transactional
    public EvaluationResult saveResult(EvaluationResult result) {
        EvaluationResult existing = evaluationMapper.findResultByPlanId(result.getEvalPlanId());
        if (existing == null) {
            if (result.getStatus() == null) result.setStatus("작성중");
            evaluationMapper.insertResult(result);
        } else {
            result.setId(existing.getId());
            evaluationMapper.updateResult(result);
        }
        return evaluationMapper.findResultByPlanId(result.getEvalPlanId());
    }

    // ===== 통계 =====
    public List<Map<String, Object>> getQuarterlySummary(Integer year) {
        int targetYear = (year != null) ? year : Year.now().getValue();
        return evaluationMapper.getQuarterlySummary(targetYear);
    }

    public List<Map<String, Object>> getDomainEffectiveness(Integer year) {
        int targetYear = (year != null) ? year : Year.now().getValue();
        return evaluationMapper.getDomainEffectiveness(targetYear);
    }
}
