#!/bin/bash

echo "[U-44] TFTP, Talk, Ntalk 서비스 점검 및 비활성화"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-44][ERROR] root 권한 필요"
    exit 1
fi

# 대상 서비스 목록
SERVICES=("tftp" "talk" "ntalk")

# systemd 서비스 점검 및 비활성화
for svc in "${SERVICES[@]}"; do
    systemctl list-unit-files | grep -qw "$svc.service"
    if [ $? -eq 0 ]; then
        systemctl stop "$svc" 2>/dev/null && echo "[U-44] $svc 서비스 중지 완료"
        systemctl disable "$svc" 2>/dev/null && echo "[U-44] $svc 서비스 비활성화 완료"
    else
        echo "[U-44] $svc 서비스 없음 또는 이미 비활성화"
    fi
done

# inetd/xinetd 서비스 점검
INETD_CONF="/etc/inetd.conf"
XINETD_DIR="/etc/xinetd.d"

if [ -f "$INETD_CONF" ]; then
    for svc in "${SERVICES[@]}"; do
        sed -i "/^[^#]*\b$svc\b/ s/^/#/" "$INETD_CONF" && echo "[U-44] $svc 항목 inetd.conf 주석 처리"
    done
    systemctl restart inetd 2>/dev/null && echo "[U-44] inetd 서비스 재시작 완료"
fi

if [ -d "$XINETD_DIR" ]; then
    for svc in "${SERVICES[@]}"; do
        if [ -f "$XINETD_DIR/$svc" ]; then
            sed -i "s/^[[:space:]]*disable[[:space:]]*=.*/disable = yes/" "$XINETD_DIR/$svc"
            echo "[U-44] $svc xinetd 설정 disable=yes 적용"
        fi
    done
    systemctl restart xinetd 2>/dev/null && echo "[U-44] xinetd 서비스 재시작 완료"
fi

echo "[U-44] TFTP, Talk, Ntalk 서비스 점검 및 비활성화 완료"
exit 0

