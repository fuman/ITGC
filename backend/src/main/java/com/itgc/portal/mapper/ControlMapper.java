package com.itgc.portal.mapper;

import com.itgc.portal.model.Control;
import com.itgc.portal.model.RiskControlMapping;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface ControlMapper {

    List<Control> findAll(@Param("domain") String domain,
                          @Param("type") String type,
                          @Param("automation") String automation,
                          @Param("effectiveness") String effectiveness);

    Control findById(@Param("id") Long id);

    Control findByControlCode(@Param("controlCode") String controlCode);

    void insert(Control control);

    void update(Control control);

    void updateDesignAdequacy(@Param("id") Long id, @Param("designAdequacy") String designAdequacy);

    void delete(@Param("id") Long id);

    long count();

    List<RiskControlMapping> findControlRiskMapping();

    List<Map<String, Object>> getDomainSummary();

    void insertMapping(RiskControlMapping mapping);

    void deleteMapping(@Param("id") Long id);
}
