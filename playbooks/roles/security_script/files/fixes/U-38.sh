#!/bin/bash

echo "[U-38] 불필요한 네트워크 서비스 비활성화 (echo, discard, daytime, chargen)"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-38][ERROR] root 권한 필요"
    exit 1
fi

SERVICES=("echo" "discard" "daytime" "chargen")

#####################################
# inetd 설정 확인/비활성화
#####################################
INETD_CONF="/etc/inetd.conf"
if [ -f "$INETD_CONF" ]; then
    for svc in "${SERVICES[@]}"; do
        if grep -q "^[^#]*$svc" "$INETD_CONF"; then
            sed -i "s/^\([^#]*$svc.*\)/#\1/" "$INETD_CONF"
            echo "[U-38][inetd] $svc 서비스 주석 처리 완료"
        fi
    done
    # inetd 재시작
    if command -v inetd &>/dev/null; then
        inetd
        echo "[U-38][inetd] inetd 재시작 완료"
    fi
fi

#####################################
# xinetd 설정 확인/비활성화
#####################################
XINETD_DIR="/etc/xinetd.d"
if [ -d "$XINETD_DIR" ]; then
    for svc in "${SERVICES[@]}"; do
        for file in "$XINETD_DIR"/*; do
            if grep -q "^\s*service\s*$svc" "$file"; then
                sed -i "s/^\s*disable\s*=.*/disable = yes/" "$file"
                echo "[U-38][xinetd] $svc 서비스 비활성화 완료 ($file)"
            fi
        done
    done
    # xinetd 재시작
    if systemctl is-active xinetd &>/dev/null || systemctl list-unit-files | grep -q xinetd; then
        systemctl restart xinetd
        echo "[U-38][xinetd] xinetd 서비스 재시작 완료"
    fi
fi

#####################################
# systemd 서비스 확인/비활성화
#####################################
for svc in "${SERVICES[@]}"; do
    if systemctl list-units --type=service | grep -q "$svc"; then
        systemctl stop "$svc"
        systemctl disable "$svc"
        echo "[U-38][systemd] $svc 서비스 중지 및 비활성화 완료"
    fi
done

echo "[U-38] 불필요 서비스 비활성화 완료"
exit 0

