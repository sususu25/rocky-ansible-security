#!/bin/bash

echo "[U-09] 불필요한 그룹 점검 시작"

echo "[U-09][CHECK] 구성원 없는 그룹 목록(기본그룹/서비스그룹 포함 가능 → 수동 판단)"
awk -F: '($4==""){print " - " $1 " (gid=" $3 ")"}' /etc/group

echo "[U-09][RESULT] 자동 삭제 미수행(권한/서비스 영향 가능)"
echo "[U-09][NEXT] 미사용 그룹 삭제: groupdel <groupname>"
echo "[U-09] 점검 종료"
exit 2
