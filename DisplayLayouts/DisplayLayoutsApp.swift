//
//  DisplayLayoutsApp.swift
//  DisplayLayouts
//
//  Created by Luca Pedrocchi on 02.10.2025.
//

import SwiftUI
import AppKit

@main
struct DisplayLayoutsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        // No main window; menu bar app only. Provide Settings placeholder.
        Settings {
            ContentView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let menuController = StatusMenuController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "display.2", accessibilityDescription: "Display Layouts")
        }
        statusItem.menu = menuController.buildMenu()
        menuController.refreshMenu()
    }
}
