#!/bin/bash
set -euo pipefail

# Notarize and staple a DMG/ZIP using an Xcode notarytool keychain profile.
#
# Prereqs (run once on your machine):
#   xcrun notarytool store-credentials AC_NOTARY \
#     --apple-id "your@appleid" \
#     --team-id "YOURTEAMID" \
#     --password "app-specific-password"
#
# Usage:
#   Scripts/notarize.sh [-p PROFILE] [path/to/artifact.dmg|zip]
#
# If no artifact path is provided, the script will pick the newest DMG/ZIP in dist/.

PROFILE="AC_NOTARY"
ARTIFACT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--profile)
      PROFILE="$2"; shift 2 ;;
    *)
      ARTIFACT="$1"; shift ;;
  esac
done

PROJECT_DIR_ABS="${PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
DIST_DIR="${PROJECT_DIR_ABS}/dist"

if [[ -z "${ARTIFACT}" ]]; then
  if [[ -d "${DIST_DIR}" ]]; then
    # pick newest dmg or zip
    ARTIFACT=$(ls -t "${DIST_DIR}"/*.{dmg,zip} 2>/dev/null | head -n1 || true)
  fi
fi

if [[ -z "${ARTIFACT}" || ! -f "${ARTIFACT}" ]]; then
  echo "Error: artifact not found. Provide a path or place a DMG/ZIP in ${DIST_DIR}" >&2
  exit 1
fi

echo "Submitting for notarization: ${ARTIFACT}"
xcrun notarytool submit "${ARTIFACT}" --keychain-profile "${PROFILE}" --wait

echo "Stapling: ${ARTIFACT}"
xcrun stapler staple "${ARTIFACT}"

echo "Gatekeeper check:"
spctl -a -vv "${ARTIFACT}" || true

echo "Notarization complete."

