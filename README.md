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
   a SHA-256 pinned per architecture and verified on download, `livecheck`, and
   `brew upgrade --cask` as the update channel (the fork build ships with the Tauri
   updater disabled — see below).

## What the fork build changes

1. `smart-actions`: contextual actions on each clipboard card (link, email,
   phone, address via `NSDataDetector`; color, math, JSON via TypeScript) plus a
   QR popover. Cherry-picked from `ed-would/copyosity` onto upstream `main`.
2. `LICENSE` added — upstream declares `"license": "MIT"` in `package.json` but
   ships no license file. Both copyright lines are present.
3. Ad-hoc signing, no Developer ID, no notarization, no updater artifacts — see
   `docs/FORK-NOTARIZATION.md` in the app repository.
4. In-app self-update is disabled (`plugins.updater.endpoints = []`), so this
   build can never replace itself with an upstream-signed artifact.

## Versions

| Cask version | Build commit | Contents |
| --- | --- | --- |
| `1.0.4-fork1` | `8556aea` on `brew-unsigned` | upstream `main@aad3c2b` (1.0.4-dev) + smart-actions + unsigned CI |

## Updating

```sh
brew update
brew upgrade --cask copyosity
```

To cut a new build: push a version tag to the fork, `.github/workflows/release-fork.yml`
builds both architectures and publishes the DMGs, then `version` and the two
`sha256` values in `Casks/copyosity.rb` are updated. `brew livecheck --tap
tayuLuc/copyosity --casks` reports when the tag and the cask drift apart.

## Uninstalling

```sh
brew uninstall --cask tayuLuc/copyosity/copyosity
brew untap tayuLuc/copyosity
```

Clipboard history lives in `~/Library/Application Support/Copyosity`; the `zap`
 stanza in the cask removes it, plain `uninstall` does not.
