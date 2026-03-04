<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">위험 식별</h1>
          <p class="page-subtitle">IT 업무 프로세스별 잠재 위험을 식별하고 등록합니다</p>
        </div>
        <div class="d-flex gap-8">
          <DxButton text="Excel 내보내기" icon="exportxlsx" type="normal" @click="exportExcel" />
          <DxButton text="위험 등록" icon="plus" type="default" @click="showAddDialog = true" />
        </div>
      </div>
    </div>

    <!-- Filter Panel -->
    <div class="card" style="margin-bottom: 20px">
      <div class="filter-row">
        <div class="filter-item">
          <label class="filter-label">위험 카테고리</label>
          <DxSelectBox
            v-model:value="filters.category"
            :items="categoryOptions"
            display-expr="name"
            value-expr="code"
            placeholder="전체"
            :show-clear-button="true"
            width="180"
          />
        </div>
        <div class="filter-item">
          <label class="filter-label">위험 수준</label>
          <DxSelectBox
            v-model:value="filters.level"
            :items="['심각', '높음', '중간', '낮음', '미미']"
            placeholder="전체"
            :show-clear-button="true"
            width="140"
          />
        </div>
        <div class="filter-item">
          <label class="filter-label">담당 부서</label>
          <DxSelectBox
            v-model:value="filters.dept"
            :items="deptOptions"
            placeholder="전체"
            :show-clear-button="true"
            width="160"
          />
        </div>
        <div class="filter-item">
          <label class="filter-label">위험 상태</label>
          <DxSelectBox
            v-model:value="filters.status"
            :items="['활성', '모니터링', '수용', '완화']"
            placeholder="전체"
            :show-clear-button="true"
            width="140"
          />
        </div>
        <DxButton text="조회" type="default" icon="search" @click="applyFilters" />
        <DxButton text="초기화" type="normal" icon="clear" @click="resetFilters" />
      </div>
    </div>

    <!-- Risk Grid -->
    <div class="card" style="padding: 0">
      <DxDataGrid
        ref="gridRef"
        :data-source="filteredRisks"
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

        <DxSearchPanel :visible="true" placeholder="위험 검색..." />
        <DxPaging :page-size="15" />
        <DxPager :show-info="true" :allowed-page-sizes="[10, 15, 30]" />

        <DxColumn data-field="riskCode" caption="위험 코드" width="130" :fixed="true" />
        <DxColumn data-field="category" caption="카테고리" width="130" cell-template="categoryTemplate" />
        <DxColumn data-field="riskName" caption="위험명" min-width="200" />
        <DxColumn data-field="riskDescription" caption="위험 설명" min-width="250" />
        <DxColumn data-field="inherentRisk" caption="고유 위험" width="100" cell-template="riskLevelTemplate" />
        <DxColumn data-field="likelihood" caption="발생 가능성" width="110" alignment="center" />
        <DxColumn data-field="impact" caption="영향도" width="90" alignment="center" />
        <DxColumn data-field="riskOwner" caption="위험 담당자" width="110" />
        <DxColumn data-field="dept" caption="담당 부서" width="120" />
        <DxColumn data-field="status" caption="상태" width="90" cell-template="statusTemplate" />
        <DxColumn data-field="lastUpdated" caption="최종 수정일" width="110" />
        <DxColumn caption="관리" width="100" cell-template="actionTemplate" :allow-sorting="false" />

        <template #titleTemplate>
          <div style="font-weight: 600; font-size: 15px; color: #1a3a6b; padding: 4px 0">
            위험 목록 (총 {{ filteredRisks.length }}건)
          </div>
        </template>
        <template #categoryTemplate="{ data }">
          <span class="coso-badge coso-risk">{{ data.value }}</span>
        </template>
        <template #riskLevelTemplate="{ data }">
          <span class="badge" :class="`badge-${getRiskClass(data.value)}`">{{ data.value }}</span>
        </template>
        <template #statusTemplate="{ data }">
          <span class="badge" :class="getStatusBadge(data.value)">{{ data.value }}</span>
        </template>
        <template #actionTemplate="{ data }">
          <div class="action-btns">
            <button class="action-btn edit" @click="editRisk(data.data)" title="수정">✏</button>
            <button class="action-btn view" @click="viewRisk(data.data)" title="상세">👁</button>
          </div>
        </template>
      </DxDataGrid>
    </div>

    <!-- Add/Edit Dialog -->
    <DxPopup
      v-model:visible="showAddDialog"
      :title="editMode ? '위험 수정' : '위험 등록'"
      :width="700"
      :height="580"
      :drag-enabled="true"
      :show-close-button="true"
    >
      <template #content>
        <div class="form-grid">
          <div class="form-row">
            <div class="form-group">
              <label class="form-label required">위험 카테고리</label>
              <DxSelectBox
                v-model:value="riskForm.category"
                :items="categoryOptions"
                display-expr="name"
                value-expr="code"
                :width="'100%'"
              />
            </div>
            <div class="form-group">
              <label class="form-label required">위험 코드</label>
              <DxTextBox v-model:value="riskForm.riskCode" placeholder="IT-SEC-001" :width="'100%'" />
            </div>
          </div>

          <div class="form-group full">
            <label class="form-label required">위험명</label>
            <DxTextBox v-model:value="riskForm.riskName" placeholder="위험의 이름을 입력하세요" :width="'100%'" />
          </div>

          <div class="form-group full">
            <label class="form-label">위험 설명</label>
            <DxTextArea
              v-model:value="riskForm.riskDescription"
              :height="80"
              placeholder="위험에 대한 상세 설명을 입력하세요"
              :width="'100%'"
            />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="form-label required">발생 가능성 (1-5)</label>
              <DxNumberBox v-model:value="riskForm.likelihood" :min="1" :max="5" :width="'100%'" />
            </div>
            <div class="form-group">
              <label class="form-label required">영향도 (1-5)</label>
              <DxNumberBox v-model:value="riskForm.impact" :min="1" :max="5" :width="'100%'" />
            </div>
            <div class="form-group">
              <label class="form-label">고유 위험 수준</label>
              <DxTextBox :value="calculateRiskLevel(riskForm.likelihood, riskForm.impact)" :read-only="true" :width="'100%'" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="form-label required">위험 담당자</label>
              <DxTextBox v-model:value="riskForm.riskOwner" :width="'100%'" />
            </div>
            <div class="form-group">
              <label class="form-label required">담당 부서</label>
              <DxSelectBox v-model:value="riskForm.dept" :items="deptOptions" :width="'100%'" />
            </div>
          </div>

          <div class="form-group full">
            <label class="form-label">관련 프로세스</label>
            <DxTagBox
              v-model:value="riskForm.processes"
              :items="processOptions"
              :width="'100%'"
              placeholder="관련 프로세스 선택"
            />
          </div>
        </div>
      </template>
      <template #toolbarItems>
        <DxToolbarItem
          widget="dxButton"
          toolbar="bottom"
          location="after"
          :options="{ text: editMode ? '수정' : '등록', type: 'default', onClick: saveRisk }"
        />
        <DxToolbarItem
          widget="dxButton"
          toolbar="bottom"
          location="after"
          :options="{ text: '취소', type: 'normal', onClick: () => showAddDialog = false }"
        />
      </template>
    </DxPopup>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxDataGrid, {
  DxColumn, DxPaging, DxPager, DxSearchPanel, DxToolbar, DxItem
} from 'devextreme-vue/data-grid'
import DxSelectBox from 'devextreme-vue/select-box'
import DxTextBox from 'devextreme-vue/text-box'
import DxTextArea from 'devextreme-vue/text-area'
import DxNumberBox from 'devextreme-vue/number-box'
import DxTagBox from 'devextreme-vue/tag-box'
import { DxPopup, DxToolbarItem } from 'devextreme-vue/popup'
import { exportDataGrid } from 'devextreme/excel_exporter'

