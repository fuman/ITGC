<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">보고서</h1>
          <p class="page-subtitle">ITGC 운영평가 결과 보고서를 생성하고 관리합니다</p>
        </div>
        <div class="d-flex gap-8">
          <DxButton text="보고서 생성" icon="file" type="default" @click="showCreateDialog = true" />
        </div>
      </div>
    </div>

    <!-- Report Types -->
    <div class="report-types-grid" style="margin-bottom: 24px">
      <div
        v-for="rtype in reportTypes"
        :key="rtype.id"
        class="report-type-card"
        :class="{ selected: selectedType === rtype.id }"
        @click="selectedType = rtype.id"
      >
        <div class="rt-icon">{{ rtype.icon }}</div>
        <div class="rt-name">{{ rtype.name }}</div>
        <div class="rt-desc">{{ rtype.desc }}</div>
        <div class="rt-count">{{ rtype.count }}개</div>
      </div>
    </div>

    <!-- Report Parameters -->
    <div class="card" style="margin-bottom: 20px" v-if="selectedType">
      <div class="card-header">
        <div class="card-title">보고서 생성 조건</div>
        <DxButton text="보고서 생성" icon="export" type="default" @click="generateReport" />
      </div>
      <div class="report-params">
        <div class="param-item">
          <label class="filter-label">평가 연도</label>
          <DxSelectBox v-model:value="reportParams.year" :items="[2024, 2025, 2026]" width="120" />
        </div>
        <div class="param-item">
          <label class="filter-label">평가 분기</label>
          <DxSelectBox v-model:value="reportParams.quarter" :items="['전체', '1분기', '2분기', '3분기', '4분기']" width="130" />
        </div>
        <div class="param-item">
          <label class="filter-label">대상 그룹사</label>
          <DxSelectBox v-model:value="reportParams.company" :items="companyOptions" display-expr="name" value-expr="id" placeholder="전체" width="180" :show-clear-button="true" />
        </div>
        <div class="param-item">
          <label class="filter-label">출력 형식</label>
          <DxSelectBox v-model:value="reportParams.format" :items="['PDF', 'Excel', 'Word', 'PPT']" width="120" />
        </div>
      </div>
    </div>

    <!-- Report List -->
    <div class="grid-2">
      <!-- Recent Reports -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">최근 생성 보고서</div>
        </div>
        <div class="report-list">
          <div v-for="report in recentReports" :key="report.id" class="report-item">
            <div class="report-file-icon" :class="`format-${report.format.toLowerCase()}`">
              {{ getFormatIcon(report.format) }}
            </div>
            <div class="report-info">
              <div class="report-title">{{ report.title }}</div>
              <div class="report-meta">
                <span>{{ report.period }}</span>
                <span>·</span>
                <span>{{ report.createdAt }}</span>
                <span>·</span>
                <span>{{ report.createdBy }}</span>
              </div>
            </div>
            <div class="report-actions">
              <button class="action-btn view" @click="previewReport(report)" title="미리보기">👁</button>
              <button class="action-btn download" @click="downloadReport(report)" title="다운로드">⬇</button>
            </div>
          </div>
        </div>
      </div>

      <!-- Report Statistics -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">보고서 현황 요약</div>
          <span class="badge badge-primary">2026년 1분기</span>
        </div>

        <!-- COSO Summary Table -->
        <table class="coso-summary-table">
          <thead>
            <tr>
              <th>COSO 구성요소</th>
              <th>통제 수</th>
              <th>효과적</th>
              <th>미비점</th>
              <th>점수</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in cosoSummary" :key="item.id">
              <td>
                <div class="coso-name">
                  <span class="coso-abbr" :class="`abbr-${item.type}`">{{ item.abbr }}</span>
                  {{ item.name }}
                </div>
              </td>
              <td class="text-center">{{ item.totalControls }}</td>
              <td class="text-center">
                <span class="text-success fw-bold">{{ item.effective }}</span>
              </td>
              <td class="text-center">
                <span :class="item.deficiency > 0 ? 'text-danger fw-bold' : 'text-muted'">
                  {{ item.deficiency }}
                </span>
              </td>
              <td class="text-center">
                <div class="score-cell">
                  <span class="score-num" :class="`score-${getScoreClass(item.score)}`">
                    {{ item.score }}점
                  </span>
                </div>
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr class="total-row">
              <td><strong>합 계</strong></td>
              <td class="text-center"><strong>111</strong></td>
              <td class="text-center"><strong class="text-success">85</strong></td>
              <td class="text-center"><strong class="text-danger">18</strong></td>
              <td class="text-center"><strong>76점</strong></td>
            </tr>
          </tfoot>
        </table>

        <!-- Overall Score -->
        <div class="overall-score">
          <div class="score-label">종합 통제 효과성 점수</div>
          <div class="score-display">
            <div class="score-big">76</div>
            <div class="score-suffix">/ 100</div>
          </div>
          <div class="progress-bar" style="margin: 12px 0 6px">
            <div class="progress-fill fill-warning" style="width: 76%"></div>
          </div>
          <div class="score-level">보통 (개선 필요)</div>
        </div>
      </div>
    </div>

    <!-- Create Dialog -->
    <DxPopup
      v-model:visible="showCreateDialog"
      title="보고서 생성"
      :width="600"
      :height="420"
      :drag-enabled="true"
      :show-close-button="true"
    >
      <template #content>
        <div class="form-grid">
          <div class="form-group">
            <label class="form-label required">보고서 유형</label>
            <DxSelectBox v-model:value="newReport.type" :items="reportTypes" display-expr="name" value-expr="id" :width="'100%'" />
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="form-label required">평가 연도</label>
              <DxSelectBox v-model:value="newReport.year" :items="[2024, 2025, 2026]" :width="'100%'" />
            </div>
            <div class="form-group">
              <label class="form-label required">평가 분기</label>
              <DxSelectBox v-model:value="newReport.quarter" :items="['전체', '1분기', '2분기', '3분기', '4분기']" :width="'100%'" />
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">대상 그룹사</label>
            <DxSelectBox v-model:value="newReport.company" :items="companyOptions" display-expr="name" value-expr="id" placeholder="전체 그룹사" :show-clear-button="true" :width="'100%'" />
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="form-label required">출력 형식</label>
              <DxSelectBox v-model:value="newReport.format" :items="['PDF', 'Excel', 'Word', 'PPT']" :width="'100%'" />
            </div>
            <div class="form-group">
              <label class="form-label">언어</label>
              <DxSelectBox v-model:value="newReport.language" :items="['한국어', 'English']" :width="'100%'" />
            </div>
          </div>
        </div>
      </template>
      <template #toolbarItems>
        <DxToolbarItem widget="dxButton" toolbar="bottom" location="after" :options="{ text: '생성', type: 'default', onClick: createReport }" />
        <DxToolbarItem widget="dxButton" toolbar="bottom" location="after" :options="{ text: '취소', type: 'normal', onClick: () => showCreateDialog = false }" />
      </template>
    </DxPopup>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxSelectBox from 'devextreme-vue/select-box'
