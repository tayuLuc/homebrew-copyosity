cask "copyosity" do
  arch arm: "aarch64", intel: "x64"

  version "1.0.4-fork6"
  sha256 arm:   "328f386831987ec12599581b06c07b32d031e4c5f499375ea629d64b8cd07305",
         intel: "29c805f46b731fa1c430d0e660876d4042d097b786d2973be3223e14fcf63dd5"

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

  # From v1.0.4-fork3 the fork self-updates from its own release channel (fork's
  # minisign key, fork's latest.json), so brew must not claim the cask is
  # outdated: after a self-update the running app is newer than this pin, and
  # `brew upgrade --cask` would quietly roll it back to the pinned build.
  # Deliberately return to the pinned artifact with `brew reinstall --cask copyosity`.
  auto_updates true

  # Символьная форма, а не ">= :monterey": строковое сравнение brew 7.0.7 помечает
  # как deprecated и предупреждает при каждой установке (замер 10.10.2026).
  depends_on macos: :monterey

  app "Copyosity.app"

  # Пути измерены на живой установке (10.10.2026), а не угаданы по имени приложения:
  # данные лежат в каталоге по bundle id, каталога "Copyosity" нет вообще.
  zap trash: [
    "~/Library/Application Support/com.vkovalskii.copyosity",
    "~/Library/Caches/com.vkovalskii.copyosity",
    "~/Library/WebKit/com.vkovalskii.copyosity",
    "~/Library/Preferences/com.vkovalskii.copyosity.plist",
    "~/Library/Saved Application State/com.vkovalskii.copyosity.savedState",
  ]
end
