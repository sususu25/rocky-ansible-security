#!/bin/bash

# === 공통 설정 ===
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$BASE_DIR/logs"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/vuln_audit_$(date +%Y%m%d_%H%M%S)_$$.log"

STATUS=0  # 하나라도 FAIL 나면 1로 올릴 예정

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

section() {
    log "────────────────────────────────────────"
    log "🔎 $1"
    log "────────────────────────────────────────"
}

ok() {
    log "✅ [OK] $1"
}

warn() {
    log "⚠ [WARN] $1"
}

fail() {
    STATUS=1
    log "❌ [FAIL] $1"
}

start_check() {
    log "▶ $1"
}

# === U-01: root 원격 접속 제한 (Telnet / SSH) ===
check_U01() {
    section "[U-01] root 원격 접속 제한 점검"

    # Telnet 서비스 상태
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl is-active --quiet telnet.socket 2>/dev/null; then
            warn "Telnet 서비스(telnet.socket)가 활성 상태입니다. 비활성화 권장."
        else
            ok "Telnet 서비스 비활성 또는 미설치"
        fi
    else
        warn "systemctl 명령을 사용할 수 없어 Telnet 서비스 상태를 확인하지 못했습니다."
    fi

    # SSH root 로그인 설정
    if [ -f /etc/ssh/sshd_config ]; then
        prl=$(grep -Ei '^[[:space:]]*PermitRootLogin' /etc/ssh/sshd_config | tail -n1 | awk '{print $2}')
        if [ -z "$prl" ]; then
            warn "sshd_config에 PermitRootLogin 설정이 명시되어 있지 않음 (기본값 확인 필요)"
        elif [[ "$prl" =~ ^no$|^prohibit-password$ ]]; then
            ok "sshd_config: PermitRootLogin $prl (root 원격 로그인 제한 적용)"
        else
            fail "sshd_config: PermitRootLogin=$prl (root 원격 로그인이 허용될 수 있음)"
        fi
    else
        warn "/etc/ssh/sshd_config 파일이 없음 (커스텀 경로 사용 여부 확인 필요)"
    fi
}

# === U-02: 패스워드 정책 (길이/사용 기간 등) ===
check_U02() {
    section "[U-02] 패스워드 정책 점검"

    # /etc/login.defs
    if [ -f /etc/login.defs ]; then
        max_days=$(grep -E '^[[:space:]]*PASS_MAX_DAYS' /etc/login.defs | awk '{print $2}')
        min_days=$(grep -E '^[[:space:]]*PASS_MIN_DAYS' /etc/login.defs | awk '{print $2}')
        if [ -z "$max_days" ] || [ -z "$min_days" ]; then
            warn "/etc/login.defs: PASS_MAX_DAYS 또는 PASS_MIN_DAYS 미설정"
        else
            ok "/etc/login.defs: PASS_MAX_DAYS=$max_days, PASS_MIN_DAYS=$min_days"
        fi
    else
        warn "/etc/login.defs 파일 없음"
    fi

    # pwquality.conf
    if [ -f /etc/security/pwquality.conf ]; then
        minlen=$(grep -E '^[[:space:]]*minlen' /etc/security/pwquality.conf | awk -F= '{print $2}' | xargs)
        if [ -z "$minlen" ]; then
            warn "pwquality.conf: minlen 미설정 (패스워드 길이 정책 불명확)"
        elif [ "$minlen" -lt 8 ]; then
            fail "pwquality.conf: minlen=$minlen (8 이상 권장)"
        else
            ok "pwquality.conf: minlen=$minlen (길이 정책 양호)"
        fi
    else
        warn "/etc/security/pwquality.conf 없음 (별도 정책 사용 여부 확인 필요)"
    fi
}

# === U-03: 계정 잠금 정책 (pam_faillock 등) ===
check_U03() {
    section "[U-03] 계정 잠금 정책 점검"

    if grep -q "pam_faillock.so" /etc/pam.d/system-auth 2>/dev/null; then
        ok "system-auth에 pam_faillock.so 설정 존재"
    else
        warn "system-auth에 pam_faillock.so 설정이 없음 (계정 잠금 미적용 가능성)"
    fi

    if [ -f /etc/security/faillock.conf ]; then
        deny=$(grep -E '^[[:space:]]*deny' /etc/security/faillock.conf | awk -F= '{print $2}' | xargs)
        lock_time=$(grep -E '^[[:space:]]*lock_time' /etc/security/faillock.conf | awk -F= '{print $2}' | xargs)
        msg="faillock.conf:"
        [ -n "$deny" ] && msg="$msg deny=$deny"
        [ -n "$lock_time" ] && msg="$msg lock_time=$lock_time"
        if [ -n "$deny" ] || [ -n "$lock_time" ]; then
            ok "$msg"
        else
            warn "faillock.conf: deny/lock_time 등 상세 설정 미확인"
        fi
    else
        warn "/etc/security/faillock.conf 없음 (기본값 사용 또는 미구성)"
    fi
}

