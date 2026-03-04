<template>
  <div>
    <div class="page-header">
      <div class="d-flex align-center justify-between">
        <div>
          <h1 class="page-title">조직 관리</h1>
          <p class="page-subtitle">그룹사 및 부서 조직 구조를 관리합니다</p>
        </div>
        <DxButton text="조직 추가" icon="plus" type="default" @click="showDialog = true" />
      </div>
    </div>

    <div class="grid-2">
      <!-- Org Tree -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">조직 계층 구조</div>
        </div>
        <DxTreeView
          :items="orgTree"
          display-expr="name"
          key-expr="id"
          parent-id-expr="parentId"
          :show-check-boxes-mode="'none'"
          :select-by-click="true"
          @item-click="selectOrg"
        >
          <template #item="{ data }">
            <div class="tree-node">
              <span class="node-icon">{{ data.type === 'company' ? '🏢' : '👥' }}</span>
              <span class="node-name">{{ data.name }}</span>
              <span class="node-badge" :class="`type-${data.type}`">{{ data.type === 'company' ? '그룹사' : '부서' }}</span>
            </div>
          </template>
        </DxTreeView>
      </div>

      <!-- Org Detail -->
      <div class="card" v-if="selectedOrg">
        <div class="card-header">
          <div class="card-title">{{ selectedOrg.name }} 상세</div>
          <DxButton text="수정" icon="edit" type="normal" size="small" />
        </div>
        <div class="org-detail">
          <div class="detail-row">
            <label>조직 유형</label>
            <span class="badge" :class="selectedOrg.type === 'company' ? 'badge-primary' : 'badge-info'">
              {{ selectedOrg.type === 'company' ? '그룹사' : '부서' }}
            </span>
          </div>
          <div class="detail-row">
            <label>코드</label>
            <span>{{ selectedOrg.code }}</span>
          </div>
          <div class="detail-row">
            <label>책임자</label>
            <span>{{ selectedOrg.head }}</span>
          </div>
          <div class="detail-row">
            <label>ITGC 담당자</label>
            <span>{{ selectedOrg.itgcOwner }}</span>
          </div>
          <div class="detail-row">
            <label>소속 통제 수</label>
            <span class="fw-bold text-primary">{{ selectedOrg.controlCount }}건</span>
          </div>
          <div class="detail-row">
            <label>발견사항 수</label>
            <span class="fw-bold text-danger">{{ selectedOrg.findingCount }}건</span>
          </div>
        </div>
      </div>

      <div class="card" v-else>
        <div class="empty-state" style="padding: 40px">
          <div class="empty-icon">🏢</div>
          <div class="empty-text">조직을 선택하세요</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import DxButton from 'devextreme-vue/button'
import DxTreeView from 'devextreme-vue/tree-view'

const showDialog = ref(false)
const selectedOrg = ref(null)

const orgTree = ref([
  { id: 1, parentId: null, name: '(주)그룹홀딩스', type: 'company', code: 'GRP-001', head: '김회장', itgcOwner: '이감사', controlCount: 111, findingCount: 47 },
  { id: 2, parentId: 1, name: '(주)그룹사A', type: 'company', code: 'GRP-A', head: '최대표', itgcOwner: '박감사', controlCount: 42, findingCount: 18 },
  { id: 3, parentId: 1, name: '(주)그룹사B', type: 'company', code: 'GRP-B', head: '정대표', itgcOwner: '김감사', controlCount: 38, findingCount: 15 },
  { id: 4, parentId: 1, name: '(주)그룹사C', type: 'company', code: 'GRP-C', head: '이대표', itgcOwner: '최감사', controlCount: 31, findingCount: 14 },
  { id: 5, parentId: 2, name: 'IT운영팀', type: 'dept', code: 'DEPT-IT-OPS', head: '박팀장', itgcOwner: '박운영', controlCount: 12, findingCount: 4 },
  { id: 6, parentId: 2, name: '정보보안팀', type: 'dept', code: 'DEPT-IT-SEC', head: '이팀장', itgcOwner: '이보안', controlCount: 8, findingCount: 6 },
  { id: 7, parentId: 2, name: '개발팀', type: 'dept', code: 'DEPT-DEV', head: '김팀장', itgcOwner: '김개발', controlCount: 10, findingCount: 3 }
])

function selectOrg(e) {
  selectedOrg.value = e.itemData
}
</script>

<style lang="scss" scoped>
.tree-node {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 0;

  .node-icon { font-size: 15px; }
  .node-name { flex: 1; font-size: 13px; }
  .node-badge {
    font-size: 10px;
    font-weight: 600;
    padding: 2px 6px;
    border-radius: 10px;

    &.type-company { background: rgba(26, 58, 107, 0.1); color: #1a3a6b; }
    &.type-dept { background: rgba(52, 152, 219, 0.1); color: #2980b9; }
  }
}

.org-detail {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.detail-row {
  display: flex;
  align-items: center;
  gap: 12px;

  label {
    font-size: 12px;
    font-weight: 600;
    color: #868e96;
    min-width: 120px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
  }

  span { font-size: 14px; color: #343a40; }
}

.empty-state {
  text-align: center;
  .empty-icon { font-size: 36px; margin-bottom: 12px; }
  .empty-text { font-size: 14px; color: #868e96; }
}
</style>
