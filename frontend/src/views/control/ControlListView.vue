<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">통제 목록</h1>
          <p class="page-subtitle">IT 일반통제(ITGC) 전체 통제 현황을 관리합니다</p>
        </div>
        <div class="d-flex gap-8">
          <DxButton text="Excel 내보내기" icon="exportxlsx" type="normal" />
          <DxButton text="통제 등록" icon="plus" type="default" @click="showAddDialog = true" />
        </div>
      </div>
    </div>

    <!-- Summary Cards -->
    <div class="stat-cards" style="margin-bottom: 20px">
      <div v-for="s in controlSummary" :key="s.id" class="stat-card">
        <div class="stat-icon" :class="`icon-${s.iconType}`">{{ s.icon }}</div>
        <div class="stat-info">
          <div class="stat-label">{{ s.label }}</div>
          <div class="stat-value">{{ s.value }}</div>
          <div class="stat-change" :class="s.changeType">{{ s.change }}</div>
        </div>
      </div>
    </div>

    <!-- ITGC Domain Tabs -->
    <div class="card" style="padding: 0; margin-bottom: 20px; overflow: hidden">
      <div class="domain-tabs">
        <button
          v-for="domain in domains"
          :key="domain.id"
          class="domain-tab"
          :class="{ active: selectedDomain === domain.id }"
          @click="selectedDomain = domain.id"
        >
          <span class="domain-icon">{{ domain.icon }}</span>
          <span class="domain-name">{{ domain.name }}</span>
          <span class="domain-count">{{ domain.count }}</span>
        </button>
      </div>
    </div>

    <!-- Filter Row -->
    <div class="card" style="margin-bottom: 16px">
      <div class="filter-row">
        <div class="filter-item">
          <label class="filter-label">통제 유형</label>
          <DxSelectBox v-model:value="filters.type" :items="['예방통제', '탐지통제', '교정통제']" placeholder="전체" :show-clear-button="true" width="140" />
        </div>
        <div class="filter-item">
          <label class="filter-label">자동화 여부</label>
          <DxSelectBox v-model:value="filters.automation" :items="['자동', '수동', '반자동']" placeholder="전체" :show-clear-button="true" width="140" />
        </div>
        <div class="filter-item">
          <label class="filter-label">효과성</label>
          <DxSelectBox v-model:value="filters.effectiveness" :items="['효과적', '부분 효과적', '비효과적', '미평가']" placeholder="전체" :show-clear-button="true" width="150" />
        </div>
        <DxButton text="조회" type="default" icon="search" />
        <DxButton text="초기화" type="normal" icon="clear" @click="resetFilters" />
      </div>
    </div>

    <!-- Controls Grid -->
    <div class="card" style="padding: 0">
      <DxDataGrid
        :data-source="filteredControls"
        :show-borders="false"
        :hover-state-enabled="true"
        :column-auto-width="true"
        :allow-column-resizing="true"
        :row-alternation-enabled="true"
        :word-wrap-enabled="true"
      >
        <DxToolbar>
          <DxItem location="before" template="titleTemplate" />
          <DxItem name="searchPanel" />
        </DxToolbar>
        <DxSearchPanel :visible="true" placeholder="통제 검색..." />
        <DxPaging :page-size="15" />
        <DxPager :show-info="true" :allowed-page-sizes="[10, 15, 30]" />

        <DxColumn data-field="controlCode" caption="통제 코드" width="130" :fixed="true" />
        <DxColumn data-field="domain" caption="도메인" width="110" cell-template="domainTemplate" />
        <DxColumn data-field="controlName" caption="통제명" min-width="200" />
        <DxColumn data-field="controlObjective" caption="통제 목적" min-width="200" />
        <DxColumn data-field="controlType" caption="통제 유형" width="100" cell-template="typeTemplate" />
        <DxColumn data-field="automation" caption="자동화" width="90" cell-template="autoTemplate" />
        <DxColumn data-field="frequency" caption="실행 주기" width="90" />
        <DxColumn data-field="controlOwner" caption="통제 담당자" width="110" />
        <DxColumn data-field="effectiveness" caption="효과성" width="110" cell-template="effectTemplate" />
        <DxColumn data-field="lastTestDate" caption="최근 평가일" width="110" />
        <DxColumn caption="관리" width="100" cell-template="actionTemplate" :allow-sorting="false" />

        <template #titleTemplate>
          <div style="font-weight: 600; font-size: 15px; color: #1a3a6b; padding: 4px 0">
            통제 목록 ({{ filteredControls.length }}건)
          </div>
        </template>
        <template #domainTemplate="{ data }">
          <span class="domain-badge" :class="`domain-${getDomainCode(data.value)}`">{{ data.value }}</span>
        </template>
        <template #typeTemplate="{ data }">
          <span class="type-badge" :class="`type-${data.value}`">{{ data.value }}</span>
        </template>
        <template #autoTemplate="{ data }">
          <span :class="`auto-badge auto-${data.value}`">{{ data.value }}</span>
        </template>
        <template #effectTemplate="{ data }">
          <div class="effect-cell">
            <span class="badge" :class="`badge-${getEffectClass(data.value)}`">{{ data.value }}</span>
          </div>
        </template>
        <template #actionTemplate="{ data }">
          <div class="action-btns">
            <button class="action-btn edit" @click="editControl(data.data)" title="수정">✏</button>
            <button class="action-btn view" @click="viewControl(data.data)" title="상세">👁</button>
          </div>
        </template>
      </DxDataGrid>
    </div>

    <!-- Add Dialog -->
    <DxPopup
      v-model:visible="showAddDialog"
      title="통제 등록"
      :width="720"
      :height="600"
      :drag-enabled="true"
      :show-close-button="true"
    >
      <template #content>
        <div class="form-grid">
          <div class="form-row">
            <div class="form-group">
              <label class="form-label required">도메인</label>
              <DxSelectBox v-model:value="controlForm.domain" :items="domains" display-expr="name" value-expr="name" :width="'100%'" />
            </div>
            <div class="form-group">
              <label class="form-label required">통제 코드</label>
              <DxTextBox v-model:value="controlForm.controlCode" placeholder="CTRL-ACC-001" :width="'100%'" />
            </div>
          </div>
          <div class="form-group full">
            <label class="form-label required">통제명</label>
            <DxTextBox v-model:value="controlForm.controlName" :width="'100%'" />
          </div>
          <div class="form-group full">
            <label class="form-label">통제 목적</label>
            <DxTextArea v-model:value="controlForm.controlObjective" :height="70" :width="'100%'" />
          </div>
          <div class="form-group full">
            <label class="form-label">통제 활동 기술</label>
            <DxTextArea v-model:value="controlForm.controlDescription" :height="80" :width="'100%'" />
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="form-label required">통제 유형</label>
              <DxSelectBox v-model:value="controlForm.controlType" :items="['예방통제', '탐지통제', '교정통제']" :width="'100%'" />
            </div>
            <div class="form-group">
              <label class="form-label required">자동화 여부</label>
              <DxSelectBox v-model:value="controlForm.automation" :items="['자동', '수동', '반자동']" :width="'100%'" />
            </div>
            <div class="form-group">
              <label class="form-label required">실행 주기</label>
              <DxSelectBox v-model:value="controlForm.frequency" :items="['상시', '일일', '주간', '월간', '분기', '반기', '연간']" :width="'100%'" />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="form-label required">통제 담당자</label>
              <DxTextBox v-model:value="controlForm.controlOwner" :width="'100%'" />
            </div>
            <div class="form-group">
              <label class="form-label required">담당 부서</label>
              <DxSelectBox v-model:value="controlForm.dept" :items="deptOptions" :width="'100%'" />
            </div>
          </div>
        </div>
      </template>
      <template #toolbarItems>
        <DxToolbarItem widget="dxButton" toolbar="bottom" location="after" :options="{ text: '등록', type: 'default', onClick: saveControl }" />
        <DxToolbarItem widget="dxButton" toolbar="bottom" location="after" :options="{ text: '취소', type: 'normal', onClick: () => showAddDialog = false }" />
      </template>
    </DxPopup>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxDataGrid, { DxColumn, DxPaging, DxPager, DxSearchPanel, DxToolbar, DxItem } from 'devextreme-vue/data-grid'
