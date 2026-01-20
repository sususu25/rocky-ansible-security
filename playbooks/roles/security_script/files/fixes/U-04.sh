#!/bin/bash

echo "[U-04] /etc/passwd 및 shadow 적용 확인"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-04][ERROR] root 권한 필요"
    exit 1
fi

PASSWD_FILE="/etc/passwd"

#####################################
# Step 1: /etc/passwd 두 번째 필드 확인
#####################################
echo "[U-04] /etc/passwd 두 번째 필드 확인"

INVALID_USERS=0
while IFS=: read -r username passwd rest; do
    if [ "$passwd" != "x" ]; then
        echo "[U-04][WARN] 사용자 $username 의 두 번째 필드가 'x'가 아님: $passwd"
        INVALID_USERS=$((INVALID_USERS+1))
    fi
done < "$PASSWD_FILE"

if [ $INVALID_USERS -eq 0 ]; then
    echo "[U-04] 모든 사용자 패스워드 필드가 'x'로 설정됨"
else
    echo "[U-04] $INVALID_USERS 개 사용자 패스워드 필드 수정 필요"
fi

#####################################
# Step 2: pwconv 적용
#####################################
echo "[U-04] pwconv 명령으로 쉐도우 비밀번호 적용"
pwconv
if [ $? -eq 0 ]; then
    echo "[U-04] pwconv 적용 완료"
else
    echo "[U-04][ERROR] pwconv 적용 실패"
fi

echo "[U-04] 조치 완료"
exit 0

