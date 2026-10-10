cask "copyosity" do
  arch arm: "aarch64", intel: "x64"

  version "1.0.4-fork2"
  sha256 arm: "d34fb4e41438011a4daf69019f4e8565e14e595fba6e48b1c1ad5ed3a83fce51", intel: "51dbc93b0eb8cefb5bc09d356990882f0f8f2fbf63288b712eda706703a13e32"

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
