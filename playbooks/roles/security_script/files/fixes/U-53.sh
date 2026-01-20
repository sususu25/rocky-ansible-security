#!/bin/bash
echo "[U-53] FTP 서비스 배너 점검 및 설정"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-53][ERROR] root 권한 필요"
    exit 1
fi

################################
# vsFTP 배너 점검
################################
VSFTP_CONF=""
if [ -f /etc/vsftpd.conf ]; then
    VSFTP_CONF="/etc/vsftpd.conf"
elif [ -f /etc/vsftpd/vsftpd.conf ]; then
    VSFTP_CONF="/etc/vsftpd/vsftpd.conf"
fi

if [ -n "$VSFTP_CONF" ]; then
    echo "[U-53] vsFTP 설정 파일: $VSFTP_CONF"
    grep -q "^ftpd_banner" "$VSFTP_CONF"
    if [ $? -eq 0 ]; then
        echo "[U-53] ftpd_banner 이미 설정됨:"
        grep "^ftpd_banner" "$VSFTP_CONF"
    else
        echo "[U-53] ftpd_banner 미설정 → 기본 배너 설정"
        echo "ftpd_banner=Welcome to Secure FTP Server" >> "$VSFTP_CONF"
        systemctl restart vsftpd
        echo "[U-53] vsFTP 서비스 재시작 완료"
    fi
else
    echo "[U-53] vsFTP 설정 파일 없음"
fi

################################
# ProFTP 배너 점검
################################
PROFTP_CONF=""
if [ -f /etc/proftpd.conf ]; then
    PROFTP_CONF="/etc/proftpd.conf"
elif [ -f /etc/proftpd/proftpd.conf ]; then
    PROFTP_CONF="/etc/proftpd/proftpd.conf"
fi

if [ -n "$PROFTP_CONF" ]; then
    echo "[U-53] ProFTP 설정 파일: $PROFTP_CONF"
    grep -q "^ServerIdent" "$PROFTP_CONF"
    if [ $? -eq 0 ]; then
        echo "[U-53] ServerIdent 이미 설정됨:"
        grep "^ServerIdent" "$PROFTP_CONF"
    else
        echo "[U-53] ServerIdent 미설정 → 기본 배너 설정"
        echo "ServerIdent off" >> "$PROFTP_CONF"
        systemctl restart proftpd
        echo "[U-53] ProFTP 서비스 재시작 완료"
    fi
else
    echo "[U-53] ProFTP 설정 파일 없음"
fi

echo "[U-53] 점검 및 배너 설정 완료"
exit 0

