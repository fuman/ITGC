<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">평가 실행</h1>
          <p class="page-subtitle">샘플을 선정하고 통제 운영 증빙을 수집·검토합니다</p>
        </div>
        <div class="d-flex gap-8">
          <DxButton text="증빙 업로드" icon="upload" type="normal" />
          <DxButton text="평가 저장" icon="save" type="default" @click="saveExecution" />
        </div>
      </div>
    </div>

    <!-- Select Evaluation Plan -->
    <div class="card" style="margin-bottom: 20px">
      <div class="d-flex align-center gap-16 flex-wrap">
        <div class="filter-item">
          <label class="filter-label">평가 대상 통제</label>
          <DxSelectBox
            v-model:value="selectedControl"
            :items="controlOptions"
            display-expr="label"
            value-expr="id"
            placeholder="통제 선택"
            width="300"
            @value-changed="loadSamples"
          />
        </div>
        <div v-if="selectedControl" class="selected-control-info">
          <div class="control-info-item">
            <span class="info-label">평가자</span>
            <span class="info-value">김감사</span>
          </div>
          <div class="control-info-item">
            <span class="info-label">계획 기간</span>
            <span class="info-value">2026.03.01 ~ 2026.03.07</span>
          </div>
          <div class="control-info-item">
            <span class="info-label">샘플링 방법</span>
            <span class="info-value">확률적 샘플링</span>
          </div>
        </div>
      </div>
    </div>

    <template v-if="selectedControl">
      <!-- Sampling -->
      <div class="section">
        <div class="section-header">
          <div class="section-title">샘플 목록</div>
          <div class="d-flex gap-8">
            <DxButton text="샘플 자동 선정" icon="refresh" type="normal" @click="autoSelectSamples" />
            <DxButton text="샘플 추가" icon="plus" type="default" @click="addSample" />
          </div>
        </div>
        <div class="card" style="padding: 0">
          <DxDataGrid
            :data-source="samples"
            :show-borders="false"
            :hover-state-enabled="true"
            :column-auto-width="true"
            key-expr="id"
          >
            <DxEditing mode="row" :allow-updating="true" />
            <DxPaging :page-size="10" />
            <DxPager :show-info="true" />

            <DxColumn data-field="sampleNo" caption="샘플 번호" width="100" :allow-editing="false" />
            <DxColumn data-field="transactionDate" caption="거래일자" width="115" data-type="date" />
            <DxColumn data-field="transactionId" caption="거래/이벤트 ID" width="150" />
            <DxColumn data-field="description" caption="내용" min-width="200" />
            <DxColumn data-field="evidenceStatus" caption="증빙 수집" width="110" cell-template="evidenceTemplate">
              <DxLookup :data-source="['수집완료', '수집중', '미수집']" />
            </DxColumn>
            <DxColumn data-field="testResult" caption="테스트 결과" width="110" cell-template="resultTemplate">
              <DxLookup :data-source="['통과', '예외', '해당없음']" />
            </DxColumn>
            <DxColumn data-field="exception" caption="예외 사항" min-width="150" />
            <DxColumn data-field="evidenceFile" caption="증빙 파일" width="120" cell-template="fileTemplate" :allow-editing="false" />

            <template #evidenceTemplate="{ data }">
              <span class="badge" :class="getEvidenceBadge(data.value)">{{ data.value }}</span>
            </template>
            <template #resultTemplate="{ data }">
              <span class="badge" :class="getResultBadge(data.value)">{{ data.value }}</span>
            </template>
            <template #fileTemplate="{ data }">
              <button v-if="data.value" class="file-btn" @click="downloadFile(data.value)">
                📎 {{ data.value }}
              </button>
              <button v-else class="file-upload-btn" @click="uploadFile(data.data)">
                + 파일 첨부
              </button>
            </template>
          </DxDataGrid>
        </div>
      </div>

      <!-- Test Conclusion -->
      <div class="section">
        <div class="section-header">
          <div class="section-title">테스트 결론</div>
        </div>
        <div class="card">
          <div class="conclusion-grid">
            <div class="conclusion-item">
              <label class="filter-label">통제 운영 효과성 결론</label>
              <DxSelectBox
                v-model:value="conclusion.effectiveness"
                :items="['효과적', '부분 효과적', '비효과적']"
                width="200"
              />
            </div>
            <div class="conclusion-item">
              <label class="filter-label">예외 건수</label>
              <DxNumberBox v-model:value="conclusion.exceptionCount" :min="0" width="100" :read-only="true" />
            </div>
            <div class="conclusion-item">
              <label class="filter-label">예외율</label>
              <DxTextBox :value="`${conclusion.exceptionRate}%`" :read-only="true" width="100" />
            </div>
          </div>
          <div style="margin-top: 16px">
            <label class="filter-label" style="display: block; margin-bottom: 6px">평가 의견</label>
            <DxTextArea v-model:value="conclusion.comment" :height="100" :width="'100%'" placeholder="통제 운영 효과성에 대한 평가 의견을 입력하세요" />
          </div>
          <div style="margin-top: 16px">
            <label class="filter-label" style="display: block; margin-bottom: 6px">개선 권고사항</label>
            <DxTextArea v-model:value="conclusion.recommendation" :height="80" :width="'100%'" placeholder="개선이 필요한 사항을 기술하세요" />
          </div>
        </div>
      </div>
    </template>

    <!-- Empty State -->
    <div v-else class="empty-state">
      <div class="empty-icon">📋</div>
      <div class="empty-text">평가 대상 통제를 선택하세요</div>
      <div class="empty-sub">위에서 평가할 통제 항목을 선택하면 샘플 목록과 평가 워크시트가 표시됩니다</div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxDataGrid, { DxColumn, DxEditing, DxLookup, DxPaging, DxPager } from 'devextreme-vue/data-grid'
