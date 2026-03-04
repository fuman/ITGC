package com.itgc.portal.mapper;

import com.itgc.portal.model.Risk;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface RiskMapper {

    List<Risk> findAll(@Param("category") String category,
                       @Param("level") String level,
                       @Param("dept") String dept,
                       @Param("status") String status);

    Risk findById(@Param("id") Long id);

    Risk findByRiskCode(@Param("riskCode") String riskCode);

    int countByRiskCode(@Param("riskCode") String riskCode);

    void insert(Risk risk);

    void update(Risk risk);

    void delete(@Param("id") Long id);

    long count();

    long countByInherentRisk(@Param("inherentRisk") String inherentRisk);

    List<Risk> findForMatrix(@Param("type") String type);

    List<Map<String, Object>> getSummaryByCategory();
}
