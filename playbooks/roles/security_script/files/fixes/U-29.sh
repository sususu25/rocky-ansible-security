#!/bin/bash

echo "[U-29] /etc/hosts.lpd 소유자 및 권한 설정"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-29][ERROR] root 권한 필요"
    exit 1
fi

FILE="/etc/hosts.lpd"

#####################################
# 파일 존재 여부 확인
#####################################
if [ ! -f "$FILE" ]; then
    echo "[U-29][INFO] /etc/hosts.lpd 파일 없음 (조치 불필요)"
    exit 0
fi

#####################################
# 소유자 확인 및 수정
#####################################
OWNER=$(stat -c "%U" "$FILE")
if [ "$OWNER" != "root" ]; then
    chown root "$FILE"
    echo "[U-29] 소유자를 root로 변경"
else
    echo "[U-29] 소유자 이미 root"
fi

#####################################
# 권한 확인 및 수정
#####################################
PERM=$(stat -c "%a" "$FILE")
if [ "$PERM" != "600" ]; then
    chmod 600 "$FILE"
    echo "[U-29] 권한을 600으로 변경"
else
    echo "[U-29] 권한 이미 600"
fi

echo "[U-29] 조치 완료"
exit 0

