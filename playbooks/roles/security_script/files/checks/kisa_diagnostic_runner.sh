#!/usr/bin/env bash
# legacy_kisa_check_wrapper.sh
# Wrapper for legacy KISA-style diagnostic script.
# Purpose:
#   - run a legacy all-in-one diagnostic script safely in a temp working dir
#   - parse its human-readable report into machine-friendly summary lines
#   - return rc suitable for current Ansible pipeline
# rc:
#   0 = PASS (no vuln/manual detected)
#   2 = MANUAL (manual review item exists, no explicit vuln found)
#   3 = VULN (one or more vulnerable items detected)
#   1 = ERROR (script/report execution problem)
#
# Usage:
#   ./legacy_kisa_check_wrapper.sh /path/to/Linux_script_v1.0\(RedHat\).sh
#
set -u

LEGACY_SCRIPT="${1:-}"
if [ -z "$LEGACY_SCRIPT" ]; then
  echo "[LEGACY-CHECK][ERROR] usage: $0 /path/to/Linux_script_v1.0(RedHat).sh"
  exit 1
fi

if [ ! -f "$LEGACY_SCRIPT" ]; then
  echo "[LEGACY-CHECK][ERROR] legacy script not found: $LEGACY_SCRIPT"
  exit 1
fi

if ! command -v awk >/dev/null 2>&1; then
  echo "[LEGACY-CHECK][ERROR] awk not found"
  exit 1
fi

TMPDIR_ROOT="$(mktemp -d /tmp/legacy-kisa-check.XXXXXX)"
cleanup() {
  rm -rf "$TMPDIR_ROOT"
}
trap cleanup EXIT

WORKDIR="$TMPDIR_ROOT/run"
mkdir -p "$WORKDIR"
cp "$LEGACY_SCRIPT" "$WORKDIR/legacy.sh"
chmod +x "$WORKDIR/legacy.sh"

pushd "$WORKDIR" >/dev/null || exit 1
bash ./legacy.sh >/tmp/legacy_kisa_wrapper.stdout 2>/tmp/legacy_kisa_wrapper.stderr
legacy_rc=$?
popd >/dev/null || exit 1

if [ $legacy_rc -ne 0 ]; then
  echo "[LEGACY-CHECK][ERROR] legacy script exited with rc=$legacy_rc"
  [ -s /tmp/legacy_kisa_wrapper.stderr ] && sed 's/^/[LEGACY-STDERR] /' /tmp/legacy_kisa_wrapper.stderr
  exit 1
fi

HOST_SHORT="$(hostname 2>/dev/null | awk -F. '{print $1}')"
REPORT_FILE="$WORKDIR/$HOST_SHORT/$HOST_SHORT.txt"

if [ ! -f "$REPORT_FILE" ]; then
  REPORT_FILE="$(find "$WORKDIR" -maxdepth 3 -type f | grep -E '/[^/]+/[^/]+\.txt$' | grep -v '/Script/' | head -n 1)"
fi

if [ -z "${REPORT_FILE:-}" ] || [ ! -f "$REPORT_FILE" ]; then
  echo "[LEGACY-CHECK][ERROR] consolidated report file not found under $WORKDIR"
  exit 1
fi

if [ -z "${REPORT_FILE:-}" ] || [ ! -f "$REPORT_FILE" ]; then
  echo "[LEGACY-CHECK][ERROR] report file not found under $WORKDIR"
  exit 1
fi

echo "[LEGACY-CHECK] source_report=$REPORT_FILE"

action_rc=0
manual_found=0
vuln_found=0

awk '
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
function flush_section() {
  if (u != "") {
    status = "PASS"
    detail = "판정 문구를 찾지 못함"

    low = tolower(section_text)
    if (section_text ~ /수동점검 필요|인터뷰 확인|담당자 확인|수동 확인|해당없음 여부 확인/) {
      status = "MANUAL"
      detail = "수동 확인 필요"
    }
    if (section_text ~ />[^\n]*취약|취약함|취약$/) {
      status = "VULN"
      detail = "취약 판정 문구 발견"
    } else if (section_text ~ />[^\n]*양호|양호함|양호$/) {
      status = "PASS"
      detail = "양호 판정 문구 발견"
    }

    # VULN beats MANUAL if both appear.
    if (section_text ~ />[^\n]*취약|취약함|취약$/) {
      status = "VULN"
      detail = "취약 판정 문구 발견"
    }

    print "[" u "][" status "] " title " - " detail
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
' "$REPORT_FILE" | while IFS= read -r line; do
  echo "$line"
  case "$line" in
    *"[VULN]"*)
      vuln_found=1
      action_rc=3
      ;;
    *"[MANUAL]"*)
      manual_found=1
      if [ $action_rc -eq 0 ]; then action_rc=2; fi
      ;;
  esac
done

# The loop above runs in a subshell in many shells, so recompute from captured output.
PARSED_OUT="$TMPDIR_ROOT/parsed.out"
awk '
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
function flush_section() {
  if (u != "") {
    status = "PASS"
    detail = "판정 문구를 찾지 못함"
    if (section_text ~ /수동점검 필요|인터뷰 확인|담당자 확인|수동 확인|해당없음 여부 확인/) {
      status = "MANUAL"
      detail = "수동 확인 필요"
    }
    if (section_text ~ />[^\n]*취약|취약함|취약$/) {
      status = "VULN"
      detail = "취약 판정 문구 발견"
    } else if (section_text ~ />[^\n]*양호|양호함|양호$/) {
      status = "PASS"
      detail = "양호 판정 문구 발견"
    }
    if (section_text ~ />[^\n]*취약|취약함|취약$/) {
      status = "VULN"
      detail = "취약 판정 문구 발견"
    }
    print "[" u "][" status "] " title " - " detail
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
