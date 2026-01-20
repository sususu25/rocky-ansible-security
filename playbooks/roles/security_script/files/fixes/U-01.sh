#!/bin/bash

echo "[U-01] root 원격 로그인 제한 (Telnet / SSH)"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-01][ERROR] root 권한으로 실행해야 합니다"
    exit 1
fi

#####################################
# 공통 함수
#####################################
error_exit() {
    echo "[U-01][ERROR] $1"
    exit 1
}

warn_msg() {
    echo "[U-01][WARN] $1"
}

#####################################
# [Telnet] root 로그인 제한
#####################################

PAM_LOGIN="/etc/pam.d/login"
SECURETTY="/etc/securetty"

# PAM 설정
if [ -f "$PAM_LOGIN" ]; then
    if grep -q "pam_securetty.so" "$PAM_LOGIN"; then
        echo "[U-01][Telnet] pam_securetty.so 이미 설정됨"
    else
        echo "auth required /lib/security/pam_securetty.so" >> "$PAM_LOGIN" \
            || error_exit "pam_securetty.so 설정 추가 실패"
        echo "[U-01][Telnet] pam_securetty.so 설정 추가 완료"
    fi
else
    warn_msg "$PAM_LOGIN 파일 없음 (Telnet 비활성 환경)"
fi

# securetty pts 제거
if [ -f "$SECURETTY" ]; then
    if grep -q "^pts/" "$SECURETTY"; then
        sed -i '/^pts\//d' "$SECURETTY" \
            || error_exit "/etc/securetty pts 항목 제거 실패"
        echo "[U-01][Telnet] securetty pts/* 제거 완료"
    else
        echo "[U-01][Telnet] securetty pts/* 항목 없음"
    fi
else
    warn_msg "/etc/securetty 파일 없음"
fi

# Telnet 서비스 중지
if systemctl list-unit-files | grep -q "^telnet.socket"; then
    systemctl stop telnet.socket 2>/dev/null \
        || warn_msg "telnet.socket stop 실패"
    systemctl disable telnet.socket 2>/dev/null \
        || warn_msg "telnet.socket disable 실패"
    echo "[U-01][Telnet] telnet 서비스 중지 및 비활성화"
else
    echo "[U-01][Telnet] telnet 서비스 미존재 또는 비활성"
fi

#####################################
# [SSH] root 로그인 차단
#####################################

SSHD_CONF="/etc/ssh/sshd_config"

if [ -f "$SSHD_CONF" ]; then
    if grep -qi "^PermitRootLogin no" "$SSHD_CONF"; then
        echo "[U-01][SSH] PermitRootLogin 이미 no"
    else
        if grep -qi "^PermitRootLogin" "$SSHD_CONF"; then
            sed -i 's/^PermitRootLogin.*/PermitRootLogin no/I' "$SSHD_CONF" \
                || error_exit "sshd_config PermitRootLogin 수정 실패"
        else
            echo "PermitRootLogin no" >> "$SSHD_CONF" \
                || error_exit "sshd_config PermitRootLogin 추가 실패"
        fi

        systemctl restart sshd \
            || error_exit "sshd 재시작 실패 (접속 차단 가능)"
        echo "[U-01][SSH] root 로그인 차단 적용 완료"
    fi
else
    warn_msg "sshd_config 파일 없음"
fi

echo "[U-01] 조치 완료"
exit 0

