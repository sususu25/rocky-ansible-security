#!/bin/sh

HOSTNAME=`hostname`

LANG=C
LANG=ko.UTF-8
export LANG
mkdir $HOSTNAME
mkdir $HOSTNAME/Script
# LastUpdate : 2023.01.19

######################################
########## 기본 설정 Check ###########
######################################

PASSWD="/etc/passwd"					#### 패스워드 파일 위치 ####
SHADOW="/etc/shadow"					#### 쉐도우 파일 위치 ####
GROUP="/etc/group"					#### group 파일 위치 ####
PASSWD_CONF_1="/etc/login.defs"				#### 패스워드 정책 파일 위치 ####
PASSWD_CONF_2="/etc/pam.d/system-auth"			#### 패스워드 정책 파일 위치 ####
HOSTS_EQUIV="/etc/hosts.equiv"				#### hosts.equiv 파일 위치 ####
LOGIN_CONF="/etc/pam.d/login"				#### 로그인 설정 파일 위치 ####
INETD_CONF="/etc/inetd.conf"				#### inetd.conf 파일 위치 ####
XINETD_CONF="/etc/xinetd.conf"				#### inetd.conf 파일 위치 ####
HOSTS="/etc/hosts"					#### hosts 파일 위치 ####
CRON_ALLOW="/etc/cron.allow"				#### cron.allow 파일 위치 ####
CRON_DENY="/etc/cron.deny"				#### cron.deny 파일 위치 ####
AT_ALLOW="/etc/at.allow"				#### at.allow 파일 위치 ####
AT_DENY="/etc/at.deny"					#### at.deny 파일 위치 ####
TELNET_BANNER="/etc/issue"				#### 텔넷 로그인 배너 설정 파일 ####
FTP_BANNER="/etc/banners/ftp.msg"			#### FTP 로그인 배너 설정 파일 ####
SYSLOG_CONF="/etc/syslog.conf"				#### SYSLOG 설정 파일 ####
SERVICES="/etc/services"				#### services 파일 위치 ####
SNMP_CONF="/etc/snmp/snmpd.conf"			#### snmpd 설정 파일 위치 ####
SMTP_CONF="/etc/mail/sendmail.cf"			#### 센드메일 설정 파일 ####
SMTP_SPAM="/etc/mail/access"				#### 스팸 릴레이 설정 파일 ####
SSH_CONFIG="/etc/ssh/sshd_config"			#### SSH 로그인 환경 설정 파일 ####
NAMED_CONF="/etc/named.conf"				#### DNS 환경설정 파일 ####


######################################

##### version 1.0 #####

echo "***************************************************************************"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "*																		  *"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "*		Script LINUX CheckList(기반시설) v1.0								  *"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "*																		  *"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "*		Copyright 2024 Script Co. Ltd. All right Reserved				  *"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "*																		  *"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "***************************************************************************"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	chmod 755 $HOSTNAME/$HOSTNAME.txt
echo "* Start Time "																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	date																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "=================== System Information Query Start ====================="
echo "=================== System Information Query Start ====================="  													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	ifconfig -a		>> $HOSTNAME/Script/Network.Config.txt 2>&1
	ps -ef | grep -v grep | grep -v ps | sort | uniq		>> $HOSTNAME/Script/process.txt 2>&1
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	netstat -an | grep -i listen			>> $HOSTNAME/Script/port.txt 2>&1
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "Apache서비스 실행여부 확인중입니다."
echo "### Apache 서비스 확인 ###"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
APACHESTATUS=0
PROCESS=`ps -ef | grep -i "http" |grep -v "grep" | wc -l`
if [ $PROCESS -ne 0 ]; then
	echo ""																																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	APACHESTATUS="ON"
	echo "[APACHE SERVICE = ON]"
	echo "[APACHE SERVICE = ON]"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	APACHE_FIND=`ps -eo args | grep -v "grep" | grep -i "httpd.conf" | sort | uniq | wc -l`
	if [ $APACHE_FIND -eq 0 ]; then
		for HTTPD in `ps -eo args | awk '{print $1}' | grep -v "grep" | egrep -i "httpd|apache2" | sort | uniq`
		do
			HTTPD_ROOT=`$HTTPD -V | grep -i "HTTPD_ROOT" | awk -F"\"" '{print $2}'`
			APACHE_CONF=`$HTTPD -V | grep -i "SERVER_CONFIG_FILE" | awk -F"\"" '{print $2}'`
		done
		echo "아파치 HOME PATH : $HTTPD_ROOT" 											>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "아파치 CONFIG PATH : $HTTPD_ROOT/$APACHE_CONF" 											>> $HOSTNAME/$HOSTNAME.txt 2>&1
			cat $HTTPD_ROOT/$APACHE_CONF																									> $HOSTNAME/$HOSTNAME.apacheconf.txt 2>&1
	else
		for APACHE_CONF in `ps -e -o args | grep -v "grep" | awk 'BEGIN{ OFS="\n"} {i=1; while(i<=NF) {print $i; i++}}' | grep -i "httpd.conf" | sort | uniq`
		do
			HTTPD=`ps -eo args | awk '{print $1}' | grep -v "grep" | egrep -i "httpd|apache2" | sort | uniq`
			HTTPD_ROOT=`$HTTPD -V | grep -i "HTTPD_ROOT" | awk -F"\"" '{print $2}'`
		done
		echo "아파치 HOME PATH : $HTTPD_ROOT" 											>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "아파치 CONFIG PATH : $APACHE_CONF" 											>> $HOSTNAME/$HOSTNAME.txt 2>&1
			cat $APACHE_CONF																									> $HOSTNAME/$HOSTNAME.apacheconf.txt 2>&1
	fi
else
	echo "[APACHE SERVICE = OFF]"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
fi
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo " "
echo "======================= System Information Query End ========================"
echo "======================= System Information Query End ========================" 												>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo " " 																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "========================== 진단 시작 ========================="  																>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "******************************** 1. 계정 관리 ******************************"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "-------------------- U-01. root 계정 원격 접속 제한 -----------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 원격 터미널 서비스를 사용하지 않거나, 사용 시 root 직접 접속을 차단한 경우 양호"										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* sh 진단"																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat $SSH_CONFIG | grep "PermitRootLogin" | grep -v "setting"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
		
	if [ `cat $SSH_CONFIG | grep -i "PermitRootLogin no" | grep -v '#' | wc -l` -gt 0 ]
	then
		result_sshd='true'
	else
		result_sshd='false'
	fi

if [ $result_sshd = 'true' ]
   	then
		echo ""													>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> root 계정의 원격 접속을 제한하였으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   	else
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> root 계정의 원격 접속을 제한하지 않았으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/securetty 진단"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/securetty | grep pts																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/pam.d/login 진단"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/pam.d/login | grep pam_securetty.so																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-1 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "★★★★참고★★★★"																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "PermitRootLogin forced-commands-only"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "-> Ubutu & Amazon Linux의 경우 위와같이 사용하며 "root"로 특정 명령어 실행하기 위해 사용하므로 양호함"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "★★★★★★★★★★"																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "SSH - PermitRootLogin no로 설정"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/securetty 파일에 pts/0~9가 설정되어 있으면 주석 처리 또는 삭제"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/pam.d/login파일에 'auth required /lib/security/pam_securetty.so' 설정"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-02. 패스워드 복잡도 설정 ---------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 영문, 숫자, 특수문자 조합하여 2종류 조합시 10자리, 3자리 이상 조합시 8자리로 패스워드 설정시 양호(공공기관 9자리 이상)"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[RHEL5]"  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/pam.d/system-auth 파일 점검"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/pam.d/system-auth | grep password																					>> $HOSTNAME/$HOSTNAME.txt 2>&1

	if [ `cat /etc/pam.d/system-auth | grep -i 'minlen' | grep -v '#'| grep -v 'maxrepeat' | wc -l` -gt 0 ]
	then
		result_RHEL5='true'
	else
		result_RHEL5='false'
	fi

if [ $result_RHEL5 = 'true' ]
   	then
		echo ""													>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> 패스워드 복잡도 설정이 적절하므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "** 결과값 참고하여 수동진단 필요" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   	else
		echo ""													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> 패스워드 복잡도 설정이 적용되어 있지 않으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
fi
:<<"END"
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[RHEL7]"  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/security/pwquality.conf 파일 점검"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/security/pwquality.conf | grep =								>> $HOSTNAME/$HOSTNAME.txt 2>&1
END
	if [ `cat /etc/security/pwquality.conf | grep -i '=' | grep -v '#' | wc -l` -gt 0 ]
	then 
		result_RHEL7='true'
	else
		result_RHEL7='false'
	fi

	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[RHEL7]"  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1

	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/security/pwquality.conf 파일 점검"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
	cat /etc/security/pwquality.conf | grep -i '=' | egrep -v 'difok|minclass|maxrepeat|maxclassrepeat|gecoscheck|dictpath'							>> $HOSTNAME/$HOSTNAME.txt 2>&1

