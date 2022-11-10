//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import AzureCommunicationUICalling
import AzureCommunicationCommon

struct SettingsView: View {
    private enum ThemeMode: String, CaseIterable, Identifiable {
        case osApp = "OS / App"
        case light = "Light Mode"
        case dark = "Dark Mode"

        var id: UIUserInterfaceStyle {
            switch self {
            case .osApp:
                return .unspecified
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }
    }

    @ObservedObject var envConfigSubject: EnvConfigSubject
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let avatarChoices: [String] = ["cat", "fox", "koala", "monkey", "mouse", "octopus"]

    var body: some View {
        NavigationView {
            Form {
                localizationSettings
                localParticipantSettings
                avatarSettings
                navigationSettings
                remoteParticipantsAvatarsSettings
                themeSettings
            }
            .navigationTitle("UI Library - Settings")
            .toolbar {
                Button(
                    action: { self.presentationMode.wrappedValue.dismiss() },
                    label: { Image(systemName: "xmark") }
                )
            }
        }
    }

    var localParticipantSettings: some View {
        Section(header: Text("Local Participant Settings")) {
            Toggle("Use expired token", isOn: $envConfigSubject.useExpiredToken)
                .accessibilityIdentifier(AccessibilityId.expiredAcsTokenToggleAccessibilityID.rawValue)
        }
    }

    var localizationSettings: some View {
        Section(header: Text("Localilzation")) {
            LocalePicker(selection: $envConfigSubject.locale)
            Toggle("Is Right-to-Left", isOn: $envConfigSubject.isRightToLeft)
            TextField(
                "Locale identifier (eg. zh-Hant, fr-CA)",
                text: $envConfigSubject.localeIdentifier
            )
            .keyboardType(.default)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .textFieldStyle(.roundedBorder)
        }
    }

    var avatarSettings: some View {
        Section(header: Text("Local Participant View Data")) {
            Picker("Avatar Choices", selection: $envConfigSubject.avatarImageName) {
                ForEach(avatarChoices, id: \.self) { avatar in
                    Image(avatar)
                }
            }.pickerStyle(.segmented)
            TextField("Rendered Display Name", text: $envConfigSubject.renderedDisplayName)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
        }
    }

    var navigationSettings: some View {
        Section(header: Text("Setup View Data")) {
            TextField("Navigation Title", text: $envConfigSubject.navigationTitle)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
            TextField("Navigation SubTitle", text: $envConfigSubject.navigationSubtitle)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
        }
    }

    var remoteParticipantsAvatarsSettings: some View {
        Section(header: Text("Remote Participants View Data")) {
            Toggle("Inject avatars", isOn: $envConfigSubject.useCustomRemoteParticipantViewData)
        }
    }

    var themeSettings: some View {
        Section(header: Text("Theme")) {
            Toggle("Use Custom Theme Colors", isOn: $envConfigSubject.useCustomColors)
            ColorPicker("Primary Color", selection: $envConfigSubject.primaryColor)
            ColorPicker("Tint 10 Color", selection: $envConfigSubject.tint10)
            ColorPicker("Tint 20 Color", selection: $envConfigSubject.tint20)
            ColorPicker("Tint 30 Color", selection: $envConfigSubject.tint30)
            Picker("Force Theme Mode", selection: $envConfigSubject.colorSchemeOverride) {
                ForEach(ThemeMode.allCases) { themeMode in
                    Text(themeMode.rawValue)
                }
            }.pickerStyle(.segmented)
        }
    }
}

struct LocalePicker: View {
    @Binding var selection: Locale
    let supportedLanguage: [Locale] = [Locale(identifier: "")] + SupportedLocale.values

    var body: some View {
            Picker("Language", selection: $selection) {
                ForEach(supportedLanguage, id: \.self) {
                    if $0.identifier == "" {
                        Text("Detect locale (en, zh-Hant, fr, fr-CA)")
                    } else {
                        Text($0.identifier)
                    }
                }
            }
    }
}
