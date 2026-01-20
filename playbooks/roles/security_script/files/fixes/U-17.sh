#!/bin/bash

echo "[U-17] 시스템 시작 스크립트 소유자 및 권한 점검"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-17][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# init 방식 (/etc/rc.d)
#####################################
if [ -d /etc/rc.d ]; then
    echo "[U-17] init 방식 시스템 스크립트 점검"

    INIT_FILES=$(readlink -f /etc/rc.d/*/* 2>/dev/null | sed 's/$/*/')

    for file in $INIT_FILES; do
        [ -e "$file" ] || continue

        OWNER=$(stat -c "%U" "$file")
        PERM=$(stat -c "%A" "$file")

        # 소유자 root 아니면 변경
        if [ "$OWNER" != "root" ]; then
            chown root "$file"
            echo "[U-17][FIX] $file 소유자 root로 변경"
        fi

        # others 쓰기 권한 있으면 제거
        if echo "$PERM" | grep -q "w$"; then
            chmod o-w "$file"
            echo "[U-17][FIX] $file other 쓰기 권한 제거"
        fi
    done
fi

#####################################
# systemd 방식
#####################################
if [ -d /etc/systemd/system ]; then
    echo "[U-17] systemd 방식 시스템 스크립트 점검"

    SYSTEMD_FILES=$(readlink -f /etc/systemd/system/* 2>/dev/null | sed 's/$/*/')

    for file in $SYSTEMD_FILES; do
        [ -e "$file" ] || continue

        OWNER=$(stat -c "%U" "$file")
        PERM=$(stat -c "%A" "$file")

        # 소유자 root 아니면 변경
        if [ "$OWNER" != "root" ]; then
            chown root "$file"
            echo "[U-17][FIX] $file 소유자 root로 변경"
        fi

        # others 쓰기 권한 있으면 제거
        if echo "$PERM" | grep -q "w$"; then
            chmod o-w "$file"
            echo "[U-17][FIX] $file other 쓰기 권한 제거"
        fi
    done
fi

echo "[U-17] 조치 완료"
exit 0

