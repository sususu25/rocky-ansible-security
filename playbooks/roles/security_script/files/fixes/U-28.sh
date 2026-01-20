#!/bin/bash

echo "[U-28] 접근 통제 설정 점검"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-28][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# 1. TCP Wrapper 설정
#####################################
HOSTS_DENY="/etc/hosts.deny"
HOSTS_ALLOW="/etc/hosts.allow"

echo "[U-28][TCP Wrapper] 설정 확인"

# hosts.deny
if [ -f "$HOSTS_DENY" ]; then
    if grep -Eq '^[[:space:]]*ALL[[:space:]]*:[[:space:]]*ALL' "$HOSTS_DENY"; then
        echo "[U-28] hosts.deny ALL:ALL 이미 설정됨"
    else
        echo "ALL:ALL" >> "$HOSTS_DENY"
        echo "[U-28] hosts.deny ALL:ALL 추가"
    fi
else
    echo "[U-28][INFO] hosts.deny 파일 없음 (기본 허용 상태)"
fi

# hosts.allow
if [ -f "$HOSTS_ALLOW" ]; then
    echo "[U-28] hosts.allow 존재 (내용 유지)"
else
    echo "[U-28][INFO] hosts.allow 파일 없음"
fi

#####################################
# 2. iptables 설정 확인
#####################################
if command -v iptables >/dev/null 2>&1; then
    echo "[U-28][iptables] 현재 정책"
    iptables -L
else
    echo "[U-28][iptables] 미사용"
fi

#####################################
# 3. firewalld 설정 확인
#####################################
if systemctl is-active firewalld >/dev/null 2>&1; then
    echo "[U-28][firewalld] 현재 정책"
    firewall-cmd --list-all
else
    echo "[U-28][firewalld] 미사용"
fi

#####################################
# 4. UFW 설정 확인
#####################################
if command -v ufw >/dev/null 2>&1; then
    echo "[U-28][ufw] 현재 정책"
    ufw status numbered
else
    echo "[U-28][ufw] 미사용"
fi

echo "[U-28] 점검 완료"
exit 0