if [ $result_RHEL7 = 'true' ]
   	then
		echo ""													>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> 패스워드 복잡도 설정이 적절하므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "** 결과값 참고하여 수동진단 필요" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   	else
		echo ""													>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> 패스워드 복잡도 설정이 주석(#)또는 Default 값이므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
fi
		
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-2 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "★★★★참고★★★★"																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "둘 중 하나라도 '양호'일 시 양호"																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "★★★★★★★★★★"																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "HOSTNAME.etc.pam.d.system-auth.txt 파일을 참고하여 패스워드를 영문, 숫자 혼합 사용하여 복잡하게 설정"							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "password requisite /lib/security/$ISA/pam_cracklib.so설정이 되어있다면 양호"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "retry=3 minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "retry   : 패스워드 입력 실패 시 재시도 횟수"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "minlen  : 최소 패스워드 길이 설정"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "lcredit : 최소 소문자 요구"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "ucredit : 최소 대문자 요구"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "dcredit : 최소 숫자 요구"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "ocredit : 최소 특수문자 요구"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-03. 계정잠금 임계값을 설정 -------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 계정 잠금 임계값이 5이하인 경우 양호"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/pam.d/system-auth 파일 점검"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/pam.d/system-auth | grep deny=																						>> $HOSTNAME/$HOSTNAME.txt 2>&1

if [ `cat /etc/pam.d/system-auth | grep -i 'deny=' | grep -v '#' | wc -l` -ge 1 ]
	then
		result_deny='true'
	else
		result_deny='false'
fi

if [ $result_deny = 'true' ]
   	then
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> 계정 잠금 임계값이 적절하므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
   	else
		echo "※ 계정 잠금 임계값 설정 없음"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> 계정 잠금 임계값이 설정되어 있지 않으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
fi

	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-3 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "HOSTNAME.etc.pam.d.system-auth.txt 파일을 참고하여 아래와 같이 설정"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "auth required /lib/security/pam_tally.so deny=5 lock_time=120 no_magic_root reset 설정이 되어있다면 양호"					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "deny=5 5회 실패 시 계정 잠금"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "lock_time=120 120초간 계정 잠금"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-04. 패스워드 파일 보호 -----------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 쉐도우 패스워드 사용하거나, 패스워드를 암호화하여 저장한 경우 양호" 													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "* $SHADOW 파일 확인"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat $SHADOW																													> $HOSTNAME/$HOSTNAME.SHADOW.txt 2>&1
		ls -aldL $SHADOW 																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/passwd 파일 점검"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/passwd | egrep -i "root:x|bin:x"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
  if [ `more /etc/passwd | awk -F: '{print $2}' | grep "!=x" | wc -l` -eq 0 ]
	then
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> Shadow 파일을 사용하여 패스워드를 암호화하여 저장하므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	else
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> 패스워드를 암호화하여 저장하지 않으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi	
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-4 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "  "																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "패스워드 혹은 쉐도우 파일 내 패스워드가 암호화되어 저장되어 있을 경우 C2 Level 적용 완료"										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-44. root이외의 UID가 '0'금지 ----------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: root 계정과 동일한 UID를 갖는 계정이 존재하지 않을 경우 양호"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* UID가 0인 사용자"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
		awk -F: '($3 == "0") {print $1}' $PASSWD																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
if [ `awk -F: '($3 == "0") {print $1}' $PASSWD | grep -v "root" | wc -l` -eq 0 ]
	then
		result_uidzero='true'
	else
		result_uidzero='false'
fi

if [ $result_uidzero = 'true' ]
	then
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> root 계정 외 UID가 '0'인 사용자가 존재하지 않으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	else
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> root 계정 외 UID가 '0'인 사용자가 존재하므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* GID 가 0인 사용자"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
		awk -F: '($4 == "0") {print $1}' $PASSWD																					>> $HOSTNAME/$HOSTNAME.txt 2>&1



	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-44 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "관례적으로 100보다 작은 UID들과 10보다 작은 GID들은 시스템 계정을 위해 사용됨"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-45. root계정 su제한 -------------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: su 명령어를 특정 그룹에 속한 사용자만 사용토록 제한되어 있는 경우 양호"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " 1.wheel그룹 구성원 존재 여부 확인"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/group | grep wheel																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " 2.wheel 그룹이 su 명령어를 사용할 수 있는지 설정 여부 확인 파일 권한 확인"										>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ls -l /usr/bin/su 																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ls -l /bin/su 																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* LINUX PAM모듈 이용 시"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " 3. 허용 그룹 (su 명령어 사용 그룹)설정 여부 확인"										>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/pam.d/su | grep pam_wheel.so																						>> $HOSTNAME/$HOSTNAME.txt 2>&1

	touch groupwheel.txt
	cat /etc/group | grep "wheel" |wc -L >> groupwheel.txt	

if [ `cat groupwheel.txt | grep "11" |  wc -l` -eq 1 ]
	then
		result_group='false'
	else
		result_group='true'
fi

if [ `cat /etc/pam.d/su | grep -i 'pam_wheel.so' | grep -v '#' | wc -l` -ge 1 ]
	then
		result_wheel='true'
	else
		result_wheel='false'
fi

if [ `ls -alL /bin/su | grep -i ".rwsr-x---" | wc -l` -eq 1 ]
	then
		result_binsu='true'
	else
		result_binsu='false'
fi		

if [ `ls -alL /usr/bin/su | grep ".rwsr-x---" | wc -l` -eq 1 ]
	then
		result_usrsu='true'
	else
		result_usrsu='false'
fi		


if [ $result_wheel = 'true' ]
   	then
		if [ $result_group = 'true' ] 
			then
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   				echo "> su 명령어 사용자를 제한하였으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	   			echo "> su 명령어 제한설정이 적용되어 있으나 wheel 그룹에 사용자 목록이 존재하지 않으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	else
		if [ $result_binsu = 'true' ] || [ $result_usrsu = 'true' ]
			then
				if [ $result_group = 'true' ] 
					then
						echo ""	>> $HOSTNAME/$HOSTNAME.txt 2>&1
						echo "> su 명령어 사용자를 제한하였으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
						echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
					else
						echo ""	>> $HOSTNAME/$HOSTNAME.txt 2>&1
						echo "> su 명령어 파일 권한은 적절하나 wheel 그룹에 사용자 목록이 존재하지 않으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
						echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
				fi
			else
				echo ""	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> su 명령어 사용자를 제한하지 않았으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
fi

rm groupwheel.txt
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-45 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "@ 권고사항"																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " 1~2. 권한있는 사용자만 su 명령어를 사용하도록 권한변경(그룹으로 관리)"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " 권한은 4750(-rwsr-x---) 권고, 4555(-r-sr-xr-x) 취약"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " 3. LINUX PAM모듈 이용 시 /etc/pam.d/su 내에 아래와 같이 주석제거(wheel그룹 활성화)"											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " auth required /lib/security/pam_wheel.so debug group=wheel "																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " auth required /lib/security/$ISA/pam_wheel.so use_id "																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-46. 패스워드 최소 길이 설정 ------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 패스워드 최소 길이가 9자 이상 설정시 양호(공공기관은 9자리 이상)"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* cat $PASSWD_CONF_1"																										>> $HOSTNAME/$HOSTNAME.PASSWD.CONF.txt 2>&1
		cat $PASSWD_CONF_1																											>> $HOSTNAME/$HOSTNAME.PASSWD.CONF.txt 2>&1
	echo "* 패스워드 최소 길이 설정 확인"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat $PASSWD_CONF_1 | grep -i PASS_MIN_LEN | grep -v "#"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1

	touch logminlen.txt
	cat /etc/login.defs | grep -i "pass_min_len" | grep -v "#" >> logminlen.txt	

if [ `awk '$2 >= 8 { print $2 }' ./logminlen.txt | wc -l` -eq 1 ]
	then
		result_minlen='true'
	else
		result_minlen='false'
fi

if [ $result_minlen = 'true' ]
	then
   		echo ""	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> 패스워드 최소 길이 설정이 8자리 이상으로 설정되어 있으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	else
   		echo ""	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> 패스워드 최소 길이 설정이 8자리 미만으로 설정되어 있으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
fi

rm logminlen.txt

	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-46 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "생성된 HOSTNAME.PASSWD.CONF.txt 파일 참고"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "default 값 및 각 계정의 minlen 값이 8으로 설정되어 있는지 확인"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-47. 패스워드 최대 사용 기간 설정 -------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 패스워드 최대 사용기간 90일(12주) 이하로 설정되어 있을시 양호"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 패스워드 최대 사용 기간 설정 확인"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/login.defs | grep -i "PASS_MAX_DAYS" | grep -v "#"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1

	touch maxday.txt
	cat /etc/login.defs | grep -i "pass_max_days" | grep -v "#" >> maxday.txt	

if [ `awk '$2 <= 90 { print $2 }' ./maxday.txt | wc -l` -eq 1 ]
	then
		result_maxday='true'
	else
		result_maxday='false'
fi

if [ $result_maxday = 'true' ]
	then
   		echo ""	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> 패스워드 최대 사용 기간 설정이 90일 이하이므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	else
   		echo ""	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> 패스워드 최대 사용 기간 설정이 90일보다 크게 설정되어 있으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
fi

rm maxday.txt


	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-47 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "최대 사용 기간을 설정할 경우 root로 su를 못할 수 있으므로 root의 경우 다음같이 설정하여"										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "패스워드가 만료되지 않도록 함."																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* passwd -x -1 root"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-48. 패스워드 최소 사용기간 설정 --------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 패스워드 최소 사용기간이 설정되어 있을시 양호"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 패스워드 최소 사용기간 설정 확인"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/login.defs | grep -i "PASS_MIN_DAYS" | grep -v "#"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1

	touch minday.txt
	cat /etc/login.defs | grep -i "pass_min_days" | grep -v "#" >> minday.txt	

if [ `awk '$2 >= 1 { print $2 }' ./minday.txt | wc -l` -eq 1 ]
	then
		result_minday='true'
	else
		result_minday='false'
fi

if [ $result_minday = 'true' ]
	then
   		echo ""	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> 패스워드 최소 사용기간 설정이 1일 이상이므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	else
   		echo ""	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> 패스워드 최소 사용 기간 설정이 1일 미만으로 설정되어 있으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
fi

rm minday.txt

	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-48 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "최소 사용 기간을 설정할 경우 root로 su를 못할 수 있으므로 root의 경우 다음같이 설정하여"										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "패스워드가 만료되지 않도록 함."																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* passwd -x -1 root"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-49. 불필요한 계정 제거 -----------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 불필요한 계정이 존재하지 않을시 양호"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo "* 사용하지 않는 Default 계정 점검"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
#		cat /etc/passwd | egrep "adm|lp|sync|uucp|shutdown|halt|news|operator|games|gopher|nfsnobody|squid"							>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo "[변경]"																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
#
		cat /etc/passwd | egrep -v "#|nologin|false"							>> $HOSTNAME/$HOSTNAME.txt 2>&1

if [ `cat /etc/passwd | egrep -v "#|nologin|false" | awk -F ":" '$3 >= 500 {print $1,$3}' | wc -l` -ge 1 ]
	then
   		echo ""	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> UID 500 이상의 추가로 생성한 사용자 계정이 존재함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "ㄴ 결과값 참고하여 수동점검" >> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "ㄴ 참고) 일반적으로 CentOS 6 이하 UID 500, CentOS 7 이상 UID 1000 부터 시작" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	else
   		echo ""	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> 일반사용자 계정이 존재하지 않으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-49 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/passwd의 계정설명은 가이드라인 부록참조"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "UID 100 이하 또는 60000 이상의 계정들은 시스템 계정으로 로그인이 필요없음"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "생성된 HOSTNAME.PASSWORD.txt를 통해 계정 확인"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "담당자와 인터뷰를 통해 불필요한 계정 확인 필요"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/bin/false"																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "-> 시스템의 로그인은 불가능, FTP 서버 프로그램같은 프로그램도 불가능하다."														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "쉘이나 ssh과 같은 터널링(원격접속) 그리고 홈디렉토리를 사용할 수 없다."															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/sbin/nologin"																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "-> 사용자 계정의 쉘부분에 /bin/nologin 으로 설정을 하면"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "로그인불가, 메시지들은 반환된다 ssh는 사용불가능하며 ftp의 경우 사용이 가능합니다."												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-50. 관리자 그룹에 최소한의 계정 포함 ----------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 관리자 그룹에 불필요 계정이 등록되어 있지 않을시 양호"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/group내에 root 계정 점검"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/group | grep root 																									>> $HOSTNAME/$HOSTNAME.txt 2>&1

if [ `cat /etc/group | grep "root:x" | awk '{print length($0)}'` -eq 9 ]
	then
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> 관리자 그룹에 불필요한 계정이 존재하지 않으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	else
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> 관리자 그룹에 추가 계정이 존재하므로 담당자 확인 필요" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
fi		
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-50 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "관리자 그룹에 최소한의 계정 포함에 대해 담당자 인터뷰 확인"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 예시"																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "system:!:0:root,test"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "system:!:0:root (test삭제)"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-51. 계정이 존재하지 않는 GID금지 -------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 시스템 관리나 운용에 불필요한 그룹이 삭제되어있을시 양호"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo "★         	  수정필요  		  ★"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "* /etc/group 점검,  root가 포함된 그룹에 속한 사용자 확인"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/group																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/group 2개 이상의 계정 점검"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/group | grep , | grep -v "grep" 																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/passwd	>> $HOSTNAME/$HOSTNAME.passwd.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "> /etc/passwd 파일수동점검 필요"																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo "* /etc/gshadow 참조"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
#		cat /etc/gshadow																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[참고]"																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "> 불필요한 그룹이 존재하지 않으므로 양호함"																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-51 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/group과 [Hostname].PASSWD의 GID가 상이한지 비교"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "같다면 양호 상이하다면 취약"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/group에서 그룹에 지정하지 않아도 gid값이 존재하면 해당 그룹 소속 계정이므로"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/passwd의 계정에 대한 GID값도 같이 확인 필요. 담당자와 인터뷰를 통해 검토 필요"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/group파일구성= 계정명(ID):패스워드:UID:GID:계정설명:홈 디렉터리:shell정보"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/gshadow파일구성= 그룹명:패스워드:관리자:멤버"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/gshadow파일: shadow파일에 사용자 계정의 암호가 저장되어 있는것 처럼"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "시스템 내 존재하는 그룹의 암호 정보 저장 파일로 그룹 관리자 및 구성원 설정 가능"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-52. 동일한 UID 금지 -------------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 동일한 UID로 설정된 사용자 계정이 존재하지 않을시 양호"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo "* 계정이 존재하지 않는 UID확인"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo "* UID 사용자"																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
#		awk -F: '($3 == "*") {print $1}' $PASSWD																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	cat /etc/passwd | awk -F ":" '{print $3}' > pwuid.txt
	cat pwuid.txt | sort | uniq -c | awk '$1 >= 2 {print "UID가 " $2 "인 계정 개수 : " $1 "개"}' >> doubleuid.txt
#	
#	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 동일한 UID 사용자 유무 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1

	cat doubleuid.txt  >> $HOSTNAME/$HOSTNAME.txt 2>&1

if [ `cat doubleuid.txt | wc -l` -ge 1 ]
	then
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> 동일한 UID를 가진 계정이 존재하므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "★★ /etc/passwd 파일 참고하여 체크리스트 작성 "																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	else
		echo "※ 동일한 UID 계정 없음"																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> 동일한 UID를 계정이 존재하지 않으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
fi

	
	rm doubleuid.txt
	rm pwuid.txt
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-52 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "UID가 동일한 계정에 대해 담당자 인터뷰 필요 후 진단"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "결과 값이 없다면 양호"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1


echo "-------------------- U-53. 사용자 shell 점검 -----------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 로그인이 불필요한 계정에 /bin/false(/sbin/nologin) 쉘이 부여되어있을 시 양호"											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/passwd내 불필요한 계정 유무 확인"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/passwd | egrep "^daemon|^bin|^sys|^adm|^listen|^nobody|^nobody4|^noaccess|^diag|^operator|^games|^gopher" | grep -v "admin" >> $HOSTNAME/$HOSTNAME.txt 2>&1

  if [ `cat /etc/passwd | egrep "^daemon|^bin|^sys|^adm|^listen|^nobody|^nobody4|^noaccess|^diag|^listen|^operator|^games|^gopher" | grep -v "admin" |  awk -F: '{print $7}'| egrep -v 'false|nologin|null|halt|sync|shutdown' | wc -l` -eq 0 ]
    then
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> 로그인이 불필요한 계정에 '/sbin/nologin(or /bin/fasle)' 쉘을 부여 하였으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
    else
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> 로그인이 필요하지 않은 계정에 '/sbin/nologin(or /bin/fasle)' 쉘을 부여하지 않았으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
  fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-53 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "일반적으로 로그인이 불필요한 계정"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "daemon, bin, sys, adm, listen, nobody, nobody4, noaccess, diag, operator, games, gopher "									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-54. Session Timeout설정 --------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: Session Timeout이 600초(10분) 이하 설정시 양호"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
:<<"END"
	echo "* /etc/profile 점검(TMOUT 유무 확인)"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/profile | egrep -i TMOUT																								>> $HOSTNAME/$HOSTNAME.txt 2>&1

	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/csh.login 점검(autologout 유무 확인)"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/csh.login | grep autologout | grep -v "grep"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1

	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/csh.cshrc 점검(autologout 유무 확인)"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/csh.cshrc | grep autologout | grep -v "grep"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1

		echo "" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "" >> $HOSTNAME/$HOSTNAME.txt 2>&1
END

if [ -f /etc/profile ]
	then
		if [ `cat /etc/profile | egrep -i "tmout|timeout" | grep -v '#' | wc -l` -gt 0 ]
			then
				echo "* /etc/profile 설정 확인"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				cat /etc/profile | egrep -i "tmout|timeout" | grep -v '#' 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""					>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> Session Timeout이 600초(10분) 이내로 설정되어 있으므로 양호함 "	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				if [ -f /etc/csh.cshrc ]
					then
						if [ `cat /etc/csh.cshrc | egrep -i "autologout" | grep -v '#' | wc -l` -gt 0 ]
							then
								echo "* /etc/csh.cshrc 설정 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
								cat /etc/csh.cshrc | egrep -i "autologout" | grep -v '#'  | grep -v '#' 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
								echo ""					>> $HOSTNAME/$HOSTNAME.txt 2>&1
								echo "> Session Timeout이 600초(10분) 이내로 설정되어 있으므로 양호함 "	>> $HOSTNAME/$HOSTNAME.txt 2>&1
							else
								if [ -f /etc/csh.login ]
									then
										if [ `cat /etc/csh.login | egrep -i "autologout" | grep -v '#' | wc -l` -gt 0 ]
											then
												echo "* /etc/csh.login 설정 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
												cat /etc/csh.login | egrep -i "autologout" | grep -v '#'	>> $HOSTNAME/$HOSTNAME.txt 2>&1
												echo ""					>> $HOSTNAME/$HOSTNAME.txt 2>&1
												echo "> Session Timeout이 600초(10분) 이내로 설정되어 있으므로 양호함 "	>> $HOSTNAME/$HOSTNAME.txt 2>&1
											else
												echo "* /etc/profile 설정 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
												echo "-> /etc/profile 설정 값 없음" >> $HOSTNAME/$HOSTNAME.txt 2>&1
												echo ""	>> $HOSTNAME/$HOSTNAME.txt 2>&1
												echo "* /etc/csh.cshrc 설정 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
												echo "-> /etc/csh.cshrc 설정 값 없음" >> $HOSTNAME/$HOSTNAME.txt 2>&1
												echo ""	>> $HOSTNAME/$HOSTNAME.txt 2>&1
												echo "* /etc/csh.login 설정 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
												echo "-> /etc/csh.login 설정 값 없음" >> $HOSTNAME/$HOSTNAME.txt 2>&1
												echo ""					>> $HOSTNAME/$HOSTNAME.txt 2>&1
												echo "> Session Timeout이 설정되어 있지 않으므로 취약함 "	>> $HOSTNAME/$HOSTNAME.txt 2>&1

										fi
								fi
						fi
				fi
		fi
fi

	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-54 END"
   		echo "★양호★ 일시 Session Timeout이 600초(10분) 이하로 설정되어있는지 확인 필요" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/profile에 'TMOUT=600(단위:초)', 'export TMOUT' 설정"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/csh.login or /etc/csh.cshrc에서 'set autologout=10(단위:분)' 확인 "													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "************************* 2. 파일 및 디렉터리 관리 *************************"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "-------------------- U-05. Root 홈, 패스 디렉터리 권한 및 패스 설정 -------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: PATH 환경변수에 "."이 맨 앞이나 중간에 포함되지 않을시 양호"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* echo PATH 환경변수 점검"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo $PATH 																														>> $HOSTNAME/$HOSTNAME.txt 2>&1			
   if [ \( `echo $PATH | grep "\.:" | wc -l` -eq 0 \) -a \( `echo $PATH | grep "::" | wc -l` -eq 0 \) -a \( `echo $PATH | grep "\." | wc -l` -eq 0 \) ] 
   then
      echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	  echo "> PATH 환경변수가 적절하게 설정되어 있으므로 양호함"                                                    >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
   else
      echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	  echo "> PATH 환경변수에 "."이 맨 앞 혹은 중간에 포함되어 있으므로 취약함"                                              >> $HOSTNAME/$HOSTNAME.txt 2>&1
   fi   	
  	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-05 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "PATH 환경변수에 "." 이 맨 앞이나 중간에 포함되지 않은 경우 양호"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

	echo "-------------------- U-06. 파일 및 디렉터리 소유자 설정 -------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 소유자가 존재하지 않는 파일 및 디렉터리가 존재하지 않을시 양호"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
  	echo " " 																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 소유자가 존재하지 않는 파일 확인" 																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ `timeout 300s find / \( ! \( \( -path /nfs -o -path /proc \) -prune \) -and \( -nouser -o -nogroup \) \) -exec ls -ald {} \; | wc -l` -eq 0 ]
		then
			echo "※ 소유자가 존재하지 않는 파일 및 디렉터리 없음" 														>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo " " 																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> 소유자가 존재하지 않는 파일 및 디렉터리가 존재하지 않으므로 양호함" 														>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
			echo "------------------------" 											>> $HOSTNAME/$HOSTNAME.txt 2>&1
			timeout 300s find / \( ! \( \( -path /nfs -o -path /proc \) -prune \) -and \( -nouser -o -nogroup \) \) -exec ls -ald {} \;					>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> 소유자가 존재하지 않는 파일 및 디렉터리가 존재하므로 취약함" 																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
  	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-06 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
  	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "▶ 점검기준 : 소유자가 존재하지 않은 파일 및 디렉터리가 존재하지 않은 경우 양호" 												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "해당 명령어들은 서버의 과부하를 줄 가능성이 있으므로 고객과 협의하여"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "스크립트를 실행하여 또한 인터뷰로 대채하거나 위험 가능성이 있는"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "디렉토리만 선택하여 명령어를 수행한다."																					  >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "-------------------- U-07. /etc/passwd 파일 소유자 및 권한 설정 -----------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1	
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: /etc/passwd 파일의 소유자가 root이고, 권한이 644 이하일시 양호"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/passwd 파일 점검"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f /etc/passwd ] 
	then
		ls -alL /etc/passwd 																										>> $HOSTNAME/$HOSTNAME.txt 2>&1	
		if [ `ls -alL /etc/passwd | awk '{print $3}' | grep "root" | wc -l` -eq 0 ]
		then
			echo " "  					>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> /etc/passwd 파일의 소유자가 root로 설정되어 있지 않으므로 취약함" 													>> $HOSTNAME/$HOSTNAME.txt 2>&1	
		else
			if [ `ls -alL /etc/passwd | awk '{print $1}' | grep '...-.--.--' | wc -l` -eq 1 ]
			then
				echo " "  					>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 파일의 소유자가 root이고 권한이 '644(-rw-r--r--)'이하로 설정되어 있으므로 양호함" 												>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else 
				echo " "  					>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 파일의 소유자가 root로 설정되어 있지만 권한이 '644(-rw-r--r--)'이하로 설정되어 있지 않으므로 취약함" 								>> $HOSTNAME/$HOSTNAME.txt 2>&1
			fi
		fi
	else 
		echo "※ '/etc/passwd' 파일이 존재하지 않습니다."																				 >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo " "  					>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> '/etc/passwd' 파일이 존재하지 않으므로 인터뷰/파일경로 확인 필요"  					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-07 END"
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "-------------------- U-08. /etc/shadow 파일 소유자 및 권한 설정 -----------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: /etc/shadow 파일의 소유자가 root이고, 권한이 400이하 일시 양호"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f /etc/shadow ] 
	then
		echo "* /etc/shadow 파일 점검" 																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ls -alL /etc/shadow 																										>> $HOSTNAME/$HOSTNAME.txt 2>&1	
		if [ `ls -alL /etc/shadow | awk '{print $3}' | grep "root" | wc -l` -eq 0 ]
		then
			echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> /etc/shadow 파일의 소유자가 root로 설정되어 있지 않으므로 취약함" 													>> $HOSTNAME/$HOSTNAME.txt 2>&1	
		else
			if [ `ls -alL /etc/shadow | awk '{print $1}' | grep '..--------' | wc -l` -eq 1 ]
			then
				echo " "  					>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 파일의 소유자가 root이고 권한이 '400(-r--------)'이하로 설정되어 있으므로 양호함" 												>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else 
				echo " "  					>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 파일의 소유자가 root로 설정되어 있지만 권한이 '400(-r--------)'이하로 설정되어 있지 않으므로 취약함" 								>> $HOSTNAME/$HOSTNAME.txt 2>&1
			fi
		fi
	else 
				echo "※ '/etc/shadow' 파일이 존재하지 않습니다." 																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "  "					>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> '/etc/shadow' 파일이 존재하지 않으므로 인터뷰/파일경로 확인 필요  "					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-08 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "* 소유자 root, -r--------   under 400" 																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-09. /etc/hosts 파일 소유자 및 권한 설정 ------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: /etc/hosts 파일의 소유자가 root이고, 권한이 600일시 양호"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/hosts 파일 점검" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f /etc/hosts ] 
	then
	
		ls -alL /etc/hosts >> $HOSTNAME/$HOSTNAME.txt 2>&1	
		if [ `ls -alL /etc/hosts | awk '{print $3}' | grep "root" | wc -l` -eq 0 ]
		then
		echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> /etc/hosts 파일의 소유자가 root로 설정되어 있지 않으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1	
		else
			if [ `ls -alL /etc/hosts | awk '{print $1}' | grep '.rw-------' | wc -l` -eq 1 ]
			then
				echo " "  					>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 파일의 소유자가 root이고 권한이 600으로 설정되어 있으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
			else 
				echo " "  					>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 파일의 소유자가 root로 설정되어 있지만 권한이 600으로 설정되어 있지 않으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
			fi
		fi
	else 
		echo " "  					>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "※ '/etc/hosts' 파일이 존재하지 않습니다." >> $HOSTNAME/$HOSTNAME.txt 2>&1	
		echo "> '/etc/hosts' 파일이 존재하지 않으므로 인터뷰/파일경로 확인 필요  "  					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-09 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "소유자 root, -rw-------   under 600"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "-------------------- U-10. /etc/(x)inetd.conf 파일 소유자 및 권한 설정 ----"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: /etc/inetd.conf 파일의 소유자가 root이고, 권한이 600일시 양호"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/(x)inetd.conf 파일 점검"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
