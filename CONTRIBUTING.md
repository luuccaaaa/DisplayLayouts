# Contributing

Thanks for your interest in improving DisplayLayouts! This is a simple, community‑driven project. Contributions of all sizes are welcome.

## Ways to Contribute
- Report bugs and UX issues
- Improve documentation
- Tweak UI/menus
- Add small, focused features

## Development Setup
- Requirements: macOS 12+, Xcode 15+
- Repo layout:
  - `DisplayLayouts.xcodeproj` — Xcode project
  - App sources under `DisplayLayouts/`
  - Bundled tool expected at `displayplacer/bin/displayplacer` (copied into the app at build time)
- Open the project in Xcode and build the `DisplayLayouts` target.

## Bundled Tool
- The app shells out to `displayplacer` to apply layouts.
- Ensure the binary is present and added to the Copy Files phase (Destination `Wrapper`, Subpath `Contents/Resources/Tools`, Code Sign on Copy).

## Coding Guidelines
- Swift 5, prefer clarity over cleverness
- Keep changes minimal and focused
- Follow existing file organization and naming
- No App Store‑only constraints; outside‑store distribution is expected

## Pull Requests
- Describe the problem and the approach briefly
- Include before/after behavior when relevant
- Keep PRs small and reviewable
- It’s okay if you can’t test every display setup—describe what you tested

## License
- By contributing, you agree that your contributions are licensed under the MIT License (see `LICENSE`).
