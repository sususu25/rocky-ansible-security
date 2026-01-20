#!/bin/bash

echo "[U-19] /etc/hosts 파일 소유자 및 권한 점검"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-19][ERROR] root 권한 필요"
    exit 1
fi

HOSTS_FILE="/etc/hosts"

#####################################
# 파일 존재 확인
#####################################
if [ ! -f "$HOSTS_FILE" ]; then
    echo "[U-19][ERROR] /etc/hosts 파일 없음"
    exit 1
fi

#####################################
# 소유자 확인 및 조치
#####################################
OWNER=$(stat -c "%U" "$HOSTS_FILE")
if [ "$OWNER" != "root" ]; then
    chown root "$HOSTS_FILE"
    echo "[U-19][FIX] /etc/hosts 소유자 root로 변경"
else
    echo "[U-19] /etc/hosts 소유자 정상(root)"
fi

#####################################
# 권한 확인 및 조치
#####################################
PERM=$(stat -c "%a" "$HOSTS_FILE")
if [ "$PERM" != "644" ]; then
    chmod 644 "$HOSTS_FILE"
    echo "[U-19][FIX] /etc/hosts 권한 644로 변경"
else
    echo "[U-19] /etc/hosts 권한 정상(644)"
fi

echo "[U-19] 조치 완료"
exit 0

