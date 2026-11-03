#!/bin/zsh
# Builds the App Store IPA of Cobi Paint with Xcode 26 or newer and, with
# --upload, sends it to App Store Connect (TestFlight).
#
#   tool/release/ios_testflight.sh            # archive + export, IPA under build/ios/ipa/
#   tool/release/ios_testflight.sh --upload   # archive + export + upload to App Store Connect
#
# App Store Connect accepts only builds made with Xcode 26 or later (since
# 28 April 2026). The Mac's default Xcode (xcode-select) is left alone: the
# script uses the newest /Applications/Xcode*.app whose version is 26 or
# newer, or the one in $XCODE_APP, through DEVELOPER_DIR. Signing is
# automatic with team 5MY44SLWZU, so Xcode must be signed in with an Apple
# account of that team (Xcode > Settings > Accounts). The version and build
# number come from pubspec.yaml; raise the build number before each upload.
set -euo pipefail
setopt null_glob

cd "$(dirname "$0")/../.."
FLUTTER="${FLUTTER:-$HOME/flutter/sdk/flutter/bin/flutter}"

if [ -z "${XCODE_APP:-}" ]; then
  for app in /Applications/Xcode*.app; do
    version=$(defaults read "$app/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo 0)
    if [ "${version%%.*}" -ge 26 ]; then
      XCODE_APP="$app"
    fi
  done
fi
if [ -z "${XCODE_APP:-}" ]; then
  echo "No Xcode 26 or newer under /Applications. Install one (for example as Xcode-26.3.app) or set XCODE_APP." >&2
  exit 1
fi
export DEVELOPER_DIR="$XCODE_APP/Contents/Developer"
echo "Xcode: $XCODE_APP ($(xcodebuild -version | head -n 1))"

plist=ios/ExportOptions.plist
if [ "${1:-}" = "--upload" ]; then
  plist=ios/ExportOptionsUpload.plist
fi
echo "Version: $(grep -E '^version:' pubspec.yaml)"

"$FLUTTER" build ipa --release --export-options-plist "$plist"

if [ "$plist" = ios/ExportOptions.plist ]; then
  ls -la build/ios/ipa/*.ipa
  echo "Not uploaded. Run again with --upload to send it to App Store Connect."
else
  echo "Uploaded. It appears under TestFlight in App Store Connect after processing (10-30 minutes)."
fi
