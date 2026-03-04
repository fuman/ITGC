package com.itgc.portal.controller;

import com.itgc.portal.common.ApiResponse;
import com.itgc.portal.model.EvaluationPlan;
import com.itgc.portal.model.EvaluationResult;
import com.itgc.portal.model.EvaluationSample;
import com.itgc.portal.service.EvaluationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 운영평가 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/v1/evaluations")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "${cors.allowed-origins}")
public class EvaluationController {

    private final EvaluationService evaluationService;

    // ===== 평가 계획 =====
    @GetMapping("/plans")
    public ResponseEntity<ApiResponse<List<EvaluationPlan>>> getPlans(
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer quarter,
            @RequestParam(required = false) String domain,
            @RequestParam(required = false) String status
    ) {
        List<EvaluationPlan> plans = evaluationService.findAllPlans(year, quarter, domain, status);
        return ResponseEntity.ok(ApiResponse.success(plans, plans.size()));
    }

    @GetMapping("/plans/{id}")
    public ResponseEntity<ApiResponse<EvaluationPlan>> getPlan(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(evaluationService.findPlanById(id)));
    }

    @PostMapping("/plans")
    public ResponseEntity<ApiResponse<EvaluationPlan>> createPlan(@RequestBody EvaluationPlan plan) {
        return ResponseEntity.ok(ApiResponse.success(evaluationService.createPlan(plan)));
    }

    @PutMapping("/plans/{id}")
    public ResponseEntity<ApiResponse<EvaluationPlan>> updatePlan(
            @PathVariable Long id, @RequestBody EvaluationPlan plan
    ) {
        return ResponseEntity.ok(ApiResponse.success(evaluationService.updatePlan(id, plan)));
    }

    @DeleteMapping("/plans/{id}")
    public ResponseEntity<ApiResponse<Void>> deletePlan(@PathVariable Long id) {
        evaluationService.deletePlan(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ===== 샘플 =====
    @GetMapping("/plans/{planId}/samples")
    public ResponseEntity<ApiResponse<List<EvaluationSample>>> getSamples(@PathVariable Long planId) {
        List<EvaluationSample> samples = evaluationService.findSamplesByPlanId(planId);
        return ResponseEntity.ok(ApiResponse.success(samples, samples.size()));
    }

    @PostMapping("/samples")
    public ResponseEntity<ApiResponse<EvaluationSample>> createSample(@RequestBody EvaluationSample sample) {
        return ResponseEntity.ok(ApiResponse.success(evaluationService.createSample(sample)));
    }

    @PutMapping("/samples/{id}")
    public ResponseEntity<ApiResponse<EvaluationSample>> updateSample(
            @PathVariable Long id, @RequestBody EvaluationSample sample
    ) {
        return ResponseEntity.ok(ApiResponse.success(evaluationService.updateSample(id, sample)));
    }

    @DeleteMapping("/samples/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteSample(@PathVariable Long id) {
        evaluationService.deleteSample(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ===== 결과 =====
    @GetMapping("/plans/{planId}/result")
    public ResponseEntity<ApiResponse<EvaluationResult>> getResult(@PathVariable Long planId) {
        return ResponseEntity.ok(ApiResponse.success(evaluationService.findResultByPlanId(planId)));
    }

    @PostMapping("/result")
    public ResponseEntity<ApiResponse<EvaluationResult>> saveResult(@RequestBody EvaluationResult result) {
        return ResponseEntity.ok(ApiResponse.success(evaluationService.saveResult(result)));
    }

    // ===== 통계 =====
    @GetMapping("/summary/quarterly")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getQuarterlySummary(
            @RequestParam(required = false) Integer year
    ) {
        return ResponseEntity.ok(ApiResponse.success(evaluationService.getQuarterlySummary(year)));
    }

    @GetMapping("/summary/domain")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getDomainEffectiveness(
            @RequestParam(required = false) Integer year
    ) {
        return ResponseEntity.ok(ApiResponse.success(evaluationService.getDomainEffectiveness(year)));
    }
}
