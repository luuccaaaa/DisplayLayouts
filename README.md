# DisplayLayouts

[![Version](https://img.shields.io/badge/version-1.0-blue.svg)](#)
[![Platform](https://img.shields.io/badge/platform-macOS-000000.svg?logo=apple&logoColor=white)](#)
[![macOS](https://img.shields.io/badge/macos-12%2B-blue.svg)](#)
[![Swift](https://img.shields.io/badge/Swift-5-orange.svg?logo=swift)](#)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A small macOS menu bar app to quickly switch between predefined multi‑monitor layouts. It saves the current display arrangement and lets you re‑apply it from the menu bar.

DisplayLayouts uses the bundled `displayplacer` tool under the hood to apply positions, resolutions, refresh rates, rotation, and mirroring.

## Features
- Save current arrangement as a named layout
- Apply saved layouts from the menu bar
- Manage layouts (rename, delete, reorder)
- Shows a checkmark for the currently active layout

## System Requirements
- macOS 12.0 (Monterey) or newer
- Apple Silicon or Intel Mac

## Download & Install
> **Latest:** DisplayLayouts 1.0 (tag `v1.0`, commit `8218a4a`) 


### Homebrew (recommended)
```bash
brew tap luuccaaaa/tap
brew install --cask displaylayouts
```

### Direct download
1. Grab `DisplayLayouts-1.0.dmg` from the GitHub Releases page.
2. (Optional) Verify the download:
   ```bash
   shasum -a 256 DisplayLayouts-1.0.dmg
   ```
   Expected SHA256: `e0942d6bfa58d6fe0fe4ce4a0c5f2f16001d00c209bbe9f6122373b348899f13`.
3. Open the DMG and drag `DisplayLayouts.app` to `Applications`.

## Build from Source
Development builds require Xcode 15 or newer and a bundled `displayplacer` binary.

1. Open `DisplayLayouts/DisplayLayouts.xcodeproj` in Xcode.
2. Set your Team under Target → Signing & Capabilities (Hardened Runtime on; Sandbox off).
3. Ensure `displayplacer` is embedded via the Copy Files phase:
   - Target → Build Phases → “Copy Files” (Destination: `Wrapper`, Subpath: `Contents/Resources/Tools`)
   - Include the `displayplacer` binary with “Code Sign on Copy” checked.
   - If missing, place a binary at `DisplayLayouts/displayplacer/bin/displayplacer` and add it to the Copy Files phase.
4. Build and run.

At runtime, the app looks for the tool at `DisplayLayouts.app/Contents/Resources/Tools/displayplacer`.

## Notes
- This app is not intended for Mac App Store distribution (uses private APIs via `displayplacer`).
- For outside‑store distribution, sign and notarize with your Developer ID, then ship a DMG/ZIP.

## License
MIT — see `LICENSE`.
