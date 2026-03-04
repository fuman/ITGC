package com.itgc.portal.repository;

import com.itgc.portal.entity.Control;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface ControlRepository extends JpaRepository<Control, Long> {

    @Query("""
        SELECT c FROM Control c
        WHERE (:domain IS NULL OR c.domain = :domain)
          AND (:type IS NULL OR c.controlType = :type)
          AND (:automation IS NULL OR c.automation = :automation)
          AND (:effectiveness IS NULL OR c.effectiveness = :effectiveness)
        ORDER BY c.domain, c.controlCode
    """)
    List<Control> findWithFilters(
            @Param("domain") String domain,
            @Param("type") String type,
            @Param("automation") String automation,
            @Param("effectiveness") String effectiveness
    );

    @Query(value = """
        SELECT c.control_code as controlCode, c.control_name as controlName,
               c.domain, c.effectiveness
        FROM itgc_control c
        ORDER BY c.domain, c.control_code
    """, nativeQuery = true)
    List<Map<String, Object>> findControlRiskMapping();

    @Query(value = """
        SELECT domain,
               COUNT(*) as totalControls,
               SUM(CASE WHEN effectiveness = '효과적' THEN 1 ELSE 0 END) as effective,
               SUM(CASE WHEN effectiveness = '비효과적' THEN 1 ELSE 0 END) as ineffective
        FROM itgc_control
        GROUP BY domain
    """, nativeQuery = true)
    List<Map<String, Object>> findDomainSummary();

    List<Control> findByDomain(String domain);

    long countByEffectiveness(String effectiveness);
}
