#!/bin/bash

echo "[U-26] /dev 디렉터리 내 불필요 또는 존재하지 않는 파일 점검"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-26][ERROR] root 권한 필요"
    exit 1
fi

DEV_DIR="/dev"

#####################################
# /dev 파일 탐색
#####################################
mapfile -t DEV_FILES < <(find "$DEV_DIR" -type f 2>/dev/null)

if [ ${#DEV_FILES[@]} -eq 0 ]; then
    echo "[U-26] /dev 내 파일 없음"
else
    for file in "${DEV_FILES[@]}"; do
        # 파일 존재 여부 확인
        if [ ! -e "$file" ]; then
            echo "[U-26][WARN] 존재하지 않는 파일: $file"
            echo "수동으로 삭제 가능: rm $file"
        else
            # 필요 시 추가 로직으로 불필요 파일 판단 가능
            echo "[U-26] 점검: $file"
        fi
    done
fi

echo "[U-26] 조치 완료 (불필요 파일은 수동 삭제 권고)"
exit 0

