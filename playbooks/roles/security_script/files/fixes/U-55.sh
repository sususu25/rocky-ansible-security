#!/bin/bash
echo "[U-55] FTP 계정 로그인 제한 설정"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-55][ERROR] root 권한 필요"
    exit 1
fi

####################################
# ftp 계정 존재 여부 확인
####################################
if ! id ftp &>/dev/null; then
    echo "[U-55] ftp 계정이 존재하지 않음 (조치 불필요)"
    exit 0
fi

####################################
# ftp 계정 로그인 쉘 확인
####################################
CURRENT_SHELL=$(getent passwd ftp | cut -d: -f7)
echo "[U-55] 현재 ftp 로그인 쉘: $CURRENT_SHELL"

####################################
# 로그인 가능한 쉘일 경우만 변경
####################################
if [[ "$CURRENT_SHELL" == "/bin/bash" || "$CURRENT_SHELL" == "/bin/sh" || "$CURRENT_SHELL" == "/usr/bin/bash" ]]; then
    if [ -x /sbin/nologin ]; then
        usermod -s /sbin/nologin ftp
        echo "[U-55] ftp 계정 로그인 쉘을 /sbin/nologin 으로 변경"
    else
        usermod -s /bin/false ftp
        echo "[U-55] ftp 계정 로그인 쉘을 /bin/false 로 변경"
    fi
else
    echo "[U-55] ftp 계정은 이미 로그인 불가 쉘로 설정됨"
fi

####################################
# 결과 확인
####################################
getent passwd ftp

echo "[U-55] FTP 계정 로그인 제한 설정 완료"
exit 0

