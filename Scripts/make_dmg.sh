#!/bin/bash
set -euo pipefail

# Create a compressed DMG from the built/archived app.
# Intended to run as an Xcode Archive post-action.

APP_NAME="${PRODUCT_NAME:-DisplayLayouts}"
VERSION="${MARKETING_VERSION:-1.0.0}"
PROJECT_DIR_ABS="${PROJECT_DIR:-$(pwd)}"
OUT_DIR="${PROJECT_DIR_ABS}/dist"

mkdir -p "${OUT_DIR}"

# Prefer the archived app (Archive post-action). Fallback to target build dir if needed.
if [[ -n "${ARCHIVE_PRODUCTS_PATH:-}" && -d "${ARCHIVE_PRODUCTS_PATH}/Applications/${APP_NAME}.app" ]]; then
  APP_PATH="${ARCHIVE_PRODUCTS_PATH}/Applications/${APP_NAME}.app"
else
  APP_PATH="${TARGET_BUILD_DIR:-build}/${APP_NAME}.app"
fi

if [[ ! -d "${APP_PATH}" ]]; then
  echo "Error: app not found at ${APP_PATH}" >&2
  exit 1
fi

DMG_NAME="${APP_NAME}-${VERSION}.dmg"
DMG_PATH="${OUT_DIR}/${DMG_NAME}"

# Stage folder with app and Applications symlink for drag & drop install
STAGING_DIR="${OUT_DIR}/_dmg_src/${APP_NAME}-${VERSION}"
rm -rf "${STAGING_DIR}"
mkdir -p "${STAGING_DIR}"

echo "Staging app and Applications symlink in ${STAGING_DIR}"
ditto "${APP_PATH}" "${STAGING_DIR}/${APP_NAME}.app"
ln -s /Applications "${STAGING_DIR}/Applications" || true

echo "Creating DMG at ${DMG_PATH}"
hdiutil create \
  -volname "${APP_NAME}" \
  -srcfolder "${STAGING_DIR}" \
  -ov \
  -format UDZO \
  "${DMG_PATH}"

echo "DMG created: ${DMG_PATH}"
if command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "${DMG_PATH}" | awk '{print "SHA256:", $1}'
fi
ls -lh "${DMG_PATH}" | awk '{print "Size:", $5}'

echo "Done. Open the DMG and drag ${APP_NAME}.app to Applications."

exit 0
