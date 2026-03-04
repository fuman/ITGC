package com.itgc.portal.controller;

import com.itgc.portal.common.ApiResponse;
import com.itgc.portal.model.Organization;
import com.itgc.portal.model.User;
import com.itgc.portal.service.OrganizationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 조직/사용자 관리 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@CrossOrigin(origins = "${cors.allowed-origins}")
public class OrganizationController {

    private final OrganizationService organizationService;

    // ===== 조직 =====
    @GetMapping("/organizations")
    public ResponseEntity<ApiResponse<List<Organization>>> getOrganizations() {
        List<Organization> orgs = organizationService.findAllOrgs();
        return ResponseEntity.ok(ApiResponse.success(orgs, orgs.size()));
    }

    @GetMapping("/organizations/{id}")
    public ResponseEntity<ApiResponse<Organization>> getOrganization(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(organizationService.findOrgById(id)));
    }

    @PostMapping("/organizations")
    public ResponseEntity<ApiResponse<Organization>> createOrganization(@RequestBody Organization org) {
        return ResponseEntity.ok(ApiResponse.success(organizationService.createOrg(org)));
    }

    @PutMapping("/organizations/{id}")
    public ResponseEntity<ApiResponse<Organization>> updateOrganization(
            @PathVariable Long id, @RequestBody Organization org
    ) {
        return ResponseEntity.ok(ApiResponse.success(organizationService.updateOrg(id, org)));
    }

    @DeleteMapping("/organizations/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteOrganization(@PathVariable Long id) {
        organizationService.deleteOrg(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    // ===== 사용자 =====
    @GetMapping("/users")
    public ResponseEntity<ApiResponse<List<User>>> getUsers(
            @RequestParam(required = false) Long orgId,
            @RequestParam(required = false) String role
    ) {
        List<User> users = organizationService.findAllUsers(orgId, role);
        return ResponseEntity.ok(ApiResponse.success(users, users.size()));
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<ApiResponse<User>> getUser(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(organizationService.findUserById(id)));
    }

    @PostMapping("/users")
    public ResponseEntity<ApiResponse<User>> createUser(@RequestBody User user) {
        return ResponseEntity.ok(ApiResponse.success(organizationService.createUser(user)));
    }

    @PutMapping("/users/{id}")
    public ResponseEntity<ApiResponse<User>> updateUser(@PathVariable Long id, @RequestBody User user) {
        return ResponseEntity.ok(ApiResponse.success(organizationService.updateUser(id, user)));
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUser(@PathVariable Long id) {
        organizationService.deleteUser(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
