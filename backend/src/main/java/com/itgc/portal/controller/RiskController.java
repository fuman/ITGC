package com.itgc.portal.controller;

import com.itgc.portal.common.ApiResponse;
import com.itgc.portal.entity.Risk;
import com.itgc.portal.service.RiskService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 위험 관리 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/v1/risks")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "${cors.allowed-origins}")
public class RiskController {

    private final RiskService riskService;

    /**
     * 위험 목록 조회
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Risk>>> getRisks(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String level,
            @RequestParam(required = false) String dept,
            @RequestParam(required = false) String status
    ) {
        log.info("GET /api/v1/risks - category: {}, level: {}", category, level);
        List<Risk> risks = riskService.findAll(category, level, dept, status);
        return ResponseEntity.ok(ApiResponse.success(risks, risks.size()));
    }

    /**
     * 위험 상세 조회
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Risk>> getRisk(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(riskService.findById(id)));
    }

    /**
     * 위험 등록
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Risk>> createRisk(@RequestBody Risk risk) {
        log.info("POST /api/v1/risks - riskCode: {}", risk.getRiskCode());
        Risk created = riskService.create(risk);
        return ResponseEntity.ok(ApiResponse.success(created));
    }

    /**
     * 위험 수정
     */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Risk>> updateRisk(@PathVariable Long id, @RequestBody Risk risk) {
        Risk updated = riskService.update(id, risk);
        return ResponseEntity.ok(ApiResponse.success(updated));
    }

    /**
     * 위험 삭제
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteRisk(@PathVariable Long id) {
        riskService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    /**
     * 위험 매트릭스 데이터 조회
     */
    @GetMapping("/matrix")
    public ResponseEntity<ApiResponse<List<Risk>>> getRiskMatrix(
            @RequestParam(defaultValue = "inherent") String type
    ) {
        List<Risk> risks = riskService.findForMatrix(type);
        return ResponseEntity.ok(ApiResponse.success(risks, risks.size()));
    }

    /**
     * 위험 통계 요약
     */
    @GetMapping("/summary")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getRiskSummary() {
        Map<String, Object> summary = riskService.getSummary();
        return ResponseEntity.ok(ApiResponse.success(summary));
    }

    /**
     * 위험 평가 저장
     */
    @PostMapping("/assessment")
    public ResponseEntity<ApiResponse<Void>> saveAssessment(
            @RequestBody List<Map<String, Object>> assessments
    ) {
        riskService.saveAssessment(assessments);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
