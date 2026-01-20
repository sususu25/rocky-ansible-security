#!/bin/bash
# U-61 SNMP 접근제어 설정

echo "[U-61] SNMP 접근 제어 설정 점검 시작"

# Step 1) SNMP 서비스 활성화 여부 확인
if ! systemctl list-units --type=service | grep -q snmpd; then
    echo "[U-61] SNMP 서비스 비활성 또는 미설치 → 조치 불필요"
    exit 0
fi

# Step 2) SNMP 접근 제어 설정
CONF="/etc/snmp/snmpd.conf"

if grep -q "^com2sec" $CONF; then
    echo "[U-61] SNMP 접근 제어 설정 존재"
else
    echo "[U-61] SNMP 접근 제어 설정 추가"
    echo "com2sec notConfigUser 127.0.0.1 public" >> $CONF
fi

# Step 3) 설정 적용
systemctl restart snmpd

echo "[U-61] SNMP 접근 제어 설정 완료"

