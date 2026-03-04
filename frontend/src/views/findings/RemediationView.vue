<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">개선 조치</h1>
          <p class="page-subtitle">발견사항에 대한 개선 조치 계획 및 이행 현황을 관리합니다</p>
        </div>
        <DxButton text="조치 현황 보고" icon="file" type="default" />
      </div>
    </div>

    <!-- Overdue Alert -->
    <div class="alert-banner" v-if="overdueItems.length > 0">
      <span class="alert-icon">⚠</span>
      <span class="alert-text">
        <strong>기한 초과 조치 {{ overdueItems.length }}건이 있습니다.</strong>
        즉각적인 조치가 필요합니다.
      </span>
      <DxButton text="기한초과 항목 보기" type="danger" @click="filterOverdue" />
    </div>

    <!-- Summary -->
    <div class="stat-cards" style="margin-bottom: 20px">
      <div v-for="s in remStats" :key="s.id" class="stat-card">
        <div class="stat-icon" :class="`icon-${s.iconType}`">{{ s.icon }}</div>
        <div class="stat-info">
          <div class="stat-label">{{ s.label }}</div>
          <div class="stat-value">{{ s.value }}</div>
          <div class="stat-change" :class="s.changeType">{{ s.change }}</div>
        </div>
      </div>
    </div>

    <!-- Remediation Kanban-style Progress -->
    <div class="card" style="margin-bottom: 20px">
      <div class="card-header">
        <div class="card-title">개선 조치 진행 현황</div>
      </div>
      <div class="kanban-board">
        <div v-for="col in kanbanColumns" :key="col.status" class="kanban-col">
          <div class="kanban-col-header" :class="`header-${col.statusClass}`">
            <span>{{ col.status }}</span>
            <span class="kanban-count">{{ col.items.length }}</span>
          </div>
          <div class="kanban-items">
            <div v-for="item in col.items" :key="item.id" class="kanban-item">
              <div class="kanban-item-header">
                <span class="badge" :class="`badge-${getSeverityClass(item.severity)}`">{{ item.severity }}</span>
                <span class="kanban-due" :class="{ overdue: item.isOverdue }">{{ item.dueDate }}</span>
              </div>
              <div class="kanban-item-title">{{ item.findingNo }}</div>
              <div class="kanban-item-desc">{{ item.title }}</div>
              <div class="kanban-item-footer">
                <span>{{ item.dept }}</span>
                <span class="badge badge-info">{{ item.progress }}%</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Remediation Table -->
    <div class="card" style="padding: 0">
      <DxDataGrid
        :data-source="remediationData"
        :show-borders="false"
        :hover-state-enabled="true"
        :column-auto-width="true"
        :allow-column-resizing="true"
        key-expr="id"
      >
        <DxEditing mode="row" :allow-updating="true" />
        <DxToolbar>
          <DxItem location="before" template="titleTemplate" />
          <DxItem name="searchPanel" />
        </DxToolbar>
        <DxSearchPanel :visible="true" placeholder="검색..." />
        <DxPaging :page-size="15" />
        <DxPager :show-info="true" />

        <DxColumn data-field="findingNo" caption="발견사항 번호" width="140" :allow-editing="false" />
        <DxColumn data-field="title" caption="발견사항명" min-width="180" :allow-editing="false" />
        <DxColumn data-field="severity" caption="심각도" width="90" cell-template="severityTemplate" :allow-editing="false" />
        <DxColumn data-field="remediationPlan" caption="개선 조치 계획" min-width="200" />
        <DxColumn data-field="dept" caption="담당 부서" width="120" :allow-editing="false" />
        <DxColumn data-field="owner" caption="담당자" width="100" />
        <DxColumn data-field="dueDate" caption="조치 기한" width="110" data-type="date" />
        <DxColumn data-field="progress" caption="진행률(%)" width="110" alignment="center" :editor-options="{ min: 0, max: 100 }" />
        <DxColumn data-field="status" caption="상태" width="100" cell-template="statusTemplate">
          <DxLookup :data-source="['미결', '조치중', '조치완료', '기한초과', '수용']" />
        </DxColumn>
        <DxColumn data-field="completionDate" caption="완료일" width="110" data-type="date" />

        <template #titleTemplate>
          <div style="font-weight: 600; font-size: 15px; color: #1a3a6b; padding: 4px 0">개선 조치 현황</div>
        </template>
        <template #severityTemplate="{ data }">
          <span class="badge" :class="`badge-${getSeverityClass(data.value)}`">{{ data.value }}</span>
        </template>
        <template #statusTemplate="{ data }">
          <span class="badge" :class="`badge-${getRemStatusClass(data.value)}`">{{ data.value }}</span>
        </template>
      </DxDataGrid>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxDataGrid, { DxColumn, DxEditing, DxLookup, DxPaging, DxPager, DxSearchPanel, DxToolbar, DxItem } from 'devextreme-vue/data-grid'
import dayjs from 'dayjs'

const remStats = ref([
  { id: 1, icon: '📋', iconType: 'primary', label: '전체 개선 조치', value: '47건', change: '총 발견사항 기준', changeType: 'neutral' },
  { id: 2, icon: '✓', iconType: 'success', label: '조치 완료', value: '23건', change: '48.9%', changeType: 'down' },
  { id: 3, icon: '⏳', iconType: 'info', label: '조치 진행중', value: '17건', change: '36.2%', changeType: 'neutral' },
  { id: 4, icon: '⚠', iconType: 'danger', label: '기한 초과', value: '7건', change: '즉시 조치', changeType: 'up' }
])

