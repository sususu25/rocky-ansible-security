#!/bin/bash

echo "[U-27] hosts.equiv / .rhosts 신뢰 관계 설정 점검"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-27][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# 1. /etc/hosts.equiv 점검
#####################################
HOSTS_EQUIV="/etc/hosts.equiv"

if [ -f "$HOSTS_EQUIV" ]; then
    echo "[U-27] $HOSTS_EQUIV 존재"

    chown root "$HOSTS_EQUIV"
    chmod 600 "$HOSTS_EQUIV"

    if grep -q '^[[:space:]]*+' "$HOSTS_EQUIV"; then
        sed -i '/^[[:space:]]*+/d' "$HOSTS_EQUIV"
        echo "[U-27] $HOSTS_EQUIV 내 '+' 옵션 제거 완료"
    else
        echo "[U-27] $HOSTS_EQUIV 내 '+' 옵션 없음"
    fi
else
    echo "[U-27] $HOSTS_EQUIV 파일 없음"
fi

#####################################
# 2. 사용자 .rhosts 점검
#####################################
while IFS=: read -r user _ uid _ home _; do
    # 시스템 계정 제외
    [ "$uid" -lt 1000 ] && continue
    [ ! -d "$home" ] && continue

    RH_FILE="$home/.rhosts"

    if [ -f "$RH_FILE" ]; then
        echo "[U-27] $RH_FILE 점검"

        chown "$user":"$user" "$RH_FILE"
        chmod 600 "$RH_FILE"

        if grep -q '^[[:space:]]*+' "$RH_FILE"; then
            sed -i '/^[[:space:]]*+/d' "$RH_FILE"
            echo "[U-27] $RH_FILE 내 '+' 옵션 제거 완료"
        else
            echo "[U-27] $RH_FILE 내 '+' 옵션 없음"
        fi
    fi
done < /etc/passwd

echo "[U-27] 조치 완료"
exit 0

