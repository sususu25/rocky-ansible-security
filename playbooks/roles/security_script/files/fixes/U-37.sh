#!/bin/bash

echo "[U-37] crontab, cron, at 파일 소유자 및 권한 점검/조치"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-37][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# SUID 제거 및 소유자/권한 설정 함수
#####################################
set_owner_perm() {
    local file="$1"
    local owner="$2"
    local perm="$3"
    if [ -f "$file" ]; then
        chown "$owner" "$file"
        chmod "$perm" "$file"
        echo "[U-37] $file 소유자=$owner, 권한=$perm 적용"
    fi
}

#####################################
# Step 1: crontab 관련
#####################################
CRONTAB_BIN="/usr/bin/crontab"
CRON_SPOOL="/var/spool/cron"
CRON_SPOOL_ALT="/var/spool/cron/crontabs"
CRON_ETC_FILES=("/etc/crontab" "/etc/cron.allow" "/etc/cron.deny")

# crontab 실행 파일 SUID 제거, 소유자 root, 권한 750
if [ -f "$CRONTAB_BIN" ]; then
    chmod u-s "$CRONTAB_BIN"
    chown root "$CRONTAB_BIN"
    chmod 750 "$CRONTAB_BIN"
    echo "[U-37] crontab 실행 파일 SUID 제거 및 권한 설정 완료"
fi

# cron 작업 목록 파일 소유자 root, 권한 640
for file in "$CRON_SPOOL"/* "$CRON_SPOOL_ALT"/*; do
    [ -f "$file" ] || continue
    set_owner_perm "$file" root 640
done

# cron 관련 파일 소유자 root, 권한 640
for file in "${CRON_ETC_FILES[@]}"; do
    [ -f "$file" ] || continue
    set_owner_perm "$file" root 640
done

#####################################
# Step 2: at 관련
#####################################
AT_BIN="/usr/bin/at"
AT_SPOOL="/var/spool/at"
AT_SPOOL_ALT="/var/spool/cron/atjobs"

# at 실행 파일 SUID 제거, 소유자 root, 권한 750
if [ -f "$AT_BIN" ]; then
    chmod u-s "$AT_BIN"
    chown root "$AT_BIN"
    chmod 750 "$AT_BIN"
    echo "[U-37] at 실행 파일 SUID 제거 및 권한 설정 완료"
fi

# at 작업 목록 파일 소유자 root, 권한 640
for file in "$AT_SPOOL"/* "$AT_SPOOL_ALT"/*; do
    [ -f "$file" ] || continue
    set_owner_perm "$file" root 640
done

echo "[U-37] crontab, cron, at 파일 소유자 및 권한 조치 완료"
exit 0

