#!/bin/bash

echo "[U-11] 로그인 불필요한 계정 쉘 제한"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-11][ERROR] root 권한 필요"
    exit 1
fi

# 로그인 불필요한 계정 목록
ACCOUNTS=(daemon bin sys adm listen nobody nobody4 noaccess diag operator games gopher)

for user in "${ACCOUNTS[@]}"; do
    if id "$user" >/dev/null 2>&1; then
        SHELL=$(getent passwd "$user" | cut -d: -f7)
        if [[ "$SHELL" != "/sbin/nologin" && "$SHELL" != "/bin/false" ]]; then
            echo "[U-11][WARN] $user 쉘이 $SHELL → /sbin/nologin 으로 변경"
            usermod -s /sbin/nologin "$user"
        else
            echo "[U-11] $user 쉘 정상 ($SHELL)"
        fi
    else
        echo "[U-11] $user 계정 없음"
    fi
done

echo "[U-11] 적용 완료"
exit 0

