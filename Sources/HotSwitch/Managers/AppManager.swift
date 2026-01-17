import AppKit
import Combine

class AppManager: ObservableObject {
    @Published private(set) var runningApps: [NSRunningApplication] = []
    private var activationOrder: [String: Date] = [:]
    private var workspaceObservers: [NSObjectProtocol] = []

    init() {
        updateRunningApps()
        setupObservers()
    }

    deinit {
        workspaceObservers.forEach { observer in
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }

    private func setupObservers() {
        let center = NSWorkspace.shared.notificationCenter

        // Watch for app launches
        let launchObserver = center.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.updateRunningApps()
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                self?.recordActivation(app)
            }
        }
        workspaceObservers.append(launchObserver)

        // Watch for app terminations
        let terminateObserver = center.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.updateRunningApps()
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
               let bundleID = app.bundleIdentifier {
                self?.activationOrder.removeValue(forKey: bundleID)
            }
        }
        workspaceObservers.append(terminateObserver)

        // Watch for app activations (front app changed)
        let activateObserver = center.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                self?.recordActivation(app)
            }
        }
        workspaceObservers.append(activateObserver)
    }

    func updateRunningApps() {
        runningApps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
    }

    func recordActivation(_ app: NSRunningApplication) {
        guard let bundleID = app.bundleIdentifier else { return }
        activationOrder[bundleID] = Date()
    }

    func getSortedApps(hotAppBundleIDs: [String]) -> [NSRunningApplication] {
        let running = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }

        // Get hot apps in their configured order (only if running)
        let hotApps = hotAppBundleIDs.compactMap { bundleID in
            running.first { $0.bundleIdentifier == bundleID }
        }

        // Get other apps sorted by recency (most recent first)
        let otherApps = running
            .filter { app in
                guard let bundleID = app.bundleIdentifier else { return true }
                return !hotAppBundleIDs.contains(bundleID)
            }
            .sorted { app1, app2 in
                let date1 = activationOrder[app1.bundleIdentifier ?? ""] ?? .distantPast
                let date2 = activationOrder[app2.bundleIdentifier ?? ""] ?? .distantPast
                return date1 > date2
            }

        return hotApps + otherApps
    }

    func getActivationDate(for bundleID: String) -> Date? {
        return activationOrder[bundleID]
    }
}
