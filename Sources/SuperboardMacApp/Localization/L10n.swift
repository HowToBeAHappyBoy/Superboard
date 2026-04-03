import Foundation

@MainActor
enum L10n {
    static func tr(_ key: String, bundle: Bundle) -> String {
        bundle.localizedString(forKey: key, value: key, table: nil)
    }

    static func trFormat(_ key: String, bundle: Bundle, args: [CVarArg]) -> String {
        let format = tr(key, bundle: bundle)
        return withVaList(args) { pointer in
            NSString(format: format, locale: Locale.current, arguments: pointer) as String
        }
    }
}
