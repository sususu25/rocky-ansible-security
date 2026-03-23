#!/bin/bash
# Security diagnostics entrypoint
# rc: 0=PASS, 2=MANUAL, 3=VULN, 1=ERROR

set -u

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNNER="${BASE_DIR}/kisa_diagnostic_runner.sh"
DIAG_SCRIPT="${BASE_DIR}/diagnostics/kisa_redhat_diagnostic.sh"

if [ ! -x "$RUNNER" ]; then
  echo "[U-00][ERROR] diagnostic runner not executable or not found: $RUNNER"
  exit 1
fi

if [ ! -f "$DIAG_SCRIPT" ]; then
  echo "[U-00][ERROR] diagnostic script not found: $DIAG_SCRIPT"
  exit 1
fi

chmod +x "$DIAG_SCRIPT" 2>/dev/null || true

echo "[U-00] run security diagnostics"
bash "$RUNNER" "$DIAG_SCRIPT"
rc=$?

if [ "$rc" -eq 0 ]; then
  echo "[U-00][PASS] security diagnostics result: PASS"
elif [ "$rc" -eq 2 ]; then
  echo "[U-00][MANUAL] security diagnostics result: MANUAL"
elif [ "$rc" -eq 3 ]; then
  echo "[U-00][VULN] security diagnostics result: VULN"
else
  echo "[U-00][ERROR] security diagnostics result: ERROR rc=$rc"
fi

exit "$rc"