import AppKit
import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettingsStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                generalSection
                shortcutSection
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .frame(width: 520, height: 420)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(nsImage: MenuBarIcon.skateboardTemplateImage(pointSize: 30))
                .renderingMode(.template)
                .foregroundStyle(Color.accentColor)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text("Superboard 설정")
                    .font(.title2.weight(.semibold))
                Text("히스토리, 단축키, 시작 동작, 클립보드 동작을 조정합니다.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
    }

    private var generalSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                StepperSettingRow(
                    title: "표시 개수",
                    subtitle: "픽커에 보여줄 최근 항목 수입니다.",
                    value: $settings.pickerDisplayLimit,
                    range: 1...50
                )

                Divider()

                StepperSettingRow(
                    title: "저장 개수",
                    subtitle: "앱이 내부에 보관할 히스토리의 최대 개수입니다.",
                    value: $settings.historyStoreLimit,
                    range: 1...500
                )

                Divider()

                ToggleSettingRow(
                    title: "시작 시 자동실행",
                    subtitle: "로그인할 때 Superboard를 자동으로 실행합니다.",
                    isOn: $settings.launchAtLogin
                )

                ToggleSettingRow(
                    title: "가상 클립보드",
                    subtitle: "선택 후 붙여넣기 뒤 원래 클립보드를 복원합니다.",
                    isOn: $settings.useVirtualClipboard
                )
            }
            .padding(.vertical, 2)
        } label: {
            Text("기본")
                .font(.headline)
        }
    }

    private var shortcutSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("픽커 열기")
                        .font(.body.weight(.medium))
                    Text("현재 단축키를 누르면 최근 항목 픽커가 열립니다.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ShortcutRecorderView(shortcut: $settings.hotKeyShortcut)
            }
            .padding(.vertical, 2)
        } label: {
            Text("단축키")
                .font(.headline)
        }
    }
}

private struct StepperSettingRow: View {
    let title: String
    let subtitle: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.medium))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 16)

                HStack(spacing: 10) {
                    Text("\(value)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 30, alignment: .trailing)

                    Stepper("", value: $value, in: range)
                        .labelsHidden()
                        .controlSize(.small)
                }
            }
        }
    }
}

private struct ToggleSettingRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 16)
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
