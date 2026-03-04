<template>
  <header class="app-header">
    <div class="header-left">
      <button class="toggle-btn" @click="appStore.toggleSidebar()">
        <span class="hamburger" :class="{ open: appStore.sidebarCollapsed }">
          <span></span><span></span><span></span>
        </span>
      </button>

      <!-- Breadcrumb -->
      <nav class="breadcrumb">
        <span class="breadcrumb-home">ITGC 포털</span>
        <template v-for="(crumb, i) in breadcrumbs" :key="i">
          <span class="breadcrumb-sep">›</span>
          <span class="breadcrumb-item" :class="{ active: i === breadcrumbs.length - 1 }">
            {{ crumb }}
          </span>
        </template>
      </nav>
    </div>

    <div class="header-center">
      <!-- 평가 기간 표시 -->
      <div class="period-badge">
        <span class="period-icon">📅</span>
        <span>{{ evalStore.periodLabel }} 운영평가</span>
      </div>
    </div>

    <div class="header-right">
      <!-- 검색 -->
      <div class="header-search">
        <input type="text" placeholder="검색..." class="search-input" />
        <span class="search-icon">🔍</span>
      </div>

      <!-- 알림 -->
      <button class="header-btn notification-btn">
        <span>🔔</span>
        <span class="notification-badge">3</span>
      </button>

      <!-- 도움말 -->
      <button class="header-btn">
        <span>❓</span>
      </button>

      <!-- 사용자 -->
      <div class="user-menu">
        <div class="user-avatar">김</div>
        <div class="user-info">
          <div class="user-name">김감사</div>
          <div class="user-role">IT 감사팀장</div>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAppStore, useEvaluationStore } from '@/store'

const appStore = useAppStore()
const evalStore = useEvaluationStore()
const route = useRoute()

const breadcrumbs = computed(() => route.meta?.breadcrumb || [])
</script>

<style lang="scss" scoped>
.app-header {
  height: 60px;
  background: white;
  border-bottom: 1px solid #e9ecef;
  display: flex;
  align-items: center;
  padding: 0 20px;
  gap: 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  position: sticky;
  top: 0;
  z-index: 50;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
}

.toggle-btn {
  width: 36px;
  height: 36px;
  border: none;
  background: transparent;
  cursor: pointer;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.15s;

  &:hover { background: #f1f3f5; }
}

.hamburger {
  display: flex;
  flex-direction: column;
  gap: 4px;
  width: 18px;

  span {
    display: block;
    height: 2px;
    background: #495057;
    border-radius: 1px;
    transition: all 0.2s;

    &:nth-child(1) { width: 18px; }
    &:nth-child(2) { width: 14px; }
    &:nth-child(3) { width: 18px; }
  }

  &.open span {
    &:nth-child(2) { width: 18px; }
  }
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
}

.breadcrumb-home { color: #868e96; }
.breadcrumb-sep { color: #ced4da; }
.breadcrumb-item {
  color: #868e96;
  &.active { color: #1a3a6b; font-weight: 500; }
}

.header-center {
  display: flex;
  align-items: center;
}

.period-badge {
  display: flex;
  align-items: center;
  gap: 6px;
  background: rgba(26, 58, 107, 0.08);
  color: #1a3a6b;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 500;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.header-search {
  position: relative;
  display: flex;
  align-items: center;
}

.search-input {
  width: 180px;
  padding: 7px 32px 7px 12px;
  border: 1px solid #dee2e6;
  border-radius: 20px;
  font-size: 13px;
  outline: none;
  transition: border-color 0.15s;
  font-family: inherit;

  &:focus { border-color: #1a3a6b; }
}

.search-icon {
  position: absolute;
  right: 10px;
  font-size: 13px;
  opacity: 0.5;
}

.header-btn {
  width: 36px;
  height: 36px;
  border: none;
  background: transparent;
  cursor: pointer;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  transition: background 0.15s;
  position: relative;

  &:hover { background: #f1f3f5; }
}

.notification-btn {
  .notification-badge {
    position: absolute;
    top: 4px;
    right: 4px;
    background: #e74c3c;
    color: white;
    font-size: 9px;
    width: 16px;
    height: 16px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
  }
}

.user-menu {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 6px 12px;
  border-radius: 8px;
  cursor: pointer;
  transition: background 0.15s;
  margin-left: 4px;

  &:hover { background: #f1f3f5; }
}

.user-avatar {
  width: 34px;
  height: 34px;
  border-radius: 50%;
  background: linear-gradient(135deg, #1a3a6b, #2d5aa0);
  color: white;
  font-size: 14px;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
}

.user-info {
  .user-name {
    font-size: 13px;
    font-weight: 600;
    color: #343a40;
    line-height: 1.2;
  }
  .user-role {
    font-size: 11px;
    color: #868e96;
  }
}
</style>
