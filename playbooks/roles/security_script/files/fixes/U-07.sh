#!/bin/bash

echo "[U-07] 불필요한 사용자 계정 점검"

awk -F: '$3 >= 1000 { print "[CHECK] 사용자:", $1, "UID:", $3 }' /etc/passwd

echo "[U-07] 위 계정 중 불필요한 계정은 관리자 판단 후 userdel로 수동 제거"
exit 0

