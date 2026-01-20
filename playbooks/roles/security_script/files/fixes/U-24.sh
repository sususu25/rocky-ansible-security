#!/bin/bash

echo "[U-23] 홈 디렉터리 환경변수 파일 소유자 및 권한 점검/조치"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-23][ERROR] root 권한 필요"
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
# /home 하위 사용자 홈 디렉터리 점검
#####################################
for HOME_DIR in /home/*; do
    [ -d "$HOME_DIR" ] || continue

    USERNAME=$(basename "$HOME_DIR")

    for file in "${ENV_FILES[@]}"; do
        TARGET="$HOME_DIR/$file"

        if [ -f "$TARGET" ]; then
            OWNER=$(stat -c "%U" "$TARGET")
            PERM=$(stat -c "%a" "$TARGET")

            echo "[U-23] 점검: $TARGET (소유자: $OWNER, 권한: $PERM)"

            #####################################
            # Step 2: 소유자 조정 (root 또는 기존 소유자 유지)
            #####################################
            if [ "$OWNER" != "root" ] && [ "$OWNER" != "$USERNAME" ]; then
                chown "$USERNAME" "$TARGET"
                echo "[U-23][FIX] $TARGET 소유자를 $USERNAME 로 변경"
            fi

            #####################################
            # Step 2: other 쓰기 권한 제거
            #####################################
            chmod o-w "$TARGET"
            echo "[U-23][FIX] $TARGET other 쓰기 권한 제거"
        fi
    done
done

echo "[U-23] 조치 완료"
exit 0

