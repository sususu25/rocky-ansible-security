#!/bin/bash
# U-59.sh - SNMP v3 사용자 점검 및 설정 (사용 안하면 스킵)

SNMP_USER="myuser"
AUTH_PROTO="SHA"
AUTH_PASS="myauthpass"
PRIV_PROTO="AES"
PRIV_PASS="myprivpass"

echo "[U-59] SNMP v3 사용자 점검 및 설정 시작"

# Step 0: SNMP 서비스 확인
if ! systemctl list-units --type=service | grep -q snmpd; then
    echo "[U-59] SNMP 서비스(snmpd) 없음 → 사용 안함, 설정 스킵"
    exit 0
fi

echo "[U-59] SNMP 서비스 확인 완료"

# Step 1: SNMP v3 접속 테스트
snmpwalk -v3 -l authPriv -u $SNMP_USER -a $AUTH_PROTO -A $AUTH_PASS -x $PRIV_PROTO -X $PRIV_PASS 127.0.0.1 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "[U-59] SNMP v3 사용자 '$SNMP_USER' 존재"
else
    echo "[U-59] SNMP v3 사용자 '$SNMP_USER' 없음 → 생성 진행"
    if ! command -v net-snmp-create-v3-user >/dev/null 2>&1; then
        echo "[U-59] net-snmp-create-v3-user 명령 없음 → 설치 필요, 생성 스킵"
        exit 0
    fi
    # Step 2: SNMP v3 사용자 생성
    net-snmp-create-v3-user -ro -A $AUTH_PASS -X $PRIV_PASS -a $AUTH_PROTO -x $PRIV_PROTO $SNMP_USER
    # Step 3: /etc/snmp/snmpd.conf 파일 내 SNMPv3 사용자 추가
    createUser $SNMP_USER $AUTH_PROTO $AUTH_PASS $PRIV_PROTO $PRIV_PASS
    # Step 4: 사용자 읽기 권한 추가
    rouser $SNMP_USER
fi

# Step 5: SNMP 서비스 실행
systemctl restart snmpd
echo "[U-59] SNMP v3 설정 완료"

