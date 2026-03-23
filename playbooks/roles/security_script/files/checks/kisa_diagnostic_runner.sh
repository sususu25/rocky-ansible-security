#!/usr/bin/env bash
# kisa_diagnostic_runner.sh
# Run KISA-style diagnostic script safely, parse consolidated report,
# and emit ONLY current fix-script numbering/title.
# rc: 0=PASS, 2=MANUAL, 3=VULN, 1=ERROR

set -u

DIAG_SCRIPT="${1:-}"
if [ -z "$DIAG_SCRIPT" ]; then
  echo "[DIAG-RUNNER][ERROR] usage: $0 /path/to/kisa_redhat_diagnostic.sh"
  exit 1
fi

if [ ! -f "$DIAG_SCRIPT" ]; then
  echo "[DIAG-RUNNER][ERROR] diagnostic script not found: $DIAG_SCRIPT"
  exit 1
fi

for cmd in awk grep find hostname mktemp cp chmod; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[DIAG-RUNNER][ERROR] required command not found: $cmd"
    exit 1
  fi
done

TMPDIR_ROOT="$(mktemp -d /tmp/kisa-diagnostic.XXXXXX)"
cleanup() {
  rm -rf "$TMPDIR_ROOT"
  rm -f /tmp/kisa_diagnostic_runner.stdout /tmp/kisa_diagnostic_runner.stderr
}
trap cleanup EXIT

WORKDIR="$TMPDIR_ROOT/run"
mkdir -p "$WORKDIR"
cp "$DIAG_SCRIPT" "$WORKDIR/diagnostic.sh"
chmod +x "$WORKDIR/diagnostic.sh"

pushd "$WORKDIR" >/dev/null || exit 1
bash ./diagnostic.sh >/tmp/kisa_diagnostic_runner.stdout 2>/tmp/kisa_diagnostic_runner.stderr
legacy_rc=$?
popd >/dev/null || exit 1

if [ $legacy_rc -ne 0 ]; then
  echo "[DIAG-RUNNER][ERROR] diagnostic script exited with rc=$legacy_rc"
  [ -s /tmp/kisa_diagnostic_runner.stderr ] && sed 's/^/[DIAG-STDERR] /' /tmp/kisa_diagnostic_runner.stderr
  exit 1
fi

HOST_SHORT="$(hostname 2>/dev/null | awk -F. '{print $1}')"
REPORT_FILE="$WORKDIR/$HOST_SHORT/$HOST_SHORT.txt"

if [ ! -f "$REPORT_FILE" ]; then
  REPORT_FILE="$(find "$WORKDIR" -maxdepth 3 -type f | grep -E '/[^/]+/[^/]+\.txt$' | grep -v '/Script/' | head -n 1 || true)"
fi

if [ -z "${REPORT_FILE:-}" ] || [ ! -f "$REPORT_FILE" ]; then
  echo "[DIAG-RUNNER][ERROR] consolidated report file not found under $WORKDIR"
  exit 1
fi

echo "[DIAG-RUNNER] source_report=$REPORT_FILE"

PARSED_OUT="$TMPDIR_ROOT/parsed.out"

