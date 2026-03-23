#!/usr/bin/env bash
# kisa_diagnostic_runner.sh
# Final fix-aligned runner
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

for cmd in awk grep find hostname mktemp cp chmod sed sort; do
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

if [ "$legacy_rc" -ne 0 ]; then
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
function normalize_status(text,   status, detail) {
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
  return status "|" detail
}
function severity_rank(status) {
  if (status == "VULN") return 3
  if (status == "MANUAL") return 2
  return 1
}
function set_map(legacy, out_num, out_title) {
  map_num[legacy] = out_num
  map_title[legacy] = out_title
}
function init_maps() {
  # fix 기준으로만 매핑. 대응 조치 스크립트가 없는 legacy 항목은 출력하지 않음.
  set_map("U-01", "U-01", "root 원격 로그인 제한 (Telnet / SSH)")
  set_map("U-02", "U-02", "패스워드 정책 강화")
  set_map("U-03", "U-03", "계정 잠금 정책 설정")
  set_map("U-04", "U-04", "/etc/passwd 및 shadow 적용 확인")
  set_map("U-44", "U-05", "UID 0 중복 계정 점검 (root 외 UID 0 금지)")
  set_map("U-45", "U-06", "su 명령어 권한 및 wheel 그룹 설정 (운영 계정 예외 포함)")
  set_map("U-49", "U-07", "불필요한 사용자 계정")
  set_map("U-50", "U-08", "root 그룹 사용자 점검")
  set_map("U-51", "U-09", "불필요한 그룹")
  set_map("U-52", "U-10", "사용자 UID 중복 점검")
  set_map("U-53", "U-11", "로그인 불필요한 계정 쉘 제한")
  set_map("U-54", "U-12", "세션 자동 로그아웃 및 기본 umask 설정")
  set_map("U-09", "U-19", "/etc/hosts 파일 소유자 및 권한 점검")
  set_map("U-10", "U-20", "inetd / xinetd / systemd 설정 파일 권한 점검")
  set_map("U-11", "U-21", "syslog / rsyslog 설정 파일 권한 점검")
  set_map("U-12", "U-22", "/etc/services 파일 소유자 및 권한 점검/조치")
  set_map("U-13", "U-23", "SUID/SGID 설정 파일")
  set_map("U-14", "U-24", "홈 디렉터리 환경변수 파일 소유자 및 권한 점검/조치 (최소 변경)")
  set_map("U-15", "U-25", "일반 사용자(others) 쓰기 권한 파일 점검 및 조치")
  set_map("U-16", "U-26", "/dev 디렉터리 내 불필요 파일")
  set_map("U-17", "U-27", "hosts.equiv / .rhosts 신뢰 관계 설정 점검")
  set_map("U-18", "U-28", "접근 통제 설정")
  set_map("U-22", "U-37", "crontab, cron, at 파일 소유자 및 권한 점검/조치")
  set_map("U-65", "U-37", "crontab, cron, at 파일 소유자 및 권한 점검/조치")
  set_map("U-19", "U-34", "Finger 서비스 비활성화 (inetd/xinetd)")
  set_map("U-20", "U-35", "익명 FTP/NFS/Samba 접근 비활성화")
  set_map("U-21", "U-36", "r 계열 서비스 비활성화 (rlogin, rsh, rexec)")
  set_map("U-23", "U-38", "불필요한 네트워크 서비스 비활성화 (echo, discard, daytime, chargen)")
  set_map("U-24", "U-39", "불필요한 NFS 서비스 및 socket 비활성화")
  set_map("U-25", "U-40", "/etc/exports 파일 점검 및 NFS 공유 설정 (기본: 공유 없음으로 정리)")
  set_map("U-26", "U-41", "자동 마운트(automount/autofs) 서비스 비활성화")
  set_map("U-27", "U-42", "불필요한 RPC 서비스 점검 및 비활성화")
  set_map("U-28", "U-43", "NIS 관련 서비스 점검 및 비활성화")
  set_map("U-29", "U-44", "TFTP, Talk, Ntalk 서비스 점검 및 비활성화")
  set_map("U-30", "U-45", "메일 서비스 점검 및 비활성화")
  set_map("U-32", "U-46", "메일 서비스 보안 설정 및 일반 사용자 권한 제한")
  set_map("U-31", "U-47", "메일 서버 릴레이 제한 설정")
  set_map("U-70", "U-48", "SMTP VRFY/EXPN 정보노출 차단 설정")
  set_map("U-33", "U-49", "DNS 서비스(named/BIND) 점검 및 비활성화")
  set_map("U-34", "U-50", "DNS Zone Transfer 제한(xfrnets, allow-transfer) 점검")
  set_map("U-62", "U-55", "FTP 계정 로그인 제한 설정")
  set_map("U-63", "U-56", "FTP 접근 제한 파일 소유자 및 권한 설정")
  set_map("U-64", "U-57", "FTP root 계정 접근 제한 설정")
  set_map("U-66", "U-58", "SNMP 서비스 비활성화")
  set_map("U-67", "U-60", "SNMP Community String 설정 점검 (납품 기본: SNMP 미사용/비활성화)")
  set_map("U-68", "U-62", "로그온 경고 메시지 점검 및 설정 시작")
  set_map("U-42", "U-64", "OS 및 보안 업데이트 필요 여부 점검")
  set_map("U-72", "U-66", "로그 기록 정책(rsyslog) 점검 및 설정 시작")

  # legacy 비밀번호 세부 항목은 모두 fix U-02로 귀속
  set_map("U-46", "U-02", "패스워드 정책 강화")
  set_map("U-47", "U-02", "패스워드 정책 강화")
  set_map("U-48", "U-02", "패스워드 정책 강화")
}
function flush_section(   result, parts, status, detail, out_num, out_title, rank) {
  if (u == "") return
  if (!(u in map_num)) return

  out_num = map_num[u]
  out_title = map_title[u]

  result = normalize_status(section_text)
  split(result, parts, "|")
  status = parts[1]
  detail = parts[2]
  rank = severity_rank(status)

  if (!(out_num in best_rank) || rank > best_rank[out_num]) {
    best_rank[out_num] = rank
    best_status[out_num] = status
    best_detail[out_num] = detail
    best_title[out_num] = out_title
  }
}
BEGIN {
  init_maps()
  u = ""
  title = ""
  section_text = ""
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
  for (i = 1; i <= 67; i++) {
    key = sprintf("U-%02d", i)
    if (key in best_status) {
      print "[" key "][" best_status[key] "] " best_title[key] " - " best_detail[key]
    }
  }
}
' "$REPORT_FILE" > "$PARSED_OUT"

cat "$PARSED_OUT"

PASS_COUNT="$(grep -c '\[PASS\]' "$PARSED_OUT" 2>/dev/null || true)"
MANUAL_COUNT="$(grep -c '\[MANUAL\]' "$PARSED_OUT" 2>/dev/null || true)"
VULN_COUNT="$(grep -c '\[VULN\]' "$PARSED_OUT" 2>/dev/null || true)"

echo "[DIAG-SUMMARY] pass=$PASS_COUNT manual=$MANUAL_COUNT vuln=$VULN_COUNT"

if grep -q '\[VULN\]' "$PARSED_OUT"; then
  exit 3
fi
if grep -q '\[MANUAL\]' "$PARSED_OUT"; then
  exit 2
fi
exit 0
