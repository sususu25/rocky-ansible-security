#!/bin/bash

echo "[U-14] PATH 환경변수 안전 설정"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-14][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# Bourne / Korn / Bash 계열
#####################################
PROFILE_FILES=("/etc/profile" "$HOME/.profile" "$HOME/.bash_profile" "$HOME/.bashrc" "/etc/bash.bashrc" "$HOME/.kshrc")

for file in "${PROFILE_FILES[@]}"; do
    if [ -f "$file" ]; then
        # 기존 PATH 내 $HOME/bin 또는 상대 경로 제거
        sed -i 's|:$HOME/bin||g' "$file"
        sed -i 's|:$HOME/\.bin||g' "$file"
        sed -i 's|:\.\{1,2\}||g' "$file"

        echo "[U-14] $file PATH 안전화 완료"
    fi
done

#####################################
# C 계열 셸
#####################################
CSH_FILES=("/etc/csh.cshrc" "/etc/csh.login" "$HOME/.cshrc" "$HOME/.login")

for file in "${CSH_FILES[@]}"; do
    if [ -f "$file" ]; then
        # 기존 PATH 내 $HOME/bin 또는 상대 경로 제거
        sed -i 's|:$HOME/bin||g' "$file"
        sed -i 's|:$HOME/\.bin||g' "$file"
        sed -i 's|:\.\{1,2\}||g' "$file"

        echo "[U-14] $file PATH 안전화 완료"
    fi
done

echo "[U-14] 모든 PATH 설정 조치 완료"
exit 0

