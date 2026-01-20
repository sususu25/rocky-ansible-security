#!/bin/bash
echo "[U-54] 불필요한 FTP 서비스 비활성화"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-54][ERROR] root 권한 필요"
    exit 1
fi

####################################
# inetd 방식 FTP 비활성화
####################################
if [ -f /etc/inetd.conf ]; then
    if grep -E "^[^#].*in.ftpd" /etc/inetd.conf >/dev/null; then
        sed -i 's/^[^#].*in.ftpd/#&/' /etc/inetd.conf
        echo "[U-54] inetd FTP 서비스 주석 처리 완료"
        systemctl restart inetd 2>/dev/null || service inetd restart 2>/dev/null
    else
        echo "[U-54] inetd FTP 서비스 비활성 또는 없음"
    fi
else
    echo "[U-54] inetd 설정 파일 없음"
fi

####################################
# xinetd 방식 FTP 비활성화
####################################
if [ -f /etc/xinetd.d/ftp ]; then
    if grep -q "disable *= *no" /etc/xinetd.d/ftp; then
        sed -i 's/disable *= *no/disable = yes/' /etc/xinetd.d/ftp
        systemctl restart xinetd
        echo "[U-54] xinetd FTP 서비스 비활성화 완료"
    else
        echo "[U-54] xinetd FTP 이미 비활성 상태"
    fi
else
    echo "[U-54] xinetd FTP 설정 파일 없음"
fi

####################################
# vsFTP 비활성화
####################################
if systemctl list-unit-files | grep -q "^vsftpd.service"; then
    systemctl stop vsftpd 2>/dev/null
    systemctl disable vsftpd 2>/dev/null
    echo "[U-54] vsftpd 서비스 중지 및 비활성화 완료"
else
    echo "[U-54] vsftpd 서비스 없음"
fi

####################################
# ProFTP 비활성화
####################################
if systemctl list-unit-files | grep -q "^proftpd.service"; then
    systemctl stop proftpd 2>/dev/null
    systemctl disable proftpd 2>/dev/null
    echo "[U-54] proftpd 서비스 중지 및 비활성화 완료"
else
    echo "[U-54] proftpd 서비스 없음"
fi

echo "[U-54] FTP 서비스 점검 및 비활성화 완료"
exit 0

