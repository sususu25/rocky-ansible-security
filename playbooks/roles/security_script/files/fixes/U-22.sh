#!/bin/bash

echo "[U-22] SUID/SGID 파일 점검 및 권한 조치"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-22][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# Step 1: SUID / SGID 파일 확인
#####################################
echo "[U-22] SUID/SGID 파일 검색 (루트 소유)"
SUID_SGID_FILES=$(find / -xdev -user root -type f \( -perm -04000 -o -perm -02000 \) 2>/dev/null)

if [ -z "$SUID_SGID_FILES" ]; then
    echo "[U-22] SUID/SGID 파일 없음"
    exit 0
fi

echo "$SUID_SGID_FILES" | while read -r file; do
    PERM=$(stat -c "%a" "$file")
    echo "[U-22] 점검: $file 권한 $PERM"

    # Step 2: 불필요한 특수 권한 제거
    # 기본 정책: 일반 사용자가 필요 없는 SUID/SGID는 제거
    # ※ 실제로 필요 없는 파일 목록은 환경별 판단 필요
    if [ "$file" != "/usr/bin/sudo" ] && [ "$file" != "/usr/bin/passwd" ]; then
        chmod u-s,g-s "$file"
        echo "[U-22][FIX] $file SUID/SGID 제거"
    fi

    # Step 3: 꼭 필요한 경우 특정 그룹 제한 (예시: wheel)
    # sudo, passwd 등 root 관리용 파일
    if [ "$file" == "/usr/bin/sudo" ] || [ "$file" == "/usr/bin/passwd" ]; then
        chgrp wheel "$file"
        chmod 4750 "$file"
        echo "[U-22][FIX] $file SUID 유지, wheel 그룹만 사용 가능"
    fi
done

echo "[U-22] 조치 완료"
exit 0

