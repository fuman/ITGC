package com.itgc.portal.repository;

import com.itgc.portal.entity.Finding;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface FindingRepository extends JpaRepository<Finding, Long> {

    @Query("""
        SELECT f FROM Finding f
        WHERE (:severity IS NULL OR f.severity = :severity)
          AND (:status IS NULL OR f.status = :status)
          AND (:dept IS NULL OR f.dept = :dept)
          AND (:type IS NULL OR f.findingType = :type)
        ORDER BY
          CASE f.severity
            WHEN '심각' THEN 1
            WHEN '높음' THEN 2
            WHEN '중간' THEN 3
            WHEN '낮음' THEN 4
            ELSE 5
          END, f.dueDate
    """)
    List<Finding> findWithFilters(
            @Param("severity") String severity,
            @Param("status") String status,
            @Param("dept") String dept,
            @Param("type") String type
    );

    long countByStatus(String status);

    long countByStatusAndDueDateBefore(String status, LocalDate date);

    @Query("""
        SELECT f FROM Finding f
        WHERE f.status IN ('미결', '조치중')
          AND f.dueDate < :today
        ORDER BY f.dueDate
    """)
    List<Finding> findOverdue(@Param("today") LocalDate today);

    List<Finding> findBySeverity(String severity);

    List<Finding> findByDept(String dept);
}
