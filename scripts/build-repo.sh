#!/usr/bin/env bash
# Build the signed APT repository in ./site from the latest GitHub releases.
#
# Needs: gh (authenticated or GH_TOKEN), apt-ftparchive (apt-utils), gpg with the
# signing key imported, and SIGNING_FINGERPRINT set to that key's fingerprint.
set -euo pipefail

SOURCES=(farvisun/gnome-launcher farvisun/nome-tweak)
ARCHES=(amd64 arm64)
: "${SIGNING_FINGERPRINT:?set SIGNING_FINGERPRINT}"

root=$(cd "$(dirname "$0")/.." && pwd)
site="$root/site"
rm -rf "$site"
mkdir -p "$site"
cp -r "$root/docs/." "$site/"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

for repo in "${SOURCES[@]}"; do
    dir="$work/${repo#*/}"
    mkdir -p "$dir"
    gh release download --repo "$repo" --pattern '*.deb' --pattern 'SHA256SUMS' --dir "$dir"
    (cd "$dir" && sha256sum --check --ignore-missing --strict SHA256SUMS)
    for deb in "$dir"/*.deb; do
        package=$(dpkg-deb --field "$deb" Package)
        dest="$site/pool/main/${package:0:1}/$package"
        mkdir -p "$dest"
        cp "$deb" "$dest/"
        echo "added $(basename "$deb")"
    done
done

cd "$site"
for arch in "${ARCHES[@]}"; do
    out="dists/stable/main/binary-$arch"
    mkdir -p "$out"
    apt-ftparchive --arch "$arch" packages pool > "$out/Packages"
    gzip -9 --keep --force "$out/Packages"
done

apt-ftparchive \
    -o APT::FTPArchive::Release::Origin=farvisun \
    -o APT::FTPArchive::Release::Label=farvisun \
    -o APT::FTPArchive::Release::Suite=stable \
    -o APT::FTPArchive::Release::Codename=stable \
    -o "APT::FTPArchive::Release::Architectures=${ARCHES[*]}" \
    -o APT::FTPArchive::Release::Components=main \
    -o "APT::FTPArchive::Release::Description=Lumen and Desktop Studio for GNOME" \
    release dists/stable > "$work/Release"
mv "$work/Release" dists/stable/Release

gpg --batch --yes --local-user "$SIGNING_FINGERPRINT" --clearsign --output dists/stable/InRelease dists/stable/Release
gpg --batch --yes --local-user "$SIGNING_FINGERPRINT" --armor --detach-sign --output dists/stable/Release.gpg dists/stable/Release

echo "Repository built in $site:"
find "$site/pool" -name '*.deb' -printf '  %P\n'
