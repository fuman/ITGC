package com.itgc.portal.mapper;

import com.itgc.portal.model.CosoConfig;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CosoConfigMapper {

    List<CosoConfig> findAll();

    CosoConfig findByComponent(@Param("component") String component);

    void update(CosoConfig config);
}
