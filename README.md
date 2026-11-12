# Farvisun APT Repository

A signed APT repository for **[Lumen](https://github.com/farvisun/gnome-launcher)** and **[Desktop Studio](https://github.com/farvisun/nome-tweak)** on Ubuntu and Debian. Add it once, and both apps update with your normal system updates.

**Website:** https://farvisun.github.io/apt/

## Add the repository

```sh
curl -fsSL https://farvisun.github.io/apt/setup.sh | sudo bash
```

Then install what you want:

```sh
sudo apt install lumen-launcher     # Lumen, a command launcher for GNOME
sudo apt install desktop-studio     # Desktop Studio, a GNOME settings app
```

Each app also has its own one-line installer that adds this repository for you. See the app's README.

## Remove

```sh
curl -fsSL https://farvisun.github.io/apt/setup.sh | sudo bash -s -- --remove
```

Installed apps stay installed. Remove them with `sudo apt remove lumen-launcher desktop-studio`.

## Trust

- The package lists are signed with a key used only for this repository:
  `F669 2EE0 1775 D624 50E2  985D 88C8 EE6A 70F5 DF57`
- `setup.sh` contains the public key itself, checks its fingerprint, and stores it in `/etc/apt/keyrings`, trusted only for this repository.
- Packages are copied from each project's latest GitHub release and checked against the release's `SHA256SUMS`.

## How it is built

`.github/workflows/publish.yml` runs `scripts/build-repo.sh` on every push, every six hours, and on demand. It downloads the latest release packages, builds the index with `apt-ftparchive`, signs it with the `APT_SIGNING_KEY` secret, and deploys it to GitHub Pages. Nothing is committed, so the git history stays small.

To publish a new app release right away:

```sh
gh workflow run publish.yml -R farvisun/apt
```

## License

[MIT](LICENSE)