#		if [ -f $INETD_CONF ]
#	then
#		ls -aldL $INETD_CONF																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	else
#		echo "※ /etc/inetd.conf 파일 존재하지 않음"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	fi			
#echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
#echo "* /etc/xinetd.conf 파일 점검"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
#ls -aldL $XINETD_CONF																										>> $HOSTNAME/$HOSTNAME.txt 2>&1


	if [ -f /etc/inetd.conf ] 
	then
		echo "/etc/inetd.conf 퍼미션" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		ls -alL /etc/hosts >> $HOSTNAME/$HOSTNAME.txt 2>&1	
		if [ `ls -alL /etc/inetd.conf | awk '{print $3}' | grep "root" | wc -l` -eq 0 ]
		then
			echo "> '/etc/inetd.conf' 파일의 소유자가 root로 설정되어 있지 않으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1	
		else
			if [ `ls -alL /etc/inetd.conf | awk '{print $1}' | grep '.rw-------' | wc -l` -eq 1 ]
			then
				echo "> 파일의 소유자가 root이고 권한이 600으로 설정되어 있으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
			else 
				echo "> 파일의 소유자가 root로 설정되어 있지만 권한이 600으로 설정되어 있지 않으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
			fi
		fi
	else 
		result_inetd='na'
		echo "※ /etc/inetd.conf 파일이 존재하지 않습니다." >> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi	
	if [ -f /etc/xinetd.conf ] 
	then
		echo "/etc/xinetd.conf 퍼미션" 																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ls -alL /etc/hosts 																											>> $HOSTNAME/$HOSTNAME.txt 2>&1	
		if [ `ls -alL /etc/xinetd.conf | awk '{print $3}' | grep "root" | wc -l` -eq 0 ]
		then
			echo "> '/etc/xinetd.conf' 파일의 소유자가 root로 설정되어 있지 않으므로 취약함" 												>> $HOSTNAME/$HOSTNAME.txt 2>&1	
		else
			if [ `ls -alL /etc/xinetd.conf | awk '{print $1}' | grep '.rw-------' | wc -l` -eq 1 ]
			then
				echo "> 파일의 소유자가 root이고 권한이 600으로 설정되어 있으므로 양호함" 													>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else 
				echo "> 파일의 소유자가 root로 설정되어 있지만 권한이 600으로 설정되어 있지 않으므로 취약함" 								>> $HOSTNAME/$HOSTNAME.txt 2>&1
			fi
		fi
	else 
		result_xinetd='na'
		echo "※ /etc/xinetd.conf 파일이 존재하지 않습니다." 																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi																																>> $HOSTNAME/$HOSTNAME.txt 2>&1

	if [ $result_inetd = 'na' -a  $result_xinetd = 'na' ]
		then
			echo "> '/etc/(x)inetd.conf' 파일이 존재하지 않으므로 해당없음" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-10 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "소유자 root, -rw-------   under 600"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "-------------------- U-11. /etc/syslog.conf 파일 소유자 및 권한 설정 ------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: /etc/syslog.conf 파일의 소유자가 root(또는 bin, sys)이고, 권한이 640 이하일시 양호"									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo "syslog.conf 확인" 																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	ls -alL /etc/syslog.conf 																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo "rsyslog.conf 확인" 																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	ls -alL /etc/rsyslog.conf 																										>> $HOSTNAME/$HOSTNAME.txt 2>&1	
#	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f /etc/syslog.conf ] 
	then
		echo "* /etc/syslog.conf 파일 확인" 																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ls -alL /etc/syslog.conf 																									>> $HOSTNAME/$HOSTNAME.txt 2>&1	
		if [ `ls -alL /etc/syslog.conf | awk '{print $3}' | egrep '(root|bin|sys)' | wc -l` -ge 1 ]
		then
			if [ `ls -alL /etc/syslog.conf | awk '{print $1}' | grep '...-.-----' | wc -l` -eq 1 ]
			then
					echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 파일의 소유자가 root(bin, sys)이고 권한이 640이하로 설정되어 있으므로 양호함" 									>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else 
					echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 파일의 소유자가 root(bin, sys)로 설정되어 있지만 권한이 640이하로 설정되어 있지 않으므로 취약함" 					>> $HOSTNAME/$HOSTNAME.txt 2>&1
			fi
		else
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> 파일의 소유자가 root(bin, sys)로 설정되어 있지 않으므로 취약함" 													>> $HOSTNAME/$HOSTNAME.txt 2>&1	
		fi
	else 
		if [ -f /etc/rsyslog.conf ] 
		then
			echo "* /etc/rsyslog.conf 파일 확인" 																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
			ls -alL /etc/rsyslog.conf 																								>> $HOSTNAME/$HOSTNAME.txt 2>&1	
			if [ `ls -alL /etc/rsyslog.conf | awk '{print $3}' | egrep '(root|bin|sys)' | wc -l` -ge 1 ]
			then
				if [ `ls -alL /etc/rsyslog.conf | awk '{print $1}' | grep '...-.-----' | wc -l` -eq 1 ]
				then
						echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
					echo "> 파일의 소유자가 root(bin, sys)이고 권한이 640이하로 설정되어 있으므로 양호함" 								>> $HOSTNAME/$HOSTNAME.txt 2>&1
				else 
						echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
					echo "> 파일의 소유자가 root(bin, sys)로 설정되어 있지만 권한이 640이하로 설정되어 있지 않으므로 취약함"			 >> $HOSTNAME/$HOSTNAME.txt 2>&1
				fi
			else
					echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 파일의 소유자가 root(bin, sys)로 설정되어 있지 않으므로 취약함" 												>> $HOSTNAME/$HOSTNAME.txt 2>&1	
			fi
		else 
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> /etc/syslog.conf, /etc/rsyslog.conf 파일이 존재하지 않습니다." 														>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1

	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-11 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 소유자 root, -rw-r-----   under 640"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-12. /etc/services 파일 소유자 및 권한 설정 ---------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: /etc/services 파일의 소유자가 root(또는 bin, sys)이고, 권한이 644 이하일시 양호"										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/services 점검"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ls -aldL $SERVICES																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ `ls -alL /etc/services | awk '{print $3}' | egrep '(root|bin|sys)' | wc -l` -ge 1 ]
	then
		if [ `ls -alL /etc/services | awk '{print $1}' | grep '...-.--.--' | wc -l` -eq 1 ]
		then
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1	
	echo "> 파일의 소유자가 root(bin, sys)이고 권한이 644이하로 설정되어 있으므로 양호함" 									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else 
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> 파일의 소유자가 root(bin, sys)로 설정되어 있지만 권한이 644이하로 설정되어 있지 않으므로 취약함" 					>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	else
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> 파일의 소유자가 root(bin, sys)로 설정되어 있지 않으므로 취약함" 													>> $HOSTNAME/$HOSTNAME.txt 2>&1	
	fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-12 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "소유자 root, -rw-r--r--   under 644"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

	echo "-------------------- U-13. SUID, SGID, Sticky bit 설정 파일 점검 ---------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 주요 실행파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있지 않을시 양호"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 주요 실행파일 SUID/SGID 설정 확인 "																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /sbin/dump \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;														>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /sbin/restore \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;													>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /sbin/unix_chkpwd \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;												>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /usr/bin/at \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;														>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /usr/bin/lpq \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;														>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /usr/bin/lpq-lpd \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;													>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /usr/bin/newgrp \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;													>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /usr/bin/lpr \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;														>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /usr/bin/lpr-lpd \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;													>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /usr/bin/lprm \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;													>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /usr/bin/lprm-lpd \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;												>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /usr/sbin/lpc-lpd \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;												>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /usr/sbin/lpc \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;													>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	find /bin/traceroute \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;													>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	FILES="/sbin/dump /usr/bin/lpq-lpd /usr/bin/newgrp /sbin/restore /usr/bin/lpr /usr/sbin/lpc /sbin/unix_chkpwd /usr/bin/lpr-lpd /usr/sbin/lpc-lpd /usr/bin/at /usr/bin/lprm /usr/sbin/traceroute /usr/bin/lpq /usr/bin/lprm-lpd"
  	for check_file in $FILES
    do
      	if [ -f $check_file ]
        then
          	if [ -g $check_file -o -u $check_file ]
            then
              	echo `ls -alL $check_file` 																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
            else
              	echo "※" $check_file "파일에 SUID, SGID가 부여되어 있지 않습니다" 															>> $HOSTNAME/$HOSTNAME.txt 2>&1
          	fi
        else
          	echo "※" $check_file "파일이 없습니다" 																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
      	fi
    done
	echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
	FILES="/sbin/dump /usr/bin/lpq-lpd /usr/bin/newgrp /sbin/restore /usr/bin/lpr /usr/sbin/lpc /sbin/unix_chkpwd /usr/bin/lpr-lpd /usr/sbin/lpc-lpd /usr/bin/at /usr/bin/lprm /usr/sbin/traceroute /usr/bin/lpq /usr/bin/lprm-lpd"
	num=0
  	for check_file in $FILES
    do
      	if [ -f $check_file ]
        then
          	if [ `ls -alL $check_file | awk '{print $1}' | grep -i 's'| wc -l` -gt 0 ]
            then
             	num=$(($num+1))
            else
              	num=$(($num+0))
			fi
		fi
    done
	if [ $num -eq "0" ]
		then
			echo "> 주요 실행파일의 권한에 'SUID(or SGID)'설정이 부여되어 있지 않으므로 양호함"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
			echo "> 주요 실행파일의 권한에 'SUID(or SGID)'설정이 부여되어 있으므로 취약함"																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-13 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* TMP 디렉토리의 권한을 Sticky bit로 설정 하였는가? "																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ls -ld /tmp /var/tmp																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 위내용에서 /tmp, /var/tmp디렉토리의 권한이 1777(drwxrwxrwt)임을 확인"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "예)-rwsr-xr-x = SUID 설정됨 | -rwxr-sr-x = SGID 설정됨"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "아래 14개 항목은 SUID/SGID 제거 권고"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "1. /sbin/dump, 2. /sbin/restore : 백업"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "3. /sbin/unix_chkpwd : 사용자의 암호검사 프로그램"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "4. /usr/bin/at 지정된 : 시간에 실행할 작업을 입력, 대기목록 확인, 제거"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "5. /usr/bin/lpq : 프린터 작업 큐 조회 명령어"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "6. /usr/bin/lpr : 콘솔환결에서 명시된 파일을 인쇄"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "7. /usr/bin/lprm : lpd명령어로 볼 수 있는 작업 큐 살펴보기, 취소, 삭제"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "8. /usr/bin/newgrp 현재 세션의 사용자 그룹 변경(지정한 그룹의 쉘로 환경이 바로 변경)"											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "9. /usr/sbin/lpc 커맨드 기반의 프린트 제어"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "10. /bin/traceroute 네트워크 경로 출력"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "11. /usr/bin/lpq-lpd, 12. /usr/bin/lpr-lpd, 13. /usr/bin/lprm-lpd ,14. /usr/sbin/lpc-lpd: 데몬"							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

	echo "---------- U-14. 사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정 ----"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 홈 디렉터리 환경변수 파일 소유자가 root 또는 해당 계정으로 지정되어 있고, 홈 디렉터리 환경변수 파일에 root와 소유자만 쓰기 권한이 부여되어 있을시 양호"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 환경파일의 소유자 및 권한 설정 점검 "																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
		
	HOMEDIRS=`cat /etc/passwd | awk -F":" 'length($6) > 0 {print $6}' | sort -u | grep -v '/bin/false' | grep -v 'nologin' | grep -v "#"`
	FILES=".profile .cshrc .kshrc .login .bash_profile .bashrc .bash_login .exrc .netrc .history .sh_history .bash_history .dtprofile"

	for file in $FILES
	do
		FILE=/$file
		if [ -f $FILE ]
		then
			ls -al $FILE >> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	done

	for dir in $HOMEDIRS
	do
		for file in $FILES
		do
      		FILE=$dir/$file
        	if [ -f $FILE ]
          	then
          		ls -al $FILE >> $HOSTNAME/$HOSTNAME.txt 2>&1
        	fi
    	done
  	done
	echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1

	echo " " > home.Script

	HOMEDIRS=`cat /etc/passwd | awk -F":" 'length($6) > 0 {print $6}' | sort -u | grep -v '/bin/false' | grep -v 'nologin' | grep -v "#"`
	FILES=".profile .cshrc .kshrc .login .bash_profile .bashrc .bash_login .exrc .netrc .history .sh_history .bash_history .dtprofile"

  	for file in $FILES
    do
      	if [ -f /$file ]
        then
          	if [ `ls -alL /$file |  awk '{print $1}' | grep "........-." | wc -l` -eq 0 ]
            then
              	echo "취약" >> home.Script
            else
              	echo "양호" >> home.Script
          	fi
        else
          	echo "양호" >> home.Script
      	fi
    done

  	for dir in $HOMEDIRS
    do
      	for file in $FILES
        do
          	if [ -f $dir/$file ]
            then
              	if [ `ls -al $dir/$file | awk '{print $1}' | grep "........-." | wc -l` -eq 0 ]
                then
                  	echo "취약" >> home.Script
                else
                  	echo "양호" >> home.Script
              	fi
            else
              echo "양호" >> home.Script
          	fi
        done
    done
  	if [ `cat home.Script | grep "취약" | wc -l` -eq 0 ]
    then
      	echo "> 사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정이 적절하므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    else
    	echo "> 사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정이 부적절하므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
  	fi

  	rm -rf home.Script
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-14 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "환경 설정 파일의 접근권한을 under 644(-rw-r--r--)으로 설정함"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

	echo "-------------------- U-15. world writable 파일 점검 ----------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1	
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: world writable 파일이 존재하지 않거나, 존재시 설정 이유를 확인하고 있는경우 양호"										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "WORLD_WRITABLE 파일 참조 [별도 저장]"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	timeout 300s find / \( ! \( \( -path /nfs -o -path /var -o -path /proc \) -prune \) -and \( -perm -2 -type f \) \) -exec ls -aldL {} \; 		> $HOSTNAME/U-15_world_writable.txt
	echo " " 																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f $HOSTNAME/U-15_world_writable.txt ]
		then
			if [ `cat $HOSTNAME/U-15_world_writable.txt | wc -l` -eq 0 ]
				then
					echo "> world writable 파일이 존재하지 않으므로 양호함" 																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
				else
					echo "> 수동진단 [U-15_world_writable.txt 참조]"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			fi
	fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-15 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "점검 시 시스템 부하가 걸리므로 담당자와 협의 후 점검 여부 결정"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "파일이 존재하지 않으면 양호 존재한다면 불필요한 World writable 권한 삭제"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

	echo "-------------------- U-16. /dev에 존재하지 않는 device 파일 점검 ----------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: dev에 대한 파일 점검 후 존재하지 않은 device 파일을 제거한 경우 양호"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /dev의 device 파일 확인"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	timeout 300s find /dev -type f -exec ls -l {} \;																								>> $HOSTNAME/U-16_device.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "> 수동진단 [device.txt 참조]"																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-16 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "파일이 존재하지 않으면 양호 존재한다면 불필요한 device 파일 삭제"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

	echo "-------------------- U-17. $HOME/.rhosts, hosts.equiv 사용 금지 ----------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: login, shell, exec 서비스를 사용하지 않거나, 사용 시 아래와 같은 설정이 적용된 경우	"									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "1. /etc/hosts.equiv 및 $HOME/.rhosts 파일 소유자가 root 또는 해당 계정인 경우"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "2. /etc/hosts.equiv 및 $HOME/.rhosts 파일 권한이 600 이하인 경우"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "3. /etc/hosts.equiv 및 $HOME/.rhosts 파일 설정이 '+' 설정이 없는 경우"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "위의 사항 만족시 양호"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "[hosts.equiv 파일]" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ -f /etc/hosts.equiv ]
		then
			ls -alL /etc/hosts.equiv	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "[hosts.equiv 설정]"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			cat /etc/hosts.equiv		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
			echo "'/etc/hosts.equiv' 파일이 존재하지 않습니다." >> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi

	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "[$HOME/.rhosts 파일]" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ -f $HOME/.rhosts ]
		then
			ls -alL $HOME/.rhosts	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "[$HOME/.rhosts 설정]" >> $HOSTNAME/$HOSTNAME.txt 2>&1
			cat $HOME/.rhosts			>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
			echo "'$HOME/.rhosts' 파일이 존재하지 않습니다." >> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " " > u17.Script
	if [ `netstat -nap | grep -i "tcp" | egrep '(:512\>|:513\>|:514\>)' | wc -l` -ge 1 ]
	then
		echo "login, shell, exec 서비스 실행 여부 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		netstat -na | egrep '(:512\>|:513\>|:514\>)' | grep -i "listen" | grep -i "tcp" 											>> $HOSTNAME/$HOSTNAME.txt 2>&1	
		echo " " 																													>> $HOSTNAME/$HOSTNAME.txt 2>&1	
		echo "r command Sevice Enable" 																								>> $HOSTNAME/$HOSTNAME.txt 2>&1	
		echo " " 																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "★★★★★ 파일의 소유자가 Home 디렉터리 소유자 설정이 적절하게 되어 있는지 확인 필요 ★★★★★"						>> $HOSTNAME/$HOSTNAME.txt 2>&1																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ `netstat -na | egrep '(:512\>|:513\>|:514\>)' | grep -i "listen" | grep -i "tcp" | wc -l` -ge 1 ]
		then
			if [ -f /etc/hosts.equiv ]
			then
				if [ `ls -alL /etc/hosts.equiv | grep "root" | grep '...-------' | grep "+" | wc -l` -eq 0 ]
				then
					echo "양호"	> u17.Script
				fi
			fi
			if [ -f $HOME/.rhosts ]
			then
				if [ `ls -alL $HOME/.rhosts | grep "root" | grep '...-------' | grep "+" | wc -l` -eq 0 ]
				then
					echo "양호"	>> u17.Script
				fi
			fi
			if [ `cat u17.Script | grep "양호" | wc -l` -eq 0 ]
			then
				echo "> /etc/hosts.equiv 및 $HOME/.rhosts 파일 설정이 적절하게 되어있지 않으므로 취약함" 								>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				echo "> login, shell, exec 서비스를 사용하고 있지만 소유자 및 권한 설정이 적절하게 되어 있으므로 양호함"					>> $HOSTNAME/$HOSTNAME.txt 2>&1
			fi
		fi
	else
		echo "> login, shell, exec 서비스를 사용하고 있지 않으므로 양호함"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	rm -rf u17.Script
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-17 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "(/etc/hosts.equiv파일삭제)"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "($ HOME/.rhosts파일삭제)"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
				
	echo "-------------------- U-18. 접속 ip 및 포트 제한 --------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 접속을 허용할 특정 호스트에 대한 IP 주소 및 포트 제한을 설정한 경우 양호"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " " > u18.Script																													
	echo "* '/etc/hosts.deny' 파일 확인"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f /etc/hosts.deny ]
		then
		echo "☞ /etc/hosts.deny 파일 내용" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/hosts.deny >> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ `cat /etc/hosts.deny  | grep -v "#" | sed 's/ *//g' |  grep "ALL:ALL" | wc -l ` -gt 0 ]
			then
			echo "양호"	>> u18.Script
		fi
		else
		echo "※ /etc/hosts.deny 파일 없음" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* '/etc/hosts.allow' 파일 확인"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f /etc/hosts.allow ]
		then
			echo "☞ /etc/hosts.allow 파일 내용" >> $HOSTNAME/$HOSTNAME.txt 2>&1
			cat /etc/hosts.allow >> $HOSTNAME/$HOSTNAME.txt 2>&1
			if [ `cat /etc/hosts.allow | grep -v "#" | sed 's/ *//g' | grep -v "^$" | grep -v "ALL:ALL" | wc -l ` -gt 0 ]
			then
				echo "양호"	>> u18.Script
			fi
		else
			echo "※ /etc/hosts.allow 파일 없음" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ `cat u18.Script | grep "양호" | wc -l` -ge 2 ]
		then
		echo "> 접속을 허용할 특정 호스트에 대한 IP 주소 및 포트 제한이 적절하게 설정되어 있으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
		echo "> 접속을 허용할 특정 호스트에 대한 IP 주소 및 포트 제한이 설정되어 있지 않으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi		
	rm -rf u18.Script																											
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-18 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "-------------------- U-55. hosts.lpd파일 소유자 및 권한설정 ---------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: hosts.lpd 파일이 삭제되어 있거나 불가피하게 hosts.lpd 파일을 사용할 시 파일의 소유자가 root이고 권한이 600일시 양호"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1	
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* '/etc/hosts.lpd' 파일 점검"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f /etc/hosts.lpd ] 
	then
