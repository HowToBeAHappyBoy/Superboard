import AppKit
import SwiftUI

struct ShortcutRecorderView: View {
    @Binding var shortcut: HotKeyShortcut
    let bundle: Bundle

    @State private var isRecording = false
    @State private var eventMonitor: Any?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                shortcutBadge

                Spacer(minLength: 12)

                Button(
                    isRecording
                        ? L10n.tr("shortcut_recorder.cancel_recording", bundle: bundle)
                        : L10n.tr("shortcut_recorder.change", bundle: bundle)
                ) {
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

                Text(
                    isRecording
                        ? L10n.tr("shortcut_recorder.prompt.recording", bundle: bundle)
                        : L10n.trFormat(
                            "shortcut_recorder.prompt.current_format",
                            bundle: bundle,
                            args: [shortcut.displayString]
                        )
                )
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
                Text(L10n.tr("shortcut_recorder.recording.waiting", bundle: bundle))
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
