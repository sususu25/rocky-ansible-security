#!/bin/bash

echo "[U-23] SUID/SGID 설정 파일 점검 시작"

echo "[U-23][CHECK] sudo 권한(표준 4755) 확인"
if [ -e /usr/bin/sudo ]; then
  mode="$(stat -c '%a' /usr/bin/sudo 2>/dev/null)"
  echo "[U-23][CHECK] /usr/bin/sudo mode=$mode"
  if [ "$mode" != "4755" ]; then
    echo "[U-23][RESULT] sudo 권한 비표준 → 자동 복구 미수행(운영 승인 필요)"
    echo "[U-23][NEXT] 권고: rpm -V sudo / (승인 후) rpm --setperms sudo 또는 dnf reinstall -y sudo"
    echo "[U-23] 점검 종료"
    exit 2
  fi
else
  echo "[U-23][CHECK] /usr/bin/sudo 없음(환경 확인 필요)"
fi

echo "[U-23][CHECK] 주요 경로 SUID/SGID 파일(있으면 수동 검토)"
for d in /home /tmp /var/tmp /usr/local /opt /srv; do
  [ -d "$d" ] || continue
  found="$(find "$d" -xdev -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | head -n 5)"
  if [ -n "$found" ]; then
    echo "[U-23][RESULT] $d 경로에서 SUID/SGID 파일 발견(상위 5개만 출력)"
    echo "$found" | sed 's/^/ - /'
    echo "[U-23][NEXT] 필요/정상 여부 확인 후 수동 조치(삭제/권한 변경 등)"
    echo "[U-23] 점검 종료"
    exit 2
  fi
done

echo "[U-23][RESULT] 주요 경로에서 SUID/SGID 파일 미발견"
echo "[U-23] 점검 종료"
exit 0
