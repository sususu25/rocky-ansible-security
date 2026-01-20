#!/bin/bash

echo "[U-31] 사용자 홈 디렉토리 소유자 및 권한 설정 (안전 적용)"

if [ "$EUID" -ne 0 ]; then
    echo "[U-31][ERROR] root 권한 필요"
    exit 1
fi

PASSWD_FILE="/etc/passwd"

while IFS=: read -r user _ uid _ _ home shell; do
    # nobody 명시적 제외
    if [ "$user" = "nobody" ]; then
        continue
    fi

    # 일반 사용자만 (UID 1000 이상)
    if [ "$uid" -lt 1000 ]; then
        continue
    fi

    # 홈 디렉토리 유효성
    if [ -z "$home" ] || [ "$home" = "/" ] || [ ! -d "$home" ]; then
        echo "[U-31][WARN] 홈 디렉토리 없음 또는 제외: $user ($home)"
        continue
    fi

    # 소유자 정상화
    if [ "$(stat -c %U "$home")" != "$user" ]; then
        chown "$user":"$user" "$home"
    fi

    # 타 사용자 쓰기 권한 제거
    chmod o-w "$home"

    echo "[U-31] 적용 완료: $user ($home)"
done < "$PASSWD_FILE"

echo "[U-31] 조치 완료"
exit 0

