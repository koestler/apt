#!/usr/bin/env bash
# Download .deb assets of the latest releases listed in packages.yml into build/incoming/.
set -euo pipefail

cd "$(dirname "$0")/.."
out=build/incoming
rm -rf build
mkdir -p "$out"

keep=$(yq '.keep // 3' packages.yml)
count=$(yq '.packages | length' packages.yml)

for i in $(seq 0 $((count - 1))); do
  repo=$(yq ".packages[$i].repo" packages.yml)
  glob=$(yq ".packages[$i].asset_glob // \"*.deb\"" packages.yml)

  tags=$(gh release list --repo "$repo" --limit "$keep" --exclude-drafts --exclude-pre-releases \
    --json tagName --jq '.[].tagName') || { echo "::warning::cannot list releases of $repo"; continue; }
  if [ -z "$tags" ]; then
    echo "::warning::no releases found for $repo"
    continue
  fi

  for tag in $tags; do
    dir="$out/$(echo "$repo" | tr / _)_$tag"
    mkdir -p "$dir"
    if ! gh release download "$tag" --repo "$repo" --pattern "$glob" --dir "$dir"; then
      echo "::warning::no assets matching $glob in $repo@$tag"
      continue
    fi
    if gh release download "$tag" --repo "$repo" --pattern 'SHA256SUMS*' --dir "$dir" 2>/dev/null; then
      (cd "$dir" && sha256sum -c --ignore-missing SHA256SUMS*)
    fi
  done
done

find "$out" -name '*.deb' | sort
