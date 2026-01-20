#!/bin/bash

echo "[U-63] sudoers 파일 소유자 및 권한 점검 시작"

SUDOERS="/etc/sudoers"

# 파일 존재 여부 확인
if [ ! -f "$SUDOERS" ]; then
    echo "[U-63][WARN] /etc/sudoers 파일 없음 → 미적용"
    echo "[U-63] 점검 종료"
    exit 0
fi

# 현재 소유자 및 권한 확인
OWNER=$(stat -c "%U" $SUDOERS)
PERM=$(stat -c "%a" $SUDOERS)

echo "[U-63] 현재 소유자: $OWNER, 권한: $PERM"

# 소유자 변경
if [ "$OWNER" != "root" ]; then
    chown root "$SUDOERS"
    echo "[U-63] sudoers 소유자 root로 변경"
fi

# 권한 변경
if [ "$PERM" != "640" ]; then
    chmod 640 "$SUDOERS"
    echo "[U-63] sudoers 권한 640으로 변경"
fi

# 문법 점검 (깨졌으면 여기서 바로 알 수 있음)
visudo -c >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "[U-63][ERROR] sudoers 문법 오류 감지됨 (즉시 확인 필요)"
    exit 1
fi

echo "[U-63] sudoers 파일 점검 및 설정 완료"
exit 0

