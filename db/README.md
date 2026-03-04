# ITGC 포털 - 데이터베이스 설정 가이드

## 사전 요구사항
- PostgreSQL 14 이상

## 데이터베이스 생성
```sql
-- psql 접속 후 실행
CREATE USER itgc_user WITH PASSWORD 'itgc_password';
CREATE DATABASE itgcdb OWNER itgc_user ENCODING 'UTF8' LC_COLLATE 'ko_KR.UTF-8' LC_CTYPE 'ko_KR.UTF-8';
GRANT ALL PRIVILEGES ON DATABASE itgcdb TO itgc_user;
```

## SQL 파일 실행 순서
```bash
psql -U itgc_user -d itgcdb -f db/ddl/01_create_tables.sql
psql -U itgc_user -d itgcdb -f db/ddl/02_create_indexes.sql
psql -U itgc_user -d itgcdb -f db/dml/03_insert_sample_data.sql   # 개발/테스트 시에만
```

## 테이블 목록
| 테이블명 | 설명 | COSO 연관 |
|----------|------|-----------|
| itgc_organization | 조직 (그룹사/부서) | 통제환경 (CE) |
| itgc_user | 사용자 계정 | 통제환경 (CE) |
| itgc_risk | 위험 | 위험평가 (RA) |
| itgc_control | 통제 | 통제활동 (CA) |
| itgc_risk_control_mapping | 위험-통제 매핑 | 통제활동 (CA) |
| itgc_eval_plan | 운영평가 계획 | 모니터링 (MA) |
| itgc_eval_sample | 평가 샘플 | 모니터링 (MA) |
| itgc_eval_result | 평가 결과 | 모니터링 (MA) |
| itgc_finding | 발견사항 | 모니터링 (MA) |
| itgc_remediation_history | 개선 조치 이력 | 모니터링 (MA) |
| itgc_report | 보고서 | 정보및의사소통 (IC) |
| itgc_coso_config | COSO 설정 | 전체 |
