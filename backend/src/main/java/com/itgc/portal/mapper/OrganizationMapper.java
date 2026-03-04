package com.itgc.portal.mapper;

import com.itgc.portal.model.Organization;
import com.itgc.portal.model.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface OrganizationMapper {

    List<Organization> findAllOrgs();

    Organization findOrgById(@Param("id") Long id);

    void insertOrg(Organization org);

    void updateOrg(Organization org);

    void deleteOrg(@Param("id") Long id);

    // 사용자
    List<User> findAllUsers(@Param("orgId") Long orgId, @Param("role") String role);

    User findUserById(@Param("id") Long id);

    User findByUserId(@Param("userId") String userId);

    void insertUser(User user);

    void updateUser(User user);

    void deleteUser(@Param("id") Long id);
}
