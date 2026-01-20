#!/bin/bash
echo "[U-51] DNS 동적 업데이트(allow-update) 점검"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-51][ERROR] root 권한 필요"
    exit 1
fi

# named(BIND) 존재 여부 확인
if ! command -v named >/dev/null 2>&1; then
    echo "[U-51] BIND(named) 미설치 – 점검 대상 아님"
    exit 0
fi

# 설정 파일 탐색
NAMED_CONF=""
if [ -f /etc/named.conf ]; then
    NAMED_CONF="/etc/named.conf"
elif [ -f /etc/bind/named.conf ]; then
    NAMED_CONF="/etc/bind/named.conf"
elif [ -f /etc/bind/named.conf.options ]; then
    NAMED_CONF="/etc/bind/named.conf.options"
fi

if [ -z "$NAMED_CONF" ]; then
    echo "[U-51][WARN] named.conf 파일을 찾을 수 없음"
    exit 0
fi

echo "[U-51] 설정 파일: $NAMED_CONF"

################################
# allow-update 설정 점검
################################
echo "[U-51] allow-update 설정 확인"
grep -n "allow-update" "$NAMED_CONF" || \
echo "[U-51][WARN] allow-update 설정 없음"

################################
# 적용 가이드 출력
################################
cat <<EOF

[U-51] 조치 가이드
────────────────────────────────────
① DNS 동적 업데이트가 필요 없는 경우 (권장)
   allow-update { none; };

② DNS 동적 업데이트가 필요한 경우
   allow-update { <허용할 IP>; };

※ zone 블록 내부에 설정해야 합니다.
※ 예시:

zone "example.com" IN {
    type master;
    file "example.com.zone";
    allow-update { none; };
};

────────────────────────────────────
설정 변경 후 반드시 적용:
# systemctl restart named
────────────────────────────────────
EOF

echo "[U-51] 점검 완료"
exit 0

