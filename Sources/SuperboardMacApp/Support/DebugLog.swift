import Foundation

enum DebugLog {
    private static let url = URL(fileURLWithPath: "/tmp/superboard-debug.log")
    private static let lock = NSLock()

    static func reset() {
        lock.lock()
        defer { lock.unlock() }
        try? Data().write(to: url, options: .atomic)
    }

    static func write(_ message: String) {
        lock.lock()
        defer { lock.unlock() }

        let line = "[\(ISO8601DateFormatter().string(from: Date()))] \(message)\n"
        guard let data = line.data(using: .utf8) else { return }

        if FileManager.default.fileExists(atPath: url.path) {
            if let handle = try? FileHandle(forWritingTo: url) {
                do {
                    try handle.seekToEnd()
                    try handle.write(contentsOf: data)
                    try handle.close()
                } catch {
                    try? handle.close()
                }
            }
        } else {
            try? data.write(to: url, options: .atomic)
        }
    }
}
