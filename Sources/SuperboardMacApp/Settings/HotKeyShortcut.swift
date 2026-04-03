import Foundation

struct HotKeyShortcut: Codable, Equatable, Sendable {
    var keyCode: Int
    var command: Bool
    var shift: Bool
    var option: Bool
    var control: Bool

    static let `default` = HotKeyShortcut(
        keyCode: 9, // kVK_ANSI_V
        command: true,
        shift: true,
        option: false,
        control: false
    )

    var displayString: String {
        var parts: [String] = []
        if control { parts.append("⌃") }
        if option { parts.append("⌥") }
        if shift { parts.append("⇧") }
        if command { parts.append("⌘") }
        parts.append(keyCodeDisplayString)
        return parts.joined()
    }

    private var keyCodeDisplayString: String {
        // Minimal mapping for the MVP use cases.
        switch keyCode {
        case 0: return "A"
        case 1: return "S"
        case 2: return "D"
        case 3: return "F"
        case 4: return "H"
        case 5: return "G"
        case 6: return "Z"
        case 7: return "X"
        case 8: return "C"
        case 9: return "V"
        case 11: return "B"
        case 12: return "Q"
        case 13: return "W"
        case 14: return "E"
        case 15: return "R"
        case 16: return "Y"
        case 17: return "T"
        case 31: return "O"
        case 32: return "U"
        case 34: return "I"
        case 35: return "P"
        case 37: return "L"
        case 38: return "J"
        case 40: return "K"
        case 45: return "N"
        case 46: return "M"
        case 36: return "⏎"
        case 48: return "⇥"
        case 49: return "␣"
        case 51: return "⌫"
        case 53: return "⎋"
        default: return "Key(\(keyCode))"
        }
    }
}

