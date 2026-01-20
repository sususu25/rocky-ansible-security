#!/bin/bash

echo "[U-09] 불필요한 그룹 점검"

PASSWD_USERS=$(cut -d: -f1 /etc/passwd | sort)

echo
echo "[U-09] 그룹 점검 결과"

while IFS=: read -r group_name passwd gid members; do
    # root, daemon 등 핵심 그룹 제외
    if [ "$gid" -lt 1000 ]; then
        continue
    fi

    if [ -z "$members" ]; then
        echo "[CHECK] 구성원 없는 그룹: $group_name (GID=$gid)"
        continue
    fi

    for user in $(echo "$members" | tr ',' ' '); do
        if ! echo "$PASSWD_USERS" | grep -qw "$user"; then
            echo "[CHECK] 존재하지 않는 사용자($user)를 포함한 그룹: $group_name"
        fi
    done

done < /etc/group

echo
echo "[U-09][ACTION] 불필요한 그룹은 관리자 판단 후 수동 제거"
echo "  groupdel <groupname>"

echo "[U-09] 점검 완료"
exit 0