const remediationData = ref([
  { id: 1, findingNo: 'FND-2026-001', title: '관리자 계정 다중 사용 발견', severity: '심각', remediationPlan: '개인별 관리자 계정 재발급 및 MFA 적용', dept: '정보보안팀', owner: '이보안', dueDate: '2026-03-15', progress: 65, status: '조치중', completionDate: null },
  { id: 2, findingNo: 'FND-2026-002', title: '퇴직자 계정 15건 미삭제', severity: '높음', remediationPlan: 'HR-IT 연동을 통한 퇴직자 계정 즉시 삭제', dept: 'HR시스템팀', owner: '최시스템', dueDate: '2026-03-10', progress: 30, status: '기한초과', completionDate: null },
  { id: 3, findingNo: 'FND-2026-003', title: '미승인 변경 3건 발생', severity: '높음', remediationPlan: '긴급변경 절차 수립 및 사후 승인 의무화', dept: '개발팀', owner: '김개발', dueDate: '2026-04-05', progress: 100, status: '조치완료', completionDate: '2026-03-28' },
  { id: 4, findingNo: 'FND-2026-004', title: '배치 오류 무감지 운영', severity: '중간', remediationPlan: '배치 모니터링 솔루션 도입 및 알람 정책 수립', dept: 'IT운영팀', owner: '박운영', dueDate: '2026-04-30', progress: 45, status: '조치중', completionDate: null },
  { id: 5, findingNo: 'FND-2026-005', title: '데이터 정합성 검증 누락', severity: '중간', remediationPlan: '데이터 전송 무결성 검증 로직 구현', dept: 'DBA팀', owner: '김DBA', dueDate: '2026-05-31', progress: 0, status: '미결', completionDate: null }
])

const overdueItems = computed(() =>
  remediationData.value.filter(r => r.status === '기한초과')
)

const kanbanColumns = computed(() => [
  {
    status: '미결',
    statusClass: 'not-started',
    items: remediationData.value.filter(r => r.status === '미결').map(r => ({
      ...r, isOverdue: dayjs(r.dueDate).isBefore(dayjs(), 'day')
    }))
  },
  {
    status: '조치중',
    statusClass: 'in-progress',
    items: remediationData.value.filter(r => r.status === '조치중').map(r => ({
      ...r, isOverdue: dayjs(r.dueDate).isBefore(dayjs(), 'day')
    }))
  },
  {
    status: '기한초과',
    statusClass: 'overdue',
    items: remediationData.value.filter(r => r.status === '기한초과').map(r => ({
      ...r, isOverdue: true
    }))
  },
  {
    status: '조치완료',
    statusClass: 'done',
    items: remediationData.value.filter(r => r.status === '조치완료').map(r => ({
      ...r, isOverdue: false
    }))
  }
])

function getSeverityClass(val) {
  const map = { '심각': 'critical', '높음': 'high', '중간': 'medium', '낮음': 'low' }
  return map[val] || 'minimal'
}

function getRemStatusClass(val) {
  const map = { '조치완료': 'effective', '조치중': 'partial', '기한초과': 'ineffective', '미결': 'not-tested', '수용': 'low' }
  return map[val] || 'not-tested'
}

function filterOverdue() {}
</script>

<style lang="scss" scoped>
// Alert Banner
.alert-banner {
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(231, 76, 60, 0.08);
  border: 1px solid rgba(231, 76, 60, 0.3);
  border-radius: 8px;
  padding: 12px 16px;
  margin-bottom: 20px;

  .alert-icon { font-size: 18px; }
  .alert-text { flex: 1; font-size: 14px; color: #c0392b; }
}

// Kanban Board
.kanban-board {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  align-items: start;

  @media (max-width: 1024px) {
    grid-template-columns: repeat(2, 1fr);
  }
}

.kanban-col {
  background: #f8f9fa;
  border-radius: 8px;
  overflow: hidden;
}

.kanban-col-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 14px;
  font-size: 13px;
  font-weight: 600;

  &.header-not-started { background: #e9ecef; color: #495057; }
  &.header-in-progress { background: rgba(52, 152, 219, 0.15); color: #2980b9; }
  &.header-overdue { background: rgba(231, 76, 60, 0.15); color: #c0392b; }
  &.header-done { background: rgba(39, 174, 96, 0.15); color: #1e8449; }
}

.kanban-count {
  background: rgba(0,0,0,0.1);
  padding: 1px 7px;
  border-radius: 10px;
  font-size: 11px;
}

.kanban-items {
  padding: 8px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: 320px;
  overflow-y: auto;
}

.kanban-item {
  background: white;
  border-radius: 6px;
  padding: 10px;
  border: 1px solid #e9ecef;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}

.kanban-item-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 6px;
}

.kanban-due {
  font-size: 11px;
  color: #868e96;

  &.overdue { color: #e74c3c; font-weight: 600; }
}

.kanban-item-title {
  font-size: 11px;
  color: #868e96;
  font-family: monospace;
  margin-bottom: 2px;
}

.kanban-item-desc {
  font-size: 12px;
  font-weight: 500;
  color: #343a40;
  margin-bottom: 8px;
  line-height: 1.4;
}

.kanban-item-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 11px;
  color: #868e96;
}
</style>
