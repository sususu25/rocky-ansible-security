#!/bin/bash

echo "[U-23] SUID/SGID 설정 파일 점검 및 조치 (SAFE ENFORCE + sudo 옵션 분리)"

AUTO_REPAIR_SUDO="${AUTO_REPAIR_SUDO:-false}"

if [ "${EUID}" -ne 0 ]; then
  echo "[U-23][ERROR] root 권한 필요"
  exit 1
fi

if ! command -v find >/dev/null 2>&1; then
  echo "[U-23][ERROR] find 명령어 없음"
  exit 1
fi

AUTO_PATHS=("/home" "/tmp" "/var/tmp" "/usr/local" "/opt" "/srv")

SUDO_BIN="/usr/bin/sudo"

WARN_FLAG=false
FAIL_FLAG=false

stat_line() {
  local f="$1"
  stat -c "%A %U:%G %a %n" "$f" 2>/dev/null || echo "STAT_FAIL $f"
}

mark_warn() {
  WARN_FLAG=true
}

mark_fail() {
  FAIL_FLAG=true
}

#####################################
# 0) sudo 권한/무결성 점검 (기본: 자동 조치 금지 → ⚠️)
#####################################
check_or_repair_sudo() {
  if [ ! -f "$SUDO_BIN" ]; then
    echo "[U-23][INFO] sudo 바이너리 없음: $SUDO_BIN (환경에 따라 N/A 가능)"
    return 0
  fi

  local owner group perm
  owner="$(stat -c "%U" "$SUDO_BIN")"
  group="$(stat -c "%G" "$SUDO_BIN")"
  perm="$(stat -c "%a" "$SUDO_BIN")"

  # 일반적 기대값(표준): root:root 4755
  if [ "$owner" = "root" ] && [ "$group" = "root" ] && [ "$perm" = "4755" ]; then
    echo "[U-23][SUDO][OK] 표준 권한: $(stat_line "$SUDO_BIN")"
    return 0
  fi

  echo "[U-23][SUDO][WARN] 비정상 권한 감지: $(stat_line "$SUDO_BIN")"

  # 기본 정책: 자동 복구 금지 → ⚠️로 남기고 운영 승인 후 수행 권고
  if [ "$AUTO_REPAIR_SUDO" != "true" ]; then
    echo "⚠️ [U-23][NOTICE] sudo 권한/정책 충돌 가능성. 자동 복구는 운영 승인 옵션(AUTO_REPAIR_SUDO=true)로 분리됨."
    echo "[U-23][RECOMMEND] (승인 후) rpm -V sudo / rpm --setperms sudo / dnf reinstall sudo"
    mark_warn
    return 0
  fi

  echo "[U-23][SUDO][ACTION] AUTO_REPAIR_SUDO=true → 패키지 기준 복구 시도"

  # 1) rpm 기반 복구 시도
  if command -v rpm >/dev/null 2>&1 && rpm -q sudo >/dev/null 2>&1; then
    rpm --setugids sudo || true
    rpm --setperms sudo || true
  fi

  owner="$(stat -c "%U" "$SUDO_BIN" 2>/dev/null || echo "")"
  group="$(stat -c "%G" "$SUDO_BIN" 2>/dev/null || echo "")"
  perm="$(stat -c "%a" "$SUDO_BIN" 2>/dev/null || echo "")"

  if [ "$owner" = "root" ] && [ "$group" = "root" ] && [ "$perm" = "4755" ]; then
    echo "[U-23][SUDO][OK] rpm 복구 성공: $(stat_line "$SUDO_BIN")"
    return 0
  fi

  # 2) dnf 재설치 시도
  if command -v dnf >/dev/null 2>&1; then
    dnf -y reinstall sudo || true
  fi

  owner="$(stat -c "%U" "$SUDO_BIN" 2>/dev/null || echo "")"
  group="$(stat -c "%G" "$SUDO_BIN" 2>/dev/null || echo "")"
  perm="$(stat -c "%a" "$SUDO_BIN" 2>/dev/null || echo "")"

  if [ "$owner" = "root" ] && [ "$group" = "root" ] && [ "$perm" = "4755" ]; then
    echo "[U-23][SUDO][OK] dnf 복구 성공: $(stat_line "$SUDO_BIN")"
    return 0
  fi

  echo "[U-23][SUDO][ERROR] 복구 실패: $(stat_line "$SUDO_BIN")"
  echo "[U-23][SUDO][ACTION] 수동 조치 필요(패키지/파일 무결성 확인)"
  mark_fail
  return 0
}

check_or_repair_sudo

#####################################
# 1) SAFE ENFORCE: AUTO_PATHS 내 SUID/SGID 제거
#####################################
FOUND_COUNT=0
REMOVED_COUNT=0

for path in "${AUTO_PATHS[@]}"; do
  if [ -d "$path" ]; then
    echo "[U-23] 자동 조치 대상 경로 검사: $path"
    while IFS= read -r file; do
      [ -z "$file" ] && continue
      FOUND_COUNT=$((FOUND_COUNT + 1))

      BEFORE="$(stat_line "$file")"

      # 제거 시도
      chmod u-s,g-s "$file" 2>/dev/null || {
        echo "[U-23][ERROR] chmod 실패: $file"
        mark_fail
        continue
      }

      AFTER="$(stat_line "$file")"
      REMOVED_COUNT=$((REMOVED_COUNT + 1))
      echo "[U-23][FIX] SUID/SGID 제거: $BEFORE -> $AFTER"
    done < <(find "$path" -xdev -type f \( -perm -04000 -o -perm -02000 \) 2>/dev/null)
  fi
done

#####################################
# 결과 요약
#####################################
if [ "$FOUND_COUNT" -eq 0 ]; then
  echo "[U-23][RESULT] 자동 조치 대상 경로 내 SUID/SGID 파일 없음 (양호)"
else
  echo "[U-23][RESULT] 발견 $FOUND_COUNT건 중 $REMOVED_COUNT건 SUID/SGID 제거"
fi

# 최종 종료코드: ❌(실패) > ⚠️(보류) > ✅(정상)
if [ "$FAIL_FLAG" = true ]; then
  echo "[U-23] 점검/조치 완료: ❌ 실패 포함"
  exit 1
fi

if [ "$WARN_FLAG" = true ]; then
  echo "[U-23] 점검/조치 완료: ⚠️ 운영 승인/수동 조치 필요"
  exit 2
fi

echo "[U-23] 점검/조치 완료: ✅"
exit 0
