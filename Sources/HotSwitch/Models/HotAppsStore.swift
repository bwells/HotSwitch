import Foundation
import Combine

class HotAppsStore: ObservableObject {
    private static let storageKey = "HotAppBundleIDs"

    @Published var hotAppBundleIDs: [String] {
        didSet {
            save()
        }
    }

    init() {
        if let saved = UserDefaults.standard.array(forKey: Self.storageKey) as? [String] {
            self.hotAppBundleIDs = saved
        } else {
            self.hotAppBundleIDs = []
        }
    }

    private func save() {
        UserDefaults.standard.set(hotAppBundleIDs, forKey: Self.storageKey)
    }

    func isHot(_ bundleID: String) -> Bool {
        hotAppBundleIDs.contains(bundleID)
    }

    func toggleHot(_ bundleID: String) {
        if isHot(bundleID) {
            hotAppBundleIDs.removeAll { $0 == bundleID }
        } else {
            hotAppBundleIDs.append(bundleID)
        }
    }

    func addHot(_ bundleID: String) {
        guard !isHot(bundleID) else { return }
        hotAppBundleIDs.append(bundleID)
    }

    func removeHot(_ bundleID: String) {
        hotAppBundleIDs.removeAll { $0 == bundleID }
    }

    func move(from source: IndexSet, to destination: Int) {
        hotAppBundleIDs.move(fromOffsets: source, toOffset: destination)
    }

    func reorder(_ bundleIDs: [String]) {
        hotAppBundleIDs = bundleIDs
    }
}
