#!/bin/bash

echo "[U-39] 불필요한 NFS 서비스 및 socket 비활성화"

if [ "$EUID" -ne 0 ]; then
    echo "[U-39][ERROR] root 권한 필요"
    exit 1
fi

NFS_SERVICES=("nfs-server" "nfs-client.target" "nfs-lock" "rpcbind")
RPCBIND_SOCKETS=("rpcbind.socket")

# 서비스 중지 및 비활성화
for svc in "${NFS_SERVICES[@]}"; do
    if systemctl list-units --type=service | grep -q "$svc"; then
        systemctl stop "$svc"
        systemctl disable "$svc"
        echo "[U-39] $svc 서비스 중지 및 비활성화 완료"
    fi
done

# rpcbind socket 비활성화
for sock in "${RPCBIND_SOCKETS[@]}"; do
    if systemctl list-units --type=socket | grep -q "$sock"; then
        systemctl stop "$sock"
        systemctl disable "$sock"
        echo "[U-39] $sock socket 중지 및 비활성화 완료"
    fi
done

echo "[U-39] NFS 관련 서비스 및 socket 점검 완료"
exit 0

