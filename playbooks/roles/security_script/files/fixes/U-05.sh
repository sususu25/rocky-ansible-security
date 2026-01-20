#!/bin/bash

echo "[U-05] UID 0 중복 계정 점검 (root 외 UID 0 금지)"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-05][ERROR] root 권한 필요"
    exit 1
fi

PASSWD_FILE="/etc/passwd"
VIOLATION_USERS=()

#####################################
# Step 1: UID 0 계정 점검
#####################################
echo "[U-05] UID 0 계정 확인"

while IFS=: read -r username passwd uid gid comment home shell; do
    if [ "$uid" -eq 0 ] && [ "$username" != "root" ]; then
        echo "[U-05][WARN] root 외 UID 0 계정 발견: $username (shell=$shell)"
        VIOLATION_USERS+=("$username")
    fi
done < "$PASSWD_FILE"

#####################################
# Step 2: 결과 출력 (조치 안내만)
#####################################
if [ ${#VIOLATION_USERS[@]} -eq 0 ]; then
    echo "[U-05][RESULT] 양호 - root 외 UID 0 계정 없음"
else
    echo "[U-05][RESULT] 취약 - root 외 UID 0 계정 존재"
    echo "[U-05] 대상 계정: ${VIOLATION_USERS[*]}"
    echo "[U-05] 조치 방법:"
    echo "  - 불필요한 계정: userdel <계정>"
    echo "  - 필요한 계정: usermod -u <0이 아닌 UID> <계정>"
    echo "[U-05] ※ 본 스크립트는 자동 조치를 수행하지 않음"
fi

echo "[U-05] 점검 완료"
exit 0

