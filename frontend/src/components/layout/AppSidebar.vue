<template>
  <aside class="sidebar" :class="{ collapsed: appStore.sidebarCollapsed }">
    <!-- Logo -->
    <div class="sidebar-logo">
      <div class="logo-icon">
        <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
          <rect width="28" height="28" rx="6" fill="white" fill-opacity="0.2"/>
          <path d="M7 8h14M7 14h10M7 20h12" stroke="white" stroke-width="2" stroke-linecap="round"/>
          <circle cx="21" cy="19" r="4" fill="#e8a020"/>
          <path d="M19.5 19l1 1 2-2" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
      </div>
      <div class="logo-text" v-if="!appStore.sidebarCollapsed">
        <span class="logo-name">ITGC 포털</span>
        <span class="logo-sub">IT General Controls</span>
      </div>
    </div>

    <!-- Navigation -->
    <nav class="sidebar-nav">
      <!-- Dashboard -->
      <router-link to="/dashboard" class="nav-item" active-class="active">
        <span class="nav-icon">⊞</span>
        <span class="nav-label">대시보드</span>
      </router-link>

      <!-- 위험 관리 -->
      <div class="nav-group">
        <div class="nav-group-title" v-if="!appStore.sidebarCollapsed">COSO · 위험관리</div>
        <div class="nav-group-divider" v-else></div>

        <div class="nav-item-group" :class="{ open: openGroups.risk }">
          <div class="nav-item nav-parent" @click="toggleGroup('risk')">
            <span class="nav-icon risk-icon">⚠</span>
            <span class="nav-label">위험 관리</span>
            <span class="nav-arrow" :class="{ rotated: openGroups.risk }">›</span>
          </div>
          <div class="nav-children">
            <router-link to="/risk/identification" class="nav-child" active-class="active">
              위험 식별
            </router-link>
            <router-link to="/risk/assessment" class="nav-child" active-class="active">
              위험 평가
            </router-link>
            <router-link to="/risk/response" class="nav-child" active-class="active">
              위험 대응
            </router-link>
            <router-link to="/risk/matrix" class="nav-child" active-class="active">
              위험 매트릭스
            </router-link>
          </div>
        </div>
      </div>

      <!-- 통제 활동 -->
      <div class="nav-group">
        <div class="nav-group-title" v-if="!appStore.sidebarCollapsed">COSO · 통제활동</div>
        <div class="nav-group-divider" v-else></div>

        <div class="nav-item-group" :class="{ open: openGroups.control }">
          <div class="nav-item nav-parent" @click="toggleGroup('control')">
            <span class="nav-icon control-icon">⚙</span>
            <span class="nav-label">통제 활동</span>
            <span class="nav-arrow" :class="{ rotated: openGroups.control }">›</span>
          </div>
          <div class="nav-children">
            <router-link to="/control/list" class="nav-child" active-class="active">
              통제 목록
            </router-link>
            <router-link to="/control/design" class="nav-child" active-class="active">
              통제 설계
            </router-link>
            <router-link to="/control/mapping" class="nav-child" active-class="active">
              위험-통제 매핑
            </router-link>
          </div>
        </div>
      </div>

      <!-- 운영 평가 -->
      <div class="nav-group">
        <div class="nav-group-title" v-if="!appStore.sidebarCollapsed">운영평가</div>
        <div class="nav-group-divider" v-else></div>

        <div class="nav-item-group" :class="{ open: openGroups.evaluation }">
          <div class="nav-item nav-parent" @click="toggleGroup('evaluation')">
            <span class="nav-icon eval-icon">✓</span>
            <span class="nav-label">운영 평가</span>
            <span class="nav-arrow" :class="{ rotated: openGroups.evaluation }">›</span>
          </div>
          <div class="nav-children">
            <router-link to="/evaluation/plan" class="nav-child" active-class="active">
              평가 계획
            </router-link>
            <router-link to="/evaluation/execution" class="nav-child" active-class="active">
              평가 실행
            </router-link>
            <router-link to="/evaluation/result" class="nav-child" active-class="active">
              평가 결과
            </router-link>
          </div>
        </div>

        <div class="nav-item-group" :class="{ open: openGroups.findings }">
          <div class="nav-item nav-parent" @click="toggleGroup('findings')">
            <span class="nav-icon finding-icon">🔍</span>
            <span class="nav-label">발견사항 관리</span>
            <span class="nav-arrow" :class="{ rotated: openGroups.findings }">›</span>
          </div>
          <div class="nav-children">
            <router-link to="/findings/list" class="nav-child" active-class="active">
              발견사항 목록
            </router-link>
            <router-link to="/findings/remediation" class="nav-child" active-class="active">
              개선 조치
            </router-link>
          </div>
        </div>
      </div>

      <!-- 보고서 & 설정 -->
      <div class="nav-group">
        <div class="nav-group-title" v-if="!appStore.sidebarCollapsed">보고서 · 설정</div>
        <div class="nav-group-divider" v-else></div>

        <router-link to="/reports" class="nav-item" active-class="active">
          <span class="nav-icon">📊</span>
          <span class="nav-label">보고서</span>
        </router-link>

        <div class="nav-item-group" :class="{ open: openGroups.settings }">
          <div class="nav-item nav-parent" @click="toggleGroup('settings')">
            <span class="nav-icon">⚙</span>
            <span class="nav-label">시스템 설정</span>
            <span class="nav-arrow" :class="{ rotated: openGroups.settings }">›</span>
          </div>
          <div class="nav-children">
            <router-link to="/settings/organization" class="nav-child" active-class="active">
              조직 관리
            </router-link>
            <router-link to="/settings/users" class="nav-child" active-class="active">
              사용자 관리
            </router-link>
            <router-link to="/settings/coso-config" class="nav-child" active-class="active">
              COSO 설정
            </router-link>
          </div>
        </div>
      </div>
    </nav>

    <!-- Sidebar Footer -->
    <div class="sidebar-footer" v-if="!appStore.sidebarCollapsed">
      <div class="coso-badge-group">
        <div class="mini-badge env">CE</div>
        <div class="mini-badge risk">RA</div>
        <div class="mini-badge ctrl">CA</div>
        <div class="mini-badge info">IC</div>
        <div class="mini-badge mon">MA</div>
      </div>
      <div class="footer-text">COSO 2013 Framework</div>
    </div>
  </aside>
