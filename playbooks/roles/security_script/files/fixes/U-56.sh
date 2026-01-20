#!/bin/bash
echo "[U-56] FTP 접근 제한 파일 소유자 및 권한 설정"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-56][ERROR] root 권한 필요"
    exit 1
fi

####################################
# 1. 공통 ftpusers 파일 (일반 FTP / ProFTP)
####################################
FTPUSERS_FILES=(
    "/etc/ftpusers"
    "/etc/ftpd/ftpusers"
)

for FILE in "${FTPUSERS_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo "[U-56] 처리 중: $FILE"
        chown root "$FILE"
        chmod 640 "$FILE"
    fi
done

####################################
# 2. vsftpd - ftpusers 방식
####################################
VSFTPD_CONF=(
    "/etc/vsftpd.conf"
    "/etc/vsftpd/vsftpd.conf"
)

for CONF in "${VSFTPD_CONF[@]}"; do
    if [ -f "$CONF" ]; then
        USERLIST_ENABLE=$(grep -i "^userlist_enable" "$CONF" | awk -F= '{print $2}' | tr -d ' ')
        if [ "$USERLIST_ENABLE" == "NO" ]; then
            echo "[U-56] vsftpd ftpusers 방식 사용 ($CONF)"
            for FILE in /etc/vsftpd.ftpusers /etc/vsftpd/ftpusers; do
                if [ -f "$FILE" ]; then
                    chown root "$FILE"
                    chmod 640 "$FILE"
                fi
            done
        fi
    fi
done

####################################
# 3. vsftpd - user_list 방식
####################################
for CONF in "${VSFTPD_CONF[@]}"; do
    if [ -f "$CONF" ]; then
        USERLIST_ENABLE=$(grep -i "^userlist_enable" "$CONF" | awk -F= '{print $2}' | tr -d ' ')
        if [ "$USERLIST_ENABLE" == "YES" ]; then
            echo "[U-56] vsftpd user_list 방식 사용 ($CONF)"
            for FILE in /etc/vsftpd.user_list /etc/vsftpd/user_list; do
                if [ -f "$FILE" ]; then
                    chown root "$FILE"
                    chmod 640 "$FILE"
                fi
            done
        fi
    fi
done

####################################
# 4. ProFTP 설정 파일 권한
####################################
PROFTPD_CONF=(
    "/etc/proftpd.conf"
    "/etc/proftpd/proftpd.conf"
)

for CONF in "${PROFTPD_CONF[@]}"; do
    if [ -f "$CONF" ]; then
        echo "[U-56] ProFTP 설정 파일 권한 설정: $CONF"
        chown root "$CONF"
        chmod 640 "$CONF"
    fi
done

echo "[U-56] FTP 접근 제한 파일 권한 설정 완료"
exit 0

