import AppKit
import Foundation
import SwiftUI

final class StatusMenuController: NSObject {
    private let menu = NSMenu()
    private let profilesStore = ProfilesStore()
    private let placer = DisplayPlacerService()

    private var applyMenu: NSMenuItem!
    private var currentMatchedProfileID: UUID?

    func buildMenu() -> NSMenu {
        menu.autoenablesItems = false
        // Observe profile changes to keep menu in sync
        NotificationCenter.default.addObserver(forName: .profilesStoreDidChange, object: nil, queue: .main) { [weak self] _ in
            self?.refreshMenu()
        }

        // Apply submenu placeholder
        let apply = NSMenuItem(title: "Apply Layout", action: nil, keyEquivalent: "")
        let sub = NSMenu()
        apply.submenu = sub
        menu.addItem(apply)
        self.applyMenu = apply

        menu.addItem(NSMenuItem.separator())

        let saveCurrent = NSMenuItem(title: "Save Current as New Layout…", action: #selector(saveCurrentLayout), keyEquivalent: "s")
        saveCurrent.target = self
        menu.addItem(saveCurrent)

        let manage = NSMenuItem(title: "Manage Layouts…", action: #selector(manageLayouts), keyEquivalent: ",")
        manage.target = self
        menu.addItem(manage)

        menu.addItem(NSMenuItem.separator())

        let quit = NSMenuItem(title: "Quit", action: #selector(quitAction), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        return menu
    }

    func refreshMenu() {
        guard let sub = applyMenu.submenu else { return }
        sub.removeAllItems()
        // Try to detect current active layout and match a profile
        if case let .success(currentArgs) = placer.captureCurrentArgs() {
            let liveSig = signature(for: currentArgs)
            currentMatchedProfileID = profilesStore.profiles.first(where: { signature(for: $0.args) == liveSig })?.id
        } else {
            currentMatchedProfileID = nil
        }

        if profilesStore.profiles.isEmpty {
            let empty = NSMenuItem(title: "No layouts saved", action: nil, keyEquivalent: "")
            empty.isEnabled = false
            sub.addItem(empty)
        } else {
            for profile in profilesStore.profiles {
                let item = NSMenuItem(title: profile.name, action: #selector(applyLayout(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = profile
                if profile.id == currentMatchedProfileID {
                    item.state = .on
                }
                sub.addItem(item)
            }
        }
    }

    private var manageWindow: NSWindow?
    @objc private func manageLayouts() {
        if manageWindow == nil {
            let vc = NSHostingController(rootView: ManageProfilesView(store: profilesStore) {
                self.manageWindow?.close()
            })
            let window = NSWindow(contentViewController: vc)
            window.title = "Display Layouts"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.center()
            manageWindow = window
            NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) { [weak self] _ in
                self?.manageWindow = nil
                self?.refreshMenu()
            }
        }
        manageWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func applyLayout(_ sender: NSMenuItem) {
        guard let profile = sender.representedObject as? LayoutProfile else { return }
        let outcome = placer.apply(args: profile.args)
        switch outcome {
        case .success:
            refreshMenu()
        case .partial(let missing):
            refreshMenu()
            let count = missing.count
            let msg = "Applied partially. Missing \(count) display\(count == 1 ? "" : "s"):\n\n" + missing.joined(separator: "\n")
            presentInfo("Layout applied with warnings", message: msg)
        case .failure(let text):
            presentError("Failed to apply layout", message: text)
        }
    }

    @objc func saveCurrentLayout() {
        switch placer.captureCurrentArgs() {
        case .failure(let error):
            presentError("Failed to read current layout", message: error.localizedDescription)
        case .success(let args):
            let name = promptForName(defaultsTo: suggestedName())
            guard let name = name, !name.isEmpty else { return }
            do {
                _ = try profilesStore.add(name: name, args: args)
                refreshMenu()
            } catch {
                presentError("Failed to save layout", message: error.localizedDescription)
            }
        }
    }

    private func suggestedName() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return "Layout \(f.string(from: Date()))"
    }

    private func promptForName(defaultsTo: String) -> String? {
        let alert = NSAlert()
        alert.messageText = "Save Current Layout"
        alert.informativeText = "Enter a name for this layout."
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        let tf = NSTextField(string: defaultsTo)
        tf.frame = NSRect(x: 0, y: 0, width: 240, height: 24)
        alert.accessoryView = tf
        let response = alert.runModal()
        return response == .alertFirstButtonReturn ? tf.stringValue : nil
    }

    private func signature(for args: [String]) -> Set<String> {
        // Order-insensitive comparison of per-display args (trimmed)
        let trimmed = args.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return Set(trimmed)
    }

    private func presentError(_ title: String, message: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }

    private func presentInfo(_ title: String, message: String) {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }

    @objc func quitAction() {
        NSApp.terminate(nil)
    }
}

extension StatusMenuController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        // Always ensure the Apply submenu reflects current profiles + active layout
        profilesStore.load()
        refreshMenu()
    }
}
