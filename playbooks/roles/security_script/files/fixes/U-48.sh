#!/bin/bash
echo "[U-48] SMTP VRFY/EXPN 정보노출 차단 설정"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-48][ERROR] root 권한 필요"
    exit 1
fi

################################
# Sendmail
################################
SENDMAIL_CF="/etc/mail/sendmail.cf"

if [ -f "$SENDMAIL_CF" ]; then
    echo "[U-48] Sendmail 설정 확인"

    if grep -q "^PrivacyOptions" "$SENDMAIL_CF"; then
        sed -i 's/^PrivacyOptions.*/PrivacyOptions=restrictqrun,goaway/' "$SENDMAIL_CF"
    else
        echo "PrivacyOptions=restrictqrun,goaway" >> "$SENDMAIL_CF"
    fi

    systemctl restart sendmail 2>/dev/null
    echo "[U-48] Sendmail PrivacyOptions 설정 완료"
else
    echo "[U-48] Sendmail 미사용"
fi

################################
# Postfix
################################
POSTFIX_MAIN="/etc/postfix/main.cf"

if [ -f "$POSTFIX_MAIN" ]; then
    echo "[U-48] Postfix 설정 확인"

    if grep -q "^disable_vrfy_command" "$POSTFIX_MAIN"; then
        sed -i 's/^disable_vrfy_command.*/disable_vrfy_command = yes/' "$POSTFIX_MAIN"
    else
        echo "disable_vrfy_command = yes" >> "$POSTFIX_MAIN"
    fi

    postfix reload
    echo "[U-48] Postfix VRFY 차단 설정 완료"
else
    echo "[U-48] Postfix 미사용"
fi

################################
# Exim
################################
EXIM_CONF=""

[ -f /etc/exim/exim.conf ] && EXIM_CONF="/etc/exim/exim.conf"
[ -f /etc/exim4/exim4.conf ] && EXIM_CONF="/etc/exim4/exim4.conf"

if [ -n "$EXIM_CONF" ]; then
    echo "[U-48] Exim 설정 확인"

    sed -i '/acl_smtp_vrfy\s*=\s*accept/d' "$EXIM_CONF"
    sed -i '/acl_smtp_expn\s*=\s*accept/d' "$EXIM_CONF"

    systemctl restart exim 2>/dev/null || systemctl restart exim4 2>/dev/null
    echo "[U-48] Exim VRFY/EXPN 차단 설정 완료"
else
    echo "[U-48] Exim 미사용"
fi

echo "[U-48] SMTP VRFY/EXPN 차단 적용 완료"
exit 0

