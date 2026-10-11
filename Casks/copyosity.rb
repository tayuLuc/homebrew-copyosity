cask "copyosity" do
  arch arm: "aarch64", intel: "x64"

  version "1.0.4-fork7"
  sha256 arm:   "ae191c2dde19421a3ebc136d92a00001110fe24c17b5a011e5aafc87e208b8e6",
         intel: "20c867819b02027e24352aaaf6eeaa1ca51a6036f141c6ad5bfbe094eb5ee6fd"

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
