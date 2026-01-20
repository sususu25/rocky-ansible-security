#!/bin/bash

echo "[U-15] 소유자/그룹이 없는 파일 및 디렉터리 점검"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-15][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# Step 1: 소유자/그룹 없는 파일 확인
#####################################
echo "[U-15] 소유자 또는 그룹이 존재하지 않는 파일/디렉터리 검색 중..."
find / \( -nouser -o -nogroup \) -xdev -print 2>/dev/null > /tmp/u15_invalid_files.txt

if [ ! -s /tmp/u15_invalid_files.txt ]; then
    echo "[U-15] 존재하지 않는 UID/GID 파일 없음"
else
    echo "[U-15][WARN] 소유자/그룹 없는 파일/디렉터리:"
    cat /tmp/u15_invalid_files.txt
fi

#####################################
# Step 2 & 3 안내
#####################################
echo "[U-15] 조치 방법 안내:"
echo "  - 사용하지 않는 파일/디렉터리: rm 또는 rm -r <파일/디렉터리>"
echo "  - 사용 중인 경우 소유자/그룹 변경: chown <사용자> <파일>, chgrp <그룹> <파일>"

echo "[U-15] 조치 완료"
exit 0

