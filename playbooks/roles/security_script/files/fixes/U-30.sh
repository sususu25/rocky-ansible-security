#!/bin/bash

echo "[U-30] UMASK 설정 확인 및 보정"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-30][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# 1. /etc/profile
#####################################
PROFILE="/etc/profile"

if [ -f "$PROFILE" ]; then
    # umask 라인 수정 (주석 제외, 위치 유지)
    if grep -Eq '^[[:space:]]*umask[[:space:]]+' "$PROFILE"; then
        sed -i 's/^[[:space:]]*umask[[:space:]]\+.*/umask 022/' "$PROFILE"
        echo "[U-30] /etc/profile umask 값 수정"
    else
        echo "umask 022" >> "$PROFILE"
        echo "[U-30] /etc/profile umask 추가"
    fi

    # export umask 존재 여부 확인
    if grep -Eq '^[[:space:]]*export[[:space:]]+umask' "$PROFILE"; then
        : 
    else
        echo "export umask" >> "$PROFILE"
        echo "[U-30] /etc/profile export umask 추가"
    fi
else
    echo "[U-30][WARN] /etc/profile 파일 없음"
fi

#####################################
# 2. /etc/login.defs
#####################################
LOGIN_DEFS="/etc/login.defs"

if [ -f "$LOGIN_DEFS" ]; then
    if grep -Eq '^[[:space:]]*UMASK[[:space:]]+' "$LOGIN_DEFS"; then
        sed -i 's/^[[:space:]]*UMASK[[:space:]]\+.*/UMASK 022/' "$LOGIN_DEFS"
        echo "[U-30] /etc/login.defs UMASK 값 수정"
    else
        echo "UMASK 022" >> "$LOGIN_DEFS"
        echo "[U-30] /etc/login.defs UMASK 추가"
    fi
else
    echo "[U-30][WARN] /etc/login.defs 파일 없음"
fi

echo "[U-30] 조치 완료"
exit 0

