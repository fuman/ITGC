package com.itgc.portal.mapper;

import com.itgc.portal.model.Finding;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Mapper
public interface FindingMapper {

    List<Finding> findAll(@Param("severity") String severity,
                          @Param("status") String status,
                          @Param("dept") String dept,
                          @Param("findingType") String findingType);

    Finding findById(@Param("id") Long id);

    void insert(Finding finding);

    void update(Finding finding);

    void updateRemediation(@Param("id") Long id,
                           @Param("status") String status,
                           @Param("remediationProgress") Integer remediationProgress,
                           @Param("remediationPlan") String remediationPlan);

    void delete(@Param("id") Long id);

    long count();

    long countByStatus(@Param("status") String status);

    long countOverdue(@Param("today") LocalDate today);

    List<Finding> findOverdue(@Param("today") LocalDate today);

    List<Map<String, Object>> getSummaryBySeverity();
}
