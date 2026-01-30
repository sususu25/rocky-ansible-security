#!/bin/bash

echo "[U-26] /dev 디렉터리 내 불필요 파일 점검 시작"

echo "[U-26][CHECK] /dev 내 일반 파일(-type f) 존재 여부(있으면 수동 검토)"
found="$(find /dev -xdev -type f 2>/dev/null | head -n 5)"

if [ -n "$found" ]; then
  echo "[U-26][RESULT] /dev 내 일반 파일 발견(상위 5개만 출력) → 자동 삭제 미수행"
  echo "$found" | sed 's/^/ - /'
  echo "[U-26][NEXT] 사용 여부 확인 후 불필요 시 수동 삭제: rm -f <경로>"
  echo "[U-26] 점검 종료"
  exit 2
fi

echo "[U-26][RESULT] /dev 내 일반 파일 없음"
echo "[U-26] 점검 종료"
exit 0
