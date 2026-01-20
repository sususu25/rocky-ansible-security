#!/bin/bash
echo "[U-57] FTP root 계정 접근 제한 설정"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-57][ERROR] root 권한 필요"
    exit 1
fi

####################################
# 1. 일반 ftpusers 파일
####################################
FTPUSERS_FILES=(
    "/etc/ftpusers"
    "/etc/ftpd/ftpusers"
    "/etc/vsftpd.ftpusers"
    "/etc/vsftpd/ftpusers"
)

for FILE in "${FTPUSERS_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo "[U-57] 처리 중: $FILE"
        # root 계정 주석 제거 또는 추가 (없으면 추가)
        if ! grep -q "^root" "$FILE"; then
            echo "root" >> "$FILE"
            echo "[U-57] root 계정 추가"
        else
            # 주석 처리 제거
            sed -i 's/^#root/root/' "$FILE"
            echo "[U-57] root 계정 주석 제거"
        fi
    fi
done

####################################
# 2. vsftpd user_list 방식
####################################
VSFTPD_CONF=(
    "/etc/vsftpd.conf"
    "/etc/vsftpd/vsftpd.conf"
)

for CONF in "${VSFTPD_CONF[@]}"; do
    if [ -f "$CONF" ]; then
        USERLIST_ENABLE=$(grep -i "^userlist_enable" "$CONF" | awk -F= '{print $2}' | tr -d ' ')
        USERLIST_DENY=$(grep -i "^userlist_deny" "$CONF" | awk -F= '{print $2}' | tr -d ' ')
        if [ "$USERLIST_ENABLE" == "YES" ] && [ "$USERLIST_DENY" == "yes" ]; then
            for FILE in /etc/vsftpd.user_list /etc/vsftpd/user_list; do
                if [ -f "$FILE" ]; then
                    if ! grep -q "^root" "$FILE"; then
                        echo "root" >> "$FILE"
                        echo "[U-57] vsftpd user_list root 계정 차단 적용: $FILE"
                    fi
                fi
            done
        fi
    fi
done

####################################
# 3. ProFTP 설정
####################################
PROFTPD_CONF=(
    "/etc/proftpd.conf"
    "/etc/proftpd/proftpd.conf"
)

for CONF in "${PROFTPD_CONF[@]}"; do
    if [ -f "$CONF" ]; then
        USEFTPUSERS=$(grep -i "^UseFtpUsers" "$CONF" | awk '{print $2}')
        if [ "$USEFTPUSERS" == "on" ]; then
            FTPUSERS_FILE="/etc/ftpusers"
            [ -f "$FTPUSERS_FILE" ] && sed -i 's/^#root/root/' "$FTPUSERS_FILE"
        elif [ "$USEFTPUSERS" == "off" ]; then
            # RootLogin 설정
            if grep -q -i "^RootLogin" "$CONF"; then
                sed -i 's/^RootLogin.*/RootLogin off/' "$CONF"
            else
                echo "RootLogin off" >> "$CONF"
            fi
            systemctl restart proftpd
            echo "[U-57] ProFTP RootLogin off 적용 및 서비스 재시작: $CONF"
        fi
    fi
done

echo "[U-57] FTP root 접근 제한 완료"
exit 0

