#!/bin/bash

echo "[U-35] 익명 FTP/NFS/Samba 접근 비활성화"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-35][ERROR] root 권한 필요"
    exit 1
fi

#############################
# FTP 계정 제거
#############################
for ftp_user in ftp anonymous; do
    if id "$ftp_user" >/dev/null 2>&1; then
        userdel "$ftp_user" && echo "[U-35][FTP] 사용자 $ftp_user 제거 완료"
    else
        echo "[U-35][FTP] 사용자 $ftp_user 없음"
    fi
done

#############################
# vsFTPd 익명 접근 비활성화
#############################
VSFTPD_CONF=""
if [ -f /etc/vsftpd.conf ]; then
    VSFTPD_CONF="/etc/vsftpd.conf"
elif [ -f /etc/vsftpd/vsftpd.conf ]; then
    VSFTPD_CONF="/etc/vsftpd/vsftpd.conf"
fi

if [ -n "$VSFTPD_CONF" ]; then
    if grep -q "^anonymous_enable=YES" "$VSFTPD_CONF"; then
        sed -i 's/^anonymous_enable=YES/anonymous_enable=NO/' "$VSFTPD_CONF"
        echo "[U-35][vsFTPd] anonymous_enable=NO 적용"
        systemctl restart vsftpd && echo "[U-35][vsFTPd] 서비스 재시작 완료"
    else
        echo "[U-35][vsFTPd] Anonymous FTP 이미 비활성화됨"
    fi
else
    echo "[U-35][vsFTPd] 설정 파일 없음"
fi

#############################
# ProFTP 익명 접근 비활성화
#############################
PROFTPD_CONF=""
if [ -f /etc/proftpd.conf ]; then
    PROFTPD_CONF="/etc/proftpd.conf"
elif [ -f /etc/proftpd/proftpd.conf ]; then
    PROFTPD_CONF="/etc/proftpd/proftpd.conf"
fi

if [ -n "$PROFTPD_CONF" ]; then
    if grep -q "<Anonymous" "$PROFTPD_CONF"; then
        sed -i '/<Anonymous/,/<\/Anonymous>/ s/^/#/' "$PROFTPD_CONF"
        echo "[U-35][ProFTP] Anonymous 섹션 주석 처리 완료"
        systemctl restart proftpd && echo "[U-35][ProFTP] 서비스 재시작 완료"
    else
        echo "[U-35][ProFTP] Anonymous FTP 이미 비활성화됨"
    fi
else
    echo "[U-35][ProFTP] 설정 파일 없음"
fi

#############################
# NFS 익명 접근 비활성화
#############################
EXPORTS_FILE="/etc/exports"
if [ -f "$EXPORTS_FILE" ]; then
    if grep -q -E "anonuid|anongid" "$EXPORTS_FILE"; then
        sed -i -E 's/(anonuid|anongid)=[0-9]+//g' "$EXPORTS_FILE"
        echo "[U-35][NFS] anon 옵션 제거 완료"
        exportfs -ra && echo "[U-35][NFS] exportfs 적용 완료"
    else
        echo "[U-35][NFS] 익명 접근 설정 없음"
    fi
else
    echo "[U-35][NFS] /etc/exports 파일 없음"
fi

#############################
# Samba 익명 접근 비활성화
#############################
SAMBA_CONF="/etc/samba/smb.conf"
if [ -f "$SAMBA_CONF" ]; then
    if grep -q "guest ok\s*=\s*yes" "$SAMBA_CONF"; then
        sed -i 's/guest ok\s*=\s*yes/guest ok = no/i' "$SAMBA_CONF"
        echo "[U-35][Samba] guest ok=no 적용"
        smbcontrol all reload-config && echo "[U-35][Samba] 설정 적용 완료"
    else
        echo "[U-35][Samba] 익명 접근 이미 비활성화됨"
    fi
else
    echo "[U-35][Samba] /etc/samba/smb.conf 파일 없음"
fi

echo "[U-35] 조치 완료"
exit 0

