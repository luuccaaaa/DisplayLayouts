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

## Requirements
- macOS 12.0 or later
- Xcode 15+
- A `displayplacer` binary embedded in the app bundle (see below)

## Build & Run
1. Open `DisplayLayouts/DisplayLayouts.xcodeproj` in Xcode.
2. Set your Team under Target → Signing & Capabilities (Hardened Runtime on; Sandbox off).
3. Ensure `displayplacer` is embedded via the Copy Files phase:
   - Target → Build Phases → “Copy Files” (Destination: `Wrapper`, Subpath: `Contents/Resources/Tools`)
   - It should include the `displayplacer` binary with “Code Sign on Copy” checked.
   - If missing, place a binary at `DisplayLayouts/displayplacer/bin/displayplacer` and add it to the Copy Files phase.
4. Build and Run.

At runtime, the app looks for the tool at:
- `DisplayLayouts.app/Contents/Resources/Tools/displayplacer`

## Usage
- Click the menu bar icon (displays symbol).
- Save Current as New Layout… → name it → layout appears under “Apply Layout”.
- Select a layout to apply it. The active layout is checked.
- Manage Layouts… → rename, delete, reorder.

## Notes
- This app is not intended for Mac App Store distribution (uses private APIs via `displayplacer`).
- For outside‑store distribution, sign and notarize with your Developer ID, then ship a DMG/ZIP.

## License
MIT — see `LICENSE`.
