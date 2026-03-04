package com.itgc.portal.mapper;

import com.itgc.portal.model.EvaluationPlan;
import com.itgc.portal.model.EvaluationResult;
import com.itgc.portal.model.EvaluationSample;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface EvaluationMapper {

    // 평가 계획
    List<EvaluationPlan> findAllPlans(@Param("evalYear") Integer evalYear,
                                      @Param("evalQuarter") Integer evalQuarter,
                                      @Param("domain") String domain,
                                      @Param("status") String status);

    EvaluationPlan findPlanById(@Param("id") Long id);

    void insertPlan(EvaluationPlan plan);

    void updatePlan(EvaluationPlan plan);

    void deletePlan(@Param("id") Long id);

    // 샘플
    List<EvaluationSample> findSamplesByPlanId(@Param("planId") Long planId);

    EvaluationSample findSampleById(@Param("id") Long id);

    void insertSample(EvaluationSample sample);

    void updateSample(EvaluationSample sample);

    void deleteSample(@Param("id") Long id);

    // 결과
    EvaluationResult findResultByPlanId(@Param("planId") Long planId);

    void insertResult(EvaluationResult result);

    void updateResult(EvaluationResult result);

    // 통계
    List<Map<String, Object>> getQuarterlySummary(@Param("evalYear") Integer evalYear);

    List<Map<String, Object>> getDomainEffectiveness(@Param("evalYear") Integer evalYear);
}