#		echo "/etc/hosts.lpd 퍼미션" 																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ls -alL /etc/hosts.lpd 																										>> $HOSTNAME/$HOSTNAME.txt 2>&1	
		if [ `ls -alL /etc/hosts.lpd | awk '{print $3}' | grep "root" | wc -l` -eq 0 ]
		then
			echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> /etc/hosts.lpd 파일이 존재하고 소유자가 root로 설정되어 있지 않으므로 취약함" 													>> $HOSTNAME/$HOSTNAME.txt 2>&1	
		else
		if [ `ls -alL /etc/hosts.lpd | awk '{print $1}' | grep '...-------' | wc -l` -eq 1 ]
		then
			echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> /etc/hosts.lpd 파일의 소유자가 root이고 권한이 600이하로 설정되어 있으므로 양호함" 												>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else 
			echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> /etc/hosts.lpd 파일의 소유자가 root로 설정되어 있지만 권한이 600이하로 설정되어 있지 않으므로 취약함" 								>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
		fi
	else
		echo "※ '/etc/hosts.lpd' 파일 존재하지 않음 "																				 >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> '/etc/hosts.lpd' 파일이 존재하지 않으므로 양호함"																				 >> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-55 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
																																	>> $HOSTNAME/$HOSTNAME.txt 2>&1

	echo "-------------------- U-56. UMASK 설정 관리 -------------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: UMASK 값이 022 이상으로 설정되어 있을시 양호"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* root계정 umask값 확인"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	
	umask >> $HOSTNAME/$HOSTNAME.txt 2>&1
 
 if [ `umask` -ge 22  ]
  then
    echo " "																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "> UMASK 값이 '022'이상이므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
  else
	echo " "																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
    echo "> UMASK 값이 '022'미만이므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
fi	

#	echo "* /etc/profile/내의 umask값 확인"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
#		cat /etc/profile | grep -i umask | grep -v "#"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
#	echo "* /etc/bashrc/내의 umask값 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
#		cat /etc/bashrc | grep -i umask | grep -v "#"		>> $HOSTNAME/$HOSTNAME.txt 2>&1

:<<'END'

#	echo "☞ /etc/profile 파일  " >> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f /etc/profile ]
    then
#		grep -C5 -i -n "umask" /etc/profile >> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ `cat /etc/profile | grep -i "umask" |grep -v "#" | awk -F"0" '$2 >= "22"' | wc -l` -eq 1 ]
		then
			echo "양호"	>> u56.Script
		fi
    else
      	echo "/etc/profile 파일이 없습니다.(수동점검)" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
#		echo "☞ /etc/bashrc 파일  " >> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f /etc/bashrc ]
    then
#		grep -C5 -i -n "umask" /etc/bashrc >> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ `cat /etc/bashrc | grep -i "umask" |grep -v "#" | awk -F"0" '$2 >= "22"' | wc -l` -eq 1 ]
		then
			echo "양호"	>> u56.Script
		fi
    else
      	echo "/etc/bashrc 파일이 없습니다.(수동점검)" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi

	if [ `cat u56.Script | grep "양호" | wc -l` -ge 2 ]
    then
		echo "> UMASK 값이 적절하게 설정되어 있으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    else
		echo "> UMASK 값이 적절하게 설정되어 있지 않으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
  	fi		
	rm -rf u56.Script		
END
	echo " "																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-56 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/profile UMASK 값 022로 설정"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "UMASK 값 0022로 설정"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-57. 홈 디렉터리 소유자 및 권한 설정 -----------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 홈 디렉터리 소유자가 해당 계정이고, 타 사용자 쓰기 권한이 제거되어있을시 양호"											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
  HOMEDIRS=`cat /etc/passwd | awk -F":" 'length($6) > 0 {print $6}' | sort -u | grep -i "home"  |grep -v "#" | grep -v "/tmp" | grep -v "uucppublic" | grep -v "var" | grep -v "news" | uniq`
  for dir in $HOMEDIRS
    do
		if [ -d $dir ]; then
  	    ls -dal $dir | grep '\d.........' >> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
    done
  echo " " > home.Script
  HOMEDIRS=`cat /etc/passwd | awk -F":" 'length($6) > 0 {print $6}' | sort -u | grep -v "#" | grep -v "/tmp" | grep -v "uucppublic" | grep -v "var" | grep -v "news" | uniq`
  for dir in $HOMEDIRS
    do
      if [ -d $dir ]
        then
          if [ `ls -dal $dir |  awk '{print $1}' | grep "........-." | wc -l` -eq 1 ] && [ `ls -dal $dir |  awk '{print $3}' | grep -v "root"` ]
            then
              echo "양호" >> home.Script 
            else
              echo "취약" >> home.Script  
          fi
        else
          echo "양호" >> home.Script
      fi
    done
  echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
  if [ `cat home.Script | grep "취약" | wc -l` -eq 0 ]
    then
	  echo "> 홈 디렉터리 소유자 및 권한 설정이 적절하게 설정되어 있으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    else
      echo "> 수동 진단 필요" >> $HOSTNAME/$HOSTNAME.txt 2>&1
#	  echo "홈 디렉터리 소유자 및 권한 설정이 부적절하므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
  fi
  rm -rf home.Script	
   	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-57 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "소유자가 디렉터리 소유자로 되어있고 권한이 under 711(drwx--x--x)으로 되있을 경우 양호"											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "홈 디렉터리의 소유자가 HOSTNAME.PASSWORD.txt에 등록된 사용자와 일치하도록 변경"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-58. 홈 디렉터리로 지정한 디렉터리의 존재 관리 --------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 홈 디렉터리가 존재하지 않는 계정이 발견되지 않을시 양호"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
   echo "☞ 홈 디렉터리가 존재하지 않는 계정리스트" >> $HOSTNAME/$HOSTNAME.txt 2>&1
  echo "------------------------------------------------------------------------------" >> $HOSTNAME/$HOSTNAME.txt 2>&1
  echo " " > DHOME_pan.Script
  HOMEDIRS=`cat /etc/passwd | egrep -v -i "nologin|false" | awk -F":" 'length($6) > 0 {print $6}' | sort -u | grep -v "#" | grep -v "/tmp" | grep -v "uucppublic" | uniq`
  for dir in $HOMEDIRS
    do
	    if [ ! -d $dir ]
	      then
		      awk -F: '$6=="'${dir}'" { print "● 계정명(홈디렉터리):"$1 "(" $6 ")" }' /etc/passwd >> $HOSTNAME/$HOSTNAME.txt 2>&1
		      echo " " > Home.Script
		    else
		      echo "없음" > no_Home.Script
	    fi
    done
  echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
  if [ ! -f no_Home.Script ]
    then
		  echo "홈 디렉터리가 존재하지 않은 계정이 발견되지 않았습니다" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    else
		  rm -rf no_Home.Script
  fi
  echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
  echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
  echo "☞ root 계정 외 '/'를 홈디렉터리로 사용하는 계정리스트" >> $HOSTNAME/$HOSTNAME.txt 2>&1
  echo "------------------------------------------------------------------------------" >> $HOSTNAME/$HOSTNAME.txt 2>&1
  
  if [ `cat /etc/passwd | egrep -v -i "nologin|false" | grep -v root | awk -F":" 'length($6) > 0' | awk -F":" '$6 == "/"' | wc -l` -eq 0 ]
  then
        echo "root 계정 외 '/'를 홈 디렉터리로 사용하는 계정이 존재하지 않습니다." >> $HOSTNAME/$HOSTNAME.txt 2>&1
  else
        cat /etc/passwd | egrep -v -i "nologin|false" | grep -v root | awk -F":" 'length($6) > 0' | awk -F":" '$6 == "/"' >> $HOSTNAME/$HOSTNAME.txt 2>&1
        echo "취약" >> DHOME_pan.Script
  fi
  echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
  if [ ! -f Home.Script ]
    then
      echo "양호" >> DHOME_pan.Script
    else
      echo "취약" >> DHOME_pan.Script
      rm -rf Home.Script
  fi
  if [ `cat DHOME_pan.Script | grep "취약" | wc -l` -eq 0 ]
    then
	  echo "> 홈 디렉터리가 존재하지 않는 계정이 존재하지 않으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    else
	  echo "> 홈 디렉터리가 존재하지 않는 계정이 존재하므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
  fi
  rm -rf DHOME_pan.Script
  	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-58 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "불법적이거나 의심스러운 디렉터리가 있어서 삭제한 경우 양호"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-59. 숨겨진 파일 및 디렉터리 검색 및 제거 ------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 불필요하거나 의심스러운 숨겨진 파일 및 디렉터리를 삭제한 경우 양호"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	find / \( ! \( \( -path /proc \) -prune \) \) -type f -name ".*" -ls >> hidden-file.Script
	find / \( ! \( \( -path /proc \) -prune \) \) -type d -name ".*" -ls >> hidden-file.Script

	if [ -s hidden-file.Script ]
		then
			cat hidden-file.Script > $HOSTNAME/U-59_hiddenfile.txt 2>&1
			echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
		rm -rf hidden-file.Script
		echo "hidden-file.Script 파일 참고"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> 숨겨진 파일 및 디렉터리가 존재하므로 수동진단 필요"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
			echo " ※ 숨김 파일 존재하지 않음"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> 숨겨진 파일 및 디렉터리가 존재하지 않으므로 양호함"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi	
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-59 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "'.'이 붙은 것은 숨김 파일"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1


echo "********************** 3. 서비스 관리 **************************************"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "-------------------- U-19. Finger서비스 비활성화 -------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: Finger 서비스가 비활성화 되어 있을시 양호"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* Finger 서비스 활성화 여부 확인"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ps -ef | egrep 'finger' | grep -v "grep"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
		
	if [ `ps -ef | egrep 'finger' | grep -v "grep" | wc -l` -eq 0 ]
	then
		result_finger='true'
	else
		result_finger='false'
	fi

if [ $result_finger = 'true' ]
   	then
   		echo "※ Finger Service 비활성화" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> Finger 서비스가 비활성화되어 있으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
   	else
		echo "※ Finger Service 활성화" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
   		echo "> Finger 서비스가 활성화되어 있으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
