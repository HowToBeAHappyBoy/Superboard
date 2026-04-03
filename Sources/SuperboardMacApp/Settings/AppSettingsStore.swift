import Combine
import Foundation

@MainActor
final class AppSettingsStore: ObservableObject {
    @Published var pickerDisplayLimit: Int {
        didSet { saveInt(pickerDisplayLimit, key: Keys.pickerDisplayLimit) }
    }

    @Published var historyStoreLimit: Int {
        didSet { saveInt(historyStoreLimit, key: Keys.historyStoreLimit) }
    }

    @Published var hotKeyShortcut: HotKeyShortcut {
        didSet { saveCodable(hotKeyShortcut, key: Keys.hotKeyShortcut) }
    }

    @Published var launchAtLogin: Bool {
        didSet { saveBool(launchAtLogin, key: Keys.launchAtLogin) }
    }

    @Published var useVirtualClipboard: Bool {
        didSet { saveBool(useVirtualClipboard, key: Keys.useVirtualClipboard) }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        let pickerDisplay = userDefaults.integer(forKey: Keys.pickerDisplayLimit)
        self.pickerDisplayLimit = pickerDisplay > 0 ? pickerDisplay : 10

        let storeLimit = userDefaults.integer(forKey: Keys.historyStoreLimit)
        self.historyStoreLimit = storeLimit > 0 ? storeLimit : 50

        self.hotKeyShortcut = Self.loadCodable(
            HotKeyShortcut.self,
            from: userDefaults,
            key: Keys.hotKeyShortcut
        ) ?? .default

        self.launchAtLogin = userDefaults.bool(forKey: Keys.launchAtLogin)
        self.useVirtualClipboard = userDefaults.bool(forKey: Keys.useVirtualClipboard)
    }

    // MARK: - Private

    private enum Keys {
        static let pickerDisplayLimit = "superboard.settings.pickerDisplayLimit"
        static let historyStoreLimit = "superboard.settings.historyStoreLimit"
        static let hotKeyShortcut = "superboard.settings.hotKeyShortcut"
        static let launchAtLogin = "superboard.settings.launchAtLogin"
        static let useVirtualClipboard = "superboard.settings.useVirtualClipboard"
    }

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private func saveInt(_ value: Int, key: String) {
        userDefaults.set(value, forKey: key)
    }

    private func saveBool(_ value: Bool, key: String) {
        userDefaults.set(value, forKey: key)
    }

    private func saveCodable<T: Codable>(_ value: T, key: String) {
        do {
            let data = try encoder.encode(value)
            userDefaults.set(data, forKey: key)
        } catch {
            DebugLog.write("Settings: failed to encode \(key): \(error)")
        }
    }

    private static func loadCodable<T: Codable>(_ type: T.Type, from userDefaults: UserDefaults, key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            DebugLog.write("Settings: failed to decode \(key): \(error)")
            return nil
        }
    }
}

