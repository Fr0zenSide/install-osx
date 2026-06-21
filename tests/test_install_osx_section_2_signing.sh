#!/usr/bin/env bash
# tests/test_install_osx_section_2_signing.sh
# W2 TDD suite — verifies install-osx.sh section 2 calls setup-dev-signing.sh
# at the right point in the install sequence.
#
# Run from repo root:
#   bash tests/test_install_osx_section_2_signing.sh
#
# Exit 0 = all pass; exit 1 = at least one failure.

set -uo pipefail

SCRIPT="install-osx.sh"
PASS=0
FAIL=0

fail() {
    echo "  FAIL: $1" >&2
    FAIL=$((FAIL + 1))
}

pass() {
    echo "  PASS: $1"
    PASS=$((PASS + 1))
}

# ── helpers ──────────────────────────────────────────────────────────────────

# Return the first line-number matching a grep pattern, or -1 if not found.
first_line() {
    local pattern="$1"
    local result
    result=$(grep -n "$pattern" "$SCRIPT" 2>/dev/null | head -1 | cut -d: -f1)
    echo "${result:--1}"
}

# ── T-1: setup-dev-signing.sh is present in install-osx.sh ───────────────────
test_signing_call_present() {
    local n
    n=$(first_line 'setup-dev-signing\.sh')
    if [ "$n" -gt 0 ]; then
        pass "T-1: setup-dev-signing.sh call found in $SCRIPT (line $n)"
    else
        fail "T-1: setup-dev-signing.sh call NOT found in $SCRIPT"
    fi
}

# ── T-2: setup-dev-signing.sh invoked AFTER homebrew install ─────────────────
test_setup_signing_after_brew() {
    local brew_line signing_line
    brew_line=$(first_line 'Homebrew/install/HEAD/install\.sh')
    signing_line=$(first_line 'setup-dev-signing\.sh')
    if [ "$brew_line" -eq -1 ]; then
        fail "T-2: could not locate homebrew install line"
        return
    fi
    if [ "$signing_line" -eq -1 ]; then
        fail "T-2: setup-dev-signing.sh call not found"
        return
    fi
    if [ "$signing_line" -gt "$brew_line" ]; then
        pass "T-2: setup-dev-signing.sh (line $signing_line) AFTER brew install (line $brew_line)"
    else
        fail "T-2: setup-dev-signing.sh (line $signing_line) must run AFTER brew install (line $brew_line)"
    fi
}

# ── T-3: setup-dev-signing.sh invoked BEFORE first shi/make build ────────────
# Section 2 doesn't call 'make install' itself; the cert bootstrap must be done
# BEFORE the operator ever runs 'make install' in the shikki repo.
# We verify the call exists inside section 2 (between elif [[ $input == 2 ]] and
# the matching fi/elif boundary), which semantically puts it before any shi build.
test_setup_signing_inside_section_2() {
    local section2_start section2_end signing_line
    section2_start=$(grep -n '\[\[ \$input == 2 \]\]' "$SCRIPT" | head -1 | cut -d: -f1)
    # Find the next elif or fi after section2_start
    section2_end=$(awk -v start="$section2_start" '
        NR > start && /^elif|^fi/ { print NR; exit }
    ' "$SCRIPT")
    signing_line=$(first_line 'setup-dev-signing\.sh')

    if [ -z "$section2_start" ] || [ -z "$section2_end" ]; then
        fail "T-3: could not locate section 2 boundaries (start=$section2_start end=$section2_end)"
        return
    fi
    if [ "$signing_line" -eq -1 ]; then
        fail "T-3: setup-dev-signing.sh call not found"
        return
    fi
    if [ "$signing_line" -gt "$section2_start" ] && [ "$signing_line" -lt "$section2_end" ]; then
        pass "T-3: setup-dev-signing.sh (line $signing_line) is INSIDE section 2 (lines $section2_start-$section2_end)"
    else
        fail "T-3: setup-dev-signing.sh (line $signing_line) is NOT inside section 2 (lines $section2_start-$section2_end)"
    fi
}

# ── T-4: idempotent re-run — setup-dev-signing.sh is called unconditionally ──
# (its own idempotency, verified in W1, handles the no-op on re-run)
# We just confirm the call exists (not behind a one-shot sentinel that would
# prevent the second invocation from running the idempotent check).
test_idempotent_not_behind_oneshotfile() {
    # Check there's no "if [ -f ~/.setup-dev-signing-done ]" guard wrapping it
    local signing_line
    signing_line=$(first_line 'setup-dev-signing\.sh')
    if [ "$signing_line" -eq -1 ]; then
        fail "T-4: setup-dev-signing.sh call not found"
        return
    fi
    # Look 3 lines before for a one-shot sentinel file test
    local context
    context=$(awk -v n="$signing_line" 'NR >= n-3 && NR <= n { print }' "$SCRIPT")
    if echo "$context" | grep -q '\.setup-dev-signing-done\|\.shikki-signing-bootstrapped'; then
        fail "T-4: one-shot sentinel file guard detected — breaks idempotency contract"
    else
        pass "T-4: no one-shot sentinel guard; W1 script's own idempotency handles re-runs"
    fi
}

# ── T-5: actionable error if cert script is missing ─────────────────────────
# The call site must include a fallback/error message so fresh-mac users who
# haven't yet cloned shikki get a clear runbook, not a silent fail.
test_actionable_error_if_script_missing() {
    local signing_line
    signing_line=$(first_line 'setup-dev-signing\.sh')
    if [ "$signing_line" -eq -1 ]; then
        fail "T-5: setup-dev-signing.sh call not found"
        return
    fi
    # Look for either a conditional check ([ -f ... ]) or error handling (|| echo / 2>&1)
    local context
    context=$(awk -v n="$signing_line" 'NR >= n-5 && NR <= n+10 { print }' "$SCRIPT")
    if echo "$context" | grep -qE '\[ -f |\|\| echo|WARNING|runbook|Manually run|After cloning'; then
        pass "T-5: actionable error handling / missing-script message found near setup-dev-signing.sh"
    else
        fail "T-5: no actionable error handling near setup-dev-signing.sh call (need '[ -f ... ]' guard or '|| echo WARNING' with runbook)"
    fi
}

# ── run ───────────────────────────────────────────────────────────────────────

echo ""
echo "=== W2 signing-bootstrap tests (install-osx.sh) ==="
echo ""

if [ ! -f "$SCRIPT" ]; then
    echo "ERROR: $SCRIPT not found — run from repo root" >&2
    exit 1
fi

test_signing_call_present
test_setup_signing_after_brew
test_setup_signing_inside_section_2
test_idempotent_not_behind_oneshotfile
test_actionable_error_if_script_missing

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
echo ""

[ "$FAIL" -eq 0 ]
