#!/bin/bash

echo "[U-41] 자동 마운트(automount/autofs) 서비스 비활성화"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-41][ERROR] root 권한 필요"
    exit 1
fi

SERVICES=("autofs" "automount")

for svc in "${SERVICES[@]}"; do
    # 서비스 존재 여부 확인
    if systemctl list-unit-files | grep -q "^$svc.service"; then
        # 서비스 상태 확인
        STATUS=$(systemctl is-active "$svc" 2>/dev/null)
        echo "[U-41] $svc 서비스 상태: $STATUS"

        # 실행 중이면 중지
        if [ "$STATUS" = "active" ]; then
            systemctl stop "$svc"
            echo "[U-41] $svc 서비스 중지 완료"
        fi

        # 비활성화
        systemctl disable "$svc"
        echo "[U-41] $svc 서비스 비활성화 완료"
    else
        echo "[U-41] $svc 서비스 없음"
    fi
done

echo "[U-41] 자동 마운트 서비스 점검 및 비활성화 완료"
exit 0

