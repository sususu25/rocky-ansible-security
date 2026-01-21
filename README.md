# Rocky Ansible Security

Rocky Linux / RHEL 계열(테스트 기준: Rocky 8.10)을 대상으로  
주요정보통신기반시설 취약점 가이드(U-01 ~ U-67)를 기반으로

- Shell 스크립트 기반 **자동 조치(Enforce)**
- 동일 항목에 대한 **점검 전용(Audit)**

을 Ansible로 한 번에 실행할 수 있게 만든 프로젝트입니다.

---

## 1. 주요 기능 개요

1. 자동 조치(Enforce)
   - `/opt/security/fixes/` 아래에 `U-01.sh ~ U-67.sh` 조치 스크립트 배치
   - `run_all.sh`로 순차 실행 + 롤백 스크립트(`restore.sh`) 포함
   - 실행 로그: `/opt/security/logs/vuln_fix_YYYYMMDD_HHMMSS_PID.log`
   - Ansible 실행 시 컨트롤 노드로 로그 자동 수집

2. 점검 전용(Audit)
   - `run_audit.sh`에서 주요 항목을 기준에 맞게 **상태만 진단**
   - 결과를 사람이 보기 좋게 이모지(✅, ⚠ 등)와 함께 정리
   - 실행 로그: `/opt/security/logs/vuln_audit_YYYYMMDD_HHMMSS_PID.log`
   - Ansible 실행 시 컨트롤 노드로 로그 자동 수집

3. Ansible Role 구조
   - `roles/security_script/files/`
     - `run_all.sh`, `run_audit.sh`, `U-01.sh ~ U-67.sh`, `restore.sh`
   - `roles/security_script/tasks/main.yml`
     - 조치용(Enforce) 시나리오
   - `roles/security_script/tasks/audit.yml`
     - 점검용(Audit) 시나리오
   - 컨트롤 노드에서는 **Ansible 명령 한 번으로 전체 실행 + 로그 수집**이 가능

---

## 2. 구현된 내용

- U-01 ~ U-67에 대해 다음 공통 구조로 조치 스크립트 작성
  - root 권한 / 환경 체크
  - 현재 상태 점검
  - 기준 미충족 시 조치(파일 권한 수정, 서비스 비활성화 등)
  - 조치 내용 및 가이드 로그로 남김
- 일부 항목(U-31 등)은 **조치 후 롤백용 스크립트** 제공
- `run_all.sh`는
  - `fixes/*.sh`를 정렬 순서로 실행
  - 각 스크립트 성공/실패, exit code를 로그에 기록
  - 마지막에 `restore.sh` 수행

- Ansible 측 기능
  - 대상 서버에 `/opt/security` 디렉터리 생성
  - 스크립트/로그 디렉터리 배포
  - 조치/점검 스크립트 실행
  - `/opt/security/logs` 아래의 로그를
    `./collected_logs/<inventory_hostname>/` 로 자동 수집

---

## 3. 보완이 필요한 부분 / 미구현 항목

- Audit 스크립트(`run_audit.sh`)
  - 현재는 U-01, U-02, U-03, U-16, U-18, U-62, U-67 등 **일부 핵심 항목만 상세 점검 로직 구현**
  - 나머지 항목은 다음 형태의 메시지만 출력:
    - `⚠ [WARN] U-XX: audit 스크립트에 상세 점검 로직이 아직 구현되지 않았습니다.`
    - `'점검 방법'을 참고하여 수동 점검 또는 향후 스크립트 보완 필요`
  - 향후 계획
    - 가이드 문서의 각 항목별 “점검 방법”을 bash 명령으로 그대로 옮겨와
      U-01 ~ U-67 전체에 대해 Audit 로직 추가 예정

- 환경 의존/조건부 항목
  - 메일, DNS, SNMP, NFS 등 **서비스가 설치되지 않은 환경**에서는
    - 미설치/미사용 여부만 확인하고 “조치 불필요”로 로그 출력
  - 실제 운영 환경에서는
    - 서비스 사용 여부에 따라 기준값/조치 로직 추가 튜닝 필요

