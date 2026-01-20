#!/bin/bash
echo "[U-50] DNS Zone Transfer 제한(xfrnets, allow-transfer) 점검"

# root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "[U-50][ERROR] root 권한 필요"
    exit 1
fi

# BIND(named) 설치 확인
if ! command -v named >/dev/null 2>&1; then
    echo "[U-50] named(BIND) 설치되지 않음. 스크립트 종료"
    exit 0
fi

# 파일 위치 확인
NAMED_BOOT=""
NAMED_CONF=""
if [ -f /etc/named.boot ]; then
    NAMED_BOOT="/etc/named.boot"
elif [ -f /etc/bind/named.boot ]; then
    NAMED_BOOT="/etc/bind/named.boot"
fi

if [ -f /etc/named.conf ]; then
    NAMED_CONF="/etc/named.conf"
elif [ -f /etc/bind/named.conf ]; then
    NAMED_CONF="/etc/bind/named.conf"
elif [ -f /etc/bind/named.conf.options ]; then
    NAMED_CONF="/etc/bind/named.conf.options"
fi

################################
# xfrnets 점검
################################
if [ -n "$NAMED_BOOT" ]; then
    echo "[U-50] xfrnets 설정 확인: $NAMED_BOOT"
    grep xfrnets "$NAMED_BOOT" || echo "[U-50][WARN] xfrnets 설정 없음"
else
    echo "[U-50][WARN] named.boot 파일 없음"
fi

################################
# allow-transfer 점검
################################
if [ -n "$NAMED_CONF" ]; then
    echo "[U-50] allow-transfer 설정 확인: $NAMED_CONF"
    grep allow-transfer "$NAMED_CONF" || echo "[U-50][WARN] allow-transfer 설정 없음"
else
    echo "[U-50][WARN] named.conf 파일 없음"
fi

echo "[U-50] 설정 적용 안내"
echo " - xfrnets 또는 allow-transfer 항목이 없는 경우"
echo "   해당 파일에 Zone Transfer를 허용할 IP만 설정하세요."
echo "   예시:"
if [ -n "$NAMED_BOOT" ]; then
    echo "   xfrnets 192.168.0.10;"
fi
if [ -n "$NAMED_CONF" ]; then
    echo "   allow-transfer { 192.168.0.10; };"
fi

################################
# DNS 서비스 재시작 안내
################################
echo "[U-50] DNS 서비스(named) 재시작 필요"
echo "   # systemctl restart named"

echo "[U-50] 점검 완료"
exit 0