fi

	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-19 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "Finger(사용자 정보 확인서비스)를 통해 네트워크 외부에서 해당 시스템에 등록된 사용자 정보 확인 가능"								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "Finger 서비스 비활성화 권고"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "결과 값이 안나온다면 비활성화 --> 양호"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-20. Anonymous FTP 비활성화 ------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: Anonymous FTP (익명 ftp) 접속을 차단한 경우 양호"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* FTP 사용여부 확인 "																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ps -ef | grep ftp | grep -v 'grep' | grep -v "ssh"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1

		if [ `ps -ef | grep ftp | grep -v 'grep' | grep -v "ssh" | wc -l` -eq 0 ]
		 then
			echo "FTP SERVICES Disable" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> FTP 서비스가 비활성화되어 있으므로 양호함" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		 else
			echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "* $PASSWD에 ftp 계정 확인 "																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
			if [ `cat /etc/passwd | egrep -i "ftp|anonymous" | grep -v "#" | wc -l` -eq 0 ]
				then
					echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
					echo "> /etc/passwd 파일에 FTP 계정이 존재하지 않으므로 양호함" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				else
					cat /etc/passwd | egrep -i "ftp|anonymous" | grep -v "#" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
					echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
					echo "> /etc/passwd 파일에 FTP 계정이 존재하므로 취약함" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			fi
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* VSFTP 익명 FTP연결 확인"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ -f /etc/vsftpd/vsftpd.conf ]
			then
				if [ `cat /etc/vsftpd/vsftpd.conf | grep -i "anonymous_enable=no" | grep -v "#" | wc -l` -eq 0 ]
					then 
						cat /etc/vsftpd/vsftpd.conf | grep -i "anonymous_enable=no" | grep -v "#"	  >> $HOSTNAME/$HOSTNAME.txt 2>&1
						echo "> vsFTP를 사용중이며 Anonymous FTP 접속을 제한하였으므로 양호함"  >> $HOSTNAME/$HOSTNAME.txt 2>&1
					else
						cat /etc/vsftpd/vsftpd.conf | grep -i "anonymous_enable"	  >> $HOSTNAME/$HOSTNAME.txt 2>&1
						echo "> vsFTP를 사용중이며 Anonymous FTP 접속을 제한하지 않았으므로 취약함"  >> $HOSTNAME/$HOSTNAME.txt 2>&1
				fi
			else
				if [ -f /etc/vsftpd.conf ]
					then
						if [ `cat /etc/vsftpd.conf | grep -i "anonymous_enable=no" | grep -v "#" | wc -l` -eq 0 ]
							then 
								cat /etc/vsftpd.conf | grep -i "anonymous_enable=no" | grep -v "#"	  >> $HOSTNAME/$HOSTNAME.txt 2>&1
							echo "> vsFTP를 사용중이며 Anonymous FTP 접속을 제한하였으므로 양호함"  >> $HOSTNAME/$HOSTNAME.txt 2>&1
						else
							cat /etc/vsftpd.conf | grep -i "anonymous_enable"	  >> $HOSTNAME/$HOSTNAME.txt 2>&1
							echo "> vsFTP를 사용중이며 Anonymous FTP 접속을 제한하지 않았으므로 취약함"  >> $HOSTNAME/$HOSTNAME.txt 2>&1
						fi
					else
						echo "vsFTP를 사용하지 않음"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				fi
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* $PASSWD에 ftp 계정 확인 "																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat $PASSWD | grep -i ftp																									>> $HOSTNAME/$HOSTNAME.txt 2>&1			


	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-20 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "익명계정에 대한 ftp 접근이 제한(anonymous_enable=NO 또는 주석처리)되어 있으면 양호 "											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "Anonymous FTP 제한을 위해 ftp 계정 삭제확인"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/vsftpd/vsftpd.conf 파일의 anonymous_enable이 yes로 되어있으면 no로 변경"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "결과 값이 안나온다면 비활성화"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1


echo "-------------------- U-21. r 계열 서비스 비활성화 -------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 불필요한 r 계열 서비스가 비활성화 되어있거나 결과값이 없을시 양호"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 취약한 r-명령어"																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ps -ef | egrep 'rsh|rlogin|rexec|rcp' | egrep -v "grep|percpu"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ `ps -ef | egrep 'rsh|rlogin|rexec|rcp' | egrep -v "grep|percpu" | wc -l` -eq 0 ]
			then
				echo "※ 활성화된 취약한 r 계열 서비스가 없음" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1			
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 불필요한 r 게열 서비스가 비활성화되어 있으므로 양호함" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 취약한 r 계열 서비스가 활성화되어 있으므로 취약함" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " ##'취약한 r-명령어' 결과값 출력시 아래 명령어 확인"																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** /etc/(x)inetd.d 에서 rsh,rlogin,rexec,rcp 서비스파일 확인"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* rsh 확인"																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ -f /etc/inetd.d/rsh ]
		 then
			cat /etc/inetd.d/rsh | grep -Pw 'disable|server'																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
		 else
			if [ -f /etc/xinetd.d/rsh ]
			 then
				cat /etc/xinetd.d/rsh | grep -Pw 'disable|server'																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
			 else
				echo "'/etc/(x)inetd.d/rsh' 파일이 존재하지 않음" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			fi
		fi
		
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* rlogin 확인"																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
			if [ -f /etc/inetd.d/rlogin ]
		 then
			cat /etc/inetd.d/rlogin | grep -Pw 'disable|server'																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
		 else
			if [ -f /etc/xinetd.d/rlogin ]
			 then
				cat /etc/xinetd.d/rlogin | grep -Pw 'disable|server'																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
			 else
				echo "'/etc/xinetd.d/rlogin' 파일이 존재하지 않음" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			fi
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* rexec 확인"																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
				if [ -f /etc/inetd.d/rexec ]
		 then
			cat /etc/inetd.d/rexec | grep -Pw 'disable|server'																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
		 else
			if [ -f /etc/xinetd.d/rexec ]
			 then
				cat /etc/xinetd.d/rexec | grep -Pw 'disable|server'																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
			 else
				echo "'/etc/xinetd.d/rexec' 파일이 존재하지 않음" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			fi
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* rcp 확인"																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
					if [ -f /etc/inetd.d/rcp ]
		 then
			cat /etc/inetd.d/rcp | grep -Pw 'disable|server'																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
		 else
			if [ -f /etc/xinetd.d/rcp ]
			 then
				cat /etc/xinetd.d/rcp | grep -Pw 'disable|server'																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
			 else
				echo "'/etc/xinetd.d/rcp' 파일이 존재하지 않음" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			fi
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-21 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " *'r' command는 인증 없이 관리자의 원격접속을 가능하게하는 명령어(rsh, rlogin, rexec, rcp)"									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "r서비스가 이용가능할시 중요 정보 유출 및 시스템 장애 발생 등 침해사고 위험이 있어 비활성화 요구"									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/(x)inetd.d 의 각 서비스파일 설정에 비활성화(disable=yes) 되어있는지 확인"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "결과 값이 안나온다면 비활성화 --> 양호"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-22. cron 파일 소유자 및 권한 설정 ------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: cron 접근제어 파일 소유자가 root이고, 권한이 640 이하일시 양호"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* ls -aldl $CRON_ALLOW"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ -f /etc/cron.allow ]
			then
				if [ `ls -al /etc/cron.allow | awk '{print $3}' | grep "root" | wc -l` -ge 1 ]
					then
						if [ `ls -al /etc/cron.allow | awk '{print $1}' | grep '...-.-----' | wc -l` -eq 1 ]
							then
								ls -al /etc/cron.allow																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
								result_cronallow="true"
							else
								result_cronallow="permitx"
						fi
					else
						result_cronallow="rootx"
				fi
			else
				result_cronallow='false'
				echo "※ '/etc/cron.allow' 파일이 존재하지 않습니다."	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* ls -aldl $CRON_DENY"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ -f /etc/cron.deny ]
		 then
			ls -al /etc/cron.deny																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
			if [ `ls -al /etc/cron.deny | awk '{print $3}' | grep "root" | wc -l` -ge 1 ]
			 then
				if [ `ls -al /etc/cron.deny | awk '{print $1}' | grep '...-.-----' | wc -l` -eq 1 ]
					then
						result_crondeny="true"
					else
						result_crondeny='permitx'
				fi
			 else
				result_crondeny='rootx'
			fi
		 else
			result_crondeny='false'
			echo "※ '/etc/cron.deny' 파일이 존재하지 않습니다."	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	

	
	
	if [ $result_cronallow = "true" -a $result_crondeny = "true" ]
	 then
		echo ""				>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> cron 파일의 권한 및 소유자가 적절하므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	 else
		if [ $result_cronallow = "false" -a $result_crondeny = "true" ]
		 then
			echo ""				>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> cron 파일의 권한 및 소유자가 적절하므로 양호함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		 else
			if [ $result_cronallow = "false" -a $result_crondeny = "false" ]
			 then
				echo ""				>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> cron 파일이 존재하지 않아 관리자 계정만 사용가능하므로 양호함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			 else
				if [ $result_cronallow = "permitx" -o $result_crondeny = "permitx" ]
				 then
					echo ""				>> $HOSTNAME/$HOSTNAME.txt 2>&1
					echo "> cron 파일의 권한이 '-rw-r-----(640)' 이하가 아니므로 취약함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				 else
					if [ $result_cronallow = "rootx" -o $result_crondeny = "rootx" ]
				 then
					echo ""				>> $HOSTNAME/$HOSTNAME.txt 2>&1
					echo "> cron 파일의 소유자가 root 계정이 아니므로 취약함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
					fi
				fi
			fi
		fi
	fi
		
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-22 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "cron은 특정 시간에, 마다 특정 작업을 자동으로 수행해주는 명령어"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "불법적인 예약파일 실행으로 시스템 피해를 일으킬 수 있음"  																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "cron.allow와 crom.deny 파일의 권한 under 640(-rw-r-----) 설정 및 소유자 root 설정 권고"										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "Default로 allow파일은 존재하지 않음 deny파일만 존재"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-23. DOS 공격에 취약한 서비스 비활성화 ---------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 사용하지 않는 DoS 공격에 취약한 서비스가 비활성화된 경우 양호"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* DOS공격에 취약한 서비스들 확인"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ps -ef | egrep 'echo|discard|daytime|chargen' | grep -v "grep"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
		
		if [ `ps -ef | egrep 'echo|discard|daytime|chargen' | grep -v "grep" | wc -l` -eq 0 ]
		 then
			echo "※ DOS 공격에 취약한 서비스가 비활성화되어 있음" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> DOS 공격에 취약한 서비스가 비활성화되어 있으므로 양호함"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		 else
			echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> DOS 공격에 취약한 서비스가 활성화되어 있으므로 취약함"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
		
: << "END"
★★★★★★★★★★★★★★★★★ 여기 나중에 수정 필요 ★★★★★★★★★★★★★★★★
 ㄴ 수정할 내용 : "/etc/xinetd.d" 하위폴더 파일 내용중 "disable" 행 출력해서 "= yes" 인지 확인
		if [ -f /etc/xinetd.d/echo ]
		 then
			if [ `cat /etc/xinetd.d/echo | grep -v "grep" | wc -l` -eq 0 ]
		
		if [ -f /etc/xinetd.d/discard ]
		
		if [ -f /etc/xinetd.d/daytime ]
		
		if [ -f /etc/xinetd.d/chargen ]
END
		
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-23 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "DoS 공격에 취약한 서비스(echo, discard, daytime, chargen) 비활성화"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "결과 값이 안나온다면 비활성화로 양호"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1



