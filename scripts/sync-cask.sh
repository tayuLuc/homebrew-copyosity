#!/usr/bin/env bash
# Point Casks/copyosity.rb at the newest fork release.
#
#   scripts/sync-cask.sh            # take the latest release
#   scripts/sync-cask.sh 1.0.4-fork2
#
# Reads the SHA-256 straight from the release asset metadata (GitHub fills in
# `digest` for assets it stored itself), so nothing is downloaded. Falls back to
# fetching the DMG and hashing it when the field is missing.
#
# The cask keeps `version` and `sha256 arm:/intel:` each on a single line so the
# sed below stays a one-liner — the same constraint deskflow documents in its
# tap-update workflow.
set -euo pipefail

REPO="${REPO:-tayuLuc/copyosity}"
CASK="${CASK:-$(dirname "$0")/../Casks/copyosity.rb}"

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
  VERSION=$(gh api "repos/$REPO/releases/latest" --jq '.tag_name')
  VERSION="${VERSION#v}"
fi

sha_of() {
  local asset="$1" digest line
  digest=$(gh api "repos/$REPO/releases/tags/v$VERSION" \
    --jq ".assets[] | select(.name==\"Copyosity-${asset}_$VERSION.dmg\") | .digest")
  if [ -n "$digest" ] && [ "$digest" != "null" ]; then
    printf '%s' "${digest#sha256:}"
    return
  fi
  line=$(gh api "repos/$REPO/releases/tags/v$VERSION" \
    --jq ".assets[] | select(.name==\"Copyosity-${asset}_$VERSION.dmg\") | .url")
  curl -sL -H "Accept: application/octet-stream" "$line" | shasum -a 256 | cut -d' ' -f1
}

ARM=$(sha_of aarch64)
X64=$(sha_of x64)

# Значения передаются через окружение, а скрипт в одинарных кавычках: в двойных
# шелл разворачивает `$` конца регулярки, и выражение не компилируется (проверено —
# молча не меняет файл, но следующий запуск должен быть рабочим, а не «почти»).
VERSION="$VERSION" ARM="$ARM" X64="$X64" perl -0pi -e '
  s{^  version "[^"]*"}{  version "$ENV{VERSION}"}m or die "no version line in $ARGV\n";
  s{^  sha256 arm: "[^"]*", intel: "[^"]*"}
   {  sha256 arm: "$ENV{ARM}", intel: "$ENV{X64}"}m
    or die "no sha256 arm/intel line in $ARGV\n";
' "$CASK"

echo "Casks/copyosity.rb -> $VERSION"
grep -E "^  (version|sha256)" "$CASK"
