#!/bin/bash
# pre-commit hook: sanitize LaTeX and BibTeX files
# Fails (exit 1) if any replacements were applied.

set -euo pipefail

changed=0

# Get staged .tex and .bib files
mapfile -t files < <(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(tex|bib)$' || true)
[[ ${#files[@]} -eq 0 ]] && exit 0

# Define replacements: pattern → replacement
declare -A replacements=(
  ["\u2013"]="--"  # en dash (–)
  ["\u00A0"]=" "   # non-breaking space ( )
  ["\u2212"]="-"   # minus sign (−)
  ["\u2018"]="\`"  # curly left apostrophe (‘)
  ["\u2019"]="'"   # curly right apostrophe (’)
)

# Detect BSD vs GNU sed
if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_INPLACE=(-i '')
else
  SED_INPLACE=(-i)
fi

# Build grep arguments dynamically from replacement keys
grep_args=()
for pattern in "${!replacements[@]}"; do
  grep_args+=(-e "$pattern")
done

for file in "${files[@]}"; do
  [[ -f "$file" ]] || continue

  # Only modify if any of the target patterns are found
  if grep -q "${grep_args[@]}" "$file"; then
    changed=1

    # Build sed expressions dynamically
    sed_args=()
    for pattern in "${!replacements[@]}"; do
      sed_args+=(-e "s/${pattern}/${replacements[$pattern]}/g")
    done

    sed "${SED_INPLACE[@]}" "${sed_args[@]}" "$file"
  fi
done

if (( changed )); then
  echo "Fixed non-ASCII characters in .tex/.bib files. Please review and re-commit."
  exit 1
fi