import DxSelectBox from 'devextreme-vue/select-box'
import DxTextBox from 'devextreme-vue/text-box'
import DxTextArea from 'devextreme-vue/text-area'
import { DxPopup, DxToolbarItem } from 'devextreme-vue/popup'

const showAddDialog = ref(false)
const selectedDomain = ref('ALL')
const filters = ref({ type: null, automation: null, effectiveness: null })

const deptOptions = ['IT운영팀', '개발팀', '정보보안팀', 'IT인프라팀', 'DBA팀', 'HR시스템팀']

const domains = [
  { id: 'ALL', name: '전체', icon: '⊞', count: 111 },
  { id: 'ACC', name: '접근통제', icon: '🔐', count: 28 },
  { id: 'CHG', name: '변경관리', icon: '🔄', count: 22 },
  { id: 'OPS', name: 'IT운영', icon: '⚙', count: 30 },
  { id: 'BCM', name: '업무연속성', icon: '🛡', count: 15 },
  { id: 'SEC', name: '정보보안', icon: '🔒', count: 16 }
]

const controlForm = ref({
  domain: null, controlCode: '', controlName: '', controlObjective: '',
  controlDescription: '', controlType: null, automation: null,
  frequency: null, controlOwner: '', dept: null
})

const controls = ref([
  { id: 1, controlCode: 'CTRL-ACC-001', domain: '접근통제', controlName: '사용자 계정 등록/변경/삭제 승인', controlObjective: '권한 없는 접근 방지', controlType: '예방통제', automation: '수동', frequency: '수시', controlOwner: '이보안', effectiveness: '효과적', lastTestDate: '2026-02-15' },
  { id: 2, controlCode: 'CTRL-ACC-002', domain: '접근통제', controlName: '특권 계정 반기 재검토', controlObjective: '과도한 권한 방지', controlType: '탐지통제', automation: '수동', frequency: '반기', controlOwner: '이보안', effectiveness: '부분 효과적', lastTestDate: '2026-01-10' },
  { id: 3, controlCode: 'CTRL-CHG-001', domain: '변경관리', controlName: '변경 요청 및 승인 관리', controlObjective: '미승인 변경 방지', controlType: '예방통제', automation: '반자동', frequency: '수시', controlOwner: '김개발', effectiveness: '효과적', lastTestDate: '2026-02-20' },
  { id: 4, controlCode: 'CTRL-CHG-002', domain: '변경관리', controlName: '변경 후 테스트 및 검증', controlObjective: '변경 오류 탐지', controlType: '탐지통제', automation: '수동', frequency: '수시', controlOwner: '김개발', effectiveness: '부분 효과적', lastTestDate: '2026-02-01' },
  { id: 5, controlCode: 'CTRL-OPS-001', domain: 'IT운영', controlName: '배치 작업 모니터링', controlObjective: '배치 오류 조기 탐지', controlType: '탐지통제', automation: '자동', frequency: '일일', controlOwner: '박운영', effectiveness: '비효과적', lastTestDate: '2026-02-25' },
  { id: 6, controlCode: 'CTRL-BCM-001', domain: '업무연속성', controlName: 'DR 테스트 실시', controlObjective: '복구 능력 검증', controlType: '탐지통제', automation: '수동', frequency: '반기', controlOwner: '정인프라', effectiveness: '미평가', lastTestDate: '-' },
  { id: 7, controlCode: 'CTRL-SEC-001', domain: '정보보안', controlName: '취약점 정기 스캔', controlObjective: '보안 취약점 조기 탐지', controlType: '탐지통제', automation: '자동', frequency: '월간', controlOwner: '이보안', effectiveness: '효과적', lastTestDate: '2026-02-28' }
])

