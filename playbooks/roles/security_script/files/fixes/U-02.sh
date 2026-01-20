#!/bin/bash

echo "[U-02] 패스워드 정책 강화"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-02][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# Step 1 & 5: /etc/login.defs
#####################################
LOGIN_DEFS="/etc/login.defs"

[ -f "$LOGIN_DEFS" ] || { echo "[U-02][ERROR] /etc/login.defs 없음"; exit 1; }

update_login_defs() {
    local key="$1"
    local value="$2"

    if grep -q "^[[:space:]]*$key" "$LOGIN_DEFS"; then
        # 기존 라인 수정, 주석 블록은 그대로 유지
        sed -i "s|^[[:space:]]*$key.*|$key   $value|" "$LOGIN_DEFS"
    else
        # 없으면 PASS_WARN_AGE 줄 위에 추가 (주석 블록 바로 뒤에)
        awk -v k="$key   $value" '
        BEGIN{added=0}
        /^[[:space:]]*PASS_WARN_AGE/{
            if(!added){print k; added=1}
        }
        {print}
        END{if(!added) print k}
        ' "$LOGIN_DEFS" > "$LOGIN_DEFS.tmp" && mv "$LOGIN_DEFS.tmp" "$LOGIN_DEFS"
    fi
}

update_login_defs PASS_MAX_DAYS 90
update_login_defs PASS_MIN_DAYS 1

echo "[U-02][login.defs] PASS_MAX_DAYS / PASS_MIN_DAYS 적용 완료"

#####################################
# Step 2: /etc/security/pwquality.conf
#####################################
PWQUALITY="/etc/security/pwquality.conf"

[ -f "$PWQUALITY" ] || { echo "[U-02][ERROR] pwquality.conf 없음"; exit 1; }

update_pwquality() {
    local key="$1"
    local value="$2"

    if grep -q "^[#[:space:]]*$key" "$PWQUALITY"; then
        sed -i "s|^[#[:space:]]*$key.*|$key = $value|" "$PWQUALITY"
    else
        echo "$key = $value" >> "$PWQUALITY"
    fi
}

update_pwquality minlen 8
update_pwquality dcredit -1
update_pwquality ucredit -1
update_pwquality lcredit -1
update_pwquality ocredit -1

# enforce_for_root 적용
if grep -q "^[#[:space:]]*enforce_for_root" "$PWQUALITY"; then
    sed -i "s|^[#[:space:]]*enforce_for_root.*|enforce_for_root|" "$PWQUALITY"
else
    echo "enforce_for_root" >> "$PWQUALITY"
fi

echo "[U-02][pwquality] 패스워드 복잡도 적용 완료"

#####################################
# Step 3: /etc/security/pwhistory.conf
#####################################
PWHISTORY="/etc/security/pwhistory.conf"

[ -f "$PWHISTORY" ] || { echo "[U-02][ERROR] pwhistory.conf 없음"; exit 1; }

update_pwhistory() {
    local key="$1"
    local value="$2"

    if grep -q "^[#[:space:]]*$key" "$PWHISTORY"; then
        sed -i "s|^[#[:space:]]*$key.*|$key=$value|" "$PWHISTORY"
    else
        echo "$key=$value" >> "$PWHISTORY"
    fi
}

update_pwhistory remember 4
update_pwhistory file /etc/security/opasswd

# enforce_for_root 적용
if grep -q "^[#[:space:]]*enforce_for_root" "$PWHISTORY"; then
    sed -i "s|^[#[:space:]]*enforce_for_root.*|enforce_for_root|" "$PWHISTORY"
else
    echo "enforce_for_root" >> "$PWHISTORY"
fi

echo "[U-02][pwhistory] 패스워드 이력 적용 완료"

#####################################
# Step 4: /etc/pam.d/system-auth
#####################################
SYSTEM_AUTH="/etc/pam.d/system-auth"

[ -f "$SYSTEM_AUTH" ] || { echo "[U-02][ERROR] system-auth 없음"; exit 1; }

# pam_pwquality 라인만 교체 (순서 유지)
if grep -q "^password.*pam_pwquality.so" "$SYSTEM_AUTH"; then
    sed -i "s|^password.*pam_pwquality.so.*|password    requisite     pam_pwquality.so try_first_pass local_users_only enforce_for_root retry=3|" "$SYSTEM_AUTH"
else
    sed -i "/^password.*pam_unix.so/i password    requisite     pam_pwquality.so try_first_pass local_users_only enforce_for_root retry=3" "$SYSTEM_AUTH"
fi

# pam_pwhistory 라인만 교체 (순서 유지)
if grep -q "^password.*pam_pwhistory.so" "$SYSTEM_AUTH"; then
    sed -i "s|^password.*pam_pwhistory.so.*|password    required      pam_pwhistory.so use_authtok remember=4 enforce_for_root|" "$SYSTEM_AUTH"
else
    sed -i "/^password.*pam_unix.so/i password    required      pam_pwhistory.so use_authtok remember=4 enforce_for_root" "$SYSTEM_AUTH"
fi

echo "[U-02][PAM] system-auth 정책 적용 완료"

#####################################
echo "[U-02] 조치 완료"
exit 0

