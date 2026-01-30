#!/bin/bash
echo "[U-52] Telnet 서비스 비활성화 점검 및 조치"

BACKUP_SUFFIX="$(date +%Y%m%d_%H%M%S)"

# 1) systemd telnet.socket 비활성/마스킹
if command -v systemctl >/dev/null 2>&1; then
  if systemctl list-unit-files | grep -q '^telnet\.socket'; then
    systemctl stop telnet.socket 2>/dev/null || true
    systemctl disable telnet.socket 2>/dev/null || true
    systemctl mask telnet.socket 2>/dev/null || true
    echo "[U-52][FIX] systemd telnet.socket stop/disable/mask 완료"
  else
    echo "[U-52] systemd telnet.socket 없음"
  fi
fi

# 2) xinetd 기반 telnet 설정 disable=yes
TELNET_XINETD="/etc/xinetd.d/telnet"
if [ -f "$TELNET_XINETD" ]; then
  cp -a "$TELNET_XINETD" "${TELNET_XINETD}.bak_${BACKUP_SUFFIX}"
  echo "[U-52][INFO] 백업 생성: ${TELNET_XINETD}.bak_${BACKUP_SUFFIX}"

  # disable 값 강제
  if grep -q '^\s*disable\s*=' "$TELNET_XINETD"; then
    sed -i 's/^\s*disable\s*=.*/\tdisable\t\t= yes/' "$TELNET_XINETD"
  else
    # disable 항목이 없으면 service 블록 내에 추가 (단순 삽입)
    sed -i '/service[[:space:]]\+telnet[[:space:]]*{/a\ \tdisable\t\t= yes' "$TELNET_XINETD"
  fi
  echo "[U-52][FIX] xinetd telnet disable=yes 적용"
  systemctl restart xinetd 2>/dev/null || true
fi

# 3) inetd 기반(/etc/inetd.conf) telnet 라인 주석 처리
INETD="/etc/inetd.conf"
if [ -f "$INETD" ]; then
  cp -a "$INETD" "${INETD}.bak_${BACKUP_SUFFIX}"
  echo "[U-52][INFO] 백업 생성: ${INETD}.bak_${BACKUP_SUFFIX}"

  # telnet 라인 중 주석 아닌 것만 주석 처리
  sed -i '/^[[:space:]]*telnet[[:space:]]/ s/^/# [DISABLED_BY_BASELINE] /' "$INETD"
  echo "[U-52][FIX] inetd.conf telnet 라인 주석 처리"
  # inetd 서비스 종류가 다양해서 재시작은 환경별로 다름 → 가능하면 건드림
  (systemctl restart inetd 2>/dev/null || systemctl restart openbsd-inetd 2>/dev/null || true)
fi

# 4) telnet-server 패키지 설치 시 제거(가능하면)
if command -v rpm >/dev/null 2>&1 && rpm -q telnet-server >/dev/null 2>&1; then
  echo "[U-52][FIX] telnet-server 패키지 설치됨 → 제거 시도"
  (dnf -y remove telnet-server 2>/dev/null || yum -y remove telnet-server 2>/dev/null || true)
fi

echo "[U-52] 점검/조치 완료"
exit 0