const filteredControls = computed(() => {
  return controls.value.filter(c => {
    if (selectedDomain.value !== 'ALL') {
      const domain = domains.find(d => d.id === selectedDomain.value)
      if (domain && c.domain !== domain.name) return false
    }
    if (filters.value.type && c.controlType !== filters.value.type) return false
    if (filters.value.automation && c.automation !== filters.value.automation) return false
    if (filters.value.effectiveness && c.effectiveness !== filters.value.effectiveness) return false
    return true
  })
})

function getDomainCode(name) {
  const map = { '접근통제': 'acc', '변경관리': 'chg', 'IT운영': 'ops', '업무연속성': 'bcm', '정보보안': 'sec' }
  return map[name] || 'default'
}

function getEffectClass(val) {
  const map = { '효과적': 'effective', '부분 효과적': 'partial', '비효과적': 'ineffective', '미평가': 'not-tested' }
  return map[val] || 'not-tested'
}

function resetFilters() {
  filters.value = { type: null, automation: null, effectiveness: null }
}

function editControl(ctrl) { console.log('Edit:', ctrl) }
function viewControl(ctrl) { console.log('View:', ctrl) }
function saveControl() { showAddDialog.value = false }
</script>

<style lang="scss" scoped>
.filter-row {
  display: flex;
  align-items: flex-end;
  gap: 16px;
  flex-wrap: wrap;
}

