#!/bin/bash

echo "[U-23] SUID/SGID 설정 파일 점검 및 조치 (안전 Enforce 버전)"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-23][ERROR] root 권한 필요"
    exit 1
fi

#####################################
# find 명령어 존재 여부 확인
#####################################
if ! command -v find >/dev/null 2>&1; then
    echo "[U-23][ERROR] find 명령어 없음"
    exit 1
fi

#####################################
# 정책(Enforce 우선, 단 시스템 핵심 바이너리는 자동 변경 금지)
# - 자동 조치 범위: 사용자/앱이 임의 파일을 만들 수 있는 영역
# - 추가 확인 범위: /usr/bin/sudo, /usr/bin/passwd, /usr/bin/su 등 핵심 바이너리
#####################################
AUTO_PATHS=(
    "/home"
    "/tmp"
    "/var/tmp"
    "/usr/local"
    "/opt"
    "/srv"
)

CRITICAL_FILES=(
    "/usr/bin/sudo"
    "/usr/bin/passwd"
    "/usr/bin/su"
)

REMOVED_COUNT=0
FOUND_COUNT=0

#####################################
# 1) 자동 조치(Enforce): AUTO_PATHS 내 SUID/SGID 제거
#####################################
for path in "${AUTO_PATHS[@]}"; do
    if [ -d "$path" ]; then
        echo "[U-23] 자동 조치 대상 경로 검사: $path"
        while IFS= read -r file; do
            [ -z "$file" ] && continue
            FOUND_COUNT=$((FOUND_COUNT + 1))

            # 혹시라도 critical 파일이 AUTO_PATHS에 링크로 걸리는 등 예외 방지
            for c in "${CRITICAL_FILES[@]}"; do
                if [ "$file" = "$c" ]; then
                    echo "[U-23][SKIP] 핵심 바이너리 자동조치 금지: $file"
                    continue 2
                fi
            done

            BEFORE="$(stat -c '%A %U:%G %a %n' "$file" 2>/dev/null)"
            chmod u-s,g-s "$file" 2>/dev/null
            AFTER="$(stat -c '%A %U:%G %a %n' "$file" 2>/dev/null)"
            REMOVED_COUNT=$((REMOVED_COUNT + 1))
            echo "[U-23][FIX] SUID/SGID 제거: $BEFORE -> $AFTER"
        done < <(find "$path" -xdev -type f \( -perm -04000 -o -perm -02000 \) 2>/dev/null)
    fi
done

#####################################
# 2) 추가 확인(자동 변경 금지): 핵심 바이너리 상태만 출력
#####################################
echo "[U-23] 추가 확인(자동 변경 금지) - 핵심 바이너리 점검"
for f in "${CRITICAL_FILES[@]}"; do
    if [ -f "$f" ]; then
        if [ -u "$f" ] || [ -g "$f" ]; then
            echo "[U-23][CHECK] 핵심 바이너리 특수권한 존재(자동 미조치): $(stat -c '%A %U:%G %a %n' "$f")"
        else
            echo "[U-23][OK] 핵심 바이너리 특수권한 없음: $(stat -c '%A %U:%G %a %n' "$f")"
        fi
    else
        echo "[U-23][INFO] 파일 없음: $f"
    fi
done

#####################################
# 결과 요약
#####################################
if [ "$FOUND_COUNT" -eq 0 ]; then
    echo "[U-23][RESULT] 자동 조치 대상 경로 내 SUID/SGID 파일 없음 (양호)"
else
    echo "[U-23][RESULT] 자동 조치 대상 경로 발견 $FOUND_COUNT건 중 $REMOVED_COUNT건 SUID/SGID 제거"
fi

echo "[U-23] 점검/조치 완료"
exit 0