---

## 4. 사용 방법

### 4-1. 사전 준비

- 컨트롤 노드
  - Ansible 설치 (2.10 이상 권장)
  - 프로젝트 클론 후 이 디렉터리에서 명령 실행
- 대상 서버
  - Rocky Linux / RHEL 계열 (테스트 기준 Rocky 8.10)
  - ssh 키 기반 접속 가능해야 함

### 4-2. 인벤토리 설정

- `inventory/hosts.ini` 예시

  - `[rocky_servers]` 그룹에 대상 서버 IP/도메인 입력
  - `ansible_ssh_private_key_file`에 키 경로 지정
  - `ansible_user`는 대상 서버 계정으로 변경

### 4-3. 조치(Enforce) 실행

- 전체 취약점 조치 + 로그 수집

  - `playbooks/security_check.yml` 실행
  - 원격: `/opt/security/logs/vuln_fix_*.log` 생성
  - 로컬: `./collected_logs/<호스트명>/vuln_fix_*.log` 자동 수집

- 실행 후
  - 운영 환경에 맞지 않는 조치가 없는지
    - `vuln_fix_*.log` 내용을 꼭 검토

### 4-4. 점검(Audit) 실행

- 현재 설정 상태만 진단하고 싶은 경우

  - `playbooks/security_audit.yml` 실행
  - 원격: `/opt/security/logs/vuln_audit_*.log` 생성
  - 로컬: `./collected_logs/<호스트명>/vuln_audit_*.log` 자동 수집

- Ansible 출력이 너무 길어지는 것을 방지하기 위해
  - audit 결과 전체를 터미널에 다 찍지 않고
  - 요약 정보만 보고, 상세 내용은 **수집된 로그 파일을 열어 확인**하는 방식으로 사용

---

## 5. 디렉터리 구조 (요약)

- `inventory/hosts.ini` : 대상 서버 목록 및 접속 정보
- `playbooks/security_check.yml` : 조치(Enforce)용 플레이북
- `playbooks/security_audit.yml` : 점검(Audit)용 플레이북
- `roles/security_script/files/`
  - `run_all.sh` : U-01 ~ U-67 조치 스크립트 전체 실행
  - `run_audit.sh` : 점검 전용 실행
  - `U-01.sh ~ U-67.sh`, `restore.sh` 등
- `roles/security_script/tasks/main.yml`
  - 조치 실행 + fix 로그 수집
- `roles/security_script/tasks/audit.yml`
  - 점검 실행 + audit 로그 수집
- `collected_logs/`
  - Ansible 실행 후
    - `collected_logs/<inventory_hostname>/vuln_fix_*.log`
    - `collected_logs/<inventory_hostname>/vuln_audit_*.log`

---

## 6. 주의사항

- 이 프로젝트는
  - **테스트/랩 환경에서 검증을 거친 샘플 스크립트**입니다.
  - 실제 운영 환경에 바로 적용하기 전에
    - 반드시 별도 테스트 서버에서 충분히 검증해야 합니다.

- 스크립트 특성상
  - 파일 권한/서비스 설정 등을 **직접 수정**합니다.
  - 기존 정책/운영 규정과 충돌할 수 있으니
    - 사내 보안 정책, 컴플라이언스, 각 서비스 담당자와 협의 후 사용하세요.

- RHEL 계열 외의 배포판(예: Debian/Ubuntu)에서는
  - 패키지명, 경로, 서비스명이 달라
  - 그대로 사용하면 동작하지 않거나 예상치 못한 결과가 나올 수 있습니다.

- 스크립트/플레이북 사용으로 인한 문제는
  - 사용자 본인의 책임이며
  - 저장소에는 **샘플/레퍼런스 용도**라는 점을 README에 명시하는 것을 권장합니다.
