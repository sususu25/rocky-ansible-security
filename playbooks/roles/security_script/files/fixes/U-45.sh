#!/bin/bash

echo "[U-45] 메일 서비스 점검 및 비활성화"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-45][ERROR] root 권한 필요"
    exit 1
fi

# 점검할 메일 서비스 목록
MAIL_SERVICES=("sendmail" "postfix" "exim")

for svc in "${MAIL_SERVICES[@]}"; do
    systemctl list-unit-files | grep -qw "$svc.service"
    if [ $? -eq 0 ]; then
        echo "[U-45] $svc 서비스 활성화됨 → 중지 및 비활성화"
        systemctl stop "$svc" 2>/dev/null && echo "[U-45] $svc 서비스 중지 완료"
        systemctl disable "$svc" 2>/dev/null && echo "[U-45] $svc 서비스 비활성화 완료"
        echo "[U-45] $svc 사용 시 최신 보안 패치 적용 필요: 홈페이지 참조"
    else
        # PID 확인 (systemd 없는 경우)
        PID=$(pgrep -x "$svc")
        if [ -n "$PID" ]; then
            kill -9 "$PID" 2>/dev/null && echo "[U-45] $svc 서비스 프로세스(PID:$PID) 종료 완료"
        else
            echo "[U-45] $svc 서비스 없음"
        fi
    fi
done

echo "[U-45] 메일 서비스 점검 및 비활성화 완료"
exit 0

