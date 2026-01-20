#!/bin/bash

echo "[U-21] syslog / rsyslog 설정 파일 권한 점검"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-21][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# 대상 파일 정의
#####################################
SYSLOG_CONF="/etc/syslog.conf"
RSYSLOG_CONF="/etc/rsyslog.conf"

#####################################
# syslog.conf
#####################################
if [ -f "$SYSLOG_CONF" ]; then
    OWNER=$(stat -c "%U" "$SYSLOG_CONF")
    PERM=$(stat -c "%a" "$SYSLOG_CONF")

    [ "$OWNER" != "root" ] && chown root "$SYSLOG_CONF" && echo "[U-21][FIX] syslog.conf 소유자 root 변경"
    [ "$PERM" != "640" ] && chmod 640 "$SYSLOG_CONF" && echo "[U-21][FIX] syslog.conf 권한 640 변경"

    echo "[U-21] /etc/syslog.conf 점검 완료"
fi

#####################################
# rsyslog.conf
#####################################
if [ -f "$RSYSLOG_CONF" ]; then
    OWNER=$(stat -c "%U" "$RSYSLOG_CONF")
    PERM=$(stat -c "%a" "$RSYSLOG_CONF")

    [ "$OWNER" != "root" ] && chown root "$RSYSLOG_CONF" && echo "[U-21][FIX] rsyslog.conf 소유자 root 변경"
    [ "$PERM" != "640" ] && chmod 640 "$RSYSLOG_CONF" && echo "[U-21][FIX] rsyslog.conf 권한 640 변경"

    echo "[U-21] /etc/rsyslog.conf 점검 완료"
fi

echo "[U-21] 조치 완료"
exit 0

