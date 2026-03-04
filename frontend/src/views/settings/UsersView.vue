<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">사용자 관리</h1>
          <p class="page-subtitle">ITGC 포털 사용자 계정 및 권한을 관리합니다</p>
        </div>
        <DxButton text="사용자 추가" icon="plus" type="default" @click="showDialog = true" />
      </div>
    </div>

    <div class="card" style="padding: 0">
      <DxDataGrid
        :data-source="users"
        :show-borders="false"
        :hover-state-enabled="true"
        :column-auto-width="true"
        key-expr="id"
      >
        <DxEditing mode="row" :allow-updating="true" :allow-deleting="true" />
        <DxToolbar>
          <DxItem location="before" template="titleTemplate" />
          <DxItem name="searchPanel" />
        </DxToolbar>
        <DxSearchPanel :visible="true" placeholder="사용자 검색..." />
        <DxPaging :page-size="15" />
        <DxPager :show-info="true" />

        <DxColumn data-field="avatar" caption="" width="50" :allow-sorting="false" :allow-editing="false" cell-template="avatarTemplate" />
        <DxColumn data-field="name" caption="이름" width="100" />
        <DxColumn data-field="email" caption="이메일" min-width="180" />
        <DxColumn data-field="dept" caption="부서" width="130" />
        <DxColumn data-field="role" caption="역할" width="130" cell-template="roleTemplate">
          <DxLookup :data-source="['시스템관리자', 'IT감사팀장', 'IT감사자', '통제담당자', '열람자']" />
        </DxColumn>
        <DxColumn data-field="company" caption="그룹사" width="130" />
        <DxColumn data-field="lastLogin" caption="최종 로그인" width="140" :allow-editing="false" />
        <DxColumn data-field="isActive" caption="활성" width="80" alignment="center" data-type="boolean" />

        <template #titleTemplate>
          <div style="font-weight: 600; font-size: 15px; color: #1a3a6b; padding: 4px 0">
            사용자 목록 ({{ users.length }}명)
          </div>
        </template>
        <template #avatarTemplate="{ data }">
          <div class="user-avatar-cell">{{ data.data.name[0] }}</div>
        </template>
        <template #roleTemplate="{ data }">
          <span class="role-badge" :class="`role-${getRoleClass(data.value)}`">{{ data.value }}</span>
        </template>
      </DxDataGrid>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxDataGrid, { DxColumn, DxEditing, DxLookup, DxPaging, DxPager, DxSearchPanel, DxToolbar, DxItem } from 'devextreme-vue/data-grid'

const showDialog = ref(false)

const users = ref([
  { id: 1, name: '김감사', email: 'kim.itaudit@group.com', dept: 'IT감사팀', role: 'IT감사팀장', company: '(주)그룹홀딩스', lastLogin: '2026-03-04 09:30', isActive: true },
  { id: 2, name: '이보안', email: 'lee.security@group-a.com', dept: '정보보안팀', role: '통제담당자', company: '(주)그룹사A', lastLogin: '2026-03-04 08:15', isActive: true },
  { id: 3, name: '박검토', email: 'park.review@group-a.com', dept: 'IT감사팀', role: 'IT감사자', company: '(주)그룹사A', lastLogin: '2026-03-03 17:20', isActive: true },
  { id: 4, name: '최시스템', email: 'choi.system@group-b.com', dept: 'HR시스템팀', role: '통제담당자', company: '(주)그룹사B', lastLogin: '2026-03-02 14:50', isActive: true },
  { id: 5, name: '정인프라', email: 'jung.infra@group-a.com', dept: 'IT인프라팀', role: '통제담당자', company: '(주)그룹사A', lastLogin: '2026-03-01 11:00', isActive: true },
  { id: 6, name: '관리자', email: 'admin@group.com', dept: 'IT기획팀', role: '시스템관리자', company: '(주)그룹홀딩스', lastLogin: '2026-03-04 07:00', isActive: true }
])

function getRoleClass(role) {
  const map = { '시스템관리자': 'admin', 'IT감사팀장': 'lead', 'IT감사자': 'auditor', '통제담당자': 'owner', '열람자': 'viewer' }
  return map[role] || 'viewer'
}
</script>

<style lang="scss" scoped>
.user-avatar-cell {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(135deg, #1a3a6b, #2d5aa0);
  color: white;
  font-size: 13px;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
}

.role-badge {
  display: inline-flex;
  padding: 3px 10px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 600;

  &.role-admin { background: rgba(139, 0, 0, 0.12); color: #8b0000; }
  &.role-lead { background: rgba(26, 58, 107, 0.12); color: #1a3a6b; }
  &.role-auditor { background: rgba(52, 152, 219, 0.12); color: #2980b9; }
  &.role-owner { background: rgba(39, 174, 96, 0.12); color: #1e8449; }
  &.role-viewer { background: rgba(149, 165, 166, 0.2); color: #616a6b; }
}
</style>
