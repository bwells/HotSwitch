import SwiftUI

@main
struct HotSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("HotSwitch", systemImage: "square.stack.3d.up.fill") {
            MenuBarView()
                .environmentObject(appDelegate.hotAppsStore)
                .environmentObject(appDelegate.appManager)
                .environmentObject(appDelegate.settingsStore)
        }
        .menuBarExtraStyle(.window)
    }
}
