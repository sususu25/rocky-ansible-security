#!/bin/bash

echo "[U-06] su 명령어 권한 및 wheel 그룹 설정 (운영 계정 예외 포함)"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-06][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# 변수 정의
#####################################
SU_BIN="/usr/bin/su"
GROUP_FILE="/etc/group"
PAM_SU="/etc/pam.d/su"

# 🔴 운영 계정 목록 (필요 시 추가)
ADMIN_USERS="rocky admin"

#####################################
# Step 1: wheel 그룹 존재 여부 확인
#####################################
if grep -q '^wheel:' "$GROUP_FILE"; then
    echo "[U-06] wheel 그룹 존재"
else
    echo "[U-06] wheel 그룹 없음 → 생성"
    groupadd wheel
fi

#####################################
# Step 2: 운영 계정 wheel 그룹 추가
#####################################
for user in $ADMIN_USERS; do
    if id "$user" &>/dev/null; then
        if id "$user" | grep -qw wheel; then
            echo "[U-06] $user 이미 wheel 그룹 소속"
        else
            usermod -aG wheel "$user"
            echo "[U-06] $user 계정을 wheel 그룹에 추가"
        fi
    else
        echo "[U-06][WARN] 사용자 $user 없음 → 건너뜀"
    fi
done

#####################################
# Step 3: su 명령어 그룹 및 권한 설정
#####################################
if [ -f "$SU_BIN" ]; then
    CURRENT_GROUP=$(stat -c "%G" "$SU_BIN")
    CURRENT_PERM=$(stat -c "%a" "$SU_BIN")

    echo "[U-06] 현재 /usr/bin/su 그룹: $CURRENT_GROUP, 권한: $CURRENT_PERM"

    if [ "$CURRENT_GROUP" != "wheel" ]; then
        chgrp wheel "$SU_BIN"
        echo "[U-06] /usr/bin/su 그룹을 wheel로 변경"
    fi

    if [ "$CURRENT_PERM" != "4750" ]; then
        chmod 4750 "$SU_BIN"
        echo "[U-06] /usr/bin/su 권한을 4750으로 변경"
    fi
else
    echo "[U-06][ERROR] /usr/bin/su 파일 없음"
fi

#####################################
# Step 4: PAM pam_wheel.so 설정 (주석 제외 체크)
#####################################
if [ -f "$PAM_SU" ]; then
    # 활성화된 pam_wheel 라인 존재 여부 확인 (주석 제외)
    if grep -Eq '^[[:space:]]*auth[[:space:]]+required[[:space:]]+pam_wheel\.so' "$PAM_SU"; then
        echo "[U-06] PAM pam_wheel.so 활성 설정 이미 존재"
    else
        # 주석된 pam_wheel 라인이 있으면 활성화
        if grep -Eq '^[[:space:]]*#.*pam_wheel\.so' "$PAM_SU"; then
            sed -i 's/^[[:space:]]*#\([[:space:]]*auth[[:space:]].*pam_wheel\.so.*\)/\1/' "$PAM_SU"
            echo "[U-06] 주석된 pam_wheel.so 설정 활성화"
        else
            # 아예 없으면 새로 추가
            echo "auth required pam_wheel.so use_uid" >> "$PAM_SU"
            echo "[U-06] PAM pam_wheel.so 설정 신규 추가"
        fi
    fi
else
    echo "[U-06][WARN] /etc/pam.d/su 파일 없음"
fi


#####################################
# 완료
#####################################
echo "[U-06] 조치 완료"
echo "[U-06] ※ wheel 그룹 추가 계정은 재로그인 후 적용됨"
exit 0

