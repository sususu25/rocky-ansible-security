#!/bin/bash

echo "[U-13] 암호화 알고리즘 적용"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-13][ERROR] root 권한 필요"
    exit 1
fi

SHADOW_FILE="/etc/shadow"
LOGIN_DEFS="/etc/login.defs"
SYSTEM_AUTH="/etc/pam.d/system-auth"

#####################################
# Step 1: /etc/shadow 암호화 확인
#####################################
echo "[U-13] /etc/shadow 암호화 확인"
WEAK_HASH=0
while IFS=: read -r username passwd rest; do
    # $1 = MD5, $5 = SHA-256, $6 = SHA-512
    if [[ "$passwd" =~ ^\$1\$ ]]; then
        echo "[U-13][WARN] 사용자 $username SHA-1(MD5) 사용: $passwd"
        WEAK_HASH=$((WEAK_HASH+1))
    fi
done < "$SHADOW_FILE"

if [ $WEAK_HASH -eq 0 ]; then
    echo "[U-13] 모든 사용자 SHA-2 이상 사용 중"
else
    echo "[U-13] SHA-1(MD5) 사용 계정 있음 → 암호 변경 필요"
fi

#####################################
# Step 2: /etc/login.defs ENCRYPT_METHOD 설정
#####################################
if [ -f "$LOGIN_DEFS" ]; then
    if grep -q '^ENCRYPT_METHOD' "$LOGIN_DEFS"; then
        sed -i 's|^ENCRYPT_METHOD.*|ENCRYPT_METHOD SHA512|' "$LOGIN_DEFS"
    else
        echo "ENCRYPT_METHOD SHA512" >> "$LOGIN_DEFS"
    fi
    echo "[U-13] /etc/login.defs ENCRYPT_METHOD=SHA512 적용 완료"
else
    echo "[U-13][WARN] /etc/login.defs 파일 없음"
fi

#####################################
# Step 3: /etc/pam.d/system-auth 패스워드 알고리즘 확인
#####################################
if [ -f "$SYSTEM_AUTH" ]; then
    if grep -q '^password.*pam_unix.so' "$SYSTEM_AUTH"; then
        sed -i 's|^\(password.*pam_unix.so.*\)|\1 sha512|' "$SYSTEM_AUTH"
        echo "[U-13] system-auth pam_unix.so SHA-512 적용 완료"
    else
        echo "password    sufficient    pam_unix.so sha512" >> "$SYSTEM_AUTH"
        echo "[U-13] system-auth pam_unix.so SHA-512 추가 완료"
    fi
else
    echo "[U-13][WARN] /etc/pam.d/system-auth 없음"
fi

echo "[U-13] 조치 완료"
exit 0

