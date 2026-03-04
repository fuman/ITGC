# ITGC 포털 - 그룹사 IT 일반통제 관리 시스템

## 개요
COSO 2013 프레임워크 기반의 그룹사 IT General Controls (ITGC) 포털입니다.
위험 식별부터 통제 설계, 운영평가, 발견사항 관리까지 전 과정을 통합 관리합니다.

---

## 기술 스택

| 구분 | 기술 |
|------|------|
| Frontend | Vue 3, DevExtreme Vue 24.1, Pinia, Vue Router 4, Vite |
| Backend | Spring Boot 3.2, Spring Security, MyBatis 3.0.3 |
| Database | PostgreSQL 14+ |
| Connection Pool | HikariCP |
| Build | Vite (FE), Maven (BE) |

---

## 사전 요구사항

| 항목 | 버전 | 확인 명령 |
|------|------|-----------|
| Java JDK | 17 이상 | `java -version` |
| Node.js | 18 이상 | `node -v` |
| npm | 9 이상 | `npm -v` |
| PostgreSQL | 14 이상 | `psql --version` |
| Maven | 3.8 이상 (또는 mvnw 사용) | `mvn -version` |
| Git | 2.x | `git --version` |

---

## 설치 및 실행 가이드

### 1단계 - 소스 코드 내려받기

```bash
git clone <REPOSITORY_URL>
cd ITGC
```

---

### 2단계 - PostgreSQL 데이터베이스 설정

#### 2-1. DB 사용자 및 데이터베이스 생성

PostgreSQL에 슈퍼유저로 접속합니다.

```bash
# Linux / macOS
psql -U postgres

# Windows (psql 설치 경로 예시)
# C:\Program Files\PostgreSQL\14\bin\psql.exe -U postgres
```

아래 SQL을 실행합니다.

```sql
-- 사용자 생성
CREATE USER itgc_user WITH PASSWORD 'itgc_password';

-- 데이터베이스 생성 (한글 지원 로케일)
CREATE DATABASE itgcdb
  OWNER itgc_user
  ENCODING 'UTF8'
  LC_COLLATE 'ko_KR.UTF-8'
  LC_CTYPE 'ko_KR.UTF-8'
  TEMPLATE template0;

-- 권한 부여
GRANT ALL PRIVILEGES ON DATABASE itgcdb TO itgc_user;

-- psql 종료
\q
```

> **Windows 로케일 참고**: Windows에서 한글 로케일이 없을 경우
> `LC_COLLATE 'Korean_Korea.949'` 또는 `LC_COLLATE 'C'`로 대체하세요.

#### 2-2. 테이블 및 샘플 데이터 생성

프로젝트 루트에서 아래 명령을 순서대로 실행합니다.

```bash
# 테이블 생성
psql -U itgc_user -d itgcdb -f db/ddl/01_create_tables.sql

# 인덱스 생성
psql -U itgc_user -d itgcdb -f db/ddl/02_create_indexes.sql

# 샘플 데이터 입력 (개발/테스트 환경에서만 실행)
psql -U itgc_user -d itgcdb -f db/dml/03_insert_sample_data.sql
```

> **Windows 경로 예시**
> ```cmd
> "C:\Program Files\PostgreSQL\14\bin\psql.exe" -U itgc_user -d itgcdb -f db\ddl\01_create_tables.sql
> ```

#### 2-3. DB 접속 정보 변경 (필요 시)

기본 접속 정보와 다른 경우 `backend/src/main/resources/application.yml`을 수정합니다.

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/itgcdb   # 호스트/포트/DB명
    username: itgc_user                            # DB 사용자
    password: itgc_password                        # DB 비밀번호
```

---

### 3단계 - 백엔드(Spring Boot) 실행

```bash
cd backend
```

#### Linux / macOS

```bash
./mvnw spring-boot:run
```

#### Windows

```cmd
mvnw.cmd spring-boot:run
```

#### Maven이 전역 설치된 경우

```bash
mvn spring-boot:run
```

> 서버가 정상 기동되면 콘솔에 `Started ItgcPortalApplication` 메시지가 출력됩니다.
> 기본 포트: **8080**

---

### 4단계 - 프론트엔드(Vue 3) 실행

새 터미널을 열고 실행합니다.

```bash
cd frontend

# 패키지 설치 (최초 1회)
npm install

# 개발 서버 실행
npm run dev
```

> 기본 포트: **3000**
> 백엔드 API는 Vite 프록시를 통해 자동으로 `http://localhost:8080`으로 전달됩니다.

---

### 5단계 - 브라우저 접속

| 항목 | URL |
|------|-----|
| ITGC 포털 | http://localhost:3000 |
| 백엔드 API | http://localhost:8080/api/v1 |

---

## 프로젝트 구조

