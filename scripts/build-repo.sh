#!/usr/bin/env bash
# Import debs with reprepro, sign, and assemble site/ for GitHub Pages.
# Env: APT_GPG_PRIVATE_KEY, APT_GPG_KEY_ID (key must have no passphrase)
set -euo pipefail

cd "$(dirname "$0")/.."
: "${APT_GPG_PRIVATE_KEY:?}" "${APT_GPG_KEY_ID:?}"

export GNUPGHOME
GNUPGHOME=$(mktemp -d)
chmod 700 "$GNUPGHOME"
trap 'gpgconf --kill gpg-agent || true; rm -rf "$GNUPGHOME"' EXIT

echo "$APT_GPG_PRIVATE_KEY" | gpg --batch --import

rm -rf build/repo site
mkdir -p build/repo/conf site
sed "s/@APT_GPG_KEY_ID@/$APT_GPG_KEY_ID/" conf/distributions > build/repo/conf/distributions
cp conf/options build/repo/conf/options

mapfile -t debs < <(find build/incoming -name '*.deb' | sort)
if [ "${#debs[@]}" -eq 0 ]; then
  echo "no .deb files found" >&2
  exit 1
fi

for deb in "${debs[@]}"; do
  reprepro -b build/repo includedeb stable "$deb"
done

cp -r build/repo/dists build/repo/pool site/
gpg --export "$APT_GPG_KEY_ID" > site/key.gpg
gpg --armor --export "$APT_GPG_KEY_ID" > site/key.asc
cp site-src/index.html site/index.html
touch site/.nojekyll

for f in Release InRelease Release.gpg; do
  test -s "site/dists/stable/$f" || { echo "missing $f" >&2; exit 1; }
done
gpg --verify site/dists/stable/InRelease
echo "site/ ready"
