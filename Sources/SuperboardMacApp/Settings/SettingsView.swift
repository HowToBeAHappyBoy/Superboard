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
                Text(settings.localized("settings.header.title"))
                    .font(.title2.weight(.semibold))
                Text(settings.localized("settings.header.subtitle"))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
    }

    private var generalSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                LanguagePickerRow(
                    title: settings.localized("settings.row.language.title"),
                    subtitle: settings.localized("settings.row.language.subtitle"),
                    selection: $settings.appLanguage,
                    options: [
                        (.system, settings.localized("settings.language.system")),
                        (.korean, settings.localized("settings.language.korean")),
                        (.japanese, settings.localized("settings.language.japanese")),
                        (.english, settings.localized("settings.language.english")),
                    ]
                )

                Divider()

                StepperSettingRow(
                    title: settings.localized("settings.row.picker_display_limit.title"),
                    subtitle: settings.localized("settings.row.picker_display_limit.subtitle"),
                    value: $settings.pickerDisplayLimit,
                    range: 1...50
                )

                Divider()

                StepperSettingRow(
                    title: settings.localized("settings.row.history_store_limit.title"),
                    subtitle: settings.localized("settings.row.history_store_limit.subtitle"),
                    value: $settings.historyStoreLimit,
                    range: 1...500
                )

                Divider()

                ToggleSettingRow(
                    title: settings.localized("settings.row.launch_at_login.title"),
                    subtitle: settings.localized("settings.row.launch_at_login.subtitle"),
                    isOn: $settings.launchAtLogin
                )

                ToggleSettingRow(
                    title: settings.localized("settings.row.virtual_clipboard.title"),
                    subtitle: settings.localized("settings.row.virtual_clipboard.subtitle"),
                    isOn: $settings.useVirtualClipboard
                )
            }
            .padding(.vertical, 2)
        } label: {
            Text(settings.localized("settings.section.general"))
                .font(.headline)
        }
    }

    private var shortcutSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.localized("settings.shortcut.open_picker.title"))
                        .font(.body.weight(.medium))
                    Text(settings.localized("settings.shortcut.open_picker.subtitle"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ShortcutRecorderView(shortcut: $settings.hotKeyShortcut, bundle: settings.localizationBundle)
            }
            .padding(.vertical, 2)
        } label: {
            Text(settings.localized("settings.section.shortcuts"))
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
