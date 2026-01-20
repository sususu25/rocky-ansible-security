#!/bin/bash

echo "[U-62] 로그온 경고 메시지 점검 및 설정 시작"

WARN_MSG="Authorized access only.
Unauthorized use of this system is prohibited and may be monitored."

################################
# 서버 공통 (항상 적용)
################################
echo "$WARN_MSG" > /etc/motd
echo "$WARN_MSG" > /etc/issue
echo "[U-62] /etc/motd, /etc/issue 설정 완료"

################################
# Telnet (사용 중일 때만)
################################
if systemctl list-units --type=socket | grep -q telnet; then
    echo "$WARN_MSG" > /etc/issue.net
    echo "[U-62] Telnet 사용 중 → /etc/issue.net 설정"
else
    echo "[U-62] Telnet 미사용 → 미적용"
fi

################################
# SSH (사용 중일 때만)
################################
if systemctl is-active --quiet sshd; then
    grep -q "^Banner" /etc/ssh/sshd_config \
        && sed -i "s|^Banner.*|Banner /etc/issue.net|" /etc/ssh/sshd_config \
        || echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config

    echo "$WARN_MSG" > /etc/issue.net
    systemctl restart sshd
    echo "[U-62] SSH 사용 중 → 배너 설정 완료"
else
    echo "[U-62] SSH 미사용 → 미적용"
fi

################################
# Sendmail
################################
if systemctl is-active --quiet sendmail; then
    sed -i "s/^O SmtpGreetingMessage=.*/O SmtpGreetingMessage=$WARN_MSG/" /etc/mail/sendmail.cf
    systemctl restart sendmail
    echo "[U-62] Sendmail 경고 메시지 설정 완료"
else
    echo "[U-62] Sendmail 미사용 → 미적용"
fi

################################
# Postfix
################################
if systemctl is-active --quiet postfix; then
    sed -i "s|^smtpd_banner.*|smtpd_banner = $WARN_MSG|" /etc/postfix/main.cf
    systemctl restart postfix
    echo "[U-62] Postfix 경고 메시지 설정 완료"
else
    echo "[U-62] Postfix 미사용 → 미적용"
fi

################################
# Exim
################################
if systemctl is-active --quiet exim; then
    sed -i "s|^smtp_banner.*|smtp_banner = $WARN_MSG|" /etc/exim/exim.conf
    systemctl restart exim
    echo "[U-62] Exim 경고 메시지 설정 완료"
else
    echo "[U-62] Exim 미사용 → 미적용"
fi

################################
# vsftpd
################################
if systemctl is-active --quiet vsftpd; then
    sed -i "s|^ftpd_banner=.*|ftpd_banner=$WARN_MSG|" /etc/vsftpd.conf
    systemctl restart vsftpd
    echo "[U-62] vsFTP 경고 메시지 설정 완료"
else
    echo "[U-62] vsFTP 미사용 → 미적용"
fi

################################
# ProFTPD
################################
if systemctl is-active --quiet proftpd; then
    WELCOME="/etc/proftpd/welcome.msg"
    echo "$WARN_MSG" > $WELCOME

    grep -q "^DisplayLogin" /etc/proftpd.conf \
        && sed -i "s|^DisplayLogin.*|DisplayLogin $WELCOME|" /etc/proftpd.conf \
        || echo "DisplayLogin $WELCOME" >> /etc/proftpd.conf

    systemctl restart proftpd
    echo "[U-62] ProFTP 경고 메시지 설정 완료"
else
    echo "[U-62] ProFTP 미사용 → 미적용"
fi

################################
# DNS (named)
################################
if systemctl is-active --quiet named; then
    sed -i 's/^version.*/version "'"$WARN_MSG"'";/' /etc/named.conf
    systemctl restart named
    echo "[U-62] DNS(named) 경고 메시지 설정 완료"
else
    echo "[U-62] DNS 미사용 → 미적용"
fi

echo "[U-62] 로그온 경고 메시지 점검 및 설정 완료"