echo "-------------------- U-24. NFS 서비스 비활성화 ---------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 불필요한 NFS 서비스 관련 데몬이 비활성화 되어있을시 양호"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* NFS 프로세스 확인"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ps -ef | egrep "nfs|statd|lockd" | egrep -v "grep|kblockd"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
		
		if [ `ps -ef | egrep "nfs|statd|lockd" | grep -v "grep" | grep -v "kblockd" | wc -l` -eq 0 ]
			then
				echo "※ NFS 관련 프로세스 없음"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> NFS 서비스 관련 데몬이 비활성화되어 있으므로 양호함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> NFS 서비스 관련 데몬이 활성화되어 있으므로 취약함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-24 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "사용자가 원격지 PC에 있는 파일을 검색, 저장, 수정하도록 해주는 클라이어트/서버형 응용프로그램"									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "불필요한 NFS 서비스 비활성화"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "결과 값이 안나온다면 비활성화"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-25. NFS 접근통제 ----------------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 불필요한 NFS 서비스를 사용하지 않거나, 불가피하게 사용 시 everyone 공유를 제한한 경우 양호"								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ `ps -ef | egrep "nfs|statd|lockd" | grep -v "grep" | grep -v "kblockd" | wc -l` -eq 0 ]
			then
				echo "> NFS 서비스가 비활성화되어 있으므로 해당없음"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else		
				echo "* /etc/dfs/dfstab 점검"			>> $HOSTNAME/$HOSTNAME.txt 2>&1
					grep -v '^#' /etc/dfs/dfstab	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""								>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "* /etc/dfs/sharetab 점검"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
					grep -v '^#' /etc/dfs/sharetab	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""								>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "* /etc/exports 점검(linux)"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
					grep -v '^#' /etc/exports		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""								>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "* share 명령어 확인"				>> $HOSTNAME/$HOSTNAME.txt 2>&1
					share							>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""								>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "NFS 접근통제 수동점검 필요"			>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""								>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	echo [_END_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-25 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " 쓰기권한으로 export시키지 않음. 읽기 모드로 사용하여야 하고"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " 반드시 nfs를 사용해야 할 경우 보안설정(dfstab)에 주의함"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " 결과 값이 안나온다면 비활성화로 양호"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-26. automountd 제거 -------------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: automountd 서비스가 비활성화 되어있을시 양호"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* automountd 서비스 데몬 확인"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ps -ef | grep -i "automountd" |	grep -v "grep"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	
		if [ `ps -ef | grep -i "automountd" |	grep -v "grep" | wc -l` -eq 0 ]
			then
				echo "※ 실행중인 automountd 서비스 없음"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> automountd 서비스가 비활성화되어 있으므로 양호함"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> automountd 서비스가 활성화되어 있으므로 취약함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi	
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-26 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "automountd란 로컬 공격자가 데몬에 Remote Procedure Call를 보낼수 있는 취약점 존재"											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "불필요한 automountd 비활성화"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "결과 값이 안나온다면 비활성화로 양호"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-27. RPC 서비스 확인 -------------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 불필요한 RPC 서비스가 비활성화 되어있을시 양호"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 버퍼 오버플로우 취약성을 가진 서비스들 탐색"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ps -ef | egrep 'rpc.cmsd|rusersd|rstatd|rpc.statd|kcms_server|rpc.ttdbserverd|walld|rpc.nids|rpc.ypupdated|cachefsd|sadmind|sprayd|rpc.pcnfsd|rexed|rpc.rquotad' | grep -v "grep" | grep -v "firewalld" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		
		if [ `ps -ef | egrep 'rpc.cmsd|rusersd|rstatd|rpc.statd|kcms_server|rpc.ttdbserverd|walld|rpc.nids|rpc.ypupdated|cachefsd|sadmind|sprayd|rpc.pcnfsd|rexed|rpc.rquotad' | grep -v "grep" | grep -v "firewalld" | wc -l` -eq 0 ]
			then
				echo "※ 실행중인 RPC 서비스 없음"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> RPC 서비스가 비활성화되어 있으므로 양호함"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> RPC 서비스가 활성화되어 있으므로 취약함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-27 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "취약한 RPC 서비스 제한"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "버퍼 오버플로우 취약성으로 root 권한 획득 및 침해사고 발생 위험이 있는 서비스를 중지해야함"										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "결과 값이 안나온다면 비활성화로 양호"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-28. NIS, NIS+ 점검 --------------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: NIS 서비스가 비활성화 되어있거나, 필요시 NIS+를 사용하는 경우 양호"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* NIS, NIS+ 서비스 구동 확인"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ps -ef | egrep "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated" | grep -v "grep"											>> $HOSTNAME/$HOSTNAME.txt 2>&1
		
		if [ `ps -ef | egrep "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated" | grep -v "grep" | wc -l` -eq 0 ]
			then
				echo "※ 실행중인 NIS, NIS+ 서비스 없음"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> NIS, NIS+ 서비스가 비활성화되어 있으므로 양호함"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> NIS, NIS+ 서비스가 활성화되어 있으므로 취약함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi				
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-28 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "NIS, NIS+ 사용여부 확인"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "보안상 취약하기 때문에 사용을 권고하지 않으나, 사용해야할 경우 보안상 더 양호한 NIS+ 사용권고"									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-29. tftp, talk 서비스 비활성화 ---------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: tftp, talk, ntalk 서비스가 비활성화되어 있을시 양호"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* tftp, talk, ntalk 서비스 활성화 여부 확인"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ps -ef | egrep 'tftp|talk|ntalk' | grep -v "grep"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
		
		if [ `ps -ef | egrep 'tftp|talk|ntalk' | grep -v "grep" | wc -l` -eq 0 ]
			then
				echo "※ 실행중인 tftp, talk, ntalk 서비스 없음"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> tftp, talk, ntalk 서비스가 비활성화되어 있으므로 양호함"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> tftp, talk, ntalk 서비스가 활성화되어 있으므로 취약함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi			

	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-29 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "tftp, talk, ntalk 서비스(불필요 서비스) 비활성화 --> 보안성 높임 --> 서비스 취약점 발견으로 인한 피해 최소화"					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "결과 값이 안나온다면 비활성화로 양호"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-30. Sendmail 버전 점검 ----------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: Sendmail 버전이 최신버전일시 양호"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* Sendmail 프로세스 확인"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		ps -ef | grep sendmail | grep -v "grep"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
		
		if [ `ps -ef | grep sendmail | grep -v "grep" | wc -l` -eq 0 ]
			then
				echo "※ 실행중인 sendmail 서비스 없음"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> sendmail 서비스가 비활성화되어 있으므로 양호함"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
			# 추후 아래 양호 취약 추가 필요
				echo "* Sendmail 버전정보 확인"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
					grep DZ $SMTP_CONF																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> sendmail 버전 수동확인 필요"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi			
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-30 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "최신버전 확인 http://www.sendmail.org"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "정기적인 sendmail 버전 점검 및 최신 패치 적용 시 양호"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "2016.01 기준 최신 버전(Version 8.15.2) 이하 대부분의 버전에서 "																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "취약점이 보고되고 있다."																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "결과 값이 안나온다면 미설치 또는 비활성화로 양호"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-31. 스팸 메일 릴레이 제한 --------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: SMTP 서비스를 사용하지 않거나 릴레이 제한이 설정되어있을시 양호"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ `ps -ef | grep sendmail | grep -v "grep" | wc -l` -eq 0 ]
			then
				echo "> Sendmail 서비스가 비활성화되어 있으므로 해당없음"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
			# 추후 아래 양호 취약 추가 필요
				echo "* 스팸 메일 릴레이 설정 확인(Sendmail 8.9이상)"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
					cat $SMTP_SPAM																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "* cat /etc/mail/sendmail.cf | grep Relaying 점검"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
					cat /etc/mail/sendmail.cf | grep Relaying																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "* 특정 IP, domain, email address 및 네트워크에 대한 sendmail 접근 제한확인 없을시 파일생성 cat /etc/mail/access"				>> $HOSTNAME/$HOSTNAME.txt 2>&1
					cat /etc/mail/access								>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> Sendmail 릴레이 제한 설정 수동점검 필요"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-31 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "스팸 메일 릴레이 방지 설정 권고"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/mail/sendmail.cf의 R$* $#error $@ 5.7.1 $: 550 Relaying denied의 주석(#)제거"											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "릴레이 기능을 제한하지 않을 경우, 스팸 메일 서버로 악용, 서버 부하--> 인증된 사용자에게 메일 보낼수 있도록 설정, 불필요시 중지"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "결과 값이 안나온다면 미설치 또는 비활성화로 양호"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

	echo "-------------------- U-32. 일반사용자의 Sendmail 실행 방지 ----------------"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: SMTP 서비스 미사용 또는 일반 사용자의 Sendmail 실행 방지가 설정되어있을 시 양호"										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ `ps -ef | grep sendmail | grep -v "grep" | wc -l` -eq 0 ]
			then	
				echo "> Sendmail 서비스가 비활성화되어 있으므로 해당없음"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
			# 추후 아래 양호 취약 추가 필요
				echo "* SMTP O PrivacyOptions, restrictqrun 옵션 확인"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
					cat $SMTP_CONF | grep -i "O PrivacyOptions" | grep -i "restrictqrun"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "* SMTP 서비스 사용 여부 및 restrictqrun 옵션 확인"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
					grep -v '^*#' /etc/mail/sendmail.cf | grep PrivacyOptions																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> Sendmail 일반사용자 실행 방지 설정 수동점검 필요"	>> $HOSTNAME/$HOSTNAME.txt 2>&1					
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-32 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "sendmail 설정파일 내에 O PrivacyOptions=authwarnings,novrfy,noexpn,restrictqrun 설정 권고"									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "결과 값이 안나온다면 미설치 또는 비활성화"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-33. DNS 보안 버전 패치 ----------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: DNS 서비스를 사용하지 않거나 주기적으로 패치를 관리하고 있을시 양호"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* DNS 서비스 사용 확인"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ `ps -ef | grep -i "named" | grep -v "grep" | wc -l` -eq 0 ]
			then
				echo "※ 실행중인 DNS 서비스 없음"	>> $HOSTNAME/$HOSTNAME.txt 2>&1			
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> DNS 서비스가 비활성화되어 있으므로 양호함"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
			# 추후 아래 양호 취약 추가 필요
				ps -ef | grep named | grep -v "grep"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "* BIND 버전 확인 "																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
				named -v																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> DNS 버전 수동점검 필요"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-33 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "양호: DNS 서비스를 사용하지 않거나 주기적으로 패치를 관리하고 있는 경우"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "취약: DNS 서비스를 사용하며 주기적으로 패치를 관리하고 있지 않는 경우"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "결과 값이 안나온다면 미설치 또는 비활성화로 양호"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "9.5.0버전 이하의 경우 취약점 존재"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "8.3.4 이하버전엔 서비스 공격, 버퍼오버플로우 및 서버 원격 침입 등 취약성 존재"  												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "BIND 8,9 취약점 사이트"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "8: https://kb.isc.org/docs/aa-00959"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "9: https://kb.isc.org/docs/aa-00913"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-34. DNS Zone Transfer 설정 ------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: DNS 서비스 미사용 또는 Zone Transfer를 허용된 사용자에게만 허용한 경우 양호"											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ `ps -ef | grep -i "named" | grep -v "grep" | wc -l` -eq 0 ]
			then
				echo "> DNS 서비스가 비활성화되어 있으므로 해당없음"	>> $HOSTNAME/$HOSTNAME.txt 2>&1	
			else	
			# 추후 아래 양호 취약 추가 필요
				echo "/etc/named.conf 출력"																										>> $HOSTNAME/$HOSTNAME.NAMED.CONF.txt 2>&1
				cat $NAMED_CONF																												>> $HOSTNAME/$HOSTNAME.NAMED.CONF.txt 2>&1
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "* /etc/named.conf 파일의 allow-transfer 및 xfrnets 확인"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				ps -ef | grep named | grep -v "grep"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "* /etc/named.conf 파일 'allow-transfer' 출력"																										>> $HOSTNAME/$HOSTNAME.NAMED.CONF.txt 2>&1
				cat /etc/named.conf | grep 'allow-transfer'																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "* /etc/named.conf 파일 'xfrnets' 출력"																										>> $HOSTNAME/$HOSTNAME.NAMED.CONF.txt 2>&1
				cat /etc/named.boot | grep 'xfrnets'																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> DNS Zone Transfer 설정 수동점검 필요"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-34 END"
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "zone 영역 전송이 특정 호스트로 제한 (allow-transfer { IP; }) 되어 있거나"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "options xfrnets IP가 설정되어 있다면 양호"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1



if [ $APACHESTATUS == "ON" ]; then
echo "-------------------- U-35. Apache 디렉터리 리스팅 제거 --------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 디렉터리 리스팅 옵션 Indexes 확인"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
			if [ `cat $HOSTNAME/$HOSTNAME.apacheconf.txt | grep -i "indexes" | grep -v "#" | wc -l` -eq 0 ]
			then
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 디렉터리 검색 기능이 제거되어 있으므로 양호함  "		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				cat $HOSTNAME/$HOSTNAME.apacheconf.txt | grep -i "indexes" | grep -v "#"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 디렉터리 검색 기능이 제거되어 있지 않으므로 취약함 "		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* apacheconf.txt 파일과 대조하여 확인"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 양호 : 디렉터리 리스팅이 불가능할 경우"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 취약 : httpd.conf 파일 내의 Options에서 Indexes 옵션이 있을 경우"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-35 END"
echo "-------------------- U-36. Apache 웹 프로세스 권한 제한 -------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* Apache 데몬 구동 권한(User 및 Group) 확인"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1

		cat $HOSTNAME/$HOSTNAME.apacheconf.txt | egrep -i 'User|Group' | grep -v "#" | grep -v "LogFormat" >> apache36.txt
		
	
		if [ `cat apache36.txt | grep -i 'root' | wc -l` -eq 0 ]
			then
				cat $HOSTNAME/$HOSTNAME.apacheconf.txt | egrep -i 'User|Group' | grep -v "#" | grep -v -i "LogFormat"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> Apache 데몬이 root 권한이 아닌 별도의 계정으로 구동되고 있으므로 양호함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				cat $HOSTNAME/$HOSTNAME.apacheconf.txt | egrep -i 'User|Group' | grep -v "#" | grep -v -i "LogFormat"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> Apache 데몬이 root 권한으로 구동되고 있으므로 취약함 " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
		rm apache36.txt
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** User [root가 아닌 별도 계정명]"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** Group [root가 아닌 별도 계정명]"			 																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 양호: Apache 데몬이 root 권한으로 구동되지 않는 경우"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 취약: Apache 데몬이 root 권한으로 구동되는 경우"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-36 END"
echo "-------------------- U-37. Apache 상위 디렉터리 접근 금지 -----------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* AllowOverride 확인"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1

		cat $HOSTNAME/$HOSTNAME.apacheconf.txt | grep -i "AllowOverride" | grep -v "#"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat $HOSTNAME/$HOSTNAME.apacheconf.txt | grep -i "AllowOverride" | grep -v "#"  >> apache37.txt
		
		if [ `cat apache37.txt | grep -i "none" | grep -v "#" | wc -l` -eq 0 ]
			then
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 'AuthConfig' 옵션을 설정하였으므로 양호함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 'AuthConfig' 옵션을 설정하지 않았으므로 취약함 " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
		rm apache37.txt

	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1		
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* apacheconf.txt 파일과 대조하여 확인"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 양호 : 상위 디렉터리 접근이 금지된 경우"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 취약 : httpd.conf 파일 내의 Options에서 AllowOverride 옵션이 있을 경우"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-37 END"
echo "-------------------- U-38. Apache 불필요한 파일 제거 ----------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* Apache 불필요한 파일 존재 여부 확인"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
		find $HTTPD_ROOT -name '*manual*' 																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
		
		if [ `find $HTTPD_ROOT -name '*manual*' | wc -l` -eq 0 ]
			then
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 기본으로 생성되는 Apache 메뉴얼 파일이 존재하지 않으므로 양호함 "		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 기본으로 생성되는 Apache 메뉴얼 파일이 존재하므로 취약함 " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
		
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 양호: 불필요한 파일이 존재하지 않을 경우(결과값 없음)"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 취약: 디폴트 cgi-bin이 존재할 경우 또는 임시 파일, 백업 파일 등이 존재할 경우"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-38 END"
echo "-------------------- U-39. Apache 링크 사용 금지 -------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* Apache 링크 사용 옵션 확인"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
		 cat $HOSTNAME/$HOSTNAME.apacheconf.txt	| grep -i "FollowSymLinks" | grep -v "#"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1

		if [ `cat $HOSTNAME/$HOSTNAME.apacheconf.txt | grep -i "FollowSymLinks" | grep -v "#" | wc -l` -eq 0 ]
			then
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 'FollowSymLinks' 옵션이 제거되어 있으므로 양호함 "		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 'FollowSymLinks' 옵션이 제거되어 있지 않으므로 취약함 " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi	

	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 양호: 취약요건에 해당사항이 없는 경우"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 취약: Apache Options에 불필요하게 FollowSymLinks 설정이 되어 있는 경우"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 업무적으로 사용하는 경우라도 중요 디렉터리 혹은 파일에 링크가 설정 되어 있는 경우"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-39 END"
echo "-------------------- U-40. Apache 파일 업로드 및 다운로드 제한 ------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 설정된 Directory의 LimitRequestBody 확인"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
		grep LimitRequestBody $HOSTNAME/$HOSTNAME.apacheconf.txt 																									>> $HOSTNAME/$HOSTNAME.txt 2>&1

		if [ `cat $HOSTNAME/$HOSTNAME.apacheconf.txt | grep -i "LimitRequestBody" | grep -v "#" | wc -l` -eq 0 ]
			then
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 파일 업로드 및 다운로드 용량을 제한하지 않았으므로 취약함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				if [ `cat $HOSTNAME/$HOSTNAME.apacheconf.txt | grep -i "LimitRequestBody" | grep -v "#" | awk '$2>5000000 {print $1,$2}' | wc -l` -eq 0 ]
					then
						echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
						echo "> 파일 업로드 및 다운로드 용량 제한 설정이 '5000000byte(5MB)'이하로 설정되어 있으므로 양호함 " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
					else
						echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
						echo "> 파일 업로드 및 다운로드 용량 제한 설정이 '5000000byte(5MB)'이상으로 설정되어 있으므로 취약함 "		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				fi
		fi	

	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 양호: httpd.conf 파일 내 디렉터리 설정에 LimitRequestBody 값 설정이 되어 있을 경우"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 취약: httpd.conf 파일 내 디렉터리 설정에 LimitRequestBody 값 설정이 되어 있지 않은 경우"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-40 END"
echo "-------------------- U-41. Apache 웹 서비스 영역의 분리 -------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1	
	echo "* DocumentRoot 디렉터리 확인 "																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	cat $HOSTNAME/$HOSTNAME.apacheconf.txt | grep -i "DocumentRoot" | grep -v "#"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		
		cat $HOSTNAME/$HOSTNAME.apacheconf.txt | grep -i "DocumentRoot" | grep -v "#"	>> apache41.txt
		
		if [ `cat apache41.txt | egrep -v "/usr/local/apache/htdocs|/usr/local/apach2/htdocs|/var/www/html" | wc -l` -eq 0 ]
			then
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> DocumentRoot를 기본 디렉터리로 지정하여 사용중이므로 취약함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> DocumentRoot를 별도의 디렉터리로 지정하여 사용중이므로 양호함"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi		

			rm apache41.txt
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 양호: 웹 서비스 경로 중 "/" 등 기타 업무와 영역이 분리되지 않은 경로 또는 불필요한 경로가 존재하지 않을 경우"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "** 취약: 웹 서비스 경로 중 "/" 등 기타 업무와 영역이 분리되지 않은 경로 또는 불필요한 경로가 존재하는 경우"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-41 END"
else
	echo "-------------------- U-35. Apache 디렉터리 리스팅 제거 --------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "U-35 END"
	echo "-------------------- U-36. Apache 웹 프로세스 권한 제한 -------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "U-36 END"
	echo "-------------------- U-37. Apache 상위 디렉터리 접근 금지 -----------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "U-37 END"
	echo "-------------------- U-38. Apache 불필요한 파일 제거 ----------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "U-38 END"
	echo "-------------------- U-39. Apache 링크 사용 금지 -------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "U-39 END"
	echo "-------------------- U-40. Apache 파일 업로드 및 다운로드 제한 ------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "U-40 END"
	echo "-------------------- U-41. Apache 웹 서비스 영역의 분리 -------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "U-41 END"
fi


