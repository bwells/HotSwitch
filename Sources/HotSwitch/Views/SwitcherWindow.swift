import AppKit
import SwiftUI

class SwitcherWindow: NSPanel {
    private var hostingView: NSHostingView<SwitcherView>?
    private var apps: [NSRunningApplication] = []
    private var selectedIndex: Int = 0
    private let hotAppsStore: HotAppsStore
    private let appManager: AppManager

    init(hotAppsStore: HotAppsStore, appManager: AppManager) {
        self.hotAppsStore = hotAppsStore
        self.appManager = appManager

        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 150),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.level = .floating
        self.isFloatingPanel = true
        self.hidesOnDeactivate = false
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }

    func showSwitcher() {
        // Get sorted apps
        apps = appManager.getSortedApps(hotAppBundleIDs: hotAppsStore.hotAppBundleIDs)

        guard !apps.isEmpty else { return }

        // Start with first app selected (or second if we want to skip current app)
        selectedIndex = 0

        updateView()
        centerOnScreen()
        orderFrontRegardless()
    }

    func hideSwitcher() {
        orderOut(nil)
    }

    func selectNext() {
        guard !apps.isEmpty else { return }
        selectedIndex = (selectedIndex + 1) % apps.count
        updateView()
    }

    func selectPrevious() {
        guard !apps.isEmpty else { return }
        selectedIndex = (selectedIndex - 1 + apps.count) % apps.count
        updateView()
    }

    func getSelectedApp() -> NSRunningApplication? {
        guard selectedIndex >= 0 && selectedIndex < apps.count else { return nil }
        return apps[selectedIndex]
    }

    private func updateView() {
        let indexBinding = Binding<Int>(
            get: { [weak self] in self?.selectedIndex ?? 0 },
            set: { [weak self] in self?.selectedIndex = $0 }
        )

        let switcherView = SwitcherView(
            apps: apps,
            hotAppBundleIDs: hotAppsStore.hotAppBundleIDs,
            selectedIndex: indexBinding
        )

        if hostingView == nil {
            hostingView = NSHostingView(rootView: switcherView)
            contentView = hostingView
        } else {
            hostingView?.rootView = switcherView
        }

        // Resize to fit content
        if let hostingView = hostingView {
            let fittingSize = hostingView.fittingSize
            setContentSize(fittingSize)
        }

        centerOnScreen()
    }

    private func centerOnScreen() {
        guard let screen = NSScreen.main else { return }

        let screenFrame = screen.visibleFrame
        let windowFrame = frame

        let x = screenFrame.midX - windowFrame.width / 2
        let y = screenFrame.midY - windowFrame.height / 2

        setFrameOrigin(NSPoint(x: x, y: y))
    }
}