const gridRef = ref(null)
const showAddDialog = ref(false)
const editMode = ref(false)

const filters = ref({ category: null, level: null, dept: null, status: null })

const categoryOptions = [
  { code: 'IT-OPS', name: 'IT 운영' },
  { code: 'IT-SEC', name: '정보보안' },
  { code: 'IT-CHG', name: '변경관리' },
  { code: 'IT-ACC', name: '접근통제' },
  { code: 'IT-BCM', name: '업무연속성' },
  { code: 'IT-DATA', name: '데이터 무결성' }
]

const deptOptions = ['IT운영팀', '개발팀', '정보보안팀', 'IT인프라팀', 'DBA팀', 'HR시스템팀', '감사팀']
const processOptions = ['ERP 운영', '인사관리', '재무관리', '구매관리', '고객관리', '시스템 개발', '배치처리']

const riskForm = ref({
  riskCode: '', category: null, riskName: '', riskDescription: '',
  likelihood: 3, impact: 3, riskOwner: '', dept: null, processes: []
})

const risks = ref([
  {
    id: 1, riskCode: 'IT-SEC-001', category: 'IT-SEC', riskName: '권한 없는 시스템 접근',
    riskDescription: '내부 또는 외부 사용자가 권한 없이 중요 시스템에 접근할 위험',
    inherentRisk: '심각', likelihood: 4, impact: 5, riskOwner: '이보안', dept: '정보보안팀',
    status: '활성', lastUpdated: '2026-02-28'
  },
  {
    id: 2, riskCode: 'IT-CHG-001', category: 'IT-CHG', riskName: '미승인 시스템 변경',
    riskDescription: '정식 변경관리 프로세스 없이 운영 환경에 변경이 적용될 위험',
    inherentRisk: '높음', likelihood: 3, impact: 4, riskOwner: '김개발', dept: '개발팀',
    status: '활성', lastUpdated: '2026-02-25'
  },
  {
    id: 3, riskCode: 'IT-OPS-001', category: 'IT-OPS', riskName: '배치 처리 실패 미탐지',
    riskDescription: '중요 배치 작업 실패 시 적시에 탐지하지 못할 위험',
    inherentRisk: '높음', likelihood: 3, impact: 4, riskOwner: '박운영', dept: 'IT운영팀',
    status: '활성', lastUpdated: '2026-02-20'
  },
  {
    id: 4, riskCode: 'IT-ACC-001', category: 'IT-ACC', riskName: '퇴직자 계정 미삭제',
    riskDescription: '임직원 퇴직 후 시스템 접근 권한이 적시에 회수되지 않을 위험',
    inherentRisk: '높음', likelihood: 4, impact: 3, riskOwner: '최시스템', dept: 'HR시스템팀',
    status: '활성', lastUpdated: '2026-02-18'
  },
  {
    id: 5, riskCode: 'IT-BCM-001', category: 'IT-BCM', riskName: '재해복구 시스템 미검증',
    riskDescription: 'DR 시스템의 실제 복구 능력을 정기적으로 검증하지 않을 위험',
    inherentRisk: '중간', likelihood: 2, impact: 5, riskOwner: '정인프라', dept: 'IT인프라팀',
    status: '모니터링', lastUpdated: '2026-01-30'
  },
  {
    id: 6, riskCode: 'IT-DATA-001', category: 'IT-DATA', riskName: '데이터 무결성 미검증',
    riskDescription: '시스템 간 데이터 전송 시 무결성 검증이 수행되지 않을 위험',
    inherentRisk: '중간', likelihood: 3, impact: 3, riskOwner: '김DBA', dept: 'DBA팀',
    status: '활성', lastUpdated: '2026-02-15'
  }
])

