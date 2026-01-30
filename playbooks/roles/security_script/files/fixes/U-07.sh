#!/bin/bash

echo "[U-07] 불필요한 사용자 계정 점검 시작"

echo "[U-07][CHECK] UID>=1000 사용자 목록(운영/업무 계정 여부 수동 판단 필요)"
awk -F: '$3>=1000 {print " - " $1 " (uid=" $3 ", home=" $6 ", shell=" $7 ")"}' /etc/passwd

echo "[U-07][RESULT] 자동 삭제 미수행(환경별 운영계정 상이)"
echo "[U-07][NEXT] 미사용 계정 삭제: userdel <계정명> / 홈 포함 삭제: userdel -r <계정명>"
echo "[U-07] 점검 종료"
exit 2
