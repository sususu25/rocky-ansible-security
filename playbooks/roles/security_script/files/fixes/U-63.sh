#!/bin/bash

SUDOERS="/etc/sudoers"

echo "[U-63] sudoers 파일 소유자 및 권한 점검 시작"

if [ ! -f "$SUDOERS" ]; then
    echo "[U-63][ERROR] $SUDOERS 파일이 존재하지 않습니다."
    echo "[U-63][ACTION] 수동으로 sudoers 구성을 확인해야 합니다."
    exit 1
fi

OWNER=$(stat -c "%U" "$SUDOERS")
PERM=$(stat -c "%a" "$SUDOERS")

echo "[U-63] 현재 소유자: $OWNER, 권한: $PERM"

# 권한 기준: 640 (가이드에 맞춰 조정한 값 유지)
if [ "$OWNER" != "root" ]; then
    echo "[U-63][WARN] sudoers 소유자가 root가 아닙니다: $OWNER"
else
    echo "[U-63] sudoers 소유자 root 확인"
fi

if [ "$PERM" != "640" ]; then
    echo "[U-63][INFO] sudoers 권한을 640으로 변경합니다."
    chmod 640 "$SUDOERS"
else
    echo "[U-63] sudoers 권한이 이미 640입니다."
fi

# 문법 검사
if ! ERR_MSG=$(visudo -c 2>&1); then
    echo "[U-63][ERROR] sudoers 문법 오류 감지됨"
    echo "[U-63][ERROR] visudo -c 출력 내용:"
    while IFS= read -r line; do
        echo "  $line"
    done <<< "$ERR_MSG"

    echo "[U-63][ACTION] 수동 조치 절차:"
    echo "  1) root 권한으로 서버 접속"
    echo "  2) 'visudo' 실행"
    echo "  3) 위 에러 메시지의 'line XX' 위치를 찾아 문법 수정 또는 주석 처리"
    echo "  4) 수정 후 다시 'visudo -c' 실행 → 'parsed OK' 확인"
    echo "[U-63][NOTE] sudoers는 자동 수정하지 않으며, 관리자가 직접 검토해야 합니다."
    exit 1
else
    echo "[U-63] sudoers 문법 정상 (visudo -c 통과)"
fi

exit 0
