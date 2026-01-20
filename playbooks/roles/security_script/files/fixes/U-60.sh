#!/bin/bash
echo "[U-59] SNMP Community String 설정 점검 및 변경"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-59][ERROR] root 권한으로 실행 필요"
    exit 1
fi

SNMP_CONF="/etc/snmp/snmpd.conf"
NEW_COMMUNITY="SECURE_COMMUNITY"   # ← 여기만 환경에 맞게 수정

# snmpd 서비스 존재 여부 확인
if ! systemctl list-unit-files | grep -q snmpd.service; then
    echo "[U-59] SNMP 서비스 미설치 – 조치 불필요"
    exit 0
fi

# 설정 파일 존재 확인
if [ ! -f "$SNMP_CONF" ]; then
    echo "[U-59][ERROR] $SNMP_CONF 파일 없음"
    exit 1
fi

# 백업
cp "$SNMP_CONF" "${SNMP_CONF}.bak"
echo "[U-59] 설정 파일 백업 완료"

# Community String 수정 (있으면 변경, 없으면 추가)
if grep -q "^com2sec.*default" "$SNMP_CONF"; then
    sed -i "s/^com2sec.*default.*/com2sec notConfigUser default $NEW_COMMUNITY/" "$SNMP_CONF"
    echo "[U-59] 기존 Community String 변경"
else
    echo "com2sec notConfigUser default $NEW_COMMUNITY" >> "$SNMP_CONF"
    echo "[U-59] Community String 신규 추가"
fi

# 서비스 재시작
systemctl restart snmpd

if systemctl is-active snmpd >/dev/null 2>&1; then
    echo "[U-59] SNMP Community String 설정 및 서비스 재시작 완료"
else
    echo "[U-59][ERROR] SNMP 서비스 재시작 실패"
fi

exit 0

