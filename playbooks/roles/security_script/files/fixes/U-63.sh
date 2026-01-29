#!/bin/bash
# U-63: sudoers 파일 소유자 및 권한 점검/조치 (검증/롤백 포함)
# 정책: /etc/sudoers는 root:root, mode 0440 이어야 함.
# 변경 후 visudo -c로 검증, 실패 시 즉시 롤백.

set -u

echo "[U-63] sudoers 파일 소유자 및 권한 점검/조치 (검증/롤백 포함)"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
  echo "[U-63][ERROR] root 권한 필요"
  exit 1
fi

SUDOERS="/etc/sudoers"
SUDOERS_D="/etc/sudoers.d"
TS="$(date +%Y%m%d_%H%M%S)"
BACKUP="/etc/sudoers.bak_${TS}"

if [ ! -f "$SUDOERS" ]; then
  echo "[U-63][ERROR] /etc/sudoers 파일 없음"
  exit 1
fi

# 현재 상태 출력
CUR_OWNER="$(stat -c '%U:%G' "$SUDOERS" 2>/dev/null || echo 'UNKNOWN')"
CUR_MODE="$(stat -c '%a' "$SUDOERS" 2>/dev/null || echo 'UNKNOWN')"
echo "[U-63] 현재 상태: owner=${CUR_OWNER} perm=${CUR_MODE}"

# 백업
cp -p "$SUDOERS" "$BACKUP"
echo "[U-63][INFO] 백업 생성: ${BACKUP}"

# 표준 권한으로 맞춤 (0440 고정)
chown root:root "$SUDOERS"
chmod 0440 "$SUDOERS"

# (선택) sudoers.d도 안전 권장값으로 정리 (있을 때만)
if [ -d "$SUDOERS_D" ]; then
  chown root:root "$SUDOERS_D"
  chmod 0750 "$SUDOERS_D" 2>/dev/null || true

  # 파일들은 0440 권장 (너무 공격적으로 바꾸고 싶지 않으면 이 블록 주석처리 가능)
  find "$SUDOERS_D" -maxdepth 1 -type f -print0 2>/dev/null \
    | xargs -0 -I{} sh -c 'chown root:root "{}" && chmod 0440 "{}"' 2>/dev/null || true
fi

# 검증
echo "[U-63][INFO] visudo -c 검증 수행"
VISUDO_OUT="$(visudo -c 2>&1)"
VISUDO_RC=$?

if [ $VISUDO_RC -ne 0 ]; then
  echo "[U-63][ERROR] sudoers 검증 실패 → 롤백 수행"
  echo "[U-63][ERROR] visudo -c 출력:"
  echo "$VISUDO_OUT"

  # 롤백
  cp -p "$BACKUP" "$SUDOERS"
  chown root:root "$SUDOERS"
  chmod 0440 "$SUDOERS"

  # 롤백 후 재검증
  echo "[U-63][INFO] 롤백 후 재검증"
  visudo -c >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "[U-63][FATAL] 롤백 후에도 sudoers 검증 실패. 수동 점검 필요."
    exit 1
  fi

  echo "[U-63][INFO] 롤백 완료. (원인: sudoers 문법/구성 또는 외부 파일 문제 가능)"
  exit 1
fi

echo "[U-63] 조치 완료 (owner=root:root, perm=0440, visudo 검증 통과)"
exit 0