# === U-16: /etc/passwd 소유자/권한 ===
check_U16() {
    section "[U-16] /etc/passwd 소유자 및 권한 점검"

    if [ ! -f /etc/passwd ]; then
        fail "/etc/passwd 파일이 존재하지 않음 (시스템 손상 가능성)"
        return
    fi

    owner=$(stat -c "%U" /etc/passwd)
    perm=$(stat -c "%a" /etc/passwd)
    log "현재 /etc/passwd: owner=$owner, perm=$perm"

    if [ "$owner" != "root" ]; then
        fail "/etc/passwd 소유자 비정상: $owner (root 여야 함)"
    elif [ "$perm" -gt 644 ]; then
        fail "/etc/passwd 권한 과도: $perm (644 이하 권장)"
    else
        ok "/etc/passwd 소유자/권한 기준 충족"
    fi
}

# === U-18: /etc/shadow 소유자/권한 ===
check_U18() {
    section "[U-18] /etc/shadow 소유자 및 권한 점검"

    if [ ! -f /etc/shadow ]; then
        fail "/etc/shadow 파일이 존재하지 않음 (쉐도우 패스워드 미사용)"
        return
    fi

    owner=$(stat -c "%U" /etc/shadow)
    perm=$(stat -c "%a" /etc/shadow)
    log "현재 /etc/shadow: owner=$owner, perm=$perm"

    if [ "$owner" != "root" ]; then
        fail "/etc/shadow 소유자 비정상: $owner (root 여야 함)"
    elif [ "$perm" -gt 400 ]; then
        fail "/etc/shadow 권한 과도: $perm (400 이하 권장)"
    else
        ok "/etc/shadow 소유자/권한 기준 충족"
    fi
}

# === U-62: 경고 배너 설정 ===
check_U62() {
    section "[U-62] 로그온 경고 메시지 설정 점검"

    for f in /etc/motd /etc/issue; do
        if [ -f "$f" ]; then
            if grep -Ei "unauthorized|무단|경고" "$f" >/dev/null 2>&1; then
                ok "$f: 경고 문구 포함"
            else
                warn "$f: 존재하지만 경고 문구(무단 접속 금지 등) 확인 필요"
            fi
        else
            warn "$f: 파일 없음"
        fi
    done

    if [ -f /etc/ssh/sshd_config ]; then
        if grep -Eq '^[[:space:]]*Banner[[:space:]]' /etc/ssh/sshd_config; then
            ok "sshd_config: Banner 설정 존재 (SSH 로그인 배너 적용)"
        else
            warn "sshd_config: Banner 설정 없음 (SSH 배너 미적용)"
        fi
    else
        warn "/etc/ssh/sshd_config 파일 없음"
    fi
}

# === U-67: 주요 로그 파일 소유자/권한 ===
check_U67() {
    section "[U-67] 주요 로그 파일 소유자 및 권한 점검"

    files=(
        /var/log/messages
        /var/log/secure
        /var/log/maillog
        /var/log/cron
        /var/log/syslog
        /var/log/btmp
        /var/log/wtmp
        /var/log/lastlog
    )

    for f in "${files[@]}"; do
        if [ ! -e "$f" ]; then
            log "[INFO] 파일 없음 → 점검 대상 아님: $f"
            continue
        fi

        owner=$(stat -c "%U:%G" "$f")
        perm=$(stat -c "%a" "$f")

        if [ "$owner" != "root:root" ]; then
            warn "$f: 소유자/그룹 $owner (root:root 권장)"
        elif [ "$perm" -gt 644 ]; then
            warn "$f: 권한 $perm (644 이하 권장)"
        else
            ok "$f: owner=$owner, perm=$perm (기준 충족)"
        fi
    done
}

# === 나머지 U-XX: 아직 미구현 안내용 ===
placeholder() {
    code="$1"
    section "[$code] 점검 (미구현)"
    warn "$code: audit 스크립트에 상세 점검 로직이 아직 구현되지 않았습니다."
    warn " → 가이드 문서의 '점검 방법'을 참고하여 수동 점검 또는 향후 스크립트 보완 필요."
}

# === 메인 실행부 ===
log "===== 취약점 점검(AUDIT) 시작 ====="

# 실제 구현된 항목
check_U01
check_U02
check_U03
check_U16
check_U18
check_U62
check_U67

# 아직 코드 안 짠 항목들은 placeholder로 표시
for code in \
    U-04 U-05 U-06 U-07 U-08 U-09 U-10 U-11 U-12 U-13 U-14 U-15 \
    U-17 U-19 U-20 U-21 U-22 U-23 U-24 U-25 U-26 U-27 U-28 U-29 \
    U-30 U-31 U-32 U-33 U-34 U-35 U-36 U-37 U-38 U-39 U-40 U-41 \
    U-42 U-43 U-44 U-45 U-46 U-47 U-48 U-49 U-50 U-51 U-52 U-53 \
    U-54 U-55 U-56 U-57 U-58 U-59 U-60 U-61 U-63 U-64 U-65 U-66
do
    placeholder "$code"
done

log "===== 취약점 점검(AUDIT) 종료 ====="

exit "$STATUS"
