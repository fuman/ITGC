package com.itgc.portal.controller;

import com.itgc.portal.common.ApiResponse;
import com.itgc.portal.entity.Finding;
import com.itgc.portal.service.FindingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 발견사항 관리 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/v1/findings")
@RequiredArgsConstructor
@CrossOrigin(origins = "${cors.allowed-origins}")
public class FindingController {

    private final FindingService findingService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<Finding>>> getFindings(
            @RequestParam(required = false) String severity,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String dept,
            @RequestParam(required = false) String type
    ) {
        List<Finding> findings = findingService.findAll(severity, status, dept, type);
        return ResponseEntity.ok(ApiResponse.success(findings, findings.size()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Finding>> getFinding(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(findingService.findById(id)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Finding>> createFinding(@RequestBody Finding finding) {
        return ResponseEntity.ok(ApiResponse.success(findingService.create(finding)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Finding>> updateFinding(@PathVariable Long id, @RequestBody Finding finding) {
        return ResponseEntity.ok(ApiResponse.success(findingService.update(id, finding)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteFinding(@PathVariable Long id) {
        findingService.delete(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    /**
     * 발견사항 통계 요약
     */
    @GetMapping("/summary")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSummary() {
        return ResponseEntity.ok(ApiResponse.success(findingService.getSummary()));
    }

    /**
     * 기한 초과 발견사항 조회
     */
    @GetMapping("/overdue")
    public ResponseEntity<ApiResponse<List<Finding>>> getOverdueFindings() {
        List<Finding> findings = findingService.findOverdue();
        return ResponseEntity.ok(ApiResponse.success(findings, findings.size()));
    }

    /**
     * 개선 조치 진행률 업데이트
     */
    @PatchMapping("/{id}/remediation")
    public ResponseEntity<ApiResponse<Finding>> updateRemediation(
            @PathVariable Long id,
            @RequestBody Map<String, Object> remediationData
    ) {
        return ResponseEntity.ok(ApiResponse.success(findingService.updateRemediation(id, remediationData)));
    }
}
