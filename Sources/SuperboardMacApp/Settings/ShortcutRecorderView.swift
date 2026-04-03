import AppKit
import SwiftUI

struct ShortcutRecorderView: View {
    @Binding var shortcut: HotKeyShortcut

    @State private var isRecording = false
    @State private var eventMonitor: Any?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                shortcutBadge

                Spacer(minLength: 12)

                Button(isRecording ? "녹화 취소" : "단축키 변경") {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            HStack(alignment: .center, spacing: 8) {
                Circle()
                    .fill(isRecording ? Color.orange : Color.green)
                    .frame(width: 8, height: 8)

                Text(isRecording ? "새 단축키를 입력하세요. ESC로 취소할 수 있습니다." : "현재 단축키: \(shortcut.displayString)")
                    .font(.caption)
                    .foregroundStyle(isRecording ? .primary : .secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isRecording ? Color.accentColor : Color(nsColor: .separatorColor), lineWidth: isRecording ? 1.5 : 1)
        )
        .animation(.easeInOut(duration: 0.15), value: isRecording)
        .onDisappear {
            stopRecording()
        }
    }

    private var shortcutBadge: some View {
        Group {
            if isRecording {
                Text("입력 대기 중")
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(Color.accentColor)
            } else {
                Text(shortcut.displayString)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isRecording ? Color.accentColor.opacity(0.12) : Color(nsColor: .windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isRecording ? Color.accentColor : Color(nsColor: .separatorColor).opacity(0.7), lineWidth: 1)
        )
    }

    private func startRecording() {
        isRecording = true
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            let keyCode = Int(event.keyCode)
            if keyCode == 53 {
                stopRecording()
                return nil
            }

            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            shortcut = HotKeyShortcut(
                keyCode: keyCode,
                command: flags.contains(.command),
                shift: flags.contains(.shift),
                option: flags.contains(.option),
                control: flags.contains(.control)
            )
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }
}
