import SwiftUI

struct OnboardingView: View {
    @ObservedObject var settings: AppSettingsStore
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            content
            footer
        }
        .padding(24)
        .frame(width: 560, height: 440, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(settings.localized("onboarding.title"))
                .font(.title2.weight(.semibold))
            Text(settings.localized("onboarding.subtitle"))
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
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
                }
                .padding(.vertical, 2)
            } label: {
                Text(settings.localized("onboarding.section.language"))
                    .font(.headline)
            }

            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    ShortcutRecorderView(shortcut: $settings.hotKeyShortcut, bundle: settings.localizationBundle)
                }
                .padding(.vertical, 2)
            } label: {
                Text(settings.localized("onboarding.section.shortcut"))
                    .font(.headline)
            }
        }
    }

    private var footer: some View {
        HStack(alignment: .center) {
            Toggle(settings.localized("onboarding.dont_show_again"), isOn: $settings.hideOnboarding)
                .toggleStyle(.checkbox)

            Spacer(minLength: 12)

            Button(settings.localized("onboarding.done")) {
                onDone()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
        }
        .padding(.top, 4)
    }
}

