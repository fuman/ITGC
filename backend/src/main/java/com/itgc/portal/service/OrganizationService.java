package com.itgc.portal.service;

import com.itgc.portal.mapper.OrganizationMapper;
import com.itgc.portal.model.Organization;
import com.itgc.portal.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class OrganizationService {

    private final OrganizationMapper organizationMapper;
    private final PasswordEncoder passwordEncoder;

    // ===== 조직 =====
    public List<Organization> findAllOrgs() {
        return organizationMapper.findAllOrgs();
    }

    public Organization findOrgById(Long id) {
        Organization org = organizationMapper.findOrgById(id);
        if (org == null) throw new NoSuchElementException("조직을 찾을 수 없습니다: " + id);
        return org;
    }

    @Transactional
    public Organization createOrg(Organization org) {
        if (org.getIsActive() == null) org.setIsActive(true);
        organizationMapper.insertOrg(org);
        return organizationMapper.findOrgById(org.getId());
    }

    @Transactional
    public Organization updateOrg(Long id, Organization org) {
        findOrgById(id);
        org.setId(id);
        organizationMapper.updateOrg(org);
        return organizationMapper.findOrgById(id);
    }

    @Transactional
    public void deleteOrg(Long id) {
        findOrgById(id);
        organizationMapper.deleteOrg(id);
    }

    // ===== 사용자 =====
    public List<User> findAllUsers(Long orgId, String role) {
        return organizationMapper.findAllUsers(orgId, role);
    }

    public User findUserById(Long id) {
        User user = organizationMapper.findUserById(id);
        if (user == null) throw new NoSuchElementException("사용자를 찾을 수 없습니다: " + id);
        return user;
    }

    @Transactional
    public User createUser(User user) {
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        if (user.getIsActive() == null) user.setIsActive(true);
        organizationMapper.insertUser(user);
        return organizationMapper.findUserById(user.getId());
    }

    @Transactional
    public User updateUser(Long id, User user) {
        findUserById(id);
        user.setId(id);
        organizationMapper.updateUser(user);
        return organizationMapper.findUserById(id);
    }

    @Transactional
    public void deleteUser(Long id) {
        findUserById(id);
        organizationMapper.deleteUser(id);
    }
}
