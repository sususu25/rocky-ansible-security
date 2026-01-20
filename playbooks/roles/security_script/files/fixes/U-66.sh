#!/bin/bash

echo "[U-66] 로그 기록 정책(rsyslog) 점검 및 설정 시작"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-66][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# rsyslog 서비스 존재 여부 확인
#####################################
if ! systemctl list-unit-files | grep -q "^rsyslog.service"; then
    echo "[U-66] rsyslog 서비스 없음 → 미적용"
    exit 0
fi

RSYSLOG_STATE=$(systemctl is-active rsyslog 2>/dev/null)

if [ "$RSYSLOG_STATE" != "active" ]; then
    echo "[U-66] rsyslog 서비스 사용 중 아님 → 미적용"
    exit 0
fi

echo "[U-66] rsyslog 서비스 사용 중 (active)"

#####################################
# 설정 파일 결정
#####################################
CONF_FILE=""

if [ -f /etc/rsyslog.conf ]; then
    CONF_FILE="/etc/rsyslog.conf"
elif [ -f /etc/rsyslog.d/default.conf ]; then
    CONF_FILE="/etc/rsyslog.d/default.conf"
else
    echo "[U-66][WARN] rsyslog 설정 파일 없음 → 수동 확인 필요"
    exit 0
fi

echo "[U-66] 설정 파일 사용: $CONF_FILE"

#####################################
# 로그 정책 설정 (중복 방지)
#####################################
grep -q "^\*.info;mail.none;authpriv.none;cron.none" "$CONF_FILE" || \
echo "*.info;mail.none;authpriv.none;cron.none    /var/log/messages" >> "$CONF_FILE"

grep -q "^auth,authpriv\.\*" "$CONF_FILE" || \
echo "auth,authpriv.*    /var/log/secure" >> "$CONF_FILE"

grep -q "^mail\.\*" "$CONF_FILE" || \
echo "mail.*    /var/log/maillog" >> "$CONF_FILE"

grep -q "^cron\.\*" "$CONF_FILE" || \
echo "cron.*    /var/log/cron" >> "$CONF_FILE"

grep -q "^\*.alert" "$CONF_FILE" || \
echo "*.alert    /dev/console" >> "$CONF_FILE"

grep -q "^\*.emerg" "$CONF_FILE" || \
echo "*.emerg    *" >> "$CONF_FILE"

echo "[U-66] 로그 기록 정책 설정 완료"

#####################################
# 서비스 재시작
#####################################
systemctl restart rsyslog

if [ $? -eq 0 ]; then
    echo "[U-66] rsyslog 서비스 재시작 완료"
else
    echo "[U-66][ERROR] rsyslog 서비스 재시작 실패"
fi

echo "[U-66] 로그 기록 정책 점검 및 적용 완료"
exit 0