import { DxPopup, DxToolbarItem } from 'devextreme-vue/popup'

const showCreateDialog = ref(false)
const selectedType = ref(1)

const reportParams = ref({ year: 2026, quarter: '1분기', company: null, format: 'PDF' })
const newReport = ref({ type: null, year: 2026, quarter: '1분기', company: null, format: 'PDF', language: '한국어' })

const reportTypes = [
  { id: 1, icon: '📊', name: '운영평가 결과 보고서', desc: '분기별 통제 운영평가 종합 결과', count: 4 },
  { id: 2, icon: '⚠', name: '위험 평가 보고서', desc: '위험 식별 및 평가 현황 보고', count: 2 },
  { id: 3, icon: '🔍', name: '발견사항 현황 보고서', desc: '발견사항 및 개선 조치 현황', count: 8 },
  { id: 4, icon: '🏛', name: 'COSO 종합 현황 보고서', desc: 'COSO 5대 구성요소 종합 보고', count: 2 }
]

const companyOptions = [
  { id: 1, name: '(주)그룹사A' },
  { id: 2, name: '(주)그룹사B' },
  { id: 3, name: '(주)그룹사C' }
]

const recentReports = ref([
  { id: 1, title: '2026년 1분기 운영평가 결과 보고서', period: '2026년 1분기', format: 'PDF', createdAt: '2026-03-04', createdBy: '김감사' },
  { id: 2, title: '2025년 연간 ITGC 종합 보고서', period: '2025년 연간', format: 'PPT', createdAt: '2026-01-15', createdBy: '이팀장' },
  { id: 3, title: '2025년 4분기 발견사항 현황', period: '2025년 4분기', format: 'Excel', createdAt: '2026-01-05', createdBy: '김감사' },
  { id: 4, title: '2025년 3분기 위험 평가 보고서', period: '2025년 3분기', format: 'Word', createdAt: '2025-10-10', createdBy: '박검토' }
])

const cosoSummary = ref([
  { id: 1, type: 'env', abbr: 'CE', name: '통제 환경', totalControls: 24, effective: 20, deficiency: 2, score: 82 },
  { id: 2, type: 'risk', abbr: 'RA', name: '위험 평가', totalControls: 18, effective: 13, deficiency: 4, score: 75 },
  { id: 3, type: 'ctrl', abbr: 'CA', name: '통제 활동', totalControls: 42, effective: 38, deficiency: 1, score: 88 },
  { id: 4, type: 'info', abbr: 'IC', name: '정보 및 의사소통', totalControls: 15, effective: 10, deficiency: 5, score: 70 },
  { id: 5, type: 'mon', abbr: 'MA', name: '모니터링', totalControls: 12, effective: 4, deficiency: 6, score: 65 }
])

