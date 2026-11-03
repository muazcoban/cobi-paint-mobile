#!/bin/sh
# Xcode Cloud runs this right after cloning, before it resolves packages and
# archives the Runner. Xcode Cloud machines have no Flutter, so the script
# installs the same Flutter release as the development machine, writes
# ios/Flutter/Generated.xcconfig (flutter pub get) and installs the pods.
# Steps for the first workflow are in README.md ("Xcode Cloud").
set -e

FLUTTER_VERSION="3.38.3"

cd "$CI_PRIMARY_REPOSITORY_PATH"
git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"

flutter --version
flutter precache --ios
flutter pub get

HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods
cd ios
pod install

exit 0
