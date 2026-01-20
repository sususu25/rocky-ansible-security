#!/bin/bash

echo "[U-12] 세션 자동 로그아웃 및 기본 umask 설정"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-12][ERROR] root 권한 필요"
    exit 1
fi

############################
# Bourne 계열 셸 (sh, ksh, bash)
############################
PROFILE_FILE="/etc/profile"

if [ -f "$PROFILE_FILE" ]; then
    # 기존 TMOUT / umask 제거
    sed -i '/^TMOUT=/d' "$PROFILE_FILE"
    sed -i '/^export TMOUT/d' "$PROFILE_FILE"

    # 새 설정 추가 (주석 없음)
    echo "TMOUT=600" >> "$PROFILE_FILE"
    echo "export TMOUT" >> "$PROFILE_FILE"

    echo "[U-12] /etc/profile 적용 완료 (umask + TMOUT)"
else
    echo "[U-12][WARN] /etc/profile 파일 없음"
fi

############################
# C 계열 셸 (csh, tcsh)
############################
CSHRC_FILES=("/etc/csh.cshrc" "/etc/csh.login")

for file in "${CSHRC_FILES[@]}"; do
    if [ -f "$file" ]; then
        # 기존 autologout 제거
        sed -i '/^set autologout/d' "$file"

        # 새 설정 추가 (주석 없음)
        echo "set autologout=10" >> "$file"
        echo "[U-12] $file autologout=10 적용 완료"
    fi
done

echo "[U-12] 적용 완료"
exit 0

