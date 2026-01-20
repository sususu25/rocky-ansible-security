#!/bin/bash

echo "[U-43] NIS 관련 서비스 점검 및 비활성화"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-43][ERROR] root 권한 필요"
    exit 1
fi

# NIS 관련 서비스 목록
NIS_SERVICES=("ypserv" "ypbind" "ypxfrd" "rpc.yppasswdd" "rpc.ypupdated")

for svc in "${NIS_SERVICES[@]}"; do
    # 서비스 존재 여부 확인
    systemctl list-unit-files | grep -qw "$svc.service"
    if [ $? -eq 0 ]; then
        # 실행 중이면 중지
        systemctl stop "$svc" 2>/dev/null && echo "[U-43] $svc 서비스 중지 완료"
        # 비활성화
        systemctl disable "$svc" 2>/dev/null && echo "[U-43] $svc 서비스 비활성화 완료"
    else
        echo "[U-43] $svc 서비스 없음 또는 이미 비활성화"
    fi
done

echo "[U-43] NIS 서비스 점검 및 비활성화 완료"
exit 0

