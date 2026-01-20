#!/bin/bash

echo "[U-31-ROLLBACK] 시스템 계정 홈 디렉토리 원복"

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] root 권한 필요"
    exit 1
fi

PASSWD_FILE="/etc/passwd"

while IFS=: read -r user _ uid _ _ home shell; do
    # 홈이 / 이거나 존재하지 않으면 스킵
    if [ "$home" = "/" ] || [ ! -d "$home" ]; then
        continue
    fi

    # nobody 계정만 원복
    if [ "$user" = "nobody" ]; then
        chown root:root "$home"
        chmod 755 "$home"
        echo "[ROLLBACK] nobody 홈 원복: $home"
    fi
done < "$PASSWD_FILE"

echo "[U-31-ROLLBACK] 완료"
exit 0

