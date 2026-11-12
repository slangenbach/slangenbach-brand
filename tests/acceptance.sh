#!/usr/bin/env bash
# Acceptance check for the slangenbach brand extension.
# Renders example.qmd as an HTML page and as a reveal.js presentation,
# then checks that both outputs carry the brand's fonts and colours.
set -uo pipefail

cd "$(dirname "$0")/.."

failures=0
fail() { echo "FAIL: $*"; failures=$((failures + 1)); }
pass() { echo "ok:   $*"; }

log=$(mktemp)
trap 'rm -f "$log"' EXIT

rm -rf example.html example-slides.html example_files

if quarto render example.qmd >"$log" 2>&1; then
  pass "quarto render example.qmd"
else
  cat "$log"
  fail "quarto render example.qmd"
  exit 1
fi

for out in example.html example-slides.html; do
  [[ -f "$out" ]] && pass "$out rendered" || fail "$out missing"
done

# CSS linked from a page, concatenated on one line.
linked_css() {
  grep -o 'href="[^"]*\.css"' "$1" | sed 's/^href="//; s/"$//' |
    while read -r f; do [[ -f "$f" ]] && cat "$f"; done | tr '\n' ' '
}

for page in example example-slides; do
  css=$(linked_css "${page}.html")

  # Fonts load from Bunny Fonts, and from nowhere else.
  for family in Source-Serif-Pro JetBrains-Mono; do
    if grep -Eq "@import[[:space:]]*(url\()?['\"]?https://fonts\.bunny\.net/css\?family=${family}:" <<<"$css"; then
      pass "$page loads $family from Bunny Fonts"
    else
      fail "$page does not load $family from Bunny Fonts"
    fi
  done
  if grep -Eq 'fonts\.googleapis|fonts\.gstatic' "${page}.html" ||
     grep -Eq 'fonts\.googleapis|fonts\.gstatic' <<<"$css"; then
    fail "$page references Google Fonts"
  else
    pass "$page does not reference Google Fonts"
  fi
done

# Each pattern must match the CSS a page links to.
expect_css() {
  local page=$1 description=$2 pattern=$3
  if grep -Eiq -- "$pattern" <<<"$(linked_css "${page}.html")"; then
    pass "$page: $description"
  else
    fail "$page: $description"
  fi
}

# HTML page, light mode.
expect_css example "body font is Source Serif Pro"   '--bs-body-font-family:[[:space:]]*"?Source Serif Pro'
expect_css example "headings use Source Serif Pro"   'h1,[^{]*\{[^}]*font-family:[[:space:]]*"?Source Serif Pro'
expect_css example "headings are weight 600"         'h1,[^{]*\{[^}]*font-weight:[[:space:]]*600'
expect_css example "code font is JetBrains Mono"     '--bs-font-monospace:[[:space:]]*"?JetBrains Mono'
expect_css example "background is paper"            '--bs-body-bg:[[:space:]]*#faf8f3'
expect_css example "text is ink"                    '--bs-body-color:[[:space:]]*#1f2328'
expect_css example "links are accent"               '--bs-link-color:[[:space:]]*#a3421c'
expect_css example "muted text is ink-muted"        '--bs-secondary:[[:space:]]*#6b665f'
expect_css example "hairlines are rule"             '--bs-tertiary-color:[[:space:]]*#e4dfd5'
expect_css example "code background is code-paper"  'background-color:[[:space:]]*#f1ede4'

# HTML page, dark mode.
expect_css example "dark background is paper-dark"  '--bs-body-bg:[[:space:]]*#17181b'
expect_css example "dark text is ink-dark"          '--bs-body-color:[[:space:]]*#e7e3da'
expect_css example "dark links are accent-dark"     '--bs-link-color:[[:space:]]*#e8895c'
expect_css example "dark muted text is ink-muted-dark" '--bs-secondary:[[:space:]]*#9b968c'
expect_css example "dark hairlines are rule-dark"   '--bs-tertiary-color:[[:space:]]*#2c2d31'
expect_css example "dark code background is code-paper-dark" 'background-color:[[:space:]]*#202125'

# reveal.js presentation: light values only.
expect_css example-slides "body font is Source Serif Pro"  '--r-main-font:[[:space:]]*"?Source Serif Pro'
expect_css example-slides "headings use Source Serif Pro"  '--r-heading-font:[[:space:]]*"?Source Serif Pro'
expect_css example-slides "code font is JetBrains Mono"    '--r-code-font:[[:space:]]*"?JetBrains Mono'
expect_css example-slides "background is paper"           '--r-background-color:[[:space:]]*#faf8f3'
expect_css example-slides "text is ink"                   '--r-main-color:[[:space:]]*#1f2328'
expect_css example-slides "links are accent"              '--r-link-color:[[:space:]]*#a3421c'
expect_css example-slides "headings are weight 600"       '--r-heading-font-weight:[[:space:]]*600'
expect_css example-slides "code background is code-paper" 'code-bg:[[:space:]]*#f1ede4'

# In a real browser, the fonts load and apply (no fallback to system fonts).
# Needs uv; the first run downloads Playwright's Chromium.
if command -v uv >/dev/null; then
  if uv run --quiet --with playwright python tests/fonts_render.py; then
    pass "fonts render in the browser"
  else
    fail "fonts render in the browser"
  fi
else
  echo "skip: fonts render in the browser (uv not installed)"
fi

echo
if [[ $failures -eq 0 ]]; then
  echo "All checks passed."
else
  echo "$failures check(s) failed."
  exit 1
fi