import DxSelectBox from 'devextreme-vue/select-box'
import DxNumberBox from 'devextreme-vue/number-box'
import DxTextBox from 'devextreme-vue/text-box'
import DxTextArea from 'devextreme-vue/text-area'

const selectedControl = ref(null)

const controlOptions = ref([
  { id: 1, label: 'CTRL-ACC-001 - 사용자 계정 등록/변경/삭제 승인' },
  { id: 2, label: 'CTRL-ACC-002 - 특권 계정 반기 재검토' },
  { id: 3, label: 'CTRL-CHG-001 - 변경 요청 및 승인 관리' },
  { id: 4, label: 'CTRL-OPS-001 - 배치 작업 모니터링' }
])

const samples = ref([
  { id: 1, sampleNo: 'S-001', transactionDate: '2026-01-05', transactionId: 'USR-CHG-20260105-001', description: '김철수 신규 계정 생성 및 권한 부여', evidenceStatus: '수집완료', testResult: '통과', exception: '', evidenceFile: 'evidence_001.pdf' },
  { id: 2, sampleNo: 'S-002', transactionDate: '2026-01-12', transactionId: 'USR-CHG-20260112-003', description: '이영희 권한 변경 (일반→관리자)', evidenceStatus: '수집완료', testResult: '예외', exception: '승인 없이 권한 상향 처리됨', evidenceFile: null },
  { id: 3, sampleNo: 'S-003', transactionDate: '2026-01-20', transactionId: 'USR-DEL-20260120-001', description: '박민준 퇴직자 계정 삭제', evidenceStatus: '수집완료', testResult: '통과', exception: '', evidenceFile: 'evidence_003.pdf' },
  { id: 4, sampleNo: 'S-004', transactionDate: '2026-02-08', transactionId: 'USR-CHG-20260208-002', description: '최수진 권한 추가 부여', evidenceStatus: '수집중', testResult: null, exception: '', evidenceFile: null },
  { id: 5, sampleNo: 'S-005', transactionDate: '2026-02-15', transactionId: 'USR-CHG-20260215-004', description: '정우성 계정 잠금 해제', evidenceStatus: '미수집', testResult: null, exception: '', evidenceFile: null }
])

const conclusion = ref({
  effectiveness: '부분 효과적',
  exceptionCount: 1,
  exceptionRate: 20,
  comment: '전반적으로 계정 등록/삭제 통제는 효과적으로 운영되나, 권한 변경에 대한 사전 승인 절차가 일부 미준수되어 개선이 필요합니다.',
  recommendation: '권한 변경 시 반드시 사전 승인을 득하도록 프로세스를 강화하고, 자동화 승인 시스템 도입을 검토하세요.'
})

function loadSamples() {}
function autoSelectSamples() {}
function addSample() {}
function downloadFile(name) {}
function uploadFile(row) {}
function saveExecution() {}

function getEvidenceBadge(v) {
  const map = { '수집완료': 'badge-effective', '수집중': 'badge-partial', '미수집': 'badge-not-tested' }
  return map[v] || 'badge-not-tested'
}

function getResultBadge(v) {
  const map = { '통과': 'badge-effective', '예외': 'badge-ineffective', '해당없음': 'badge-not-tested' }
  return map[v] || 'badge-not-tested'
}
</script>

<style lang="scss" scoped>
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

.selected-control-info {
  display: flex;
  gap: 24px;
}

.control-info-item {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.info-label {
  font-size: 11px;
  color: #868e96;
}

.info-value {
  font-size: 13px;
  font-weight: 500;
  color: #343a40;
}

.conclusion-grid {
  display: flex;
  gap: 24px;
  flex-wrap: wrap;
}

.conclusion-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.file-btn {
  border: 1px solid #dee2e6;
  background: #f8f9fa;
  border-radius: 4px;
  padding: 3px 8px;
  font-size: 11px;
  cursor: pointer;
  color: #495057;

  &:hover { background: #e9ecef; }
}

.file-upload-btn {
  border: 1px dashed #adb5bd;
  background: transparent;
  border-radius: 4px;
  padding: 3px 8px;
  font-size: 11px;
  cursor: pointer;
  color: #868e96;

  &:hover { border-color: #1a3a6b; color: #1a3a6b; }
}

// Empty State
.empty-state {
  text-align: center;
  padding: 80px 40px;
  background: white;
  border-radius: 10px;
  border: 2px dashed #dee2e6;

  .empty-icon { font-size: 48px; margin-bottom: 16px; }
  .empty-text { font-size: 18px; font-weight: 600; color: #495057; margin-bottom: 8px; }
  .empty-sub { font-size: 14px; color: #868e96; }
}
</style>
