//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import AzureCommunicationUI
import AzureCommunicationCalling

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

    @State private var isLocalePickerDisplayed: Bool = false

    @ObservedObject var envConfigSubject: EnvConfigSubject

    let avatarChoices: [String] = ["cat", "fox", "koala", "monkey", "mouse", "octopus"]

    var body: some View {
        NavigationView {
            Form {
                localizationSettings
                avatarSettings
                themeSettings
            }.navigationTitle("UI Library - Settings")
        }
    }

    var localizationSettings: some View {
        Section(header: Text("Localilzation")) {
            LocalePicker(selection: $envConfigSubject.languageCode)
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
        Section(header: Text("Persona")) {
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
    @Binding var selection: String
    let supportedLanguage: [String] = ["auto"] + LocalizationConfiguration.supportedLanguages

    var body: some View {
            Picker("Language", selection: $selection) {
                ForEach(supportedLanguage, id: \.self) {
                    if $0 == "auto" {
                        Text("Detect locale (en, zh-Hant, fr, fr-CA)")
                    } else {
                        Text($0)
                    }
                }
            }
    }
}
