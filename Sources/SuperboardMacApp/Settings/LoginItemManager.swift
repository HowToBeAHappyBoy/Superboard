import Foundation
import ServiceManagement

enum LoginItemManager {
    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
                DebugLog.write("LoginItem: registered")
            } else {
                try SMAppService.mainApp.unregister()
                DebugLog.write("LoginItem: unregistered")
            }
        } catch {
            DebugLog.write("LoginItem: failed enabled=\(enabled) error=\(error)")
        }
    }
}

