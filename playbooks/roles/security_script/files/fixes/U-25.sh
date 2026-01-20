#!/bin/bash

echo "[U-25] 일반 사용자(others) 쓰기 권한 파일 점검 및 조치"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-25][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# world writable 파일 탐색
#####################################
mapfile -t WW_FILES < <(find / -xdev -type f -perm -2 2>/dev/null)

if [ ${#WW_FILES[@]} -eq 0 ]; then
    echo "[U-25] world writable 파일 없음"
else
    for file in "${WW_FILES[@]}"; do
        echo "[U-25] 점검: $file"

        #################################
        # others 쓰기권한 제거
        #################################
        chmod o-w "$file"
        if [ $? -eq 0 ]; then
            echo "[U-25][FIX] $file others 쓰기권한 제거"
        else
            echo "[U-25][WARN] $file 권한 제거 실패"
        fi
    done
fi

echo "[U-25] 조치 완료"
exit 0

