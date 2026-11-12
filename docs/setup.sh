#!/usr/bin/env bash
# Add the farvisun APT repository (Lumen, Desktop Studio) to Ubuntu or Debian.
#
#   Add:     curl -fsSL https://farvisun.github.io/apt/setup.sh | sudo bash
#   Remove:  curl -fsSL https://farvisun.github.io/apt/setup.sh | sudo bash -s -- --remove
#
# The repository's public signing key is embedded below, so nothing else is
# downloaded to trust it. Packages then update with your normal system updates.
set -euo pipefail

KEYRING=/etc/apt/keyrings/farvisun.gpg
SOURCES=/etc/apt/sources.list.d/farvisun.sources
URL=https://farvisun.github.io/apt
FINGERPRINT=F6692EE01775D62450E2985D88C8EE6A70F5DF57

say() { [ "${QUIET:-0}" = 1 ] || printf '\033[1m==>\033[0m %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

QUIET=0
ACTION=add
for arg in "$@"; do
    case $arg in
        --remove) ACTION=remove ;;
        --quiet) QUIET=1 ;;
        *) die "unknown option: $arg" ;;
    esac
done

[ "$(id -u)" -eq 0 ] || die "Run with sudo: curl -fsSL $URL/setup.sh | sudo bash"
command -v apt-get >/dev/null 2>&1 || die "This repository is for Ubuntu and Debian (apt) systems."

if [ "$ACTION" = remove ]; then
    rm -f "$KEYRING" "$SOURCES"
    say "Removed the farvisun repository. Installed packages stay installed."
    apt-get update -qq || true
    exit 0
fi

command -v gpg >/dev/null 2>&1 || { say "Installing gpg"; apt-get update -qq && apt-get install -y -qq gpg >/dev/null; }

say "Adding the farvisun signing key ($FINGERPRINT)"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export GNUPGHOME="$tmp/gnupg"   # keep root's own GnuPG folder untouched
mkdir -m 700 "$GNUPGHOME"
cat > "$tmp/key.asc" <<'KEY'
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBGr2HckBEADvEfOPfo+FHcNY5HwNgoWz7kLptTHBMlKCCiFmvbxm50acC1e9
qj4ck9IsmFwpV5JSYJ5/hfGNrB4GiEM96+ma7DitdZwyXD7BiaEoc/+K9t9rZ1a7
k9fxTmK81bdDxfeX7+gQGtqFMTQPO1+iK/fF649AdVuJCzQAXgKB+nsLpKdlm+xH
Gm+tZI/Zg1LhVf70BXODKcjGRCFUx2rgi42Yl8ehpvxZw3WLOtboGHErQHebwWZH
RWuKYUqezxHJQSv6h2QA3YfHfxG5MLBzS2M6Uo6krFsYgFteNoRsziH1JPNpnOcc
Upltd9kGNPurAGyuq2f1erXeQCsUOEdzP1Y+hvmDrnaJgMoPh2NA+Kh8sLug9h6r
U5YYqDjMqFw7VJmCESDtoW+gx0iwYWklovaX1cC2AHQdX6iXV0H+tqprg8zJy21c
XHZ7aTdLVFd7JMsVH4MJr+Rg7SIjJOlFT8o/KioJtckTsYRBbVF3rzl6R8f045Q/
qp8tdQOdVBITVw8eCU2b2xCV1Ua7tW0XGC1VjhO3Nw0+itPuvDV8r7/6Cvk6hKXY
bngAYTJykqyGfbcDuso23qiJPWsxNrPsoFzZMfjJheN5mpX9mPk2foVHPMG7qCuF
PSzaDgRtofq52NCBgJBbIuOQZvarVKX3U4y7bTl5wHfYeT9U8QRIuK0tVQARAQAB
tBdGYXJ2aXN1biBBUFQgcmVwb3NpdG9yeYkCVAQTAQoAPhYhBPZpLuAXddYkUOKY
XYjI7mpw9d9XBQJq9h3JAhsDBQkJZgGABQsJCAcCBhUKCQgLAgQWAgMBAh4BAheA
AAoJEIjI7mpw9d9Xm1AP/i6NBb3HCjzr1iSByU6OShQboivpCpRsFMHz969VjHPr
m7wNOJaFAwBaLep0RKcbknWM1mtvzXsCqE5dpGk+nUgFkh6sTADmxLfkQCMmkYn3
fRCIb06rabQwO37N6/L7nNmeco5QfS1cLVUPqfi6QZ/6JXLdrs7IBTeDuwWTd+dv
Z4dh9/f5rb3h4E1TrPfKWp4eJ+aXu0sioFf6Z1bEHllPUyHhOwqujb62phna0spI
40kpcVCvndQhkoJQ2xUNH8x5gPus1X9MXUJLe43bQ4I90qhkgY8IoEIS0diQ54M7
M0HS0y3Kx3lXJXB01v4zs8qG+Rij3OWoFF+ShKLeUlVqsa+hjZOfhGFNjJmo3W3X
LBlhLWAx/pErh3SJ/WHRTniI7bGorc9p0FZ9okhvNHG1ZyZVSah/V3PLzr0SGEJh
y8buXSJtemyeBW0ndlFbLatLxRDNqJ+/GQZKJApFLBi/ecdJGjWnED0JvWDc+/GN
ZgMZ4OG+BkbekDjOnYJkL087LWP/6GnGwjbuqsvNzszJ4NISP9mg9ZUL1J5huV/0
CbXqRij8QXJmWMVr6TMd1bA2YrvYMMcqgKnxiqvp8sY/T9HZhK7A4GBzr53lESQG
V9oHDkN9mkPJZxkbtCwbISbCq6a2AMGGcYl0PuZ49FbULFwfd+8r03ZuqrbJtEuY
=y14R
-----END PGP PUBLIC KEY BLOCK-----
KEY
actual=$(gpg --batch --with-colons --show-keys "$tmp/key.asc" | awk -F: '/^fpr/{print $10; exit}')
[ "$actual" = "$FINGERPRINT" ] || die "Embedded key fingerprint mismatch."
install -d -m 0755 /etc/apt/keyrings
gpg --batch --yes --dearmor -o "$tmp/farvisun.gpg" "$tmp/key.asc"
install -m 0644 "$tmp/farvisun.gpg" "$KEYRING"

say "Adding $URL"
cat > "$SOURCES" <<SRC
Types: deb
URIs: $URL
Suites: stable
Components: main
Signed-By: $KEYRING
SRC

say "Refreshing the package list"
apt-get update -qq

if [ "$QUIET" = 0 ]; then
    echo
    echo "Done. Install the apps with:"
    echo "  sudo apt install lumen-launcher     # Lumen launcher"
    echo "  sudo apt install desktop-studio     # Desktop Studio"
fi
