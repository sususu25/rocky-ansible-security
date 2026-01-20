#!/bin/bash
echo "[U-49] DNS 서비스(named/BIND) 점검 및 비활성화"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-49][ERROR] root 권한 필요"
    exit 1
fi

################################
# DNS 서비스 활성화 여부 확인
################################
if systemctl list-units --type=service | grep -q named; then
    echo "[U-49] DNS(named) 서비스 활성화됨. 비활성화 진행"

    # 서비스 중지
    systemctl stop named
    systemctl disable named
    echo "[U-49] named 서비스 중지 및 비활성화 완료"
else
    echo "[U-49] named 서비스 미사용"
fi

################################
# BIND 버전 확인
################################
if command -v named >/dev/null 2>&1; then
    echo "[U-49] BIND(named) 버전 확인"
    named -v
    echo "[U-49] 최신 패치 버전 적용 필요 시 ISC 홈페이지 확인: https://www.isc.org/downloads/"
else
    echo "[U-49] BIND(named) 설치되지 않음"
fi

echo "[U-49] DNS 서비스 점검 및 비활성화 완료"
exit 0

