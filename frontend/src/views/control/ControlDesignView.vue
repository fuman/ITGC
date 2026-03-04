<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">통제 설계</h1>
          <p class="page-subtitle">통제의 설계 적합성을 평가합니다</p>
        </div>
        <DxButton text="설계 평가 저장" icon="save" type="default" @click="saveDesign" />
      </div>
    </div>

    <!-- Design Evaluation Grid -->
    <div class="card" style="padding: 0">
      <DxDataGrid
        :data-source="designData"
        :show-borders="false"
        :hover-state-enabled="true"
        :column-auto-width="true"
        :allow-column-resizing="true"
        :word-wrap-enabled="true"
        key-expr="id"
      >
        <DxEditing mode="cell" :allow-updating="true" />
        <DxToolbar>
          <DxItem location="before" template="titleTemplate" />
          <DxItem name="searchPanel" />
        </DxToolbar>
        <DxSearchPanel :visible="true" placeholder="통제 검색..." />
        <DxPaging :page-size="10" />
        <DxPager :show-info="true" />

        <DxColumn data-field="controlCode" caption="통제 코드" width="130" :allow-editing="false" />
        <DxColumn data-field="controlName" caption="통제명" min-width="180" :allow-editing="false" />
        <DxColumn data-field="controlObjective" caption="통제 목적" min-width="150" :allow-editing="false" />
        <DxColumn data-field="designAdequacy" caption="설계 적합성" width="120" :allow-editing="true">
          <DxLookup :data-source="['적합', '부분 적합', '부적합', '미평가']" />
        </DxColumn>
        <DxColumn data-field="keyControl" caption="핵심 통제" width="90" alignment="center" data-type="boolean" />
        <DxColumn data-field="itdmControl" caption="ITDM 통제" width="100" alignment="center" data-type="boolean" />
        <DxColumn data-field="designIssue" caption="설계 이슈" min-width="180" />
        <DxColumn data-field="improvementNeeded" caption="개선 필요사항" min-width="180" />
        <DxColumn data-field="designEvaluator" caption="평가자" width="90" :allow-editing="false" />

        <template #titleTemplate>
          <div style="font-weight: 600; font-size: 15px; color: #1a3a6b; padding: 4px 0">
            통제 설계 평가 워크시트
          </div>
        </template>
      </DxDataGrid>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxDataGrid, { DxColumn, DxEditing, DxLookup, DxPaging, DxPager, DxSearchPanel, DxToolbar, DxItem } from 'devextreme-vue/data-grid'

const designData = ref([
  { id: 1, controlCode: 'CTRL-ACC-001', controlName: '사용자 계정 등록/변경/삭제 승인', controlObjective: '권한 없는 접근 방지', designAdequacy: '적합', keyControl: true, itdmControl: false, designIssue: '', improvementNeeded: '', designEvaluator: '김감사' },
  { id: 2, controlCode: 'CTRL-ACC-002', controlName: '특권 계정 반기 재검토', controlObjective: '과도한 권한 방지', designAdequacy: '부분 적합', keyControl: true, itdmControl: true, designIssue: '검토 주기 불충분', improvementNeeded: '분기 1회로 주기 단축 필요', designEvaluator: '김감사' },
  { id: 3, controlCode: 'CTRL-CHG-001', controlName: '변경 요청 및 승인 관리', controlObjective: '미승인 변경 방지', designAdequacy: '적합', keyControl: true, itdmControl: false, designIssue: '', improvementNeeded: '', designEvaluator: '박검토' },
  { id: 4, controlCode: 'CTRL-OPS-001', controlName: '배치 작업 모니터링', controlObjective: '배치 오류 조기 탐지', designAdequacy: '부적합', keyControl: false, itdmControl: false, designIssue: '알람 임계값 설정 불명확', improvementNeeded: '임계값 기준 수립 및 에스컬레이션 체계 구축', designEvaluator: '김감사' },
  { id: 5, controlCode: 'CTRL-BCM-001', controlName: 'DR 테스트 실시', controlObjective: '복구 능력 검증', designAdequacy: '미평가', keyControl: true, itdmControl: false, designIssue: '', improvementNeeded: '', designEvaluator: '-' }
])

function saveDesign() {
  console.log('Saving design evaluation...')
}
</script>
