#!/bin/bash
set -u

BASE_DIR="/opt/security"
FIX_DIR="$BASE_DIR/fixes"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/vuln_fix_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$LOG_DIR"

log() { echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"; }

# root 권한 체크
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "❌ root 권한으로 실행해야 합니다."
  exit 1
fi

# “수동/확인/승인 필요” 문구 감지 → rc=0이어도 ⚠️로 승격
needs_manual_by_output() {
  local f="$1"
  grep -qiE "(수동|보류|승인.*필요|관리자 판단|수동 확인 필요|자동 판단 불가|자동 조치 불가|확인/수정하세요|NOTICE|RECOMMEND|⚠️)" "$f"
}

log "===== 취약점 조치 전체 시작 ====="

total=0; ok=0; manual=0; fail=0
manual_list=()

# restore.sh 있으면 먼저 실행
if [ -x "$FIX_DIR/restore.sh" ]; then
  log "▶ 실행 시작: restore.sh"
  "$FIX_DIR/restore.sh" 2>&1 | tee -a "$LOG_FILE"
  r=${PIPESTATUS[0]}
  log "✅ 완료: restore.sh (exit=$r)"
fi

for script in $(ls "$FIX_DIR"/U-*.sh 2>/dev/null | sort); do
  total=$((total+1))
  name=$(basename "$script")
  tmp=$(mktemp)

  log "▶ 실행 시작: $name"
  bash "$script" 2>&1 | tee -a "$tmp" | tee -a "$LOG_FILE"
  rc=${PIPESTATUS[0]}

  # rc=0이어도 “수동” 문구가 있으면 manual로 승격
  if [ "$rc" -eq 0 ] && needs_manual_by_output "$tmp"; then
    rc=2
  fi

  if [ "$rc" -eq 0 ]; then
    ok=$((ok+1))
    log "✅ 완료: $name (exit=0)"
  elif [ "$rc" -eq 2 ]; then
    manual=$((manual+1))
    manual_list+=("$name")
    log "⚠️ 보류/수동 필요: $name (exit=2)"
  else
    fail=$((fail+1))
    log "❌ 실패: $name (exit=$rc)"
  fi

  rm -f "$tmp"
done

log "===== 취약점 조치 요약 ====="
log "총 ${total}개 | ✅ ${ok} | ⚠️ ${manual} | ❌ ${fail}"
if [ "$manual" -gt 0 ]; then
  log "⚠️ 목록: ${manual_list[*]}"
fi
log "===== 취약점 조치 전체 종료 ====="

# 전체 종료코드: 실패 있으면 1, 아니면 수동 있으면 2, 아니면 0
if [ "$fail" -gt 0 ]; then exit 1; fi
if [ "$manual" -gt 0 ]; then exit 2; fi
exit 0
