#!/bin/bash
# U-64.sh (심플)
# 목적: "보안 업데이트가 남아있는지"만 점검하고, 남아있으면 수동 업데이트 안내(⚠️)

echo "[U-64] OS 및 보안 업데이트 필요 여부 점검"

OS_INFO=$(grep -E '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2- | tr -d '"')
KERNEL_VER=$(uname -r 2>/dev/null)

echo "[U-64] OS: ${OS_INFO:-UNKNOWN}"
echo "[U-64] Kernel: ${KERNEL_VER:-UNKNOWN}"

if ! command -v dnf >/dev/null 2>&1; then
  echo "⚠️ [U-64] dnf 없음 → 업데이트 여부 판단 불가"
  echo "[U-64] 수동 조치: dnf update -y --security"
  exit 2
fi

# 보안 업데이트 목록 조회(조용히) → 있으면 수동 조치
SEC_LIST=$(dnf -q updateinfo list --security 2>/dev/null | awk 'NF>0')
if [ -z "$SEC_LIST" ]; then
  echo "✅ [U-64] 보안 업데이트 목록 없음(또는 조회 결과 없음) → 양호로 처리"
  exit 0
fi

# 대략 개수만
SEC_COUNT=$(echo "$SEC_LIST" | grep -v -E '^(Last metadata expiration check:|Update ID|Updates Information Summary)' | wc -l | tr -d ' ')
echo "⚠️ [U-64] 보안 업데이트 항목 존재: ${SEC_COUNT}건"
echo "[U-64] 수동 조치: dnf update -y --security"
echo "[U-64] (옵션) 커널 제외: dnf update -y --security --exclude=kernel*"
exit 2
