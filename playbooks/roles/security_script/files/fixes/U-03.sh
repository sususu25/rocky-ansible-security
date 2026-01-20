#!/bin/bash

echo "[U-03] 계정 잠금 정책 설정"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-03][ERROR] root 권한 필요"
    exit 1
fi

SYSTEM_AUTH="/etc/pam.d/system-auth"
PASSWORD_AUTH="/etc/pam.d/password-auth"
FAILLOCK_CONF="/etc/security/faillock.conf"

#####################################
# 1️⃣ pam_faillock 모듈 경로 확인
#####################################
if [ -f /lib64/security/pam_faillock.so ]; then
    FAILLOCK_SO="/lib64/security/pam_faillock.so"
elif [ -f /lib/security/pam_faillock.so ]; then
    FAILLOCK_SO="/lib/security/pam_faillock.so"
else
    echo "[U-03][WARN] pam_faillock.so 모듈 없음"
    echo "[U-03][INFO] pam_faillock 적용을 위해 모듈 설치 필요: dnf install -y pam_faillock"
    exit 0
fi

echo "[U-03] pam_faillock 사용: $FAILLOCK_SO"

#####################################
# PAM 파일 적용 함수
#####################################
apply_faillock_pam() {
    local PAM_FILE="$1"

    [ -f "$PAM_FILE" ] || return

    # auth preauth
    if grep -Eq "^[[:space:]]*auth[[:space:]]+required[[:space:]]+pam_faillock.so.*preauth" "$PAM_FILE"; then
        sed -i "s|^[[:space:]]*auth[[:space:]]\+required[[:space:]]\+pam_faillock.so.*preauth.*|auth    required    $FAILLOCK_SO preauth silent audit deny=10 unlock_time=120|" "$PAM_FILE"
    else
        sed -i "/^[[:space:]]*auth[[:space:]]\+required[[:space:]]\+pam_env.so/a auth    required    $FAILLOCK_SO preauth silent audit deny=10 unlock_time=120" "$PAM_FILE"
    fi

    # account
    if grep -Eq "^[[:space:]]*account[[:space:]]+required[[:space:]]+pam_faillock.so" "$PAM_FILE"; then
        sed -i "s|^[[:space:]]*account[[:space:]]\+required[[:space:]]\+pam_faillock.so.*|account required    $FAILLOCK_SO|" "$PAM_FILE"
    else
        sed -i "/^[[:space:]]*account[[:space:]]\+required[[:space:]]\+pam_unix.so/a account required    $FAILLOCK_SO" "$PAM_FILE"
    fi
}

#####################################
# system-auth / password-auth 적용
#####################################
apply_faillock_pam "$SYSTEM_AUTH"
apply_faillock_pam "$PASSWORD_AUTH"

#####################################
# faillock.conf 정책 적용 (순서 유지)
#####################################
if [ -f "$FAILLOCK_CONF" ]; then
    # silent
    if grep -q "^[[:space:]]*#\?[[:space:]]*silent" "$FAILLOCK_CONF"; then
        sed -i "s|^[[:space:]]*#\?[[:space:]]*silent.*|silent|" "$FAILLOCK_CONF"
    else
        sed -i "1i silent" "$FAILLOCK_CONF"
    fi

    # deny
    if grep -q "^[[:space:]]*#\?[[:space:]]*deny[[:space:]]*=" "$FAILLOCK_CONF"; then
        sed -i "s|^[[:space:]]*#\?[[:space:]]*deny[[:space:]]*=.*|deny = 10|" "$FAILLOCK_CONF"
    else
        # silent 뒤에 삽입
        sed -i "/^silent/a deny = 10" "$FAILLOCK_CONF"
    fi

    # unlock_time
    if grep -q "^[[:space:]]*#\?[[:space:]]*unlock_time[[:space:]]*=" "$FAILLOCK_CONF"; then
        sed -i "s|^[[:space:]]*#\?[[:space:]]*unlock_time[[:space:]]*=.*|unlock_time = 120|" "$FAILLOCK_CONF"
    else
        # deny 뒤에 삽입
        sed -i "/^deny = 10/a unlock_time = 120" "$FAILLOCK_CONF"
    fi
else
    echo "[U-03][WARN] faillock.conf 없음"
fi

echo "[U-03] pam_faillock 계정 잠금 정책 적용 완료"
exit 0

