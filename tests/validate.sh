#!/usr/bin/env bash
# Lightweight repository validation for solana-bridge-skill.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "ERROR: $1" >&2
  exit 1
}

assert_file() {
  [ -f "$1" ] || fail "Missing required file: $1"
}

assert_dir() {
  [ -d "$1" ] || fail "Missing required directory: $1"
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  grep -Eq -- "$pattern" "$file" || fail "Expected '$file' to contain pattern: $pattern"
}

assert_absent() {
  local pattern="$1"
  if grep -RInE --exclude-dir=.git --exclude=validate.sh -- "$pattern" . >/tmp/solana-bridge-skill-validate-grep.txt; then
    cat /tmp/solana-bridge-skill-validate-grep.txt >&2
    fail "Found forbidden pattern: $pattern"
  fi
}

assert_dir skill
assert_file skill/SKILL.md
assert_file skill/parsing-idl.md
assert_file skill/state-fetching.md
assert_file skill/pda-derivation.md
assert_file skill/react-hooks.md
assert_file skill/validation.md
assert_file README.md
assert_file .editorconfig
assert_file COMPATIBILITY.md
assert_file LICENSE
assert_file SECURITY.md
assert_file SUBMISSION.md
assert_file install.sh
assert_file examples/sample-anchor-idl.json
assert_file examples/expected-profile-bridge.md
assert_file examples/pda-transaction-hook.md
assert_file examples/token2022-transfer-hook.md

assert_contains skill/SKILL.md "^---$"
assert_contains skill/SKILL.md "^name: solana-bridge-skill$"
assert_contains skill/SKILL.md "./parsing-idl.md"
assert_contains skill/SKILL.md "./state-fetching.md"
assert_contains skill/SKILL.md "./pda-derivation.md"
assert_contains skill/SKILL.md "./react-hooks.md"
assert_contains skill/SKILL.md "./validation.md"

assert_contains README.md "Fit for Solana AI Kit"
assert_contains README.md "Design Rules"
assert_contains README.md "Quality Checks"
assert_contains README.md "pda-derivation.md"
assert_contains README.md "token2022-transfer-hook.md"
assert_contains COMPATIBILITY.md "Anchor Compatibility Boundary"
assert_contains COMPATIBILITY.md "Token-2022 Layouts"

assert_absent "YOUR_USERNAME|YOUR_PROGRAM_ID|TODO|FIXME"

bash -n install.sh
bash -n tests/validate.sh

if command -v jq >/dev/null 2>&1; then
  jq empty examples/sample-anchor-idl.json
fi

INSTALL_TARGET="${TMPDIR:-/tmp}/solana-bridge-skill"
./install.sh "$INSTALL_TARGET" >/tmp/solana-bridge-skill-install.log

for file in SKILL.md parsing-idl.md state-fetching.md pda-derivation.md react-hooks.md validation.md; do
  assert_file "$INSTALL_TARGET/$file"
done

echo "Validation passed."
