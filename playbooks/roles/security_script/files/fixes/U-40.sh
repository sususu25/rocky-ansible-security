#!/bin/bash
echo "[U-40] /etc/exports 파일 점검 및 NFS 공유 설정 (기본: 공유 없음으로 정리)"

EXPORTS="/etc/exports"
BACKUP_SUFFIX="$(date +%Y%m%d_%H%M%S)"

# 1) /etc/exports 존재 시: 권한/소유자 정리 + 활성 라인 주석 처리
if [ -f "$EXPORTS" ]; then
  echo "[U-40] exports 파일 존재: $EXPORTS"

  # 백업
  cp -a "$EXPORTS" "${EXPORTS}.bak_${BACKUP_SUFFIX}"
  echo "[U-40][INFO] 백업 생성: ${EXPORTS}.bak_${BACKUP_SUFFIX}"

  # 주석/공백 제외하고 활성 라인 있으면 주석 처리 (공유 제거 방향)
  if grep -Ev '^\s*#|^\s*$' "$EXPORTS" >/dev/null 2>&1; then
    echo "[U-40][FIX] 활성 공유 설정 발견 → 납품 기본값(공유 없음)으로 주석 처리"
    sed -i 's/^\s*\([^#[:space:]].*\)$/# [DISABLED_BY_BASELINE] \1/g' "$EXPORTS"
  else
    echo "[U-40] 활성 공유 설정 없음(이미 안전 상태)"
  fi

  # 권한/소유자 강제
  chown root:root "$EXPORTS"
  chmod 600 "$EXPORTS"
  echo "[U-40] 권한/소유자 설정 완료 (root:root 600)"
else
  echo "[U-40][INFO] /etc/exports 없음 → NFS 공유 설정 대상 아님(양호)"
fi

# 2) nfs-server 서비스가 있으면 "기본 비활성" 보장 (공유 안 쓰는 납품 기준)
if command -v systemctl >/dev/null 2>&1; then
  if systemctl list-unit-files | grep -q '^nfs-server\.service'; then
    systemctl stop nfs-server 2>/dev/null || true
    systemctl disable nfs-server 2>/dev/null || true
    systemctl mask nfs-server 2>/dev/null || true
    echo "[U-40] nfs-server 비활성/마스킹 완료"
  else
    echo "[U-40] nfs-server 서비스 없음"
  fi
fi

echo "[U-40] 점검/조치 완료"
exit 0
