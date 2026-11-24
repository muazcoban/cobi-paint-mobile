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
cd ..

# The Full Version purchase (lib/services/purchase_service.dart) is compiled
# in only with COBI_IAP=true. The App Store product com.cobi.paint.full exists
# since 24 November 2026, so cloud builds sell it unless the workflow sets
# COBI_IAP=false. --config-only writes the define into Generated.xcconfig,
# which the Xcode archive reads; it builds nothing itself. It runs after the
# pods are installed because it may run pod install too.
COBI_IAP="${COBI_IAP:-true}"
if [ "$COBI_IAP" != true ] && [ "$COBI_IAP" != false ]; then
  echo "COBI_IAP must be true or false, not '$COBI_IAP'." >&2
  exit 1
fi
echo "Full Version purchase (COBI_IAP): $COBI_IAP"
flutter build ios --config-only --release --no-codesign --dart-define=COBI_IAP="$COBI_IAP"
grep -q '^DART_DEFINES=.*Q09CSV9JQVA9' ios/Flutter/Generated.xcconfig || {
  echo "COBI_IAP did not reach ios/Flutter/Generated.xcconfig." >&2
  exit 1
}

exit 0