awk '
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
function classify(text,   status, detail) {
  status = "PASS"
  detail = "판정 문구를 찾지 못함"

  if (text ~ /수동점검 필요|인터뷰 확인|담당자 확인|수동 확인|해당없음 여부 확인/) {
    status = "MANUAL"
    detail = "수동 확인 필요"
  }
  if (text ~ />[^\n]*취약|취약함|취약$/) {
    status = "VULN"
    detail = "취약 판정 문구 발견"
  } else if (text ~ />[^\n]*양호|양호함|양호$/) {
    status = "PASS"
    detail = "양호 판정 문구 발견"
  }
  if (text ~ />[^\n]*취약|취약함|취약$/) {
    status = "VULN"
    detail = "취약 판정 문구 발견"
  }
  return status "|" detail
}
function map_fix(title, legacy,   t) {
  t = title

  if (t ~ /root 계정 원격 접속 제한/) return "U-01|root 원격 로그인 제한"
  if (t ~ /패스워드 복잡도 설정/) return "U-02|패스워드 정책 강화"
  if (t ~ /계정잠금 임계값/) return "U-03|계정 잠금 정책"
  if (t ~ /패스워드 파일 보호/) return "U-04|/etc/passwd, shadow 적용 확인"
  if (t ~ /root이외의 UID가.*0.*금지/) return "U-05|root 외 UID 0 금지"
  if (t ~ /root계정 su제한/) return "U-06|su / wheel 설정"
  if (t ~ /불필요한 계정 제거/) return "U-07|불필요 사용자 계정"
  if (t ~ /관리자 그룹에 최소한의 계정 포함/) return "U-08|root 그룹 사용자"
  if (t ~ /계정이 존재하지 않는 GID금지/) return "U-09|불필요 그룹"
  if (t ~ /동일한 UID 금지/) return "U-10|UID 중복"
  if (t ~ /사용자 shell 점검/) return "U-11|로그인 불필요 계정 쉘 제한"
  if (t ~ /Session Timeout설정/) return "U-12|세션 자동 로그아웃 + 기본 umask"
  if (t ~ /Root 홈, 패스 디렉터리 권한 및 패스 설정/) return "U-14|PATH 환경변수 안전 설정"
  if (t ~ /파일 및 디렉터리 소유자 설정/) return "U-15|소유자/그룹 없는 파일"
  if (t ~ /\/etc\/passwd 파일 소유자 및 권한 설정/) return "U-16|/etc/passwd"
  if (t ~ /\/etc\/shadow 파일 소유자 및 권한 설정/) return "U-18|/etc/shadow"
  if (t ~ /\/etc\/hosts 파일 소유자 및 권한 설정/) return "U-19|/etc/hosts"
  if (t ~ /\/etc\/\(x\)inetd\.conf 파일 소유자 및 권한 설정/) return "U-20|inetd/xinetd/systemd 설정 파일"
  if (t ~ /\/etc\/syslog\.conf 파일 소유자 및 권한 설정/) return "U-21|syslog/rsyslog 설정 파일"
  if (t ~ /\/etc\/services 파일 소유자 및 권한 설정/) return "U-22|/etc/services"
  if (t ~ /SUID, SGID, Sticky bit 설정 파일 점검/) return "U-23|SUID/SGID 설정 파일"
  if (t ~ /사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정/) return "U-24|홈 디렉터리 환경변수 파일"
  if (t ~ /world writable 파일 점검/) return "U-25|others 쓰기 권한 파일"
  if (t ~ /\/dev에 존재하지 않는 device 파일 점검/) return "U-26|/dev 내 불필요 파일"
  if (t ~ /\.rhosts|hosts\.equiv 사용 금지/) return "U-27|hosts.equiv / .rhosts"
  if (t ~ /접속 ip 및 포트 제한/) return "U-28|접근 통제 설정"
  if (t ~ /hosts\.lpd파일 소유자 및 권한설정/) return "U-29|/etc/hosts.lpd"
  if (t ~ /UMASK 설정 관리/) return "U-30|UMASK"
  if (t ~ /홈 디렉터리 소유자 및 권한 설정/) return "U-31|사용자 홈 디렉터리 권한"
  if (t ~ /홈 디렉터리로 지정한 디렉터리의 존재 관리/) return "U-32|홈 디렉터리 미존재 계정"
  if (t ~ /숨겨진 파일 및 디렉터리 검색 및 제거/) return "U-33|불필요 숨김 파일/디렉터리"
  if (t ~ /Finger서비스 비활성화/) return "U-34|Finger 비활성화"
  if (t ~ /Anonymous FTP 비활성화/) return "U-35|익명 FTP/NFS/Samba 접근 비활성화"
  if (t ~ /r 계열 서비스 비활성화/) return "U-36|r 계열 서비스 비활성화"
  if (t ~ /cron 파일 소유자 및 권한 설정/) return "U-37|crontab/cron/at 권한"
  if (t ~ /DOS 공격에 취약한 서비스 비활성화/) return "U-38|불필요한 네트워크 서비스 비활성화"
  if (t ~ /NFS 서비스 비활성화/) return "U-39|불필요한 NFS 서비스/socket 비활성화"
  if (t ~ /NFS 접근통제/) return "U-40|/etc/exports / NFS 공유 설정"
  if (t ~ /automountd 제거/) return "U-41|automount/autofs 비활성화"
  if (t ~ /RPC 서비스 확인/) return "U-42|불필요한 RPC 서비스"
  if (t ~ /NIS, NIS\+ 점검/) return "U-43|NIS 관련 서비스"
  if (t ~ /tftp, talk 서비스 비활성화/) return "U-44|TFTP / Talk / Ntalk 서비스"
  if (t ~ /Sendmail 버전 점검/) return "U-45|메일 서비스 점검 및 비활성화"
  if (t ~ /일반사용자의 Sendmail 실행 방지/) return "U-46|메일 서비스 보안 설정 / 일반 사용자 권한 제한"
  if (t ~ /스팸 메일 릴레이 제한/) return "U-47|메일 서버 릴레이 제한"
  if (t ~ /expn, vrfy 명령어 제한/) return "U-48|SMTP VRFY/EXPN 차단"
  if (t ~ /DNS 보안 버전 패치/) return "U-49|DNS 서비스(named/BIND)"
  if (t ~ /DNS Zone Transfer 설정/) return "U-50|DNS Zone Transfer 제한"
  if (t ~ /SSH 원격 접속 허용/) return "U-60|SSH 원격 접속 허용"
  if (t ~ /ftp 계정 shell 제한/) return "U-62|ftp 계정 shell 제한"
  if (t ~ /Ftpusers 파일 소유자 및 권한 설정/) return "U-63|Ftpusers 파일 소유자 및 권한 설정"
  if (t ~ /Ftpusers 파일 설정/) return "U-64|Ftpusers 파일 설정"
  if (t ~ /at 서비스 권한 설정/) return "U-65|at 서비스 권한 설정"
  if (t ~ /SNMP 서비스 구동 점검/) return "U-66|SNMP 서비스 구동 점검"
  if (t ~ /SNMP 서비스 커뮤니티스트링의 복잡성 설정/) return "U-67|SNMP 서비스 커뮤니티스트링의 복잡성 설정"
  if (t ~ /로그온 시 경고 메시지 제공/) return "U-68|로그온 시 경고 메시지 제공"
  if (t ~ /NFS 설정 파일 접근 권한/) return "U-69|NFS 설정 파일 접근 권한"
  if (t ~ /Apache서비스 정보 숨김/) return "U-71|Apache서비스 정보 숨김"
  if (t ~ /최신 보안패치 및 벤더 권고사항 적용/) return "U-42|최신 보안패치 및 벤더 권고사항 적용"
  if (t ~ /로그의 정기적 검토 및 보고/) return "U-43|로그의 정기적 검토 및 보고"
  if (t ~ /정책에 따른 시스템 로깅 설정/) return "U-72|정책에 따른 시스템 로깅 설정"

  return sprintf("U-%02d", substr(legacy, 3) + 0) "|" t
}
function flush_section(   mapped, result, status, detail, out_num, out_title) {
  if (u != "") {
    mapped = map_fix(title, u)
    split(mapped, m, "|")
    out_num = m[1]
    out_title = m[2]

    result = classify(section_text)
    split(result, parts, "|")
    status = parts[1]
    detail = parts[2]

    if (!(out_num in seen)) {
      seen[out_num] = 1
      print "[" out_num "][" status "] " out_title " - " detail
    }
  }
}
/^[- ]*U-[0-9][0-9][.]/ {
  flush_section()
  line = $0
  match(line, /U-[0-9][0-9]/)
  u = substr(line, RSTART, RLENGTH)
  title = trim(substr(line, RSTART + RLENGTH + 1))
  gsub(/^\.+[ ]*/, "", title)
  gsub(/^-+/, "", title)
  gsub(/-+$/, "", title)
  title = trim(title)
  section_text = line "\n"
  next
}
{
  if (u != "") section_text = section_text $0 "\n"
}
END {
  flush_section()
}
' "$REPORT_FILE" > "$PARSED_OUT"

cat "$PARSED_OUT"

if grep -q '\[VULN\]' "$PARSED_OUT"; then
  exit 3
fi
if grep -q '\[MANUAL\]' "$PARSED_OUT"; then
  exit 2
fi
exit 0
