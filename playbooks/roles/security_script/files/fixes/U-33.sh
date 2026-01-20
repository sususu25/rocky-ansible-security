#!/bin/bash

echo "[U-33] 불필요 숨김 파일 및 디렉토리 점검"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-33][ERROR] root 권한 필요"
    exit 1
fi

# 점검할 디렉토리 목록 (필요에 따라 추가 가능)
DIRS_TO_CHECK=("/home" "/tmp" "/var/tmp")

for DIR in "${DIRS_TO_CHECK[@]}"; do
    if [ -d "$DIR" ]; then
        echo "[U-33] $DIR 디렉토리 내 숨김 파일/디렉토리 점검"

        # 숨김 파일
        HIDDEN_FILES=$(find "$DIR" -maxdepth 1 -type f -name ".*" 2>/dev/null)
        for FILE in $HIDDEN_FILES; do
            echo "[U-33][INFO] 숨김 파일 발견: $FILE"
            # rm "$FILE"  # 필요 시 주석 해제
        done

        # 숨김 디렉토리
        HIDDEN_DIRS=$(find "$DIR" -maxdepth 1 -type d -name ".*" 2>/dev/null)
        for HDIR in $HIDDEN_DIRS; do
            # '.'와 '..' 제외
            if [[ "$HDIR" != "$DIR/." && "$HDIR" != "$DIR/.." ]]; then
                echo "[U-33][INFO] 숨김 디렉토리 발견: $HDIR"
                # rm -r "$HDIR"  # 필요 시 주석 해제
            fi
        done
    else
        echo "[U-33][WARN] 디렉토리 없음: $DIR"
    fi
done

echo "[U-33] 점검 완료 (삭제는 주석 해제 후 적용)"
exit 0

