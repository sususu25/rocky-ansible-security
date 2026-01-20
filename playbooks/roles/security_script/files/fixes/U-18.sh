#!/bin/bash

echo "[U-18] /etc/shadow 파일 소유자 및 권한 점검"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-18][ERROR] root 권한 필요"
    exit 1
fi

SHADOW_FILE="/etc/shadow"

#####################################
# 파일 존재 확인
#####################################
if [ ! -f "$SHADOW_FILE" ]; then
    echo "[U-18][ERROR] /etc/shadow 파일 없음"
    exit 1
fi

#####################################
# 소유자 확인 및 조치
#####################################
OWNER=$(stat -c "%U" "$SHADOW_FILE")
if [ "$OWNER" != "root" ]; then
    chown root "$SHADOW_FILE"
    echo "[U-18][FIX] /etc/shadow 소유자 root로 변경"
else
    echo "[U-18] /etc/shadow 소유자 정상(root)"
fi

#####################################
# 권한 확인 및 조치
#####################################
PERM=$(stat -c "%a" "$SHADOW_FILE")
if [ "$PERM" != "400" ]; then
    chmod 400 "$SHADOW_FILE"
    echo "[U-18][FIX] /etc/shadow 권한 400으로 변경"
else
    echo "[U-18] /etc/shadow 권한 정상(400)"
fi

echo "[U-18] 조치 완료"
exit 0

