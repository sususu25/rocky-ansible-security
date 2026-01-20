#!/bin/bash

echo "[U-36] r 계열 서비스 비활성화 (rlogin, rsh, rexec)"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-36][ERROR] root 권한 필요"
    exit 1
fi

R_SERVICES=("rlogin" "rsh" "rexec")

#############################
# inetd.conf 처리
#############################
INETD_CONF="/etc/inetd.conf"
if [ -f "$INETD_CONF" ]; then
    for svc in "${R_SERVICES[@]}"; do
        if grep -q "^[^#].*\b$svc\b" "$INETD_CONF"; then
            sed -i "/\b$svc\b/ s/^/#/" "$INETD_CONF"
            echo "[U-36][inetd] $svc 주석 처리 완료"
        fi
    done
    systemctl restart inetd 2>/dev/null && echo "[U-36][inetd] 서비스 재시작 완료"
else
    echo "[U-36][inetd] /etc/inetd.conf 파일 없음"
fi

#############################
# xinetd.d 처리
#############################
XINETD_DIR="/etc/xinetd.d"
if [ -d "$XINETD_DIR" ]; then
    for svc in "${R_SERVICES[@]}"; do
        for file in "$XINETD_DIR"/*; do
            if grep -q "^service\s*=\s*$svc" "$file"; then
                sed -i 's/^\s*disable\s*=\s*no/disable = yes/' "$file"
                echo "[U-36][xinetd] $svc 비활성화 (disable=yes) : $file"
            fi
        done
    done
    systemctl restart xinetd 2>/dev/null && echo "[U-36][xinetd] 서비스 재시작 완료"
else
    echo "[U-36][xinetd] /etc/xinetd.d 디렉토리 없음"
fi

#############################
# systemd 서비스 처리
#############################
for svc in "${R_SERVICES[@]}"; do
    if systemctl list-unit-files | grep -q "^$svc"; then
        if systemctl is-active "$svc" >/dev/null 2>&1; then
            systemctl stop "$svc"
            echo "[U-36][systemd] $svc 중지 완료"
        fi
        systemctl disable "$svc" >/dev/null 2>&1
        echo "[U-36][systemd] $svc 비활성화 완료"
    fi
done

echo "[U-36] r 계열 서비스 비활성화 조치 완료"
exit 0

