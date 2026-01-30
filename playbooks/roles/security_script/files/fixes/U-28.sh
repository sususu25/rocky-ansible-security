#!/bin/bash

echo "[U-28] 접근 통제 설정 점검 시작"

echo "[U-28][CHECK] firewalld 상태"
if command -v systemctl >/dev/null 2>&1; then
  active="$(systemctl is-active firewalld 2>/dev/null || echo unknown)"
  enabled="$(systemctl is-enabled firewalld 2>/dev/null || echo unknown)"
  echo "[U-28][CHECK] firewalld active=$active enabled=$enabled"
else
  echo "[U-28][CHECK] systemctl 없음"
fi

echo "[U-28][CHECK] iptables INPUT 기본 정책"
if command -v iptables >/dev/null 2>&1; then
  policy="$(iptables -S 2>/dev/null | grep '^-P INPUT' | head -n 1)"
  [ -n "$policy" ] && echo "[U-28][CHECK] $policy" || echo "[U-28][CHECK] iptables 정책 확인 불가"
else
  echo "[U-28][CHECK] iptables 없음"
fi

echo "[U-28][RESULT] 접근통제 정책은 서비스 포트/운영정책에 따라 달라 자동 적용 미수행"
echo "[U-28][NEXT] 납품 정책에 맞게 firewalld 또는 iptables 규칙 확정 후 적용"
echo "[U-28] 점검 종료"
exit 2
