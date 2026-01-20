#!/bin/bash

echo "[U-40] /etc/exports 파일 점검 및 NFS 공유 설정"

#####################################
# root 권한 확인
#####################################
if [ "$EUID" -ne 0 ]; then
    echo "[U-40][ERROR] root 권한 필요"
    exit 1
fi

EXPORTS_FILE="/etc/exports"

#####################################
# Step 1: 파일 존재 확인
#####################################
if [ ! -f "$EXPORTS_FILE" ]; then
    echo "[U-40][WARN] /etc/exports 파일 없음"
    exit 0
fi

#####################################
# Step 2: 파일 소유자 및 권한 확인/수정
#####################################
CURRENT_OWNER=$(stat -c "%U" "$EXPORTS_FILE")
CURRENT_PERM=$(stat -c "%a" "$EXPORTS_FILE")

if [ "$CURRENT_OWNER" != "root" ]; then
    chown root "$EXPORTS_FILE"
    echo "[U-40] /etc/exports 소유자를 root로 변경"
fi

if [ "$CURRENT_PERM" -ne 644 ]; then
    chmod 644 "$EXPORTS_FILE"
    echo "[U-40] /etc/exports 권한을 644로 변경"
fi

#####################################
# Step 3: 공유 디렉터리 및 권한 확인
#####################################
echo "[U-40] 현재 NFS 공유 설정:"
cat "$EXPORTS_FILE"

echo "[U-40] 공유 설정을 필요에 맞게 확인/수정하세요."
echo "예시) /home/example host1(ro,root_squash)"

#####################################
# Step 4: NFS 설정 적용
#####################################
exportfs -ra
echo "[U-40] NFS 설정 적용 완료"

exit 0

