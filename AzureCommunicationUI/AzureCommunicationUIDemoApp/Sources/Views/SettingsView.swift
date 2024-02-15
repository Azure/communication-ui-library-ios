//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import AzureCommunicationUICalling
import AzureCommunicationCommon

struct SettingsView: View {
    @State private var setupSelectedOrientation: String = OrientationOptions.portrait.requestString
    @State private var callingSelectedOrientation: String = OrientationOptions.portrait.requestString
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
            settingsForm
            .accessibilityElement(children: .contain)
            .navigationTitle("UI Library - Settings")
            .toolbar {
                dismissButton
            }
        }
        .accessibilityElement(children: .contain)
    }

    var dismissButton: some View {
        Button(
            action: { self.presentationMode.wrappedValue.dismiss() },
            label: { Image(systemName: "xmark") }
        )
        .accessibilityIdentifier(AccessibilityId.settingsCloseButtonAccessibilityID.rawValue)
    }

    var settingsForm: some View {
        Form {
            orientationOptions
            Group {
                localizationSettings
                skipSetupScreenSettings
                micSettings
                localParticipantSettings
                avatarSettings
                useMockCallingSDKHandler
                navigationSettings
                remoteParticipantsAvatarsSettings
                themeSettings
                multitaskingSettings
            }
            exitCompositeSettings
        }
    }

    var orientationOptions: some View {
        Group {
            callingViewOrientationSettings
            setupViewOrientationSettings
        }
    }

    var localParticipantSettings: some View {
        Section(header: Text("Local Participant Settings")) {
            expiredTokenToggle
            audioOnlyModeToggle
        }
        .accessibilityElement(children: .contain)
    }

    var expiredTokenToggle: some View {
        Toggle("Use expired token", isOn: $envConfigSubject.useExpiredToken)
            .accessibilityIdentifier(AccessibilityId.expiredAcsTokenToggleAccessibilityID.rawValue)
    }

    var useMockCallingSDKHandler: some View {
        #if DEBUG
        Section(header: Text("Calling SDK Wrapper Handler Mocking")) {
            mockCallingSDKToggle
        }
        .accessibilityElement(children: .contain)
        #else
        EmptyView()
        #endif
    }

    var mockCallingSDKToggle: some View {
        Toggle("Use mock Calling SDK Wrapper Handler",
               isOn: $envConfigSubject.useMockCallingSDKHandler)
    }

    /* <AVMODE> */
    var audioOnlyModeToggle: some View {
        Toggle("Audio only",
               isOn: $envConfigSubject.audioOnly)
    }
    /* </AVMODE> */

    var relaunchCompositeOnDismissedToggle: some View {
        Toggle("Relaunch composite after dismiss api call",
               isOn: $envConfigSubject.useRelaunchOnDismissedToggle)
        .accessibilityIdentifier(AccessibilityId.useRelaunchOnDismissedToggleToggleAccessibilityID.rawValue)
    }

    var exitCompositeSettings: some View {
        Section(header: Text("Exit API Testing")) {
            relaunchCompositeOnDismissedToggle
            TextField(
                "Exit composite after seconds",
                text: $envConfigSubject.exitCompositeAfterDuration
            )
            .keyboardType(.numberPad)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .textFieldStyle(.roundedBorder)
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

    var callingViewOrientationSettings: some View {
        Section(header: Text("Calling View Orientation")) {
            Picker("Orientation", selection: $callingSelectedOrientation) {
                ForEach([OrientationOptions.portrait.requestString, OrientationOptions.landscape.requestString,
                         OrientationOptions.landscapeLeft.requestString,
                         OrientationOptions.landscapeRight.requestString,
                         OrientationOptions.allButUpsideDown.requestString], id: \.requestString) { orientationOption in
                    Text(orientationOption.requestString.capitalized).tag(orientationOption.requestString)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onAppear {
                callingSelectedOrientation =
                envConfigSubject.callingViewOrientation.requestString
            }
            .onChange(of: callingSelectedOrientation) { newValue in
                switch newValue {
                case OrientationOptions.portrait.requestString:
                    envConfigSubject.callingViewOrientation = .portrait
                case OrientationOptions.landscape.requestString:
                    envConfigSubject.callingViewOrientation = .landscape
                case OrientationOptions.landscapeRight.requestString:
                    envConfigSubject.callingViewOrientation = .landscapeRight
                case OrientationOptions.landscapeLeft.requestString:
                    envConfigSubject.callingViewOrientation = .landscapeLeft
                default:
                    envConfigSubject.callingViewOrientation = .allButUpsideDown
                }
            }
        }
    }

    var setupViewOrientationSettings: some View {
        Section(header: Text("Setup View Orientation")) {
            Picker("Orientation", selection: $setupSelectedOrientation) {
                ForEach([OrientationOptions.allButUpsideDown.requestString,
                         OrientationOptions.portrait.requestString, OrientationOptions.landscape.requestString,
                         OrientationOptions.landscapeLeft.requestString,
                         OrientationOptions.landscapeRight.requestString], id: \.requestString) { orientationOption in
                    Text(orientationOption.requestString.capitalized).tag(orientationOption.requestString)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onAppear {
                setupSelectedOrientation = envConfigSubject.setupViewOrientation.requestString
            }
            .onChange(of: setupSelectedOrientation) { newValue in
                switch newValue {
                case OrientationOptions.portrait.requestString:
                    envConfigSubject.setupViewOrientation = .portrait
                case OrientationOptions.landscape.requestString:
                    envConfigSubject.setupViewOrientation = .landscape
                case OrientationOptions.landscapeLeft.requestString:
                    envConfigSubject.setupViewOrientation = .landscapeLeft
                case OrientationOptions.landscapeRight.requestString:
                    envConfigSubject.setupViewOrientation = .landscapeRight
                case OrientationOptions.allButUpsideDown.requestString:
                    envConfigSubject.setupViewOrientation = .allButUpsideDown
                default:
                    envConfigSubject.setupViewOrientation = .portrait
                }
            }
        }
    }

    var micSettings: some View {
        Section(header: Text("Mic & Carmera Default Vaule")) {
            Toggle("Mic Default", isOn: $envConfigSubject.microphoneOn)

            Toggle("Camera Default", isOn: $envConfigSubject.cameraOn)
        }
    }

    var skipSetupScreenSettings: some View {
        Section(header: Text("Skip Setup Screen Default Value")) {
            Toggle("Skip Setup Screen", isOn: $envConfigSubject.skipSetupScreen)
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

    var multitaskingSettings: some View {
        Section(header: Text("Multitasking")) {
            Toggle("Enable multitasking", isOn: $envConfigSubject.enableMultitasking)
            Toggle("Enable Pip", isOn: $envConfigSubject.enablePipWhenMultitasking)
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
