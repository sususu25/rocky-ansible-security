#!/bin/bash

echo "[U-60] SNMP Community String 설정 점검 (정책 보류/수동 승인 분리)"

if [ "$EUID" -ne 0 ]; then
  echo "[U-60][ERROR] root 권한으로 실행 필요"
  exit 1
fi

SNMP_CONF="/etc/snmp/snmpd.conf"
SNMP_COMMUNITY="${SNMP_COMMUNITY:-}"

# snmpd 설정 파일 존재 확인
if [ ! -f "$SNMP_CONF" ]; then
  echo "[U-60][INFO] $SNMP_CONF 파일 없음 (SNMP 미사용 가능)"
  exit 0
fi

# 현재 community 관련 라인 출력
echo "[U-60] 현재 설정(발견 시 일부 표시):"
grep -E "^(com2sec|rocommunity|rwcommunity)" "$SNMP_CONF" 2>/dev/null | head -n 5 || echo "[U-60][INFO] community 설정 라인 없음"

# 위험 기본값(public/private) 탐지
HAS_WEAK=false
if grep -qE "^(rocommunity|rwcommunity)\s+(public|private)\b" "$SNMP_CONF"; then
  HAS_WEAK=true
fi
if grep -qE "^com2sec\s+\S+\s+\S+\s+(public|private)\b" "$SNMP_CONF"; then
  HAS_WEAK=true
fi

# 복잡도 검사
is_strong() {
  local s="$1"
  # 영문 포함, 숫자 포함
  if ! echo "$s" | grep -qE '[A-Za-z]'; then return 1; fi
  if ! echo "$s" | grep -qE '[0-9]'; then return 1; fi

  # 케이스1: 영문+숫자만, 길이>=10
  if echo "$s" | grep -qE '^[A-Za-z0-9]+$'; then
    [ "${#s}" -ge 10 ] && return 0
    return 1
  fi

  # 케이스2: 영문+숫자+특수문자 포함, 길이>=8
  # (특수문자: 알파/숫자/공백 제외)
  if echo "$s" | grep -qE '[^A-Za-z0-9]'; then
    [ "${#s}" -ge 8 ] && return 0
  fi

  return 1
}

# 정책: 값이 없으면 자동 변경 금지 → ⚠️
if [ -z "$SNMP_COMMUNITY" ]; then
  if [ "$HAS_WEAK" = true ]; then
    echo "⚠️ [U-60][NOTICE] community가 public/private로 설정된 흔적이 있으나, 변경값(SNMP_COMMUNITY) 미주입으로 자동 조치 보류"
    echo "[U-60][ACTION] 운영 승인 후 SNMP_COMMUNITY 값을 안전한 문자열로 주입하여 재실행 권고"
    exit 2
  fi

  echo "[U-60][OK] public/private 기본값 설정 흔적 없음 또는 community 설정 없음"
  exit 0
fi

# 주입된 값이 안전 기준 충족하는지 확인
if ! is_strong "$SNMP_COMMUNITY"; then
  echo "⚠️ [U-60][NOTICE] SNMP_COMMUNITY 복잡도 기준 미달: 길이/구성 확인 필요"
  echo "[U-60][INFO] 정책: 안전 기준 충족 전까지 자동 변경 금지"
  exit 2
fi

# 여기부터는 안전값이 주입된 상태 → 적용
cp -p "$SNMP_CONF" "${SNMP_CONF}.bak_$(date +%Y%m%d_%H%M%S)" || { echo "[U-60][ERROR] 백업 실패"; exit 1; }
echo "[U-60][INFO] 백업 생성 완료"

# rocommunity/rwcommunity 치환(있으면)
if grep -qE "^(rocommunity|rwcommunity)" "$SNMP_CONF"; then
  sed -i -E "s/^(rocommunity|rwcommunity)\s+.*/\1 ${SNMP_COMMUNITY}/" "$SNMP_CONF" || { echo "[U-60][ERROR] sed 실패"; exit 1; }
  echo "[U-60][FIX] rocommunity/rwcommunity 값 변경 완료"
fi

# com2sec 치환(있으면)
if grep -qE "^com2sec" "$SNMP_CONF"; then
  sed -i -E "s/^(com2sec\s+\S+\s+\S+\s+).*/\1${SNMP_COMMUNITY}/" "$SNMP_CONF" || { echo "[U-60][ERROR] sed 실패"; exit 1; }
  echo "[U-60][FIX] com2sec 값 변경 완료"
fi

echo "[U-60] 변경 후 설정 확인:"
grep -E "^(com2sec|rocommunity|rwcommunity)" "$SNMP_CONF" || echo "[U-60][INFO] 변경된 항목 없음(설정 라인 자체가 없을 수 있음)"

echo "[U-60] 점검/조치 완료: ✅"
exit 0
