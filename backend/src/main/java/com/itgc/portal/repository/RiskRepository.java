package com.itgc.portal.repository;

import com.itgc.portal.entity.Risk;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RiskRepository extends JpaRepository<Risk, Long> {

    boolean existsByRiskCode(String riskCode);

    long countByInherentRisk(String level);

    @Query("""
        SELECT r FROM Risk r
        WHERE (:category IS NULL OR r.category = :category)
          AND (:level IS NULL OR r.inherentRisk = :level)
          AND (:dept IS NULL OR r.dept = :dept)
          AND (:status IS NULL OR r.status = :status)
        ORDER BY r.inherentLikelihood DESC, r.inherentImpact DESC
    """)
    List<Risk> findWithFilters(
            @Param("category") String category,
            @Param("level") String level,
            @Param("dept") String dept,
            @Param("status") String status
    );

    List<Risk> findByInherentRiskIn(List<String> levels);

    List<Risk> findByCategory(String category);

    List<Risk> findByDept(String dept);
}
