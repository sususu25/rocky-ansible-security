#!/bin/bash

echo "[U-42] 불필요한 RPC 서비스 점검 및 비활성화"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-42][ERROR] root 권한 필요"
    exit 1
fi

############################
# inetd 기반
############################
INETD_CONF="/etc/inetd.conf"
if [ -f "$INETD_CONF" ]; then
    # rpc 관련 항목 주석 처리
    if grep -q "rpc" "$INETD_CONF"; then
        sed -i.bak '/rpc/ s/^/#/' "$INETD_CONF"
        echo "[U-42] /etc/inetd.conf 내 RPC 서비스 주석 처리 완료"
        systemctl restart inetd 2>/dev/null && echo "[U-42] inetd 서비스 재시작 완료"
    else
        echo "[U-42] /etc/inetd.conf 내 RPC 서비스 없음"
    fi
else
    echo "[U-42] inetd.conf 파일 없음"
fi

############################
# xinetd 기반
############################
XINETD_DIR="/etc/xinetd.d"
if [ -d "$XINETD_DIR" ]; then
    for f in "$XINETD_DIR"/*; do
        if grep -q "rpc" "$f"; then
            sed -i.bak '/disable/s/no/yes/' "$f"
            echo "[U-42] $f 파일 내 RPC 서비스 비활성화(disable=yes)"
        fi
    done
    systemctl restart xinetd 2>/dev/null && echo "[U-42] xinetd 서비스 재시작 완료"
else
    echo "[U-42] /etc/xinetd.d 디렉터리 없음"
fi

############################
# systemd 기반
############################
RPC_SERVICES=$(systemctl list-units --type=service | grep -E "rpc" | awk '{print $1}')
if [ -n "$RPC_SERVICES" ]; then
    for svc in $RPC_SERVICES; do
        systemctl stop "$svc" 2>/dev/null
        systemctl disable "$svc" 2>/dev/null
        echo "[U-42] $svc 서비스 중지 및 비활성화 완료"
    done
else
    echo "[U-42] 활성화된 systemd RPC 서비스 없음"
fi

echo "[U-42] 불필요한 RPC 서비스 점검 및 비활성화 완료"
exit 0

