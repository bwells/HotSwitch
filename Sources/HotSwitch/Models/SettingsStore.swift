import Foundation
import Combine

enum ModifierKey: String, CaseIterable {
    case option = "option"
    case command = "command"

    var displayName: String {
        switch self {
        case .option: return "Option"
        case .command: return "Command"
        }
    }

    var symbol: String {
        switch self {
        case .option: return "⌥"
        case .command: return "⌘"
        }
    }

    var shortcutDescription: String {
        "\(symbol)Tab"
    }
}

class SettingsStore: ObservableObject {
    private static let modifierKeyStorageKey = "ModifierKey"

    @Published var modifierKey: ModifierKey {
        didSet {
            save()
        }
    }

    init() {
        if let saved = UserDefaults.standard.string(forKey: Self.modifierKeyStorageKey),
           let modifier = ModifierKey(rawValue: saved) {
            self.modifierKey = modifier
        } else {
            self.modifierKey = .option
        }
    }

    private func save() {
        UserDefaults.standard.set(modifierKey.rawValue, forKey: Self.modifierKeyStorageKey)
    }
}
