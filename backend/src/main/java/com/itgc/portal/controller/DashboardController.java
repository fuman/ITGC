package com.itgc.portal.controller;

import com.itgc.portal.common.ApiResponse;
import com.itgc.portal.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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

    /**
     * 대시보드 종합 현황
     */
    @GetMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDashboard(
            @RequestParam(defaultValue = "2026") int year,
            @RequestParam(defaultValue = "1") int quarter
    ) {
        Map<String, Object> data = dashboardService.getDashboardData(year, quarter);
        return ResponseEntity.ok(ApiResponse.success(data));
    }

    /**
     * COSO 구성요소별 현황
     */
    @GetMapping("/coso-overview")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getCosoOverview(
            @RequestParam(defaultValue = "2026") int year,
            @RequestParam(defaultValue = "1") int quarter
    ) {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getCosoOverview(year, quarter)));
    }

    /**
     * KPI 통계
     */
    @GetMapping("/kpi")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getKpi(
            @RequestParam(defaultValue = "2026") int year,
            @RequestParam(defaultValue = "1") int quarter
    ) {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getKpiStats(year, quarter)));
    }

    /**
     * 위험 분포 차트 데이터
     */
    @GetMapping("/risk-distribution")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getRiskDistribution(
            @RequestParam(defaultValue = "2026") int year
    ) {
        return ResponseEntity.ok(ApiResponse.success(dashboardService.getRiskDistribution(year)));
    }
}
