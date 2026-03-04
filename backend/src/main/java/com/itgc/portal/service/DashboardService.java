package com.itgc.portal.service;

import com.itgc.portal.mapper.DashboardMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Year;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DashboardService {

    private final DashboardMapper dashboardMapper;

    public Map<String, Object> getKpiSummary() {
        return dashboardMapper.getKpiSummary();
    }

    public List<Map<String, Object>> getRiskDistribution() {
        return dashboardMapper.getRiskDistribution();
    }

    public List<Map<String, Object>> getControlEffectiveness() {
        return dashboardMapper.getControlEffectiveness();
    }

    public List<Map<String, Object>> getEvalTrend(Integer year) {
        int targetYear = (year != null) ? year : Year.now().getValue();
        return dashboardMapper.getEvalTrend(targetYear);
    }

    public List<Map<String, Object>> getRecentFindings(int limit) {
        return dashboardMapper.getRecentFindings(limit);
    }

    public List<Map<String, Object>> getCosoScores() {
        return dashboardMapper.getCosoScores();
    }

    public List<Map<String, Object>> getOverdueFindingsSummary() {
        return dashboardMapper.getOverdueFindingsSummary();
    }
}
