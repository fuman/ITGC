package com.itgc.portal.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface DashboardMapper {

    Map<String, Object> getKpiSummary();

    List<Map<String, Object>> getRiskDistribution();

    List<Map<String, Object>> getControlEffectiveness();

    List<Map<String, Object>> getEvalTrend(@Param("year") int year);

    List<Map<String, Object>> getRecentFindings(@Param("limit") int limit);

    List<Map<String, Object>> getCosoScores();

    List<Map<String, Object>> getOverdueFindingsSummary();
}
