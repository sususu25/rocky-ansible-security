#!/bin/bash

echo "[U-24] 홈 디렉터리 환경변수 파일 소유자 및 권한 점검/조치 (최소 변경)"

if [ "$EUID" -ne 0 ]; then
  echo "[U-24][ERROR] root 권한 필요"
  exit 1
fi

ENV_FILES=(
  ".profile"
  ".kshrc"
  ".cshrc"
  ".bashrc"
  ".bash_profile"
  ".login"
  ".exrc"
  ".netrc"
)

# 일반 사용자 홈(UID>=1000, nologin 제외)
USER_HOMES=$(awk -F: '$3 >= 1000 && $7 !~ /nologin/ {print $6}' /etc/passwd | sort -u)

FAIL_FLAG=false

for home in $USER_HOMES; do
  [ -d "$home" ] || continue
  echo "[U-24] 사용자 홈 디렉터리: $home"

  home_owner="$(stat -c "%U" "$home" 2>/dev/null || echo "")"
  [ -n "$home_owner" ] || continue

  for file in "${ENV_FILES[@]}"; do
    target="$home/$file"
    [ -f "$target" ] || continue

    echo "[U-24] 점검 대상: $target"

    owner="$(stat -c "%U" "$target" 2>/dev/null || echo "")"
    perm="$(stat -c "%a" "$target" 2>/dev/null || echo "")"

    # 1) 소유자: root 또는 해당 계정(home_owner) 허용
    if [ "$owner" != "root" ] && [ "$owner" != "$home_owner" ]; then
      if chown "$home_owner:$home_owner" "$target"; then
        echo "[U-24][FIX] 소유자 변경: $owner -> $home_owner"
      else
        echo "[U-24][ERROR] chown 실패: $target"
        FAIL_FLAG=true
      fi
    fi

    # 2) 권한: root/소유자 외 쓰기권한 제거(최소 변경)
    #    - group write / other write가 있으면 제거
    #    - 600으로 강제하지 않음(과조치 방지)
    if [ -n "$perm" ]; then
      perm_int=$((8#$perm))
      need_write_fix=false

      # group write(020) 또는 other write(002)
      if (( (perm_int & 020) != 0 )) || (( (perm_int & 002) != 0 )); then
        need_write_fix=true
      fi

      if [ "$need_write_fix" = true ]; then
        if chmod go-w "$target"; then
          new_perm="$(stat -c "%a" "$target" 2>/dev/null || echo "")"
          echo "[U-24][FIX] 쓰기권한 제거(go-w): $perm -> $new_perm"
        else
          echo "[U-24][ERROR] chmod 실패: $target"
          FAIL_FLAG=true
        fi
      fi
    fi
  done
done

echo "[U-24] 점검/조치 완료"

if [ "$FAIL_FLAG" = true ]; then
  exit 1
fi
exit 0
