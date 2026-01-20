import AppKit
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var hotkeyManager: HotkeyManager!
    let appManager = AppManager()
    let hotAppsStore = HotAppsStore()
    let settingsStore = SettingsStore()
    var switcherWindow: SwitcherWindow?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize hotkey manager with callbacks
        hotkeyManager = HotkeyManager(
            onSwitcherShow: { [weak self] in
                self?.showSwitcher()
            },
            onSwitcherHide: { [weak self] in
                self?.hideSwitcher()
            },
            onNextApp: { [weak self] in
                self?.switcherWindow?.selectNext()
            },
            onPreviousApp: { [weak self] in
                self?.switcherWindow?.selectPrevious()
            }
        )

        // Set initial modifier key from settings
        hotkeyManager.modifierKey = settingsStore.modifierKey

        // Listen for modifier key changes
        settingsStore.$modifierKey
            .sink { [weak self] newModifier in
                self?.hotkeyManager.modifierKey = newModifier
            }
            .store(in: &cancellables)

        // Check and request accessibility permissions
        checkAccessibilityPermissions()

        // Start hotkey monitoring
        let success = hotkeyManager.start()
        if !success {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Failed to Start Hotkey Monitoring"
                alert.informativeText = "Could not create event tap. Please ensure Accessibility permission is granted in System Settings > Privacy & Security > Accessibility, then restart the app."
                alert.alertStyle = .critical
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Quit")

                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                } else {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager?.stop()
    }

    private func checkAccessibilityPermissions() {
        // Check without prompting first
        let isTrusted = AXIsProcessTrusted()

        if !isTrusted {
            // Prompt the system dialog - this will show macOS's native permission request
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
        }
    }

    private func showSwitcher() {
        if switcherWindow == nil {
            switcherWindow = SwitcherWindow(
                hotAppsStore: hotAppsStore,
                appManager: appManager
            )
        }
        switcherWindow?.showSwitcher()
    }

    private func hideSwitcher() {
        if let selectedApp = switcherWindow?.getSelectedApp() {
            selectedApp.activate(options: [.activateIgnoringOtherApps])
            appManager.recordActivation(selectedApp)
        }
        switcherWindow?.hideSwitcher()
    }
}
