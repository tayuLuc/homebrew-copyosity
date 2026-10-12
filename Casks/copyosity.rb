cask "copyosity" do
  arch arm: "aarch64", intel: "x64"

  version "1.0.4-fork11"
  sha256 arm:   "fe840a951a67b0eed3533c0fbcf02fe7a0661d499f6546951f7eb3d833736d62",
         intel: "a2c08e926ef2952e2e8e3ccfd39ef171f1f2aff2bdc23a64f8f350bf28a1a982"

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
