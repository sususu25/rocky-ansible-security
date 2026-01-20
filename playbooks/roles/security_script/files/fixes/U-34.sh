#!/bin/bash

echo "[U-34] Finger 서비스 비활성화 (inetd/xinetd)"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-34][ERROR] root 권한 필요"
    exit 1
fi

#############################
# inetd 환경
#############################
INETD_CONF="/etc/inetd.conf"
if [ -f "$INETD_CONF" ]; then
    if grep -q -E "^[^#]*finger" "$INETD_CONF"; then
        sed -i 's/^[^#]*finger/#&/' "$INETD_CONF"
        echo "[U-34][inetd] /etc/inetd.conf Finger 서비스 주석 처리 완료"
        # inetd 재시작
        if command -v systemctl >/dev/null 2>&1; then
            systemctl restart inetd && echo "[U-34][inetd] inetd 서비스 재시작 완료"
        else
            service inetd restart && echo "[U-34][inetd] inetd 서비스 재시작 완료"
        fi
    else
        echo "[U-34][inetd] Finger 서비스 비활성화 이미 적용됨"
    fi
else
    echo "[U-34][inetd] /etc/inetd.conf 파일 없음"
fi

#############################
# xinetd 환경
#############################
XINETD_DIR="/etc/xinetd.d"
FINGER_XINETD="$XINETD_DIR/finger"

if [ -f "$FINGER_XINETD" ]; then
    if grep -q -E "^\s*disable\s*=\s*no" "$FINGER_XINETD"; then
        sed -i 's/^\(\s*disable\s*=\s*\)no/\1yes/' "$FINGER_XINETD"
        echo "[U-34][xinetd] Finger 서비스 disable=yes 적용"
        # xinetd 재시작
        if command -v systemctl >/dev/null 2>&1; then
            systemctl restart xinetd && echo "[U-34][xinetd] xinetd 서비스 재시작 완료"
        else
            service xinetd restart && echo "[U-34][xinetd] xinetd 서비스 재시작 완료"
        fi
    else
        echo "[U-34][xinetd] Finger 서비스 이미 비활성화됨"
    fi
else
    echo "[U-34][xinetd] /etc/xinetd.d/finger 파일 없음"
fi

echo "[U-34] 조치 완료"
exit 0

