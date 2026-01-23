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

**컨트롤 노드 (Ansible 실행 서버)**
- Ansible 설치: `pip install ansible>=2.10`
- Python 3.6 이상
- SSH 클라이언트

**대상 서버 (Rocky Linux)**
- Rocky Linux 8.x / RHEL 8.x 이상
- SSH 서버 실행 중
- SSH 키 기반 인증 설정 완료
- rocky 사용자 계정 존재
- 인터넷 연결 (패키지 설치 필요 시)

### 4-2. 초기 설정

1. **프로젝트 클론**
   ```bash
   git clone <repository-url>
   cd rocky-ansible-security
   ```

2. **SSH 키 준비**
   - 대상 서버의 프라이빗 키를 `~/.ssh/rocky-key.pem`에 저장
   - 권한 설정: `chmod 600 ~/.ssh/rocky-key.pem`

3. **인벤토리 파일 생성**
   ```bash
   cp inventory/hosts.ini.example inventory/hosts.ini
   vim inventory/hosts.ini  # 실제 IP와 SSH 정보 입력
   ```

4. **대상 서버에서 sudo 설정** (필수)
   ```bash
   ssh -i ~/.ssh/rocky-key.pem rocky@<TARGET_IP>
   sudo su -
   echo "rocky ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/rocky
   chmod 440 /etc/sudoers.d/rocky
   exit
   ```

### 4-3. 로그 디렉토리 초기화 (재실행 시)

대상 서버에서 기존 로그를 초기화하고 싶을 때:
```bash
ansible rocky01 -i inventory/hosts.ini -m shell -a "rm -rf /opt/security/logs/*"
```

### 4-4. 조치(Enforce) 실행

전체 취약점 조치 + 로그 수집 (실제 시스템 설정 변경):
```bash
ansible-playbook -i inventory/hosts.ini playbooks/security_check.yml
```

**실행 결과:**
- 원격 서버: `/opt/security/logs/vuln_fix_YYYYMMDD_HHMMSS_PID.log` 생성
- 로컬: `./collected_logs/<호스트명>/vuln_fix_*.log` 자동 수집

**조치 후 확인:**
```bash
# 생성된 로그 확인
cat collected_logs/rocky01/vuln_fix_*.log

# 조치 내용이 예상과 맞는지 검토 필수!
# 불필요한 조치가 있으면 restore.sh로 롤백 가능
```

### 4-5. 점검(Audit) 실행

현재 설정 상태만 진단 (시스템 변경 없음):
```bash
ansible-playbook -i inventory/hosts.ini playbooks/security_audit.yml
```

**실행 결과:**
- 원격 서버: `/opt/security/logs/vuln_audit_YYYYMMDD_HHMMSS_PID.log` 생성
- 로컬: `./collected_logs/<호스트명>/vuln_audit_*.log` 자동 수집

**결과 확인:**
```bash
# 진단 결과 확인
cat collected_logs/rocky01/vuln_audit_*.log

# 항목별 상태 확인:
# ✅ PASS   - 기준 충족
# ❌ FAIL   - 기준 미충족 (조치 필요)
# ⚠  WARN   - 구현 대기 중
```

### 4-6. 개발/디버깅용 명령

단일 호스트에 대한 명령 실행:
```bash
# 단일 스크립트 테스트
ansible rocky01 -i inventory/hosts.ini -m copy -a "src=playbooks/roles/security_script/files/U-01.sh dest=/tmp/ owner=root mode=0755"

# 원격 명령 직접 실행
ansible rocky01 -i inventory/hosts.ini -m shell -a "cd /opt/security && bash U-01.sh"
```

---

## 5. 디렉터리 구조 (요약)

- `inventory/hosts.ini` : 대상 서버 목록 및 접속 정보
- `inventory/hosts.ini.example` : hosts.ini 예시 파일 (GitHub에 올림)
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

## 6. 문제 해결

### SSH/연결 오류

**오류: `Failed to connect to the host via ssh`**
```bash
# 1. SSH 키 확인
ls -la ~/.ssh/rocky-key.pem
chmod 600 ~/.ssh/rocky-key.pem

# 2. 인벤토리의 IP 주소 확인
cat inventory/hosts.ini

# 3. 수동 SSH 접속 테스트
ssh -i ~/.ssh/rocky-key.pem rocky@<IP_ADDRESS>

# 4. SSH 디버그 모드
ssh -vvv -i ~/.ssh/rocky-key.pem rocky@<IP_ADDRESS>
```

### Sudo 권한 오류

**오류: `/usr/bin/sudo: Permission denied`**
```bash
# 1. 대상 서버에서 rocky 사용자의 sudo 권한 확인
ssh -i ~/.ssh/rocky-key.pem rocky@<IP_ADDRESS>
sudo -l

# 2. 권한 추가 (root로 실행)
sudo su -
echo "rocky ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/rocky
chmod 440 /etc/sudoers.d/rocky
```

### Ansible 연결 테스트

```bash
# 전체 호스트 ping
ansible all -i inventory/hosts.ini -m ping

# 디버그 모드
ansible rocky01 -i inventory/hosts.ini -m ping -vvv

# 특정 호스트 연결 정보 확인
ansible rocky01 -i inventory/hosts.ini -m debug -a "msg={{ ansible_host }}"
```

## 7. 보안 주의사항

### 파일 보안

- **`hosts.ini` 파일 관리**
  - 실제 IP 주소와 SSH 키 경로 포함
  - GitHub에 절대 올리지 마세요
  - `.gitignore`에 추가 권장:
    ```
    inventory/hosts.ini
    collected_logs/
    ```

- **SSH 프라이빗 키 관리**
  - 파일 권한을 `600` 으로 유지
  - 절대 GitHub에 올리지 마세요
  - 정기적으로 백업하세요

- **NOPASSWD sudo 설정**
  - 프라이빗 네트워크 환경에서만 사용 권장
  - 공개 환경에서는 비밀번호 기반 sudo 고려

### 운영 환경 적용 전 필수 확인

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
