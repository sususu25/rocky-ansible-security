#!/bin/bash

echo "[U-47] 메일 서버 릴레이 제한 설정"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-47][ERROR] root 권한 필요"
    exit 1
fi

############################
# Sendmail 설정
############################
SENDMAIL_CF="/etc/mail/sendmail.cf"
SENDMAIL_MC="/etc/mail/sendmail.mc"
ACCESS_FILE="/etc/mail/access"

if [ -f "$SENDMAIL_CF" ] || [ -f "$SENDMAIL_MC" ]; then
    # Sendmail 8.9 이상: promiscuous_relay 제거
    if [ -f "$SENDMAIL_MC" ]; then
        if grep -q "promiscuous_relay" "$SENDMAIL_MC"; then
            sed -i '/promiscuous_relay/d' "$SENDMAIL_MC"
            m4 "$SENDMAIL_MC" > "$SENDMAIL_CF"
            echo "[U-47] Sendmail mc 파일 promiscuous_relay 제거 후 cf 재생성"
        fi
    fi

    # /etc/mail/access 설정
    if [ ! -f "$ACCESS_FILE" ]; then
        cat <<EOF > "$ACCESS_FILE"
localhost.localdomain RELAY
localhost RELAY
127.0.0.1 RELAY
spam.com REJECT
EOF
        makemap hash /etc/mail/access.db < "$ACCESS_FILE"
        echo "[U-47] Sendmail /etc/mail/access 파일 생성 및 DB 적용"
    else
        echo "[U-47] Sendmail access 파일 이미 존재, 필요시 수동 점검"
    fi

    systemctl restart sendmail 2>/dev/null && echo "[U-47] Sendmail 서비스 재시작 완료"
else
    echo "[U-47] Sendmail 설치 없음"
fi

############################
# Postfix 설정
############################
POSTFIX_MAIN="/etc/postfix/main.cf"
if [ -f "$POSTFIX_MAIN" ]; then
    # 허용 네트워크 예시: 로컬호스트만 허용
    if grep -q "^mynetworks" "$POSTFIX_MAIN"; then
        sed -i 's/^mynetworks.*/mynetworks = 127.0.0.0\/8/' "$POSTFIX_MAIN"
    else
        echo "mynetworks = 127.0.0.0/8" >> "$POSTFIX_MAIN"
    fi
    postfix reload
    echo "[U-47] Postfix mynetworks 설정 적용 및 reload"
else
    echo "[U-47] Postfix 설치 없음"
fi

############################
# Exim 설정
############################
EXIM_CONF=""
if [ -f "/etc/exim/exim.conf" ]; then
    EXIM_CONF="/etc/exim/exim.conf"
elif [ -f "/etc/exim4/exim4.conf" ]; then
    EXIM_CONF="/etc/exim4/exim4.conf"
fi

if [ -n "$EXIM_CONF" ]; then
    if grep -q "relay_from_hosts" "$EXIM_CONF"; then
        sed -i 's/hostlist relay_from_hosts =.*/hostlist relay_from_hosts = 127.0.0.1/' "$EXIM_CONF"
    else
        echo "hostlist relay_from_hosts = 127.0.0.1" >> "$EXIM_CONF"
    fi
    systemctl restart exim 2>/dev/null || systemctl restart exim4 2>/dev/null
    echo "[U-47] Exim 릴레이 제한 설정 적용 및 서비스 재시작"
else
    echo "[U-47] Exim 설치 없음"
fi

echo "[U-47] 메일 서버 릴레이 제한 설정 완료"
exit 0

