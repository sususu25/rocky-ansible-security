#!/bin/bash

echo "[U-46] 메일 서비스 보안 설정 및 일반 사용자 권한 제한"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-46][ERROR] root 권한 필요"
    exit 1
fi

############################
# Sendmail 설정
############################
SENDMAIL_CF="/etc/mail/sendmail.cf"
if [ -f "$SENDMAIL_CF" ]; then
    if grep -q "PrivacyOptions.*restrictqrun" "$SENDMAIL_CF"; then
        echo "[U-46] Sendmail PrivacyOptions 이미 설정됨"
    else
        # 기존 PrivacyOptions가 있으면 뒤에 restrictqrun 추가
        if grep -q "PrivacyOptions" "$SENDMAIL_CF"; then
            sed -i 's/^\(PrivacyOptions.*\)/\1, restrictqrun/' "$SENDMAIL_CF"
        else
            echo "PrivacyOptions = authwarnings, novrfy, noexpn, restrictqrun" >> "$SENDMAIL_CF"
        fi
        echo "[U-46] Sendmail PrivacyOptions에 restrictqrun 추가"
        systemctl restart sendmail 2>/dev/null && echo "[U-46] Sendmail 서비스 재시작 완료"
    fi
else
    echo "[U-46] Sendmail 설정 파일 없음: $SENDMAIL_CF"
fi

############################
# Postfix 권한 제한
############################
POSTSUPER_BIN="/usr/sbin/postsuper"
if [ -f "$POSTSUPER_BIN" ]; then
    chmod o-x "$POSTSUPER_BIN"
    echo "[U-46] Postfix postsuper 일반 사용자 실행 권한 제거"
else
    echo "[U-46] Postfix postsuper 파일 없음"
fi

############################
# Exim 권한 제한
############################
EXIQGREP_BIN="/usr/sbin/exiqgrep"
if [ -f "$EXIQGREP_BIN" ]; then
    chmod o-x "$EXIQGREP_BIN"
    echo "[U-46] Exim exiqgrep 일반 사용자 실행 권한 제거"
else
    echo "[U-46] Exim exiqgrep 파일 없음"
fi

echo "[U-46] 메일 서비스 보안 설정 완료"
exit 0

