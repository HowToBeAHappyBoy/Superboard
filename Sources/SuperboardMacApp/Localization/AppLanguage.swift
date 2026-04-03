import Foundation

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case system
    case english
    case japanese
    case korean

    var id: String { rawValue }
}

enum ResolvedLanguage: String {
    case en
    case ja
    case ko

    var localeIdentifier: String { rawValue }
}

enum LanguageResolver {
    static func resolveSystemLanguage() -> ResolvedLanguage {
        let preferred = Locale.preferredLanguages.first?.lowercased() ?? "en"
        if preferred.hasPrefix("ko") { return .ko }
        if preferred.hasPrefix("ja") { return .ja }
        return .en
    }

    static func resolve(_ language: AppLanguage) -> ResolvedLanguage {
        switch language {
        case .system:
            return resolveSystemLanguage()
        case .english:
            return .en
        case .japanese:
            return .ja
        case .korean:
            return .ko
        }
    }
}

enum LocalizationBundle {
    static func bundle(for resolved: ResolvedLanguage) -> Bundle {
        if let path = Bundle.main.path(forResource: resolved.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path)
        {
            return bundle
        }

        if let sourceBundle = sourceBundle(for: resolved) {
            return sourceBundle
        }

        return Bundle.main
    }

    private static func sourceBundle(for resolved: ResolvedLanguage) -> Bundle? {
        let fileURL = URL(fileURLWithPath: #file)
        // Sources/SuperboardMacApp/Localization/AppLanguage.swift -> Sources/SuperboardMacApp/Resources
        let resourcesDir = fileURL
            .deletingLastPathComponent() // Localization
            .deletingLastPathComponent() // SuperboardMacApp
            .appendingPathComponent("Resources")
        let lprojDir = resourcesDir.appendingPathComponent("\(resolved.rawValue).lproj")
        return Bundle(path: lprojDir.path)
    }
}
