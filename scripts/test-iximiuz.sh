#!/usr/bin/env bash
# Static validation for the iximiuz Labs content (iximiuz/).
#   - every index.md / unit-*.md has parseable YAML frontmatter with a `kind`
#   - every workshop/.../{setup-background.sh,verify.sh} the challenges reference
#     actually exists (the init/verify tasks shell out to these at runtime)
# Dependency-light: bash + python3 (PyYAML optional; falls back to a tolerant check).
set -uo pipefail
cd "$(dirname "$0")/.."   # repo root

ROOT=iximiuz
fail=0
ok()  { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad() { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=1; }

echo "━━ iximiuz Labs (static) ━━"

[ -d "$ROOT" ] || { bad "no $ROOT/ directory"; exit 1; }

# 1) frontmatter parses + has a kind
while IFS= read -r f; do
  if python3 - "$f" <<'PY'
import sys
p = sys.argv[1]
t = open(p, encoding="utf-8").read()
if not t.startswith("---"):
    print("no frontmatter"); sys.exit(1)
end = t.find("\n---", 3)
if end == -1:
    print("unterminated frontmatter"); sys.exit(1)
fm = t[3:end]
try:
    import yaml
    d = yaml.safe_load(fm) or {}
    if "kind" not in d:
        print("no kind"); sys.exit(1)
except ImportError:
    if "kind:" not in fm:
        print("no kind"); sys.exit(1)
sys.exit(0)
PY
  then ok "frontmatter ok: $f"; else bad "frontmatter invalid: $f"; fi
done < <(find "$ROOT" -name '*.md' | sort)

# 2) referenced workshop scripts exist
refs=$(grep -rhoE '/opt/wk/workshop/[A-Za-z0-9/._-]+\.sh' "$ROOT" | sort -u)
if [ -z "$refs" ]; then
  bad "no workshop script references found in challenges (init/verify tasks missing?)"
else
  while IFS= read -r r; do
    local_path="${r#/opt/wk/}"
    if [ -f "$local_path" ]; then ok "referenced script exists: $local_path"
    else bad "referenced script MISSING: $local_path"; fi
  done <<< "$refs"
fi

# 3) surface unresolved publish-time TODOs (informational, not a failure)
todos=$(grep -rc "TODO(verify at publish)" "$ROOT" 2>/dev/null | grep -v ':0$' || true)
if [ -n "$todos" ]; then
  echo "  • publish-time TODOs to resolve (see docs/iximiuz-setup.md §4):"
  echo "$todos" | sed 's/^/      /'
fi

echo
if [ "$fail" = 0 ]; then printf '━━ RESULT: \033[32mpassed\033[0m ━━\n'; else printf '━━ RESULT: \033[31mFAILED\033[0m ━━\n'; fi
exit $fail
