cask "copyosity" do
  arch arm: "aarch64", intel: "x64"

  version "1.0.4-fork1"
  sha256 arm: "58f3c44269a8ad1de6282680a35ca0bfdba815a8cd80cff7868f73a5ab2271ca", intel: "495df80dfb396f4c3f2dd78365be7e441600c71cd60125b26ebdc47c04599853"

  url "https://github.com/tayuLuc/copyosity/releases/download/v#{version}/Copyosity-#{arch}_#{version}.dmg"
  name "Copyosity"
  desc "Clipboard history manager with voice input, OCR and local Ollama (fork build)"
  homepage "https://github.com/tayuLuc/copyosity"

  livecheck do
    url "https://github.com/tayuLuc/copyosity"
    # Не :github_latest: он читает заголовок Latest-Version, а GitHub считает
    # суффикс `-fork1` semver-пре-релизом и отдаёт в нём `1.0.4` — livecheck
    # вечно рапортовал бы «есть новее». Список релизов даёт тег целиком.
    strategy :github_release
  end

  # The fork build has the Tauri updater switched off: it cannot mint minisign
  # artifacts, and pointing at the upstream channel would install upstream's
  # signed build over this one. Upgrades happen through this cask.
  auto_updates false

  depends_on macos: ">= :monterey"

  app "Copyosity.app"

  zap trash: [
    "~/Library/Application Support/Copyosity",
    "~/Library/Preferences/com.vkovalskii.copyosity.plist",
    "~/Library/Saved Application State/com.vkovalskii.copyosity.savedState",
  ]
end
