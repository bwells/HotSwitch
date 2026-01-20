import SwiftUI
import AppKit

struct MenuBarView: View {
    @EnvironmentObject var hotAppsStore: HotAppsStore
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("HotSwitch")
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            Divider()

            // Hot Apps Section
            if !hotAppsStore.hotAppBundleIDs.isEmpty {
                Text("Hot Apps")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                ForEach(hotAppsStore.hotAppBundleIDs, id: \.self) { bundleID in
                    if let app = appManager.runningApps.first(where: { $0.bundleIdentifier == bundleID }) {
                        HotAppRow(app: app, isHot: true) {
                            hotAppsStore.toggleHot(bundleID)
                        }
                    } else {
                        // App not running but is hot
                        NotRunningHotAppRow(bundleID: bundleID) {
                            hotAppsStore.removeHot(bundleID)
                        }
                    }
                }

                Divider()
                    .padding(.vertical, 4)
            }

            // Running Apps Section
            Text("Running Apps")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 4)

            let nonHotApps = appManager.runningApps.filter { app in
                guard let bundleID = app.bundleIdentifier else { return true }
                return !hotAppsStore.isHot(bundleID)
            }

            if nonHotApps.isEmpty {
                Text("All running apps are hot!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
            } else {
                ForEach(nonHotApps, id: \.processIdentifier) { app in
                    HotAppRow(app: app, isHot: false) {
                        if let bundleID = app.bundleIdentifier {
                            hotAppsStore.toggleHot(bundleID)
                        }
                    }
                }
            }

            Divider()
                .padding(.vertical, 4)

            // Settings Section
            Text("Shortcut")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 4)
                .padding(.bottom, 4)

            HStack {
                Text("Modifier Key")
                Spacer()
                Picker("", selection: $settingsStore.modifierKey) {
                    ForEach(ModifierKey.allCases, id: \.self) { key in
                        Text("\(key.symbol) \(key.displayName)").tag(key)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 120)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 4)

            // Help text
            Text("Press \(settingsStore.modifierKey.shortcutDescription) to switch")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.bottom, 4)

            Divider()

            // Quit button
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Text("Quit HotSwitch")
                    Spacer()
                    Text("⌘Q")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 260)
        .padding(.vertical, 4)
    }
}

struct HotAppRow: View {
    let app: NSRunningApplication
    let isHot: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "app.fill")
                        .frame(width: 20, height: 20)
                }

                Text(app.localizedName ?? "Unknown")
                    .lineLimit(1)

                Spacer()

                if isHot {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                } else {
                    Image(systemName: "flame")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct NotRunningHotAppRow: View {
    let bundleID: String
    let onRemove: () -> Void

    private var appName: String {
        // Try to get the app name from the bundle ID
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            return url.deletingPathExtension().lastPathComponent
        }
        return bundleID.components(separatedBy: ".").last ?? bundleID
    }

    private var appIcon: NSImage? {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            return NSWorkspace.shared.icon(forFile: url.path)
        }
        return nil
    }

    var body: some View {
        Button(action: onRemove) {
            HStack(spacing: 8) {
                if let icon = appIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .opacity(0.5)
                } else {
                    Image(systemName: "app.fill")
                        .frame(width: 20, height: 20)
                        .opacity(0.5)
                }

                Text(appName)
                    .lineLimit(1)
                    .foregroundColor(.secondary)

                Text("(not running)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Image(systemName: "flame.fill")
                    .foregroundColor(.orange.opacity(0.5))
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MenuBarView()
        .environmentObject(HotAppsStore())
        .environmentObject(AppManager())
        .environmentObject(SettingsStore())
}
