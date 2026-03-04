package com.itgc.portal.controller;

import com.itgc.portal.common.ApiResponse;
import com.itgc.portal.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 대시보드 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/v1/dashboard")
@RequiredArgsConstructor
@CrossOrigin(origins = "${cors.allowed-origins}")
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/kpi")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getKpi() {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getKpiSummary()));
    }

    @GetMapping("/risk-distribution")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getRiskDistribution() {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getRiskDistribution()));
    }

    @GetMapping("/control-effectiveness")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getControlEffectiveness() {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getControlEffectiveness()));
    }

    @GetMapping("/eval-trend")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getEvalTrend(
            @RequestParam(required = false) Integer year
    ) {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getEvalTrend(year)));
    }

    @GetMapping("/recent-findings")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getRecentFindings(
            @RequestParam(defaultValue = "10") int limit
    ) {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getRecentFindings(limit)));
    }

    @GetMapping("/coso-scores")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getCosoScores() {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getCosoScores()));
    }

    @GetMapping("/overdue-findings")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getOverdueFindingsSummary() {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getOverdueFindingsSummary()));
    }
}
