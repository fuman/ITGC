# ITGC 포털 - 그룹사 IT 일반통제 관리 시스템

## 개요
COSO 2013 프레임워크 기반의 그룹사 IT General Controls (ITGC) 포털입니다.
위험 식별부터 통제 설계, 운영평가, 발견사항 관리까지 전 과정을 통합 관리합니다.

## 기술 스택
| 구분 | 기술 |
|------|------|
| Frontend | Vue 3, DevExtreme Vue, Pinia, Vue Router |
| Backend | Spring Boot 3.2, Spring Security, Spring Data JPA |
| Database | PostgreSQL (운영) / H2 (개발) |
| Build | Vite (FE), Maven (BE) |

## 주요 기능

### COSO 2013 Framework 기반
| 구성요소 | 기능 |
|----------|------|
| 통제 환경 (CE) | 조직 구조, 사용자 권한 관리 |
| 위험 평가 (RA) | 위험 식별, 5×5 매트릭스 평가, 위험 대응 |
| 통제 활동 (CA) | 통제 설계, 통제 목록, 위험-통제 매핑 |
| 정보 및 의사소통 (IC) | 보고서, 알림, 발견사항 공유 |
| 모니터링 (MA) | 운영평가, 발견사항, 개선 조치 추적 |

### 모듈별 기능
- **대시보드**: COSO 5대 구성요소 현황, KPI, 위험 분포 차트
- **위험 관리**: 위험 식별/평가(5×5 매트릭스)/대응 계획
- **통제 활동**: 통제 설계 평가, 위험-통제 매핑
- **운영 평가**: 평가 계획/실행/결과(샘플링, 증빙 수집)
- **발견사항**: 미비점 등록, 개선 조치 Kanban 추적
- **보고서**: COSO 종합 보고서, 분기별 운영평가 보고서
- **시스템 설정**: 조직 관리, 사용자 관리, COSO 평가 기준 설정

## 시작하기

### Frontend 실행
```bash
cd frontend
npm install
npm run dev
```

### Backend 실행
```bash
cd backend
./mvnw spring-boot:run
```

### 접속
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080/api/v1
- H2 Console: http://localhost:8080/h2-console

## API 엔드포인트
| 모듈 | 엔드포인트 |
|------|-----------|
| 대시보드 | GET /api/v1/dashboard |
| 위험 관리 | /api/v1/risks |
| 통제 활동 | /api/v1/controls |
| 운영 평가 | /api/v1/evaluation |
| 발견사항 | /api/v1/findings |
| 보고서 | /api/v1/reports |