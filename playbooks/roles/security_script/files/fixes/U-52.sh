#!/bin/bash
echo "[U-52] Telnet 서비스 비활성화 점검"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-52][ERROR] root 권한 필요"
    exit 1
fi

################################
# SSH 서비스 확인
################################
if systemctl list-unit-files | grep -q sshd.service; then
    systemctl is-active sshd >/dev/null 2>&1 || {
        echo "[U-52] SSH 서비스 시작"
        systemctl start sshd
    }
    echo "[U-52] SSH 서비스 정상"
else
    echo "[U-52][WARN] SSH 서비스 없음 (환경 확인 필요)"
fi

################################
# systemd telnet.socket
################################
if systemctl list-unit-files | grep -q telnet.socket; then
    if systemctl is-active telnet.socket >/dev/null 2>&1; then
        systemctl stop telnet.socket
        echo "[U-52] telnet.socket 중지"
    fi
    systemctl disable telnet.socket >/dev/null 2>&1
    echo "[U-52] telnet.socket 비활성화"
else
    echo "[U-52] systemd telnet.socket 없음"
fi

################################
# xinetd 기반 telnet
################################
if [ -f /etc/xinetd.d/telnet ]; then
    echo "[U-52] xinetd telnet 설정 파일 존재"
    grep -n "disable" /etc/xinetd.d/telnet
    echo "[U-52] → disable = yes 로 설정 필요 (자동 수정 안 함)"
else
    echo "[U-52] xinetd telnet 설정 없음"
fi

################################
# inetd 기반 telnet
################################
if [ -f /etc/inetd.conf ]; then
    echo "[U-52] inetd.conf telnet 설정 확인"
    grep -n telnet /etc/inetd.conf || echo "[U-52] telnet 설정 없음"
    echo "[U-52] → telnet 라인 주석 처리 필요"
else
    echo "[U-52] inetd.conf 없음"
fi

################################
# 요약
################################
cat <<EOF

[U-52] 조치 요약
────────────────────────────────────
✔ SSH 서비스 실행 확인
✔ systemd telnet.socket 중지/비활성화
✔ xinetd / inetd 기반 telnet 설정 점검 완료

※ xinetd / inetd 설정은
   운영 환경 확인 후 수동 주석 권장
────────────────────────────────────
EOF

echo "[U-52] 점검 및 조치 완료"
exit 0

