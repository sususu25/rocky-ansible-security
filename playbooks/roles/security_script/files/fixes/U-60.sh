#!/bin/bash
echo "[U-60] SNMP Community String 설정 점검 및 변경"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-60][ERROR] root 권한으로 실행 필요"
    exit 1
fi

SNMP_CONF="/etc/snmp/snmpd.conf"
NEW_COMMUNITY="SECURE_COMMUNITY"   # ← 여기만 환경에 맞게 수정

# snmpd 설정 파일 존재 확인
if [ ! -f "$SNMP_CONF" ]; then
    echo "[U-60][INFO] $SNMP_CONF 파일 없음 (SNMP 미사용 가능)"
    exit 0
fi

echo "[U-60] 기존 community string 확인..."

# 기존 community string 라인 찾기
OLD_COMMUNITY_LINE=$(grep -E "^(com2sec|rocommunity|rwcommunity)" "$SNMP_CONF" | head -n 1)

if [ -z "$OLD_COMMUNITY_LINE" ]; then
    echo "[U-60][INFO] community 설정 없음 → 추가 필요"
else
    echo "[U-60][FOUND] 기존 설정: $OLD_COMMUNITY_LINE"
fi

# 백업
cp -p "$SNMP_CONF" "${SNMP_CONF}.bak_$(date +%Y%m%d_%H%M%S)"
echo "[U-60] 백업 생성 완료"

# rocommunity/rwcommunity 치환(있으면)
if grep -qE "^(rocommunity|rwcommunity)" "$SNMP_CONF"; then
    sed -i -E "s/^(rocommunity|rwcommunity)\\s+.*/\\1 ${NEW_COMMUNITY}/" "$SNMP_CONF"
    echo "[U-60][FIX] rocommunity/rwcommunity 값 변경 완료"
fi

# com2sec 치환(있으면)
if grep -qE "^com2sec" "$SNMP_CONF"; then
    sed -i -E "s/^(com2sec\\s+\\S+\\s+\\S+\\s+).*/\\1${NEW_COMMUNITY}/" "$SNMP_CONF"
    echo "[U-60][FIX] com2sec 값 변경 완료"
fi

echo "[U-60] 변경 후 설정 확인:"
grep -E "^(com2sec|rocommunity|rwcommunity)" "$SNMP_CONF" || echo "[U-60][INFO] 변경된 항목 없음"

echo "[U-60] 점검/조치 완료"
exit 0
