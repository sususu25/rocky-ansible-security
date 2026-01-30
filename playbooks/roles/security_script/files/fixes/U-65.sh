#!/bin/bash
# U-65.sh (심플)
# 목적: chrony(chronyd)가 동작하고 동기화 징후가 있는지 점검

echo "[U-65] 시간 동기화(Chrony) 점검"

# 서비스 존재/상태
if command -v systemctl >/dev/null 2>&1; then
  ACTIVE=$(systemctl is-active chronyd 2>/dev/null)
else
  ACTIVE="unknown"
fi

echo "[U-65] chronyd 상태: $ACTIVE"

if ! command -v chronyc >/dev/null 2>&1; then
  echo "⚠️ [U-65] chronyc 없음 → 동기화 상태 확인 불가"
  echo "[U-65] 수동 조치: dnf install -y chrony && systemctl enable --now chronyd"
  exit 2
fi

# sources 출력에서 ^* (선택된 소스) 가 있으면 동기화 중으로 간주
SRC=$(chronyc sources 2>/dev/null | tail -n +1)
if echo "$SRC" | grep -q '^\^\*'; then
  echo "✅ [U-65] 동기화 소스(^*) 확인됨 → 양호"
  exit 0
fi

echo "⚠️ [U-65] 동기화 소스(^*) 미확인 → 확인 필요"
echo "[U-65] 수동 확인: chronyc sources -v / chronyc tracking"
echo "[U-65] 수동 조치(필요 시): /etc/chrony.conf 서버 설정 후 systemctl restart chronyd"
exit 2
