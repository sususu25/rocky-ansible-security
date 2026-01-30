#!/bin/bash
echo "[U-60] SNMP Community String 설정 점검 (납품 기본: SNMP 미사용/비활성화)"

CONF="/etc/snmp/snmpd.conf"
BACKUP_SUFFIX="$(date +%Y%m%d_%H%M%S)"

# 1) snmpd 서비스 stop/disable/mask
if command -v systemctl >/dev/null 2>&1; then
  if systemctl list-unit-files | grep -q '^snmpd\.service'; then
    systemctl stop snmpd 2>/dev/null || true
    systemctl disable snmpd 2>/dev/null || true
    systemctl mask snmpd 2>/dev/null || true
    echo "[U-60][FIX] snmpd stop/disable/mask 완료"
  else
    echo "[U-60] snmpd 서비스 없음"
  fi
fi

# 2) 설정 파일이 있으면 rocommunity 등 community 기반 라인 주석 처리
if [ -f "$CONF" ]; then
  cp -a "$CONF" "${CONF}.bak_${BACKUP_SUFFIX}"
  echo "[U-60][INFO] 백업 생성: ${CONF}.bak_${BACKUP_SUFFIX}"

  # community 관련 라인(예: rocommunity/public 등) 주석 처리
  sed -i '/^\s*\(rocommunity\|rwcommunity\|com2sec\|community\)\b/ s/^/# [DISABLED_BY_BASELINE] /' "$CONF"
  echo "[U-60][FIX] community 기반 설정 주석 처리 완료"
else
  echo "[U-60][INFO] snmpd.conf 없음 → SNMP 미사용 가능(양호)"
fi

# 3) 패키지 제거는 환경마다 정책이 달라 optional로만
if command -v rpm >/dev/null 2>&1 && rpm -q net-snmp >/dev/null 2>&1; then
  echo "[U-60][INFO] net-snmp 패키지 존재(필요 시 제거 가능) — 현재는 서비스 비활성으로 기준 충족"
fi

echo "[U-60] 점검/조치 완료"
exit 0
