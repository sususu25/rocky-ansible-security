#!/bin/bash

echo "[U-08] root 그룹 사용자 점검"

ROOT_GROUP=$(getent group root)

if [ -z "$ROOT_GROUP" ]; then
    echo "[U-08][WARN] root 그룹 정보 없음"
    exit 0
fi

echo "[U-08] root 그룹 정보:"
echo "  $ROOT_GROUP"

MEMBERS=$(echo "$ROOT_GROUP" | awk -F: '{print $4}')

if [ -z "$MEMBERS" ]; then
    echo "[U-08] root 그룹에 추가 사용자 없음 (정상)"
else
    echo "[U-08][CHECK] root 그룹에 포함된 사용자:"
    echo "  $MEMBERS"
    echo
    echo "[U-08][ACTION] 불필요한 사용자는 아래 명령으로 수동 제거"
    echo "  gpasswd -d <username> root"
fi

echo "[U-08] 점검 완료"
exit 0

