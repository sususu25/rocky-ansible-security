#!/bin/bash

echo "[U-16] /etc/passwd 파일 소유자 및 권한 점검"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-16][ERROR] root 권한 필요"
    exit 1
fi

PASSWD_FILE="/etc/passwd"

#####################################
# Step 1: 소유자 및 권한 확인
#####################################
if [ -f "$PASSWD_FILE" ]; then
    LS_OUTPUT=$(ls -l "$PASSWD_FILE")
    OWNER=$(stat -c "%U" "$PASSWD_FILE")
    PERM=$(stat -c "%a" "$PASSWD_FILE")
    echo "[U-16] 현재 /etc/passwd 소유자: $OWNER, 권한: $PERM"
else
    echo "[U-16][ERROR] /etc/passwd 파일 없음"
    exit 1
fi

#####################################
# Step 2: 소유자 및 권한 조정
#####################################
if [ "$OWNER" != "root" ]; then
    chown root "$PASSWD_FILE"
    echo "[U-16] /etc/passwd 소유자를 root로 변경"
fi

if [ "$PERM" != "644" ]; then
    chmod 644 "$PASSWD_FILE"
    echo "[U-16] /etc/passwd 권한을 644로 변경"
fi

echo "[U-16] 조치 완료"
exit 0

