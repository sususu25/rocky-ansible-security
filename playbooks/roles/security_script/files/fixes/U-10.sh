#!/bin/bash

echo "[U-10] 사용자 UID 중복 점검"

if [ "$EUID" -ne 0 ]; then
    echo "[U-10][ERROR] root 권한 필요"
    exit 1
fi

PASSWD_FILE="/etc/passwd"
declare -A UID_MAP
declare -a DUPLICATES

while IFS=: read -r username passwd uid gid comment home shell; do
    if [ -n "${UID_MAP[$uid]}" ]; then
        echo "[U-10][WARN] UID $uid 중복: ${UID_MAP[$uid]} 와 $username"
        DUPLICATES+=("$username")
    else
        UID_MAP[$uid]="$username"
    fi
done < "$PASSWD_FILE"

if [ ${#DUPLICATES[@]} -eq 0 ]; then
    echo "[U-10] 중복 UID 없음"
else
    echo "[U-10] UID 변경 필요 사용자: ${DUPLICATES[*]}"
    echo "[U-10] 필요 시 조치: usermod -u <새 UID> <사용자>"
fi

echo "[U-10] 점검 완료"
exit 0