```
ITGC/
├── frontend/                    # Vue 3 프론트엔드
│   ├── src/
│   │   ├── api/                 # Axios API 클라이언트
│   │   ├── assets/css/          # SCSS 변수 및 전역 스타일
│   │   ├── components/layout/   # 사이드바, 헤더
│   │   ├── router/              # Vue Router 라우트 정의
│   │   ├── store/               # Pinia 상태 관리
│   │   └── views/               # 화면 컴포넌트 (14개)
│   ├── package.json
│   └── vite.config.js
│
├── backend/                     # Spring Boot 백엔드
│   └── src/main/java/com/itgc/portal/
│       ├── config/              # SecurityConfig
│       ├── controller/          # REST API 컨트롤러 (7개)
│       ├── mapper/              # MyBatis Mapper 인터페이스 (7개)
│       ├── model/               # POJO 모델 클래스 (10개)
│       ├── service/             # 비즈니스 로직 (6개)
│       └── common/              # 공통 ApiResponse
│   └── src/main/resources/
│       ├── mapper/              # MyBatis XML 매퍼 (7개)
│       └── application.yml      # 설정 파일
│
└── db/                          # 데이터베이스 스크립트
    ├── ddl/
    │   ├── 01_create_tables.sql # 12개 테이블 생성
    │   └── 02_create_indexes.sql
    └── dml/
        └── 03_insert_sample_data.sql
```

---

## API 엔드포인트

| 모듈 | 메서드 | 엔드포인트 |
|------|--------|-----------|
| 대시보드 KPI | GET | `/api/v1/dashboard/kpi` |
| 대시보드 COSO 점수 | GET | `/api/v1/dashboard/coso-scores` |
| 위험 목록/등록 | GET/POST | `/api/v1/risks` |
| 위험 수정/삭제 | PUT/DELETE | `/api/v1/risks/{id}` |
| 위험 매트릭스 | GET | `/api/v1/risks/matrix` |
| 통제 목록/등록 | GET/POST | `/api/v1/controls` |
| 통제 설계 평가 | POST | `/api/v1/controls/design-evaluation` |
| 위험-통제 매핑 | GET/POST | `/api/v1/controls/mapping` |
| 운영평가 계획 | GET/POST | `/api/v1/evaluations/plans` |
| 평가 샘플 | GET/POST | `/api/v1/evaluations/plans/{id}/samples` |
| 평가 결과 | GET/POST | `/api/v1/evaluations/result` |
| 발견사항 | GET/POST | `/api/v1/findings` |
| 개선조치 업데이트 | PUT | `/api/v1/findings/{id}/remediation` |
| 조직 관리 | GET/POST | `/api/v1/organizations` |
| 사용자 관리 | GET/POST | `/api/v1/users` |
| COSO 설정 | GET/PUT | `/api/v1/coso-config` |

---

## 주요 기능

### COSO 2013 Framework 기반

| 구성요소 | 약어 | 기능 |
|----------|------|------|
| 통제 환경 | CE | 조직 구조, 사용자/권한 관리 |
| 위험 평가 | RA | 위험 식별, 5×5 매트릭스 평가, 위험 대응 전략 |
| 통제 활동 | CA | 통제 설계 평가, 위험-통제 매핑, 효과성 평가 |
| 정보 및 의사소통 | IC | 종합 보고서, 분기별 현황 보고서 |
| 모니터링 | MA | 운영평가 계획/실행/결과, 발견사항, 개선 Kanban |

---

## 운영 환경 배포

운영 환경으로 배포 시 아래와 같이 환경 변수를 설정하고 `prod` 프로파일로 실행합니다.

```bash
export DB_USERNAME=실제DB사용자
export DB_PASSWORD=실제DB비밀번호

# 백엔드
cd backend
./mvnw clean package -DskipTests
java -jar -Dspring.profiles.active=prod target/itgc-portal-1.0.0.jar

# 프론트엔드 빌드
cd frontend
npm run build
# dist/ 폴더를 Nginx 또는 정적 파일 서버에 배포
```

---

## 자주 묻는 문제

### Q. DB 접속 오류가 발생합니다.
- PostgreSQL 서비스가 실행 중인지 확인하세요: `pg_ctl status` 또는 서비스 관리자
- `application.yml`의 host/port/username/password가 맞는지 확인하세요.
- 방화벽에서 5432 포트가 열려 있는지 확인하세요.

### Q. `npm install` 시 DevExtreme 관련 오류가 발생합니다.
- Node.js 18 이상 버전을 사용하세요.
- `npm install --legacy-peer-deps` 옵션을 시도하세요.

### Q. 백엔드 빌드 시 Maven 플러그인 다운로드가 안 됩니다.
- 네트워크 프록시 환경이라면 `~/.m2/settings.xml`에 프록시 설정을 추가하세요.
- `./mvnw -Dmaven.repo.local=.m2 spring-boot:run`으로 로컬 저장소를 지정할 수 있습니다.

### Q. 한글 데이터가 깨집니다.
- DB 생성 시 `ENCODING 'UTF8'`로 생성되었는지 확인하세요.
- psql 클라이언트 인코딩을 맞춰주세요: `SET client_encoding TO 'UTF8';`
