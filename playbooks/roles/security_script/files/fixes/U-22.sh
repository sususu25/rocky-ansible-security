#!/bin/bash

echo "[U-22] /etc/services 파일 소유자 및 권한 점검/조치"

if [ "$EUID" -ne 0 ]; then
  echo "[U-22][ERROR] root 권한 필요"
  exit 1
fi

TARGET="/etc/services"
ALLOWED_OWNERS=("root" "bin" "sys")

if [ ! -f "$TARGET" ]; then
  echo "[U-22][ERROR] $TARGET 파일 없음"
  exit 1
fi

CUR_OWNER="$(stat -c "%U" "$TARGET" 2>/dev/null)"
CUR_GROUP="$(stat -c "%G" "$TARGET" 2>/dev/null)"
CUR_PERM="$(stat -c "%a" "$TARGET" 2>/dev/null)"

echo "[U-22] 현재 상태: owner=$CUR_OWNER group=$CUR_GROUP perm=$CUR_PERM"

# 1) 소유자 점검 (root/bin/sys만 허용, 그 외만 변경)
OWNER_OK=false
for o in "${ALLOWED_OWNERS[@]}"; do
  if [ "$CUR_OWNER" = "$o" ]; then
    OWNER_OK=true
    break
  fi
done

if [ "$OWNER_OK" = false ]; then
  chown root:root "$TARGET" || { echo "[U-22][ERROR] chown 실패"; exit 1; }
  echo "[U-22][FIX] 소유자 변경: $CUR_OWNER:$CUR_GROUP -> root:root"
fi

# 2) 권한 점검: "644 이하 권장" → (그룹/기타 쓰기 제거 + 실행비트 제거)만 수행
#    이미 더 엄격(600 등)하면 그대로 유지
PERM_INT=$((8#$CUR_PERM))
NEED_FIX=false

# 그룹/기타 쓰기(022) 존재 여부
if (( (PERM_INT & 022) != 0 )); then
  NEED_FIX=true
fi
# 실행 비트(111) 존재 여부
if (( (PERM_INT & 111) != 0 )); then
  NEED_FIX=true
fi

if [ "$NEED_FIX" = true ]; then
  chmod 644 "$TARGET" || { echo "[U-22][ERROR] chmod 실패"; exit 1; }
  echo "[U-22][FIX] 권한 변경: $CUR_PERM -> 644"
fi

NEW_OWNER="$(stat -c "%U" "$TARGET" 2>/dev/null)"
NEW_GROUP="$(stat -c "%G" "$TARGET" 2>/dev/null)"
NEW_PERM="$(stat -c "%a" "$TARGET" 2>/dev/null)"
echo "[U-22] 최종 상태: owner=$NEW_OWNER group=$NEW_GROUP perm=$NEW_PERM"

echo "[U-22] 점검/조치 완료"
exit 0
