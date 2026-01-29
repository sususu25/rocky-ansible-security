#!/bin/bash

echo "[U-22] /etc/services 파일 소유자 및 권한 점검/조치"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-22][ERROR] root 권한 필요"
    exit 1
fi

TARGET="/etc/services"
ALLOWED_OWNERS=("root" "bin" "sys")

#####################################
# 대상 파일 존재 확인
#####################################
if [ ! -f "$TARGET" ]; then
    echo "[U-22][ERROR] $TARGET 파일 없음"
    exit 1
fi

#####################################
# 현재 값 출력
#####################################
CUR_OWNER="$(stat -c "%U" "$TARGET" 2>/dev/null)"
CUR_GROUP="$(stat -c "%G" "$TARGET" 2>/dev/null)"
CUR_PERM="$(stat -c "%a" "$TARGET" 2>/dev/null)"

echo "[U-22] 현재 상태: owner=$CUR_OWNER group=$CUR_GROUP perm=$CUR_PERM"

#####################################
# 1) 소유자 점검/조치
# - 가이드: root(또는 bin, sys) 권장
#####################################
OWNER_OK=false
for o in "${ALLOWED_OWNERS[@]}"; do
    if [ "$CUR_OWNER" = "$o" ]; then
        OWNER_OK=true
        break
    fi
done

if [ "$OWNER_OK" = false ]; then
    chown root:root "$TARGET"
    echo "[U-22][FIX] 소유자 변경: root:root"
fi

#####################################
# 2) 권한 점검/조치
# - 가이드: 644 이하 권장
# - 구현: (그룹/기타 쓰기 금지) + (실행 비트 제거)
#   * 더 엄격한 권한(600 등)은 유지
#####################################
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
    chmod 644 "$TARGET"
    echo "[U-22][FIX] 권한 변경: 644"
fi

#####################################
# 최종 확인
#####################################
NEW_OWNER="$(stat -c "%U" "$TARGET" 2>/dev/null)"
NEW_GROUP="$(stat -c "%G" "$TARGET" 2>/dev/null)"
NEW_PERM="$(stat -c "%a" "$TARGET" 2>/dev/null)"
echo "[U-22] 최종 상태: owner=$NEW_OWNER group=$NEW_GROUP perm=$NEW_PERM"

echo "[U-22] 점검/조치 완료"
exit 0
