#!/bin/bash

echo "[U-67] 로그 파일 소유자 및 권한 점검 및 설정 시작"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-67][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# /var/log 디렉터리 확인
#####################################
if [ ! -d /var/log ]; then
    echo "[U-67][WARN] /var/log 디렉터리 없음 → 점검 불가"
    exit 0
fi

#####################################
# 점검 대상 로그 파일
#####################################
LOG_FILES=(
    /var/log/messages
    /var/log/secure
    /var/log/maillog
    /var/log/cron
    /var/log/syslog
    /var/log/btmp
    /var/log/wtmp
    /var/log/lastlog
)

#####################################
# 점검 및 조치
#####################################
for LOG in "${LOG_FILES[@]}"; do
    if [ -f "$LOG" ]; then
        OWNER=$(stat -c "%U:%G" "$LOG")
        PERM=$(stat -c "%a" "$LOG")

        if [ "$OWNER" != "root:root" ] || [ "$PERM" -gt 644 ]; then
            chown root:root "$LOG"
            chmod 644 "$LOG"
            echo "[U-67][FIX] $LOG → owner=root:root, perm=644 적용"
        else
            echo "[U-67][OK] $LOG → 이미 기준 충족 (owner=$OWNER, perm=$PERM)"
        fi
    else
        echo "[U-67][INFO] 파일 없음 → 점검 대상 아님: $LOG"
    fi
done

echo "[U-67] 로그 파일 소유자 및 권한 점검 및 설정 완료"
exit 0