.filter-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.filter-label {
  font-size: 12px;
  font-weight: 500;
  color: #495057;
}

// Domain Tabs
.domain-tabs {
  display: flex;
  overflow-x: auto;
}

.domain-tab {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 20px;
  border: none;
  background: white;
  cursor: pointer;
  border-bottom: 3px solid transparent;
  color: #495057;
  font-size: 13px;
  font-family: inherit;
  white-space: nowrap;
  transition: all 0.15s;

  &:hover {
    background: #f8f9fa;
    color: #1a3a6b;
  }

  &.active {
    color: #1a3a6b;
    border-bottom-color: #1a3a6b;
    font-weight: 600;
    background: #f0f4ff;
  }
}

.domain-icon { font-size: 15px; }
.domain-count {
  background: #e9ecef;
  color: #495057;
  padding: 1px 7px;
  border-radius: 10px;
  font-size: 11px;
  font-weight: 600;
}

.domain-tab.active .domain-count {
  background: #1a3a6b;
  color: white;
}

// Domain Badges
.domain-badge {
  display: inline-flex;
  padding: 3px 9px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;

  &.domain-acc { background: rgba(74, 111, 165, 0.12); color: #2d5aa0; }
  &.domain-chg { background: rgba(142, 68, 173, 0.12); color: #7d3c98; }
  &.domain-ops { background: rgba(39, 174, 96, 0.12); color: #1e8449; }
  &.domain-bcm { background: rgba(230, 126, 34, 0.12); color: #ca6f1e; }
  &.domain-sec { background: rgba(231, 76, 60, 0.12); color: #c0392b; }
}

// Type Badges
.type-badge {
  display: inline-flex;
  padding: 3px 9px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;

  &.type-예방통제 { background: rgba(52, 152, 219, 0.12); color: #2980b9; }
  &.type-탐지통제 { background: rgba(243, 156, 18, 0.12); color: #ca6f1e; }
  &.type-교정통제 { background: rgba(39, 174, 96, 0.12); color: #1e8449; }
}

// Auto Badge
.auto-badge {
  display: inline-flex;
  padding: 3px 9px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;

  &.auto-자동 { background: rgba(39, 174, 96, 0.12); color: #1e8449; }
  &.auto-수동 { background: rgba(149, 165, 166, 0.2); color: #616a6b; }
  &.auto-반자동 { background: rgba(243, 156, 18, 0.12); color: #ca6f1e; }
}

// Action buttons
.action-btns {
  display: flex;
  gap: 4px;
}

.action-btn {
  width: 28px;
  height: 28px;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  background: white;
  cursor: pointer;
  font-size: 13px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.15s;

  &.edit:hover { background: #e8f0fe; border-color: #1a3a6b; }
  &.view:hover { background: #e8f5e9; border-color: #27ae60; }
}

// Form
.form-grid {
  padding: 4px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;

  &.full { grid-column: 1 / -1; }
}

.form-label {
  font-size: 13px;
  font-weight: 500;
  color: #495057;

  &.required::after {
    content: ' *';
    color: #e74c3c;
  }
}
</style>
