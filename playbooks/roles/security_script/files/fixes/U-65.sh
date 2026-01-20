#!/bin/bash

echo "[U-65] 시간 동기화(NTP/Chrony) 서비스 점검 시작"

############################
# Chrony (RHEL8+/Rocky)
############################
if systemctl list-unit-files | grep -q "^chronyd.service"; then
    CHRONY_STATE=$(systemctl is-active chronyd 2>/dev/null)

    echo "[U-65] Chrony 서비스 존재 확인"

    if [ "$CHRONY_STATE" = "active" ]; then
        echo "[U-65] Chrony 서비스 사용 중 (active)"

        echo "[U-65] Chrony 동기화 서버 확인"
        chronyc sources 2>/dev/null

        # 설정 파일 존재 시만 처리
        if [ -f /etc/chrony.conf ]; then
            echo "[U-65] /etc/chrony.conf 설정 파일 존재"
            echo "[U-65] NTP 서버 설정 여부 수동 확인 필요"
        fi

    else
        echo "[U-65] Chrony 서비스 존재하나 사용 중 아님 → 미적용"
    fi

############################
# NTP (구버전)
############################
elif systemctl list-unit-files | grep -q "^ntpd.service"; then
    NTP_STATE=$(systemctl is-active ntpd 2>/dev/null)

    echo "[U-65] NTP 서비스 존재 확인"

    if [ "$NTP_STATE" = "active" ]; then
        echo "[U-65] NTP 서비스 사용 중 (active)"

        echo "[U-65] NTP 동기화 서버 확인"
        ntpq -pn 2>/dev/null

        if [ -f /etc/ntp.conf ]; then
            echo "[U-65] /etc/ntp.conf 설정 파일 존재"
            echo "[U-65] NTP 서버 설정 여부 수동 확인 필요"
        fi

    else
        echo "[U-65] NTP 서비스 존재하나 사용 중 아님 → 미적용"
    fi

else
    echo "[U-65] NTP/Chrony 서비스 미설치 또는 미사용 → 미적용"
fi

echo "[U-65] 시간 동기화 서비스 점검 완료"
exit 0