const filteredRisks = computed(() => {
  return risks.value.filter(r => {
    if (filters.value.category && r.category !== filters.value.category) return false
    if (filters.value.level && r.inherentRisk !== filters.value.level) return false
    if (filters.value.dept && r.dept !== filters.value.dept) return false
    if (filters.value.status && r.status !== filters.value.status) return false
    return true
  })
})

function getRiskClass(level) {
  const map = { '심각': 'critical', '높음': 'high', '중간': 'medium', '낮음': 'low', '미미': 'minimal' }
  return map[level] || 'minimal'
}

function getStatusBadge(status) {
  const map = { '활성': 'high', '모니터링': 'medium', '수용': 'low', '완화': 'effective' }
  return `badge-${map[status] || 'not-tested'}`
}

function calculateRiskLevel(likelihood, impact) {
  const score = likelihood * impact
  if (score >= 20) return '심각'
  if (score >= 12) return '높음'
  if (score >= 6) return '중간'
  if (score >= 3) return '낮음'
  return '미미'
}

function applyFilters() {}
function resetFilters() {
  filters.value = { category: null, level: null, dept: null, status: null }
}

function editRisk(risk) {
  riskForm.value = { ...risk }
  editMode.value = true
  showAddDialog.value = true
}

function viewRisk(risk) {
  console.log('View risk:', risk)
}

function saveRisk() {
  if (!editMode.value) {
    const newRisk = {
      id: Date.now(),
      ...riskForm.value,
      inherentRisk: calculateRiskLevel(riskForm.value.likelihood, riskForm.value.impact),
      lastUpdated: new Date().toISOString().split('T')[0]
    }
    risks.value.push(newRisk)
  }
  showAddDialog.value = false
  editMode.value = false
}

function exportExcel() {
  console.log('Export to Excel')
}
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
</style>
