#!/bin/bash
echo "[U-58] SNMP 서비스 비활성화"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-58][ERROR] root 권한 필요"
    exit 1
fi

# SNMP 서비스 확인
SNMP_SERVICE=$(systemctl list-units --type=service | grep -E "^snmpd.service" | awk '{print $1}')

if [ -n "$SNMP_SERVICE" ]; then
    echo "[U-58] SNMP 서비스 중지 및 비활성화: $SNMP_SERVICE"
    systemctl stop "$SNMP_SERVICE"
    systemctl disable "$SNMP_SERVICE"
    echo "[U-58] SNMP 서비스 중지 및 비활성화 완료"
else
    echo "[U-58] SNMP 서비스 없음 또는 이미 비활성화 상태"
fi

exit 0

