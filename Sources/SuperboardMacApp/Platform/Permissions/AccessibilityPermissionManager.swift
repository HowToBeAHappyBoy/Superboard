import Foundation
import ApplicationServices

struct AccessibilityPermissionManager {
    func requestIfNeeded() {
        if AXIsProcessTrusted() {
            DebugLog.write("AX: trusted")
            return
        }
        DebugLog.write("AX: not trusted; prompting")
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }
}
