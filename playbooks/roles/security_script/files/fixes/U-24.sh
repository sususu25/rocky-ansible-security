#!/bin/bash

echo "[U-24] 홈 디렉터리 환경변수 파일 소유자 및 권한 점검/조치"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-24][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# 점검 대상 파일 목록
#####################################
ENV_FILES=(
    ".profile"
    ".kshrc"
    ".cshrc"
    ".bashrc"
    ".bash_profile"
    ".login"
    ".exrc"
    ".netrc"
)

#####################################
# 사용자 홈 디렉터리 목록 가져오기
#####################################
USER_HOMES=$(awk -F: '$3 >= 1000 && $7 !~ /nologin/ {print $6}' /etc/passwd | sort -u)

#####################################
# 점검/조치
#####################################
for home in $USER_HOMES; do
    if [ -d "$home" ]; then
        echo "[U-24] 사용자 홈 디렉터리: $home"

        for file in "${ENV_FILES[@]}"; do
            target="$home/$file"

            if [ -f "$target" ]; then
                echo "[U-24] 점검 대상: $target"

                # 소유자 확인 (홈 디렉터리 소유자와 일치해야 함)
                owner=$(stat -c "%U" "$target")
                home_owner=$(stat -c "%U" "$home")

                if [ "$owner" != "$home_owner" ]; then
                    chown "$home_owner:$home_owner" "$target"
                    echo "[U-24][FIX] 소유자 변경: $owner → $home_owner"
                fi

                # 권한 확인 (600 권장)
                perm=$(stat -c "%a" "$target")
                if [ "$perm" -gt 600 ]; then
                    chmod 600 "$target"
                    echo "[U-24][FIX] 권한 변경: $perm → 600"
                fi
            fi
        done
    fi
done

echo "[U-24] 점검/조치 완료"
exit 0
