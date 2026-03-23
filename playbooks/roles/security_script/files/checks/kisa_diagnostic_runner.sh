#!/usr/bin/env bash
# kisa_diagnostic_runner.sh
# Run legacy KISA-style diagnostic script safely, parse consolidated report,
# relabel legacy item numbers to current fix-script numbering, and return rc.
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

for cmd in awk grep find hostname mktemp; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[DIAG-RUNNER][ERROR] required command not found: $cmd"
    exit 1
  fi
done

TMPDIR_ROOT="$(mktemp -d /tmp/kisa-diagnostic.XXXXXX)"
cleanup() {
  rm -rf "$TMPDIR_ROOT"
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

# Prefer the consolidated report file. Do not fall back to Script/*.txt files.
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
function relabel(u, n) {
  n = substr(u, 3) + 0

  # legacy diagnostic number -> current fix-script number
  # Keep identity by default, override only known mismatches.
  if (n == 9)  return "U-19"  # /etc/hosts file ownership/permission
  if (n == 18) return "U-28"  # access control (IP/port restriction)
  if (n == 23) return "U-38"  # vulnerable network services (echo/discard/daytime/chargen)
  if (n == 29) return "U-44"  # tftp/talk/ntalk disable

  return sprintf("U-%02d", n)
}
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
function flush_section(   rel, result, status, detail, msg) {
  if (u != "") {
    rel = relabel(u)
    result = classify(section_text)
    split(result, parts, "|")
    status = parts[1]
    detail = parts[2]

    msg = "[" rel "][" status "] " title " - " detail
    if (rel != u) {
      msg = msg " (legacy=" u ")"
    }
    print msg
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
