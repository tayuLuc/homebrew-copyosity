# Homebrew tap: Copyosity (fork build)

Cask for the **[tayuLuc/copyosity](https://github.com/tayuLuc/copyosity)** fork
build of [Copyosity](https://github.com/vakovalskii/copyosity), a privacy-first
clipboard manager for macOS with voice input, OCR and local Ollama.

```sh
brew tap tayuLuc/copyosity
brew install --cask tayuLuc/copyosity/copyosity
```

Trust note from the Homebrew docs: code in a tap runs with your user's
privileges, and installing by the fully-qualified name trusts that one cask, not
the whole tap.

## Why this tap exists

1. Upstream ships no cask, formula or tap — `formulae.brew.sh` answers 404 for
   both `cask/copyosity` and `formula/copyosity`, and there is no
   `homebrew-copyosity` repository under `vakovalskii`.
2. Upstream's released DMGs are advertised as notarized but are not: `xcrun
   stapler validate` finds no ticket in the app inside
   `Copyosity-aarch64_1.0.3.dmg`, and `spctl -a -t install` answers
   `Unnotarized Developer ID`. Downloading it in a browser therefore needs a
   manual Gatekeeper override.
3. What the cask does *not* do is disable Gatekeeper. Measured on the install of
   `1.0.4-fork1`: the downloaded DMG carries `com.apple.quarantine` (flags `0281`), the
   installed bundle inherits it (`03c1`), and `spctl -a -t install` answers `rejected`.
   `open -a` still launched it without a prompt here, most likely because this bundle id at
   this path had already been approved once on this machine. What the cask buys instead:
   a SHA-256 pinned per architecture and verified on download, plus one repeatable
   install line for a machine that has never seen this repository. It is the *pinned*
   channel; the rolling one is the app's own updater, and the cask says
   `auto_updates true` so `brew upgrade` does not roll a self-updated install back.

## What the fork build changes

1. `smart-actions`: contextual actions on each clipboard card (link, email,
   phone, address via `NSDataDetector`; color, math, JSON via TypeScript) plus a
   QR popover. Cherry-picked from `ed-would/copyosity` onto upstream `main`.
2. `LICENSE` added — upstream declares `"license": "MIT"` in `package.json` but
   ships no license file. Both copyright lines are present.
3. Ad-hoc signing, no Developer ID, no notarization — see
   `docs/FORK-NOTARIZATION.md` in the app repository.
4. In-app self-update is on, reading `tayuLuc/copyosity/releases/latest/download/latest.json`
   and verifying against the fork's own minisign key (`1F02BEF343E06964`), so an
   upstream-signed build can never replace this one over the wire. The CI Config gate
   asserts the endpoint belongs to the repository running the workflow and that the
   pubkey is not upstream's.

## Versions

The fork keeps upstream's number and appends `-forkN`, in all four manifests at
once (`tauri.conf.json`, `package.json`, `Cargo.toml`, `Cargo.lock`) — the fork's
Config gate fails the build if they disagree. A tag is never re-cut once its
assets have been consumed: new bytes mean a new `-forkN`.

| Cask version | Build commit | Contents |
| --- | --- | --- |
| `1.0.4-fork1` | `92284ad` on `brew-unsigned` | upstream `main@aad3c2b` + smart-actions cherry-pick + unsigned CI |
| `1.0.4-fork2` | `cab0f96` on `brew-unsigned` | same code; version aligned across manifests, gate extended |

## Updating

Two channels, on purpose:

```sh
# rolling — the app itself checks this repo's releases on launch and installs
# what the fork's minisign key vouches for; nothing to run here
open -a Copyosity

# pinned — the cask installs the artifact whose sha256 it carries
brew update
brew reinstall --cask copyosity   # deliberate return to the pinned build
```

`auto_updates true` in the cask keeps `brew upgrade --cask` from rolling a
self-updated install back to the pin.

To cut a new build: merge the feature branch into `main`, bump the version in all four
manifests, push an annotated `v<version>` tag — `.github/workflows/release-fork.yml`
builds both architectures, publishes the DMGs plus updater tarballs and `latest.json`,
then `scripts/sync-cask.sh <version>` rewrites `version` and the two `sha256` values in
`Casks/copyosity.rb`. `brew livecheck --tap tayuLuc/copyosity --casks` reports when the
tag and the cask drift apart.

## Uninstalling

```sh
brew uninstall --cask tayuLuc/copyosity/copyosity
brew untap tayuLuc/copyosity
```

Clipboard history lives in `~/Library/Application Support/Copyosity`; the `zap`
 stanza in the cask removes it, plain `uninstall` does not.