function getFormatIcon(format) {
  const icons = { PDF: '📄', Excel: '📗', Word: '📘', PPT: '📙' }
  return icons[format] || '📄'
}

function getScoreClass(score) {
  if (score >= 85) return 'good'
  if (score >= 70) return 'warn'
  return 'bad'
}

function generateReport() { console.log('Generating...') }
function previewReport(r) { console.log('Preview:', r) }
function downloadReport(r) { console.log('Download:', r) }
function createReport() { showCreateDialog.value = false }
</script>

<style lang="scss" scoped>
// Report Types
.report-types-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;

  @media (max-width: 1024px) {
    grid-template-columns: repeat(2, 1fr);
  }
}

.report-type-card {
  background: white;
  border: 2px solid #e9ecef;
  border-radius: 10px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.15s;
  text-align: center;

  &:hover { border-color: #2d5aa0; }
  &.selected { border-color: #1a3a6b; background: rgba(26, 58, 107, 0.03); }

  .rt-icon { font-size: 28px; margin-bottom: 8px; }
  .rt-name { font-size: 13px; font-weight: 600; color: #343a40; margin-bottom: 4px; }
  .rt-desc { font-size: 11px; color: #868e96; margin-bottom: 8px; line-height: 1.4; }
  .rt-count { font-size: 12px; color: #1a3a6b; font-weight: 600; }
}

// Report Params
.report-params {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
  align-items: flex-end;
}

.param-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.filter-label {
  font-size: 12px;
  font-weight: 500;
  color: #495057;
}

// Report List
.report-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.report-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  background: #f8f9fa;
  transition: all 0.15s;

  &:hover { border-color: #1a3a6b; background: #f0f4ff; }
}

.report-file-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  flex-shrink: 0;

  &.format-pdf { background: rgba(231, 76, 60, 0.1); }
  &.format-excel { background: rgba(39, 174, 96, 0.1); }
  &.format-word { background: rgba(52, 152, 219, 0.1); }
  &.format-ppt { background: rgba(230, 126, 34, 0.1); }
}

.report-info { flex: 1; }

.report-title {
  font-size: 13px;
  font-weight: 500;
  color: #343a40;
  margin-bottom: 4px;
}

.report-meta {
  display: flex;
  gap: 6px;
  font-size: 11px;
  color: #868e96;
}

.report-actions {
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

  &.view:hover { background: #e8f5e9; border-color: #27ae60; }
  &.download:hover { background: #e8f0fe; border-color: #1a3a6b; }
}

// COSO Summary Table
.coso-summary-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
  margin-bottom: 20px;

  th {
    background: #f8f9fa;
    padding: 8px 12px;
    text-align: left;
    font-weight: 600;
    color: #495057;
    border-bottom: 2px solid #e9ecef;
    font-size: 12px;

    &.text-center { text-align: center; }
  }

  td {
    padding: 10px 12px;
    border-bottom: 1px solid #f1f3f5;

    &.text-center { text-align: center; }
  }

  tbody tr:hover td { background: #f8f9fa; }

  tfoot .total-row td {
    background: #f0f4ff;
    border-top: 2px solid #dee2e6;
    font-size: 13px;
  }
}

.coso-name {
  display: flex;
  align-items: center;
  gap: 8px;
}

.coso-abbr {
  display: inline-flex;
  width: 28px;
  height: 20px;
  border-radius: 4px;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  font-weight: 700;

  &.abbr-env { background: rgba(74, 111, 165, 0.15); color: #2d5aa0; }
  &.abbr-risk { background: rgba(192, 57, 43, 0.15); color: #c0392b; }
  &.abbr-ctrl { background: rgba(39, 174, 96, 0.15); color: #1e8449; }
  &.abbr-info { background: rgba(142, 68, 173, 0.15); color: #7d3c98; }
  &.abbr-mon { background: rgba(230, 126, 34, 0.15); color: #ca6f1e; }
}

.score-num {
  font-weight: 700;
  font-size: 14px;

  &.score-good { color: #27ae60; }
  &.score-warn { color: #f39c12; }
  &.score-bad { color: #e74c3c; }
}

// Overall Score
.overall-score {
  background: linear-gradient(135deg, rgba(26, 58, 107, 0.04), rgba(26, 58, 107, 0.08));
  border-radius: 10px;
  padding: 20px;
  text-align: center;

  .score-label { font-size: 13px; color: #868e96; margin-bottom: 8px; }
  .score-display {
    display: flex;
    align-items: baseline;
    justify-content: center;
    gap: 4px;
  }
  .score-big { font-size: 52px; font-weight: 800; color: #f39c12; line-height: 1; }
  .score-suffix { font-size: 20px; color: #adb5bd; }
  .score-level { font-size: 13px; font-weight: 600; color: #f39c12; }
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
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-label {
  font-size: 13px;
  font-weight: 500;
  color: #495057;

  &.required::after { content: ' *'; color: #e74c3c; }
}
</style>
