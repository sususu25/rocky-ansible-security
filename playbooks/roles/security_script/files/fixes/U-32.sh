#!/bin/bash

echo "[U-32] 홈 디렉토리 미존재 사용자 계정 점검 및 보완"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-32][ERROR] root 권한 필요"
    exit 1
fi

PASSWD_FILE="/etc/passwd"

while IFS=: read -r user _ uid gid comment home shell; do
    # UID 1000 이상 일반 사용자만
    if [ "$uid" -lt 1000 ]; then
        continue
    fi

    # nobody 명시적 제외
    if [ "$user" = "nobody" ]; then
        continue
    fi

    # 로그인 쉘 없는 계정 제외
    if [[ "$shell" =~ (nologin|false)$ ]]; then
        continue
    fi

    # 홈 디렉토리 없는 경우
    if [ ! -d "$home" ]; then
        echo "[U-32][WARN] 홈 디렉토리 없음: $user ($home)"

        # 홈 디렉토리 자동 생성
        mkdir -p "$home"
        chown "$user":"$gid" "$home"
        chmod 750 "$home"

        echo "[U-32] 홈 디렉토리 생성 및 권한 설정 완료: $user"
    fi
done < "$PASSWD_FILE"

echo "[U-32] 점검 및 조치 완료"
exit 0

