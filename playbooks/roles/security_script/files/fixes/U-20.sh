#!/bin/bash

echo "[U-20] inetd / xinetd / systemd 설정 파일 권한 점검"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-20][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# [inetd]
#####################################
INETD_CONF="/etc/inetd.conf"

if [ -f "$INETD_CONF" ]; then
    OWNER=$(stat -c "%U" "$INETD_CONF")
    PERM=$(stat -c "%a" "$INETD_CONF")

    [ "$OWNER" != "root" ] && chown root "$INETD_CONF" && echo "[U-20][FIX][inetd] 소유자 root 변경"
    [ "$PERM" != "600" ] && chmod 600 "$INETD_CONF" && echo "[U-20][FIX][inetd] 권한 600 변경"

    echo "[U-20][inetd] 점검 완료"
fi

#####################################
# [xinetd]
#####################################
XINETD_CONF="/etc/xinetd.conf"
XINETD_DIR="/etc/xinetd.d"

if [ -f "$XINETD_CONF" ]; then
    OWNER=$(stat -c "%U" "$XINETD_CONF")
    PERM=$(stat -c "%a" "$XINETD_CONF")

    [ "$OWNER" != "root" ] && chown root "$XINETD_CONF" && echo "[U-20][FIX][xinetd] xinetd.conf 소유자 root 변경"
    [ "$PERM" != "600" ] && chmod 600 "$XINETD_CONF" && echo "[U-20][FIX][xinetd] xinetd.conf 권한 600 변경"
fi

if [ -d "$XINETD_DIR" ]; then
    chown -R root "$XINETD_DIR"
    chmod -R 600 "$XINETD_DIR"
    echo "[U-20][FIX][xinetd] /etc/xinetd.d 디렉터리 전체 권한 조치"
fi

#####################################
# [systemd]
#####################################
SYSTEMD_CONF="/etc/systemd/system.conf"
SYSTEMD_DIR="/etc/systemd"

if [ -f "$SYSTEMD_CONF" ]; then
    OWNER=$(stat -c "%U" "$SYSTEMD_CONF")
    PERM=$(stat -c "%a" "$SYSTEMD_CONF")

    [ "$OWNER" != "root" ] && chown root "$SYSTEMD_CONF" && echo "[U-20][FIX][systemd] system.conf 소유자 root 변경"
    [ "$PERM" != "600" ] && chmod 600 "$SYSTEMD_CONF" && echo "[U-20][FIX][systemd] system.conf 권한 600 변경"
fi

if [ -d "$SYSTEMD_DIR" ]; then
    chown -R root "$SYSTEMD_DIR"
    chmod -R 600 "$SYSTEMD_DIR"
    echo "[U-20][FIX][systemd] /etc/systemd 디렉터리 전체 권한 조치"
fi

echo "[U-20] 조치 완료"
exit 0