</template>

<script setup>
import { reactive } from 'vue'
import { useAppStore } from '@/store'

const appStore = useAppStore()

const openGroups = reactive({
  risk: true,
  control: true,
  evaluation: true,
  findings: false,
  settings: false
})

function toggleGroup(group) {
  openGroups[group] = !openGroups[group]
}
</script>

<style lang="scss" scoped>
.sidebar {
  width: 260px;
  height: 100vh;
  background: linear-gradient(180deg, #1a3a6b 0%, #0f2448 60%, #0a1a30 100%);
  display: flex;
  flex-direction: column;
  transition: width 0.25s ease;
  overflow: hidden;
  position: relative;
  z-index: 100;
  flex-shrink: 0;

  &.collapsed {
    width: 64px;

    .nav-parent .nav-arrow { display: none; }
    .nav-children { display: none !important; }
    .nav-label { display: none; }
  }
}

// Logo
.sidebar-logo {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 18px 16px;
  border-bottom: 1px solid rgba(255,255,255,0.1);
  min-height: 64px;
}

.logo-icon {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.logo-text {
  display: flex;
  flex-direction: column;
}

.logo-name {
  font-size: 16px;
  font-weight: 700;
  color: white;
  letter-spacing: 0.5px;
}

.logo-sub {
  font-size: 10px;
  color: rgba(255,255,255,0.5);
  letter-spacing: 0.3px;
}

// Navigation
.sidebar-nav {
  flex: 1;
  overflow-y: auto;
  padding: 8px 0;

  &::-webkit-scrollbar { width: 4px; }
  &::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.2); border-radius: 2px; }
}

.nav-group {
  margin-bottom: 4px;
}

.nav-group-title {
  font-size: 10px;
  font-weight: 600;
  color: rgba(255,255,255,0.4);
  text-transform: uppercase;
  letter-spacing: 1px;
  padding: 12px 16px 4px;
}

.nav-group-divider {
  height: 1px;
  background: rgba(255,255,255,0.1);
  margin: 8px 12px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 16px;
  color: rgba(255,255,255,0.75);
  cursor: pointer;
  transition: all 0.15s ease;
  border-radius: 0;
  font-size: 13.5px;
  text-decoration: none;

  &:hover {
    background: rgba(255,255,255,0.08);
    color: white;
  }

  &.active {
    background: rgba(255,255,255,0.15);
    color: white;
    border-left: 3px solid #e8a020;
  }
}

.nav-icon {
  font-size: 16px;
  width: 20px;
  text-align: center;
  flex-shrink: 0;
}

.nav-label {
  flex: 1;
  white-space: nowrap;
}

.nav-arrow {
  font-size: 16px;
  transition: transform 0.2s ease;
  margin-left: auto;
  opacity: 0.6;

  &.rotated {
    transform: rotate(90deg);
  }
}

.nav-parent {
  &:hover .nav-arrow { opacity: 1; }
}

.nav-children {
  overflow: hidden;
  max-height: 0;
  transition: max-height 0.25s ease;
}

.nav-item-group.open .nav-children {
  max-height: 300px;
}

.nav-child {
  display: block;
  padding: 8px 16px 8px 46px;
  color: rgba(255,255,255,0.6);
  font-size: 13px;
  text-decoration: none;
  transition: all 0.15s ease;

  &:hover {
    color: white;
    background: rgba(255,255,255,0.05);
  }

  &.active {
    color: #e8a020;
    font-weight: 500;
  }
}

// Footer
.sidebar-footer {
  padding: 16px;
  border-top: 1px solid rgba(255,255,255,0.1);
}

.coso-badge-group {
  display: flex;
  gap: 4px;
  margin-bottom: 8px;
}

.mini-badge {
  flex: 1;
  height: 24px;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 9px;
  font-weight: 700;
  letter-spacing: 0.5px;

  &.env { background: rgba(74, 111, 165, 0.4); color: #7fb3d3; }
  &.risk { background: rgba(192, 57, 43, 0.4); color: #e74c3c; }
  &.ctrl { background: rgba(39, 174, 96, 0.4); color: #58d68d; }
  &.info { background: rgba(142, 68, 173, 0.4); color: #bb8fce; }
  &.mon { background: rgba(230, 126, 34, 0.4); color: #f0b27a; }
}

.footer-text {
  font-size: 10px;
  color: rgba(255,255,255,0.3);
  text-align: center;
}
</style>
