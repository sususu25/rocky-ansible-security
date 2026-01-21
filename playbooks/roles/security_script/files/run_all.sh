#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
FIX_DIR="$BASE_DIR/fixes"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/vuln_fix_$(date +%Y%m%d_%H%M%S)_$$.log"

mkdir -p "$LOG_DIR"

log() {
    echo "[`date '+%F %T'`] $1" | tee -a "$LOG_FILE"
}

# root 권한 체크
if [ "$EUID" -ne 0 ]; then
    echo "❌ root 권한으로 실행해야 합니다."
    exit 1
fi

log "===== 취약점 조치 전체 시작 ====="

for script in $(ls "$FIX_DIR"/*.sh 2>/dev/null | sort); do
    log "▶ 실행 시작: $(basename "$script")"

    bash "$script" 2>&1 | tee -a "$LOG_FILE"
    RET=${PIPESTATUS[0]}

    if [ $RET -ne 0 ]; then
        log "❌ 실패: $(basename "$script") (exit code=$RET)"
    else
        log "✅ 완료: $(basename "$script")"
    fi
done

log "===== 취약점 조치 전체 종료 ====="

