#!/bin/bash

echo "[U-23] SUID / SGID 설정 파일 점검 및 조치"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-23][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# find 명령어 존재 여부 확인
#####################################
if ! command -v find >/dev/null 2>&1; then
    echo "[U-23][ERROR] find 명령어 없음 (findutils 미설치)"
    echo "[U-23][RESULT] 점검 불가"
    exit 2
fi

#####################################
# 점검 대상 경로 정의
# (사용자 생성 가능 영역만 조치)
#####################################
TARGET_PATHS=(
    /usr/local
    /home
    /tmp
    /var/tmp
)

#####################################
# SUID / SGID 파일 탐색
#####################################
FOUND=false

for path in "${TARGET_PATHS[@]}"; do
    [ -d "$path" ] || continue

    while IFS= read -r file; do
        FOUND=true
        echo "[U-23][CHECK] $file"

        chmod -s "$file"
        echo "[U-23][FIX] $file → SUID/SGID 제거"

    done < <(
        find "$path" -xdev -type f \( -perm -04000 -o -perm -02000 \) 2>/dev/null
    )
done

#####################################
# 점검 결과 판단
#####################################
if [ "$FOUND" = false ]; then
    echo "[U-23][RESULT] 사용자 영역 내 불필요한 SUID/SGID 파일 없음 (양호)"
else
    echo "[U-23][RESULT] 불필요한 SUID/SGID 파일 조치 완료"
fi

#####################################
# su 명령어 추가 보호 (필수)
#####################################
if [ -f /usr/bin/su ]; then
    chgrp wheel /usr/bin/su 2>/dev/null
    chmod 4750 /usr/bin/su
    echo "[U-23][HARDEN] /usr/bin/su → wheel + 4750"
fi

echo "[U-23] 점검 및 조치 완료"
exit 0