echo "-------------------- U-60. SSH 원격 접속 허용 ----------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 원격 접속시 SSH 프로토콜을 사용하는 경우 양호"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "① 프로세스 데몬 동작 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "-------------------------" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ `ps -ef | grep sshd | grep -v "grep" | wc -l` -eq 0 ]
		then
			echo "☞ SSH Service Disable" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
			ps -ef | grep sshd | grep -v "grep" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "② 서비스 포트 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "-------------------------" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " " > ssh-result.Script
	ServiceDIR="/etc/sshd_config /etc/ssh/sshd_config /usr/local/etc/sshd_config /usr/local/sshd/etc/sshd_config /usr/local/ssh/etc/sshd_config /etc/opt/ssh/sshd_config"
  	for file in $ServiceDIR
    do
	    if [ -f $file ]
	    then
		    if [ `cat $file | grep "^Port" | grep -v "^#" | wc -l` -gt 0 ]
		    then
			        cat $file | grep "^Port" | grep -v "^#" | awk '{print "SSH 설정파일('${file}'): " $0 }' >> ssh-result.Script
			        port1=`cat $file | grep "^Port" | grep -v "^#" | awk '{print $2}'`
			        echo " " > port1-search.Script
		    else
			        echo "SSH 설정파일($file): 포트 설정 X (Default 설정: 22포트 사용)" >> ssh-result.Script
		    fi
	    fi
    done
  	if [ `cat ssh-result.Script | grep -v "^ *$" | wc -l` -gt 0 ]
    then
	    cat ssh-result.Script | grep -v "^ *$" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    else
	    echo "SSH 설정파일: 설정 파일을 찾을 수 없습니다." >> $HOSTNAME/$HOSTNAME.txt 2>&1
  	fi
	echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
	# 서비스 포트 점검
	echo "③ 서비스 포트 활성화 여부 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "-------------------------" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f port1-search.Script ]
    then
	    if [ `netstat -nat | grep ":$port1 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]
	    then
		      echo "☞ SSH Service Disable" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	    else
		      netstat -na | grep ":$port1 " | grep -i "^tcp" | grep -i "LISTEN" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	    fi
    else
	    if [ `netstat -nat | grep ":22 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]
	      then
		      echo "☞ SSH Service Disable" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	      else
		      netstat -nat | grep ":22 " | grep -i "^tcp" | grep -i "LISTEN" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	    fi
  	fi
	echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
  	if [ -f port1-search.Script ]
    then
      	if [ `netstat -nat | grep ":$port1 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]
	      then
            echo "> 원격접속 시 SSH를 사용하고 있지 않으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	      else
            echo "> 원격접속 시 SSH를 사용하고 있으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	    fi
    else
	    if [ `netstat -nat | grep ":22 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]
	      then
            echo "> 원격접속 시 SSH를 사용하고 있지 않으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	      else
            echo "> 원격접속 시 SSH를 사용하고 있으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	    fi
	fi
  	rm -rf ssh-result.Script port1-search.Script																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-60 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "SSH를 이용하여 원격접속을 사용하고 있는지 점검"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1


echo "-------------------- U_61. ftp 서비스 확인 -------------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: FTP 서비스가 비활성화되어 있을시 양호"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1	
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
    ftpActivated=0
  echo "/etc/services 파일에서 포트 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
  echo "------------------------------------------------------------------------------" >> $HOSTNAME/$HOSTNAME.txt 2>&1

  if [ `cat /etc/services | awk -F" " '$1=="ftp" {print "/etc/service파일 : " $1 " " $2}' | grep "tcp" | wc -l` -gt 0 ]
    then
	    cat /etc/services | awk -F" " '$1=="ftp" {print "/etc/service파일 : " $1 " " $2}' | grep "tcp" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    else
	    echo "* 1. /etc/service파일: 포트 설정 X (Default 21번 포트)" >> $HOSTNAME/$HOSTNAME.txt 2>&1
  fi



  if [ -s /etc/vsftpd/vsftpd.conf ] 
    then
	    if [ `cat /etc/vsftpd/vsftpd.conf | grep "listen_port" | grep -v "^#" | awk '{print "VsFTP 포트: " $1 "  " $2}' | wc -l` -gt 0 ]
	      then
		      cat  /etc/vsftpd/vsftpd.conf | grep "listen_port" | grep -v "^#" | awk '{print "VsFTP 포트: " $1 "  " $2}' >> $HOSTNAME/$HOSTNAME.txt 2>&1
	      else
		      echo "* VsFTP 포트: 포트 설정 X (Default 21번 포트 사용중)" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	    fi
    else
	    echo "* VsFTP 포트: VsFTP가 설치되어 있지 않습니다." >> $HOSTNAME/$HOSTNAME.txt 2>&1
  fi
  
  
  if [ -s /etc/proftpd.conf ]
    then
	    if [ `cat /etc/proftpd.conf | grep "Port" | grep -v "^#" | awk '{print "ProFTP 포트: " $1 "  " $2}' | wc -l` -gt 0 ]
	      then
		      cat /etc/proftpd.conf | grep "Port" | grep -v "^#" | awk '{print "ProFTP 포트: " $1 "  " $2}' >> $HOSTNAME/$HOSTNAME.txt 2>&1
	      else
		      echo "ProFTP 포트: 포트 설정 X (/etc/service 파일에 설정된 포트 사용중)" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	    fi
    else
	    echo "ProFTP 포트: ProFTP가 설치되어 있지 않습니다." >> $HOSTNAME/$HOSTNAME.txt 2>&1
  fi



echo "서비스 포트 활성화 여부 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
  echo "------------------------------------------------------------------------------" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	portArr=[]
  ################# /etc/services 파일에서 포트 확인 #################

  if [ `cat /etc/services | awk -F" " '$1=="ftp" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
    then
	    port=`cat /etc/services | awk -F" " '$1=="ftp" {print $1 "   " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	    if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]
	      then
		      netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		      portArr[0]="enable"
	    fi
    else
	    netstat -nat | grep ":21 " | grep -i "^tcp" | grep -i "LISTEN" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	    portArr[0]="Disable"
  fi

  ################# vsftpd 에서 포트 확인 ############################
#find /etc -name "vsftpd.conf"  cat /etc/vsftpd/vsftpd.conf | grep "listen_port" | grep -v "^#" | awk -F"=" '{print $2}'
  if [ -s /etc/vsftpd/vsftpd.conf ]
    then
	    if [ `cat /etc/vsftpd/vsftpd.conf | grep "listen_port" | grep -v "^#" | awk -F"=" '{print $2}' | wc -l` -eq 0 ]
	      then
		      port=21
	      else
		      port=`cat /etc/vsftpd/vsftpd.conf | grep "listen_port" | grep -v "^#" | awk -F"=" '{print $2}'`
	    fi
	    if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]
	      then
		      netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		      portArr[1]="enable"
	    fi
	  else
	   	portArr[1]="Disable"
  fi
  


  ################# proftpd 에서 포트 확인 ###########################

  if [ -s /etc/proftpd.conf ]
    then
	    port=`cat /etc/proftpd.conf | grep "Port" | grep -v "^#" | awk '{print $2}'`
	    
	    if [ `netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]
	      then
		      netstat -nat | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" >> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "ftp Service Enable" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		      portArr[2]="enable"
		    else
				echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "ftp Service Disable" >> $HOSTNAME/$HOSTNAME.txt 2>&1
		      portArr[2]="Disable"
	    fi
	  else
	    portArr[2]="Disable"
  fi
    echo "${portArr[*]}" > result_U61.txt


  	echo "서비스 활성화 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "------------------------------------------------------------------------------" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ `ps -ef | grep -i "ftp" | grep -v "grep" | grep -v "ssh" | wc -l` -eq 0 ]
	then
		echo ' ' >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "※ FTP Service 비활성화" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	else
		echo ' ' >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "※ FTP Service 활성화" >> $HOSTNAME/$HOSTNAME.txt 2>&1
        echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
    if [ `cat result_U61.txt | grep "enable" | wc -l` -gt 0 ]
    then
        echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> FTP 서비스가 활성화되어 있으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
        ftpActivated=1
    else
        echo ""		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> FTP 서비스가 비활성화되어 있으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    fi
    echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U_61 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "FTP 서비스 비활성화, 사용해야 한다면 암호화 통신이 되는 접속 프로토콜 사용시 양호"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "암호화되지 않은 채로 전송하기때문에 스니핑 가능, 반드시 필요한 경우 제외하곤 사용 제한"											>> $HOSTNAME/$HOSTNAME.txt 2>&1  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
rm -r result_U61.txt



echo "-------------------- U-62. ftp 계정 shell 제한 ---------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: ftp 계정에 /bin/false 쉘이 부여되어 있을시 양호"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "" 																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "" 	                                                                                                                        >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ `ps -ef | grep -i ftp | grep -v grep | wc -l` -gt 0 ]
	then
		echo "※ FTP Service 활성화"                                                                                                >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo " "                                                                                                                    >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "* ftp 계정 쉘 확인"                                                              >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "--------------------------------"                                                   >> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ `cat /etc/passwd | awk -F: '$1=="ftp"' | wc -l` -gt 0 ]
		then
			cat /etc/passwd | awk -F: '$1=="ftp"'                                                                                       >> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo " "                                                                                                                >> $HOSTNAME/$HOSTNAME.txt 2>&1
				if [ `cat /etc/passwd | awk -F: '$1=="ftp"' | egrep "false|nologin" | wc -l` -gt 0 ]
				then
					echo " "                                                                                                        >> $HOSTNAME/$HOSTNAME.txt 2>&1
					echo "> FTP 서비스가 실행되고 있으나 FTP 계정에 /flase, /nologin 쉘이 부여되어 있으므로 양호함 "                                              >> $HOSTNAME/$HOSTNAME.txt 2>&1
				else
					echo " "                                                                                                        >> $HOSTNAME/$HOSTNAME.txt 2>&1
					echo "> FTP 계정에 shell 제한이 부여되어 있지 않으므로 취약함"                                                                >> $HOSTNAME/$HOSTNAME.txt 2>&1
				fi
		else
			echo "ftp 계정이 존재하지 않음."                                                                                            >> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo " "                                                                                                                >> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo " "                                                                                                                >> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "ftp 계정이 존재하지 않으므로 양호함"                                                                                      >> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	else
		echo "※ FTP Service 비활성화"                                                                                                           >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo " "                                                                                                                    >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo " "                                                                                                                    >> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> FTP 서비스가 비활성화되어 있으므로 양호함"                                                                                >> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-62 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "ftp 설치시 default ftp 계정은 로그인이 필요하지 않으므로 쉘을 제한하여 시스템 접근 차단 필요"									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "로그인이 불필요한 default 계정에 쉘을 부여할 경우 공격자에게 해당 계정이 노출, 시스템 불법 침투 가능"  							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/bin/false 접근 금지"  																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1



echo "-------------------- U-63. Ftpusers 파일 소유자 및 권한 설정 --------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: ftpusers 파일의 소유자가 root이고, 권한이 640 이하인 경우 "															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
    ftpUsers=( $(find /etc -name "ftpusers") )
    echo "* ftpusers 파일 확인"                                                                                                        >> $HOSTNAME/$HOSTNAME.txt 2>&1
		find /etc -name "ftpusers"                                                                                                           >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
    echo " " > result_U63.txt
    for i in ${ftpUsers[*]}
    do
		if [ `ls -l $i | awk '{print $3}' | grep "root" | wc -l` -eq 0 ]
		then
		  	echo "취약" >> result_U63.txt
		else
			if [ `ls -l $i | awk '{print $1}' | grep '...-.-----' | wc -l` -eq 1 ]
			then
				echo "양호" >> result_U63.txt
			else 
				echo "취약" >> result_U63.txt	
			fi
		fi
    done
    if [ $ftpActivated == 1 ]
    then
        if [ `cat result_U63.txt | grep "취약" | wc -l` -gt 0 ]
        then
            echo "> ftpusers 파일 소유자 및 권한 설정이 부적절하게 되어 있으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
        else
            echo "> ftpusers 파일 소유자 및 권한 설정이 적절하게 되어 있으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
        fi
    else
            echo "※ FTP Service 비활성화"                                                                                                           >> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo " "                                                                                                                    >> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "> FTP 서비스가 비활성화되어 있으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    fi
    rm -r result_U63.txt
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-63 END"
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1



echo "-------------------- U-64. Ftpusers 파일 설정 ----------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: FTP 서비스가 비활성화 되어있거나, 활성화시 root 계정 접속을 차단한 경우 양호"											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
    echo " " > result_U64.txt
    if [ $ftpActivated == 1 ]
    then
        echo "1. ftpusers"																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
        echo "* /etc/ftpusers 점검"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
            if [ `cat /etc/ftpusers | grep root | grep -v "#" | wc -l` -gt 0 ]
            then
                echo "양호" >> result_U64.txt
            else
                echo "취약" >> result_U64.txt
            fi
            if [ `cat /etc/ftpd/ftpusers | grep root | grep -v "#" | wc -l` -gt 0 ]
            then
                echo "양호" >> result_U64.txt
            else
                echo "취약" >> result_U64.txt
            fi
            if [ `cat /etc/proftpd.conf | grep root | grep -v "#" | wc -l` -gt 0 ]
            then
                echo "양호" >> result_U64.txt
            else
                echo "취약" >> result_U64.txt
            fi
            if [ `cat /etc/vsftpd/ftpusers | grep root | grep -v "#" | wc -l` -gt 0 ]
            then
                echo "양호" >> result_U64.txt
            else
                echo "취약" >> result_U64.txt
            fi
            if [ `cat /etc/vsftpd/user_list | grep root | grep -v "#" | wc -l` -gt 0 ]
            then
                echo "양호" >> result_U64.txt
            else
                echo "취약" >> result_U64.txt
            fi
            if [ `cat /etc/vsftpd.ftpusers | grep root | grep -v "#" | wc -l` -gt 0 ]
            then
                echo "양호" >> result_U64.txt
            else
                echo "취약" >> result_U64.txt
            fi
            if [ `cat /etc/vsftpd.user_list | grep root | grep -v "#" | wc -l` -gt 0 ]
            then
                echo "양호" >> result_U64.txt
            else
                echo "취약" >> result_U64.txt
            fi
    else    
        echo "> FTP서비스가 비활성화 되어 있으므로 양호함"                                                                                    >> $HOSTNAME/$HOSTNAME.txt 2>&1
    fi
    if [ `cat result_U64.txt | grep "취약" | wc -l` -gt 0 ]
    then
        echo ""				>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> FTP root 계정 접속을 차단하지 않고 사용 중이므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    else
        echo ""				>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> FTP root 계정 접속을 차단하고 사용 중이므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    fi
	echo ""				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-64 END"
    rm -r result_U64.txt
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "1. ftpusers 파일내에 #root (주석처리) 또는 root 계정 미등록"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "2. ProFTP 파일내에 RootLogin off"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "3. vsFTP 파일내에 #root (주석처리) 또는 root 계정 미등록"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1



echo "-------------------- U-65. at 서비스 권한 설정 --------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: at 접근제어 파일의 소유자가 root이고, 권한이 640 이하일시 양호"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
    if [ -f /etc/at.allow ]
        then
        echo "* /etc/at.allow 파일 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
            echo `ls -l /etc/at.allow` >> $HOSTNAME/$HOSTNAME.txt 2>&1
            echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
            echo "/etc/at.allow 파일 내용" >> $HOSTNAME/$HOSTNAME.txt 2>&1
            echo "----------------------">> $HOSTNAME/$HOSTNAME.txt 2>&1
            if [ `cat /etc/at.allow | wc -l` -ge 1 ];then
                cat /etc/at.allow >> $HOSTNAME/$HOSTNAME.txt 2>&1
            else
                echo "파일 내용이 없습니다." >> $HOSTNAME/$HOSTNAME.txt 2>&1
            fi
            echo "----------------------">> $HOSTNAME/$HOSTNAME.txt 2>&1
            
        if [ \( `ls -l /etc/at.allow | awk '{print $3}' | grep -i root | wc -l` -eq 1 \) -a \( `ls -l /etc/at.allow | grep '...-.-----' | wc -l` -eq 1 \) ]; then
                if [ `cat /etc/at.allow | wc -l` -ge 1 ]; then
                    allow_result='true'
                else
                    allow_result='false'
                fi
            else
                allow_result='false'
            fi
    else
        echo "※ /etc/at.allow 파일이 없습니다." >> $HOSTNAME/$HOSTNAME.txt 2>&1
            allow_result='true'
    fi
    
    if [ -f /etc/at.deny ]
        then					
        echo "* /etc/at.deny 파일 확인" >> $HOSTNAME/$HOSTNAME.txt 2>&1
            echo `ls -l /etc/at.deny` >> $HOSTNAME/$HOSTNAME.txt 2>&1
            echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
            echo "■/etc/at.deny 파일 내용" >> $HOSTNAME/$HOSTNAME.txt 2>&1
            echo "----------------------">> $HOSTNAME/$HOSTNAME.txt 2>&1
            if [ `cat /etc/at.deny | wc -l` -ge 1 ];then
                cat /etc/at.deny >> $HOSTNAME/$HOSTNAME.txt 2>&1
            else
                echo "파일 내용이 없습니다." >> $HOSTNAME/$HOSTNAME.txt 2>&1
            fi 
            echo "----------------------" >> $HOSTNAME/$HOSTNAME.txt 2>&1
        
            if [ \( `ls -l /etc/at.deny | awk '{print $3}' | grep -i root |wc -l` -eq 1 \) -a \( `ls -l /etc/at.deny | grep '...-.-----' | wc -l` -eq 1 \) ]; then
                if [ `cat /etc/at.deny | wc -l` -ge 1 ];then
                    deny_result='true'
                else
                    deny_result='false'
                fi
            else
                deny_result='false'
            fi
    else
        echo "※ /etc/at.deny 파일이 없습니다." >> $HOSTNAME/$HOSTNAME.txt 2>&1
            deny_result='true'
    fi
	  
    echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
    if [ $allow_result = 'false' -o $deny_result = 'false' ]
    then
        echo "> at 접근제어 파일의 권한 또는 소유자가 부적절하므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    else
        echo "> at 접근제어 파일의 권한 및 소유자가 적절하므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
  echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-65 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
    echo "▶ 점검기준 : at 접근제어 파일의 소유자가 root이고, 권한이 640 이하인 경우 양호(권한 640이지만 파일에 내용 없을 시 취약)" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    echo "          at.deny, at.allow파일 모두 없을 시 관리자 계정 이외는 사용하지 못하므로 양호" >> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "at 파일의 소유자: root | 권한: -rw-r----- under 640"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-66. SNMP 서비스 구동 점검 -------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: SNMP 서비스를 사용하지 않을시 양호 "																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
    SNMPActivate=0
    if [ `ps -ef | grep snmp | grep -v "dmi" | grep -v "grep" | wc -l` -eq 0 ]
        then
            echo "※ SNMP Service 비활성화"  >> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1           
		    echo "> SNMP 서비스를 사용하고 있지 않으므로 양호함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
        else
            ps -ef | grep snmp | grep -v "dmi" | grep -v "grep" >> $HOSTNAME/$HOSTNAME.txt 2>&1
            echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
            SNMPActivate=1
            echo "> SNMP 서비스를 사용하고 있으므로 취약함" >> $HOSTNAME/$HOSTNAME.txt 2>&1
            echo "** U-67 항목이 양호일 경우 U-66 항목도 양호" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    fi
    echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-66 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "양호: Snmp 서비스를 사용하지 않는 경우 or 서비스를 사용하지만 U-67 항목이 양호인 경우"										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "취약: Snmp 서비스를 사용하고 and U-67 항목이 취약인 경우"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "--------------- U-67. SNMP 서비스 커뮤니티스트링의 복잡성 설정 -------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: SNMP Community 이름이 public, private이 아닐시 양호 "																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
    SPCONF_DIR="/etc/snmpd.conf /etc/snmpdv3.conf /etc/snmp/snmpd.conf /etc/snmp/conf/snmpd.conf /etc/sma/snmp/snmpd.conf"
    if [ $SNMPActivate == 1 ]
    then
        for file in $SPCONF_DIR
        do
            if [ -f $file ]
            then
                echo "■ "$file"파일 내 CommunityString 설정" >> $HOSTNAME/$HOSTNAME.txt 2>&1
                echo "------------------------------------------------------------------------------" >> $HOSTNAME/$HOSTNAME.txt 2>&1
                echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
                cat $file | grep -i -A1 -B1 "Community" | grep -v "#" >> $HOSTNAME/$HOSTNAME.txt 2>&1
                echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
            fi
        done 
                echo " " >> $HOSTNAME/$HOSTNAME.txt 2>&1
    else
        echo "> SNMP 서비스를 사용하고 있지 않으므로 해당없음" >> $HOSTNAME/$HOSTNAME.txt 2>&1
    fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-67 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "Community String은 default로 public, private로 설정된 경우가 다수"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "이를 변경하지 않으면 이 String을 악용하여 시스템의 주요 정보 및 설정을 파악할 수 있음"  										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "Snmp의 community name이 기본값인 public, private가 아니도록 설정"															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-68. 로그온 시 경고 메시지 제공 ---------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 서버 및 Telnet, FTP, SMTP, DNS, 서비스에 로그온 메시지가 설정되어 있으면 양호 "										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 서버 로그온 메시지 점검 /etc/motd"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ `cat /etc/motd | grep -v '#' | wc -l` -eq 0 ]
			then
				echo "> 로그온 시 경고 메시지가 설정되어 있지 않으므로 취약함 " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				cat /etc/motd | grep -v '#'																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 로그온 시 경고 메시지가 설정되어 있으므로 양호함 " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* Telnet 배너 점검 /etc/issue.net"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f /etc/issue.net ]
		then
			cat /etc/issue.net | grep -v '#'																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
			cat $TELNET_BANNER | grep -i herald | grep -v '#'																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
			echo "'/etc/issue.net' 파일이 존재하지 않습니다. " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* Ftp 배너 점검"																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f $FTP_BANNER ]
		then
			cat $FTP_BANNER | grep -v '#'																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
			echo "'$FTP_BANNER' 파일이 존재하지 않습니다. " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* SMTP 배너 점검 /etc/mail/sendmail.cf"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f /etc/mail/sendmail.cf ]
		then
			cat /etc/mail/sendmail.cf | grep -v '#'																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
			echo "'/etc/mail/sendmail.cf' 파일이 존재하지 않습니다. " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi	
	
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -f /etc/welcome.msg ]
		then
			echo "* /etc/welcome.msg 메시지 점검"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			cat /etc/welcome.msg | grep -v '#'																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
			echo "'/etc/welcome.msg' 파일이 존재하지 않습니다. " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi	

	if [ -f /etc/vsftpd/vsftpd.conf ]
		then
			echo "* /etc/vsftpd/vsftpd.conf 메시지 점검"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			cat /etc/vsftpd/vsftpd.conf | grep -v '#'																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
			echo "'/etc/vsftpd/vsftpd.conf' 파일이 존재하지 않습니다. " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi	

	if [ -f /etc/vsftpd/vsftpd.msg ]
		then
			echo "* /etc/vsftpd/vsftpd.msg 메시지 점검"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			cat /etc/vsftpd/vsftpd.msg | grep -i ftpd_banners																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
			echo "'/etc/vsftpd/vsftpd.msg' 파일이 존재하지 않습니다. " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi	

	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* DNS 배너 설정"																											>> $HOSTNAME/$HOSTNAME.txt 2>&1		

	if [ -f /etc/named.conf ]
		then
			echo "* /etc/named.conf"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			cat /etc/named.conf																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
		else
			echo "'/etc/named.conf' 파일이 존재하지 않습니다. " 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi	

	
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-68 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "ftp 접속 경고 배너 수동 점검 : 접속 시도"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "로그인 전후 'Authorized users only. All activity may be monitored and reported'와 같은 경고문띄움"							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-69. NFS 설정 파일 접근 권한 ------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: NFS 접근제어 설정 파일의 소유자가 root이고, 권한이 644 이하일시 양호 "													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		if [ `ps -ef | egrep "nfs|statd|lockd" | grep -v "grep" | grep -v "kblockd" | wc -l` -eq 0 ]
			then
				echo "> NFS 서비스가 비활성화되어 있으므로 해당없음"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
			## 추후 아래 취약 양호 구별 함수 추가 필요
				echo "* nfs 프로세스 확인"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
					ps -ef | egrep -i "nfs|lockd|statd"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "* /etc/exports 점검"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
					ls -al /etc/exports																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
					echo "share 명령어 확인"																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
						share																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "exportfs -a 명령어 확인"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
					exportfs -a																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-69 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "NFS 파일의 소유자: root | 권한: -rw-r--r-- under 644"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-70. expn, vrfy 명령어 제한 ------------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: SMTP 서비스 미사용 또는 noexpn, novrfy 옵션이 설정되어 있는 경우 양호 "												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* EXPN, VRFY 명령어 제한 확인"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/mail/sendmail.cf | grep -i "O PrivacyOptions"																		>> $HOSTNAME/$HOSTNAME.txt 2>&1

		if [ `cat /etc/mail/sendmail.cf | grep -i "O PrivacyOptions" | grep -v "#" | grep -i -o "" | wc -l` -eq 0 ]
			then	
				echo "> Sendmail 서비스가 비활성화되어 있으므로 해당없음"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
			# 추후 아래 양호 취약 추가 필요
				echo "* SMTP O PrivacyOptions, restrictqrun 옵션 확인"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
					cat $SMTP_CONF | grep -i "O PrivacyOptions" | grep -i "restrictqrun"														>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "* SMTP 서비스 사용 여부 및 restrictqrun 옵션 확인"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
					grep -v '^*#' /etc/mail/sendmail.cf | grep PrivacyOptions																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> Sendmail 일반사용자 실행 방지 설정 수동점검 필요"	>> $HOSTNAME/$HOSTNAME.txt 2>&1					
		fi
		
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-70 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "O PrivacyOptions=authwarnings, noexpn, novrfy 옵션 설정 확인"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "EXPN : 메일 전송 시 포워딩하기 위한 명령어"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "VRFY : SMTP 클라이언트가 SMTP서버에 특정 ID에 대한 메일이 있는지 검증하기 위한 명령어"  										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

if [ $APACHESTATUS == "ON" ]; then
	echo "-------------------- U-71. Apache 웹서비스 정보 숨김 ----------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
			echo "* ServerTokens, ServerSignature 확인"																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
			cat $HOSTNAME/$HOSTNAME.apacheconf.txt | egrep -i "ServerTokens|serverSignature" | grep -v "#"  																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
			
		if [ `cat $HOSTNAME/$HOSTNAME.apacheconf.txt | grep -i "ServerTokens" | wc -l` -eq 0 ]
			then
				echo " 'ServerTokens' 값이 존재하지 않음 "		>> $HOSTNAME/$HOSTNAME.txt 2>&1
				echo "> 'ServerTokens' 값 설정이 존재하지 않으므로 취약함 "		>> $HOSTNAME/$HOSTNAME.txt 2>&1
			else
				if [ `cat $HOSTNAME/$HOSTNAME.apacheconf.txt | grep -i "ServerTokens" | grep -i -o "prod" | wc -l` -eq 0 ]
					then
						echo "> 'ServerTokens' 값이 'Prod'로 설정되어 있지 않으므로 취약함" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
					else
						if [ `cat $HOSTNAME/$HOSTNAME.apacheconf.txt | grep -i "serverSignature" | wc -l` -eq 0 ]
							then
								echo " 'ServerSignature' 값이 존재하지 않음 "		>> $HOSTNAME/$HOSTNAME.txt 2>&1
								echo "> 'ServerSignature' 값 존재하지 않으므로 취약함 "		>> $HOSTNAME/$HOSTNAME.txt 2>&1
							else
								if [ `cat $HOSTNAME/$HOSTNAME.apacheconf.txt | grep -i "serverSignature" | grep -i -o "off" | wc -l` -eq 0 ]
									then
										echo "> 'ServerSignature' 값이 'off'로 설정되어 있지 않으므로 취약함" 	>> $HOSTNAME/$HOSTNAME.txt 2>&1
									else
										echo "> ServerTokens, ServerSignature 설정이 적절하므로 양호함"	>> $HOSTNAME/$HOSTNAME.txt 2>&1
								fi
						fi
				fi
		fi
		echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "U-71 END"
		echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "*ServerTokens 지시자 옵션 "																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "Prod - 제공하는 정보 : 웹 서버 종류 (Ex. ServerApache)"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "Min - 제공하는 정보 : Prod 키워드 제공 정보 + 웹 서버 버전 (Ex. ServerApache/1.3.0)"												>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "OS - 제공하는 정보 : Min 키워드 제공 정보 + 운영체제 (Ex. ServerApache/1.3.0 (Unix))"											>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "Full - 제공하는 정보 : OS 키워드 제공 정보 + 설치된 모듈(응용프로그램) 정보 (Ex. ServerApache/1.3.0 (Unix), PHP/3.0, MyMod/1.2)"		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "양호: ServerTokens 지시자에 Prod 옵션이 설정되어 있는 경우										"								>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "취약: ServerTokens 지시자에 Prod 옵션이 설정되어 있지 않는 경우"																	>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "결과 값이 안나온다면 미설치 또는 비활성화"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	else 
		echo "---------- U-71. Apache서비스 정보 숨김 ----------------------------------"																>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "> apache 웹 서비스가 비활성화되어 있으므로 해당 없음 "		>> $HOSTNAME/$HOSTNAME.txt 2>&1
		echo "U-71 END"
		echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
echo "********************** 4. 패치 관리 ****************************************"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "-------------------- U-42. 최신 보안패치 및 벤더 권고사항 적용 -------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 패치 적용 정책을 수립하여 주기적으로 패치관리를 하고 있으며, 패치 관련 내용을 확인하고 적용했을 경우 양호"					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* 커널 정보 확인"																											>> $HOSTNAME/$HOSTNAME.txt 2>&1
		uname -a																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* OS버전에 대한 정보 확인"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/issue																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* OS버전에 대한 정보 확인2"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/redhat-release																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* OS버전에 대한 정보 확인3"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		cat /etc/*release*		>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* OS버전에 대한 정보 확인4"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
		hostnamectl >> $HOSTNAME/OSversion.txt 2>&1
	echo ""	>> $HOSTNAME/OSversion.txt 2>&1
	echo ""	>> $HOSTNAME/OSversion.txt 2>&1
	
	echo "< RedHat/CentOS 버전별 지원 기간 >"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "RHEL 8 : 2029년 05월 31일 일반 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "RHEL 8 : 2031년 05월 31일 연장 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "RHEL 7 / Cent 7 : 2024년 06월 30일 일반 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "RHEL 7 / Cent 7 : 2026년 06월 30일 연장 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "RHEL 7.6 : 2022년 10월 31일 일반 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "RHEL 7.7 : 2023년 08월 31일 일반 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "RHEL 8.1 : 2023년 11월 30일 일반 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "RHEL 8.2 : 2024년 04월 30일 일반 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "RHEL 8.4 : 2025년 05월 30일 일반 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	
	echo "< Ubuntu 버전별 지원 기간 >"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "Ubuntu 22.04 : 2027년 4월 일반/연장 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "Ubuntu 21.10 : 2022년 7월 일반/연장 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "Ubuntu 21.04 : 2022년 1월 일반/연장 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "Ubuntu 20.04 LTS (20.04.1~3 포함) : 2025년 4월 일반 종료"	>> $HOSTNAME/OSversion.txt 2>&1	
	echo "Ubuntu 20.04 LTS (20.04.1~3 포함) : 2030년 4월 연장 종료"	>> $HOSTNAME/OSversion.txt 2>&1	
	echo "Ubuntu 18.04 LTS (18.04.1~6 포함) : 2023년 4월 일반 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "Ubuntu 18.04 LTS (18.04.1~6 포함) : 2028년 4월 연장 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "Ubuntu 16.04 LTS (18.04.1~6 포함) : 일반 지원 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "Ubuntu 16.04 LTS (18.04.1~6 포함) : 2026년 4월 연장 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "Ubuntu 14.04 LTS (18.04.1~6 포함) : 일반 지원 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "Ubuntu 14.04 LTS (18.04.1~6 포함) : 2024년 4월 연장 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	
	echo "< AIX/HP-UX 버전별 지원 기간 >"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "AIX 7.1 TL5 : 2023년 04월 30일 일반 종료(추정)"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "AIX 7.2 TL4 : 2022년 11월 30일 일반 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "AIX 7.2 TL5 : 2023년 11월 30일 일반 종료(추정)"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "AIX 7.3 TL0 : 2024년 12월 31일 일반 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	echo "HP-UX 11i v3(B.11.31) : 2025년 12월 31일 일반 종료"	>> $HOSTNAME/OSversion.txt 2>&1
	
	echo "> OS 버전 및  수동점검 필요"	>> $HOSTNAME/$HOSTNAME.txt 2>&1	
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-42 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "Redhat 보안 사이트"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "http://www.redhat.com/security/updates/"																					>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "********************** 5. 로그 관리 ****************************************"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "-------------------- U-43. 로그의 정기적 검토 및 보고 ---------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 접속기록 등의 보안 로그, 응용 프로그램 및 시스템 로그 기록에 대해 정기적으로 검토, 분석, 리포트 작성 및 보고 등의 조치가 이루어지는 경우 양호 "	>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* /etc/syslog.conf 점검"																									>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -e /etc/syslog.conf ]; then
		cat /etc/syslog.conf | grep -v "#"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
		echo "* rsyslog.conf"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	if [ -e /etc/rsyslog.conf ]; then
		cat /etc/rsyslog.conf | grep -v "#"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	fi
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-43 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "/etc/syslog.conf 다음의 설정을 권고함"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "mail.debug/var/adm/syslog/mail.log"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "*.info/var/adm/syslog/syslog.log"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "*.alert/var/adm/syslog/syslog.log"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "*.alert/dev/console"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "*.alertroot"																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "*.emerg*"																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " 정기적으로 로그 분석에 대한 결과물 존재 확인"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " 다음 스크립트 결과는 추가적으로 확인"																						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1

echo "-------------------- U-72. 정책에 따른 시스템 로깅 설정 -------------------"													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_START_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[기준]: 로그 기록 정책이 정책에 따라 설정되어 수립되어 있으며 보안정책에 따라 로그를 남기고 있을시 양호 "							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "[설정 현황]"  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* syslog 파일 탐색"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	cat $SYSLOG_CONF | grep -v '^#'																									>> $HOSTNAME/$HOSTNAME.syslog.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* rsyslog 파일 탐색"																										>> $HOSTNAME/$HOSTNAME.txt 2>&1
	cat /etc/rsyslog.conf | grep -v '^#'																							>> $HOSTNAME/$HOSTNAME.rsyslog.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* syslog 파일 내 로깅 설정 확인"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	cat /etc/syslog.conf | grep -v 'info;mail.none|mail.*|cron.*|*.alret|*.emerg'													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "-----------------------------------------------"																			>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "* rsyslog 파일 내 로깅 설정 확인"																							>> $HOSTNAME/$HOSTNAME.txt 2>&1
	cat /etc/rsyslog.conf | grep -v 'info;mail.none|authpriv.*|mail.*|cron.*|*.alret|*.emerg' | grep -v "#"						>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_END_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "U-72 END"
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_RSTART_]  																												>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""																															>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo "정책에 따른 시스템 로깅설정 담당자 인터뷰 확인"																				>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo ""  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo [_REND_]  																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	echo " "  																														>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "* System Information Query End "																								>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "* End Time "																													>> $HOSTNAME/$HOSTNAME.txt 2>&1
	date																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo ""																																>> $HOSTNAME/$HOSTNAME.txt 2>&1
echo "********************************************************************"
echo "*                          (ScriptEND)                        *"
echo "********************************************************************"

	tar -cvf $HOSTNAME.tar $HOSTNAME
exit 0
